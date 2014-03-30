//
//  STDViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDTableViewController.h"
#import "STDAppDelegate.h"
#import "STDTableViewCell.h"
#import "STDEditReminderViewController.h"
#import "STDReminderUtils.h"

static NSString *kTableViewCellIdentifier		= @"STDTableViewCell";
static NSString *kPlaceHolderCellIdentifier		= @"Cell";
static NSString *kSegueGoToEditReminder			= @"editReminder";

@interface STDTableViewController () <UITableViewDelegate , STDEditReminderViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *reminderList;

@end

@implementation STDTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"listvc_title_vc", nil);
	
    [self requestAccess];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.reminderList.count > 0)
	{
		return self.reminderList.count;
	}
	
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	if (self.reminderList.count == 0)
	{
		// No reminders
		cell = [tableView dequeueReusableCellWithIdentifier:kPlaceHolderCellIdentifier];
		
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlaceHolderCellIdentifier];
		}
		
		cell.textLabel.text = NSLocalizedString(@"listvc_no_reminders", nil);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier forIndexPath:indexPath];
		[self configureCell:(STDTableViewCell *)cell atIndexPath:indexPath];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.reminderList.count > 0)
	{
		[self performSegueWithIdentifier:kSegueGoToEditReminder sender:[self.reminderList objectAtIndex:indexPath.row]];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.reminderList.count > 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([STDReminderUtils removeReminder:[self.reminderList objectAtIndex:indexPath.row]])
        {
			[self.reminderList removeObjectAtIndex:indexPath.row];
			
			[self.tableView beginUpdates];
			
			// if it's not the last row we just delete the row
			if ([tableView numberOfRowsInSection:[indexPath section]] > 1)
			{
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
			}
			
			[self.tableView endUpdates];
			
			[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

- (void)configureCell:(STDTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EKReminder *reminder = [self.reminderList objectAtIndex:indexPath.row];
    
	cell.tag = indexPath.row;
	
    UIColor *highPriorityColor = [UIColor colorWithRed:232.0f/255.0f green:39.0f/255.0f blue:61.0/255.0f alpha:1.0];
    cell.backgroundColor = reminder.priority > 0 ? highPriorityColor : [UIColor whiteColor];
	
	UIColor *labelColor = reminder.priority > 0 ? [UIColor whiteColor] : [UIColor blackColor];
	
    cell.titleLabel.text = reminder.title;
    cell.titleLabel.textColor = labelColor;
    
	cell.dateLabel.textColor = labelColor;
	cell.dateLabel.text = [STDReminderUtils getTimestampForDate:reminder.startDateComponents];
	
	cell.descriptionLabel.text = reminder.notes;
	cell.dateLabel.textColor = labelColor;
	
    // Gestures
    UISwipeGestureRecognizer *leftToRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [leftToRightRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft+UISwipeGestureRecognizerDirectionRight];
    [cell addGestureRecognizer:leftToRightRecognizer];
    
    // When the reminder is completed we draw an stroke in the middle of the cell
    cell.taskCompleted = reminder.isCompleted;
}

#pragma mark - STDEditReminderViewControllerDelegate

- (void)editReminderViewController:(STDEditReminderViewController *)editReminderViewController didSaveNewReminder:(EKReminder *)reminder
{
	[self.reminderList insertObject:reminder atIndex:0];
	
	[self.tableView beginUpdates];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
	// if it's not the last row we just inser the row the place holder cell
	if (self.reminderList.count > 1)
	{
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
	}
	
	[self.tableView endUpdates];
    
	[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"listvc_new_reminder_added", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
    [alert show];
}

- (void)editReminderViewController:(STDEditReminderViewController *)editReminderViewController didModifiedNeminder:(EKReminder *)reminder
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"listvc_reminder_updated", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Segue

- (void)addNewReminder:(UIEvent *)event
{
    [self performSegueWithIdentifier:kSegueGoToEditReminder sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueGoToEditReminder])
    {
        STDEditReminderViewController *vc = (STDEditReminderViewController *)[segue destinationViewController];
        vc.delegate = self;
        [vc setCurrentReminder:sender];
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
					[self addRigthButton];
                    [self fetchData];
                });
            }
        }];
    }
    else if (authorizationStatus == EKAuthorizationStatusAuthorized)
    {
		[self addRigthButton];
        [self fetchData];
    }
    else
    {
        // Access denied
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"listvc_no_access", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)addRigthButton
{
	// Right button for adding new reminders
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewReminder:)];
	
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)fetchData
{
    NSPredicate *predicate = [[[STDAppDelegate shareInstance] eventStore] predicateForRemindersInCalendars:nil];
    
    [[[STDAppDelegate shareInstance] eventStore] fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        self.reminderList = [[[reminders reverseObjectEnumerator] allObjects] mutableCopy];
		[self.tableView reloadData];
    }];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    STDTableViewCell *cell = (STDTableViewCell *)sender.view;
    EKReminder *reminder = [self.reminderList objectAtIndex:cell.tag];
    reminder.completed = !reminder.isCompleted;
    
    // We update the reminder
    if ([STDReminderUtils saveReminderToStore:reminder])
    {
        [self.tableView beginUpdates];
        NSArray *reloadIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:cell.tag inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

@end
