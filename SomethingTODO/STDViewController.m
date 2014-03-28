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

@interface STDViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSArray *eventList;

@end

@implementation STDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL needsToRequestAccessToEventStore = NO;
    EKAuthorizationStatus authorizationStatus = EKAuthorizationStatusAuthorized;
    if ([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);
    }
    
    if (needsToRequestAccessToEventStore) {
        [[STDAppDelegate shareInstance].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // We can use the event store now
                    [self fetchData];
                });
            }
        }];
    } else if (authorizationStatus == EKAuthorizationStatusAuthorized)
    {
        [self fetchData];
    } else
    {
        // Access denied
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STDTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEvent"]) {
//        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Helpers

- (void)fetchData
{
    // We ask for permission
    
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Create the start date components
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;

    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [[STDAppDelegate shareInstance].eventStore predicateForEventsWithStartDate:oneDayAgo
                                                                                                endDate:oneYearFromNow
                                                                                              calendars:nil];
    
    self.eventList = [[STDAppDelegate shareInstance].eventStore eventsMatchingPredicate:predicate];
    
    [self.tableView reloadData];
}

- (void)configureCell:(STDTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EKEvent *event = [self.eventList objectAtIndex:indexPath.row];
    
    cell.labelTitle.text = event.title;
    cell.labelDescription.text = event.description;
//    cell.labelDate.text = event.lastModifiedDate;
}

@end
