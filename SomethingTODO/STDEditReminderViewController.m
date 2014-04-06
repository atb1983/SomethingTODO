//
//  STDEditReminderViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDEditReminderViewController.h"
#import "STDAppDelegate.h"
#import "STDReminderUtils.h"
#import "STDMapViewController.h"
#import "STDReminderUtils.h"

#import "UITextField+ExtraPadding.h"
#import "UIView+Border.h"
#import <MGConferenceDatePicker.h>
#import <MGConferenceDatePickerDelegate.h>

#import <QuartzCore/QuartzCore.h>

static NSString *kSegueGoToReminderMap	= @"ReminderMapSegue";

@interface STDEditReminderViewController () <UITextFieldDelegate, UITextViewDelegate, MGConferenceDatePickerDelegate, STDMapViewControllerDelegate>

@property (strong, nonatomic) UIViewController *pickerViewController;

@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField        *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel            *priorityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySergmentedControl;
@property (weak, nonatomic) IBOutlet UIButton           *saveChangesButton;
@property (weak, nonatomic) IBOutlet UILabel			*alarmLabel;

@property (strong, nonatomic) EKStructuredLocation		*structuredLocation;
@property (strong, nonatomic) NSDate					*alarmDate;
@property (assign, nonatomic) BOOL						isNewReminder;

@end

@implementation STDEditReminderViewController

#pragma mark - View Life's Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Update the view.
	[self applyLocalization];
    [self applyStyle];
    [self configureView];
}

- (void)setCurrentReminder:(id)currentReminder
{
    if (_currentReminder != currentReminder)
    {
        _currentReminder = currentReminder;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField)
	{
        [self.descriptionTextView becomeFirstResponder];
	}
	
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange) range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
	{
        [textView resignFirstResponder];
		[self saveReminderInformation];
		
        return NO;
    }
    return YES;
}

#pragma mark - MGConferenceDatePickerDelegate

- (void)conferenceDatePicker:(MGConferenceDatePicker *)datePicker saveDate:(NSDate *)date
{
	[self.pickerViewController dismissViewControllerAnimated:YES completion:^{
		self.alarmDate = date;
		self.alarmLabel.text = [self alarmTextWithDate:date];
	}];
}

#pragma mark - STDMapViewControllerDelegate

- (void)mapViewController:(STDMapViewController *)mapViewController positionUpdated:(EKStructuredLocation *)location;
{
	self.structuredLocation = location;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueGoToReminderMap])
    {
        STDMapViewController *vc = (STDMapViewController *)[segue destinationViewController];
		[vc setDelegate:self];
		[vc setReminderTitle:self.currentReminder.title];
		[vc setReminderDescription:self.currentReminder.notes];
        [vc setStructuredLocation:self.structuredLocation];
    }
}

#pragma mark - IBActions

- (IBAction)saveChanges:(id)sender
{
	if ([self.titleTextField.text isEqualToString:@""])
	{
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"edit_title_textfield_empty", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
		[alert show];
		
		[self.titleTextField becomeFirstResponder];
	}
	else
	{
		[self.titleTextField resignFirstResponder];
		[self.descriptionTextView resignFirstResponder];
		
		[self saveReminderInformation];
	}
}

#pragma mark - Actions

- (IBAction)changeDate:(id)sender
{
	//New view controller
	self.pickerViewController = [[UIViewController alloc] init];
	
    //Init the datePicker view and set self as delegate
    MGConferenceDatePicker *datePicker = [[MGConferenceDatePicker alloc] initWithFrame:self.view.bounds];
    [datePicker setDelegate:self];
	
    //OPTIONAL: Choose the background color
    [datePicker setBackgroundColor:[UIColor whiteColor]];
	
    //Set the data picker as view of the new view controller
    [self.pickerViewController setView:datePicker];
	
    //Present the view controller
    [self presentViewController:self.pickerViewController animated:YES completion:nil];
}


#pragma mark - Helpers

// Set the name of the view controoler, labels and place holders.
- (void)applyLocalization
{
	// Localization
    self.title =								NSLocalizedString(@"edit_title_vc", nil);
    self.titleLabel.text =						NSLocalizedString(@"edit_title_label", nil);
    self.titleTextField.placeholder =			NSLocalizedString(@"edit_title_textfield_placeholder", nil);
    self.descriptionLabel.text =				NSLocalizedString(@"edit_description_label", nil);
    self.priorityLabel.text =					NSLocalizedString(@"edit_priority_label", nil);
    [self.prioritySergmentedControl setTitle:	NSLocalizedString(@"edit_priority_segment_normal", nil) forSegmentAtIndex:0];
	[self.prioritySergmentedControl setTitle:	NSLocalizedString(@"edit_priority_segment_high", nil) forSegmentAtIndex:1];
    [self.saveChangesButton setTitle:			NSLocalizedString(@"edit_save", nil) forState:UIControlStateNormal];
	self.alarmLabel.text =						NSLocalizedString(@"edit_alarm_no_set", nil);
}

// Set the style for the labels and text fields
- (void)applyStyle
{
	// Colors
    UIColor *defaultBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.titleTextField.textColor = defaultBlue;
    self.descriptionTextView.textColor = defaultBlue;
    
    // Padding
    [self.titleTextField setLeftPadding:4.0f];
    [self.titleTextField setRightPadding:4.0f];
    
	// Borders
	[self.titleTextField applyBorderWithColor:defaultBlue];
    [self.descriptionTextView applyBorderWithColor:defaultBlue];
    [self.saveChangesButton applyBorderWithColor:defaultBlue];
}

- (void)configureView
{
    // Update the user interface for the reminder item.
    if (self.currentReminder)
    {
		self.isNewReminder = NO;
		
		self.titleTextField.text = self.currentReminder.title;
		self.descriptionTextView.text = self.currentReminder.notes;
		[self.prioritySergmentedControl setSelectedSegmentIndex:self.currentReminder.priority];
		
		EKAlarm *alarm = [self.currentReminder.alarms lastObject];
		
		if (alarm)
		{
			self.structuredLocation = [alarm structuredLocation];
			self.alarmDate = [alarm absoluteDate];
			
			if (self.alarmDate)
			{
				self.alarmLabel.text = [self alarmTextWithDate:alarm.absoluteDate];
			}
			else
			{
				self.alarmLabel.text = NSLocalizedString(@"edit_alarm_no_set", nil);
			}
		}
    }
	else
	{
		self.isNewReminder = YES;
		
		self.currentReminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
		[self.currentReminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];
	}
}

// Save a new rmeinder or update it.
- (void)saveReminderInformation
{
	// new information
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	[self.currentReminder setStartDateComponents:[cal components:unitFlags fromDate:[NSDate date]]];
    [self.currentReminder setTitle:self.titleTextField.text];
    [self.currentReminder setNotes:self.descriptionTextView.text];
    [self.currentReminder setPriority:self.prioritySergmentedControl.selectedSegmentIndex];
	
	// Alarm
	EKAlarm *alarm;
	
	if (self.currentReminder.alarms > 0)
	{
		alarm = [self.currentReminder.alarms lastObject];
	}
	else
	{
		alarm = [[EKAlarm alloc] init];
		self.currentReminder.alarms = @[alarm];
	}
	
	if (self.alarmDate)
	{
		[alarm setAbsoluteDate:self.alarmDate];
	}
	
	if (self.structuredLocation)
	{
		[alarm setStructuredLocation:self.structuredLocation];
	}
	
	// we try to save the reminder
    if ([STDReminderUtils saveReminderToStore:self.currentReminder])
    {
		// saved and new
        if (self.isNewReminder)
        {
			// we trigger the delegate
            if ([self.delegate respondsToSelector:@selector(editReminderViewController:didSaveNewReminder:)])
            {
                [self.delegate editReminderViewController:self didSaveNewReminder:self.currentReminder];
            }
        }
        else
        {
			// we trigger the delegate
            if ([self.delegate respondsToSelector:@selector(editReminderViewController:didModifiedNeminder:)])
            {
                [self.delegate editReminderViewController:self didModifiedNeminder:self.currentReminder];
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)alarmTextWithDate:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
	
	return [dateFormatter stringFromDate:date];
}

@end
