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
static NSString *kKeyStorePoints				= @"MyPoints";
static NSString *kKeyStoreListTitle				= @"MyListTitle";
static NSInteger kShareAlertView					= 100;

// Segues
static NSString *kSegueGoToEditReminder			= @"editReminder";
static NSString *kSegueGoToSettings				= @"settings";

@interface STDTableViewController () <UITableViewDelegate , STDEditReminderViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *reminderList;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *pointsButton;
@property (nonatomic, strong) NSNumber *points;
@property (nonatomic, strong) NSUbiquitousKeyValueStore *keyStore;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecon;

@end

@implementation STDTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self addToolbar];
	[self addLeftButton];
    [self requestAccess];
	
	// KeyStore
	self.keyStore = [[NSUbiquitousKeyValueStore alloc] init];
	self.points = [self.keyStore objectForKey:kKeyStorePoints];
	
	if (self.points != nil)
	{
		[self.pointsButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"listvc_points", nil), self.points] forState:UIControlStateNormal];
	}
	else
	{
		self.points = 0;
	}
	
	
	// Navigation Bar
	NSString *newTitle = [self.keyStore objectForKey:kKeyStoreListTitle];
	self.title = newTitle == nil ? NSLocalizedString(@"listvc_title_vc", nil) : newTitle;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector: @selector(ubiquitousKeyValueStoreDidChange:)
												 name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
											   object:self.keyStore];

	// Navigation bar clickable
	self.tapRecon = [[UITapGestureRecognizer alloc]
										initWithTarget:self action:@selector(changeTitle:)];
    self.tapRecon.numberOfTapsRequired = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
	
	[self.navigationController.navigationBar addGestureRecognizer:self.tapRecon];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	[self.navigationController.navigationBar removeGestureRecognizer:self.tapRecon];

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
			cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
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
	else
	{
		[self addNewReminder:nil];
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
			
			self.points = [NSNumber numberWithInt:[self.points intValue] + 1];
			[self savePoints];
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
	cell.dateLabel.text = [STDReminderUtils getTimestampWithDateComponents:reminder.startDateComponents];
	
	cell.dateLabel.textColor = labelColor;
	
	EKAlarm *alarm = [reminder.alarms lastObject];
	
	if (alarm)
	{
		[cell.calendarImageView setHidden:alarm.absoluteDate ? NO : YES];
		[cell.locationImageView setHidden:alarm.structuredLocation ? NO : YES];
	}
	else
	{
		[cell.calendarImageView setHidden:YES];
		[cell.locationImageView setHidden:YES];
	}
	
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
}

- (void)editReminderViewController:(STDEditReminderViewController *)editReminderViewController didModifiedNeminder:(EKReminder *)reminder
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UIActions

- (void)addNewReminder:(UIButton *)control
{
    [self performSegueWithIdentifier:kSegueGoToEditReminder sender:nil];
}

- (void)goToSettings:(UIButton *)control
{
	[self performSegueWithIdentifier:kSegueGoToSettings sender:nil];
}

- (void)showPointsHelp:(UIButton *)control
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat: NSLocalizedString(@"points_help", nil), self.points] delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
	[alertView show];
}

- (void)changeTitle:(UIGestureRecognizer *)recognizer
{
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"listvc_new_title_alertview", nil)
							  message:NSLocalizedString(@"listvc_new_title_message", nil)
							  delegate:self
							  cancelButtonTitle:NSLocalizedString(@"common_cancel", nil)
							  otherButtonTitles:NSLocalizedString(@"common_ok", nil), nil];
																  
	[alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
	alertView.tag = kShareAlertView;
	
	/* Display a numerical keypad for this text field */
	UITextField *textField = [alertView textFieldAtIndex:0];
	textField.text = self.navigationItem.title;
	
	[alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kShareAlertView)
	{
		if (buttonIndex == 1)
		{
			self.title = [alertView textFieldAtIndex:0].text;
			[self saveListTitle];
		}
	}
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueGoToEditReminder])
    {
        STDEditReminderViewController *vc = (STDEditReminderViewController *)[segue destinationViewController];
        vc.delegate = self;
        [vc setCurrentReminder:sender];
    }
	else if ([[segue identifier] isEqualToString:kSegueGoToSettings])
	{
		// Nothing to do right now
	}
}

#pragma mark - Notifications

- (void)ubiquitousKeyValueStoreDidChange: (NSNotification *)notification
{
	self.points = [self.keyStore objectForKey:kKeyStorePoints];
	[self.pointsButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"listvc_points", nil), [self.keyStore stringForKey:kKeyStorePoints]] forState:UIControlStateNormal];
	
	NSString *newTitle = [self.keyStore objectForKey:kKeyStorePoints];
	self.title = newTitle == nil ? NSLocalizedString(@"listvc_title_vc", nil) : newTitle;
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

- (void)addLeftButton
{
	// Left button for about
	UIButton *btnLogo = [[UIButton alloc] init];
	btnLogo.frame = CGRectMake(0,0,25,25);
	[btnLogo setBackgroundImage:[UIImage imageNamed: @"Logo"] forState:UIControlStateNormal];
	[btnLogo addTarget:self action:@selector(goToSettings:) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnLogo];
}

- (void)addRigthButton
{
	// Right button for adding new reminders
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewReminder:)];
	
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)addToolbar
{
	UIColor *defaultBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
	
	self.pointsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 140, 0, 140, 44)];
	[self.pointsButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"listvc_points", nil), self.points] forState:UIControlStateNormal];
	self.pointsButton.backgroundColor = [UIColor clearColor];
	[self.pointsButton setTitleColor:defaultBlue forState:UIControlStateNormal];
	[self.pointsButton addTarget:self action:@selector(showPointsHelp:) forControlEvents:UIControlEventTouchUpInside];
	self.pointsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.pointsButton];
	[self.navigationController.toolbar setItems:[NSArray arrayWithObject:item] animated:NO];
	
	self.toolbarItems = [NSArray arrayWithObjects:item, nil];
}

- (void)savePoints
{
    [self.keyStore setObject:self.points forKey:kKeyStorePoints];
    [self.keyStore synchronize];
	[self.pointsButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"listvc_points", nil), self.points] forState:UIControlStateNormal];
}

- (void)saveListTitle
{
	[self.keyStore setString:self.title forKey:kKeyStoreListTitle];
	[self.keyStore synchronize];
}

- (void)fetchData
{
    NSPredicate *predicate = [[[STDAppDelegate shareInstance] eventStore] predicateForRemindersInCalendars:nil];
    
    [[[STDAppDelegate shareInstance] eventStore] fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.reminderList = [[[reminders reverseObjectEnumerator] allObjects] mutableCopy];
			[self.tableView reloadData];
		});
    }];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender
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
