//
//  STDViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDViewController.h"
#import "STDAppDelegate.h"
#import "STDTableViewCell.h"
#import "STDTableViewCellOverlay.h"

@interface STDViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *reminderList;

@end

@implementation STDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestAccess];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reminderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STDTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([self removeReminder:[self.reminderList objectAtIndex:indexPath.row]])
        {
            [self.reminderList removeObjectAtIndex:indexPath.row];

            [self.tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

- (void)configureCell:(STDTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EKReminder *reminder = [self.reminderList objectAtIndex:indexPath.row];
    
    cell.labelTitle.text = reminder.title;
    cell.labelDescription.text = reminder.notes;
    //    cell.labelDate.text = event.lastModifiedDate;
    
    cell.tag = indexPath.row;
    
    // Gestures
    UISwipeGestureRecognizer *leftToRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [leftToRightRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft+UISwipeGestureRecognizerDirectionRight];
    [cell addGestureRecognizer:leftToRightRecognizer];
    
    // Cell Style
    static float alpha = 0.5f;
    [cell.labelDate         setAlpha:reminder.isCompleted ? 1.0f : alpha];
    [cell.labelDescription  setAlpha:reminder.isCompleted ? 1.0f : alpha];
    [cell.labelTitle        setAlpha:reminder.isCompleted ? 1.0f : alpha];
    
    // When the reminder is completed we draw an stroke in the middle of the cell
    cell.taskCompleted = reminder.isCompleted;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEvent"])
    {
        //        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Helpers

- (void)requestAccess
{
    BOOL needsToRequestAccessToEventStore = NO;
    EKAuthorizationStatus authorizationStatus = EKAuthorizationStatusAuthorized;
    if ([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)])
    {
        authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
        needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);
    }
    
    if (needsToRequestAccessToEventStore)
    {
        [[STDAppDelegate shareInstance].eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // We can use the event store now
                    [self fetchData];
                });
            }
        }];
    }
    else if (authorizationStatus == EKAuthorizationStatusAuthorized)
    {
        [self fetchData];
    }
    else
    {
        // Access denied
    }
}

- (void)fetchData
{
    NSPredicate *predicate = [[[STDAppDelegate shareInstance] eventStore] predicateForRemindersInCalendars:nil];
    
    [[[STDAppDelegate shareInstance] eventStore] fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        self.reminderList = [reminders mutableCopy];
        [self.tableView reloadData];
    }];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    STDTableViewCell *cell = (STDTableViewCell *)sender.view;
    EKReminder *reminder = [self.reminderList objectAtIndex:cell.tag];
    reminder.completed = !reminder.isCompleted;
    
    // We update the reminder
    if ([self saveReminderToStore:reminder])
    {
        [self.tableView beginUpdates];
        NSArray *reloadIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:cell.tag inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (BOOL)addReminderToStoreWithTitle:(NSString *)title notes:(NSString *)notes
{
    BOOL result;
    
    if(title == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Enter Data" message:@"Please enter data into fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        EKReminder *reminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
        [reminder setTitle:title];
        [reminder setNotes:notes];
        [reminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];

        // We store the new reminder
        if ([self saveReminderToStore:reminder])
        {
            [self.reminderList addObject:reminder];

            [self.tableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            result = YES;
        }
    }
    
    return result;
}

- (BOOL)saveReminderToStore:(EKReminder *)reminder
{
    BOOL result;
    
    NSError *error = nil;
    
    [[STDAppDelegate shareInstance].eventStore saveReminder:reminder commit:YES error:&error];
    
    if (error)
    {
        // TODO
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"We are not able to save your reminder, try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        result = YES;
    }
    
    return result;
}

- (BOOL)removeReminder:(EKReminder *)reminder
{
    BOOL result;

    NSError *error = nil;
    
    [[STDAppDelegate shareInstance].eventStore removeReminder:reminder commit:YES error:&error];
    
    if (error)
    {
        // TODO
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"We are not able to remove your reminder, try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        result = YES;
    }
    
    return result;
}

@end
