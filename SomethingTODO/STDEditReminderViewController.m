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

#import "UITextField+ExtraPadding.h"
#import "UIView+Border.h"

#import <QuartzCore/QuartzCore.h>

@interface STDEditReminderViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField        *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel            *priorityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySergmentedControl;
@property (weak, nonatomic) IBOutlet UIButton           *saveChangesButton;

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

#pragma mark - UITextFieldDelegate

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

#pragma mark - Helper

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
}

// Set the style for the labels and text fields
- (void)applyStyle
{
	// Colors
    UIColor *defaultBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.titleLabel.textColor = defaultBlue;
    self.titleTextField.textColor = defaultBlue;
    self.descriptionLabel.textColor = defaultBlue;
    self.descriptionTextView.textColor = defaultBlue;
    self.priorityLabel.textColor = defaultBlue;
    
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
        EKReminder *reminder = self.currentReminder;
        
		// only when the reminder is valid we fetch its data
        if (reminder)
        {
            self.titleTextField.text = reminder.title;
            self.descriptionTextView.text = reminder.notes;
            [self.prioritySergmentedControl setSelectedSegmentIndex:reminder.priority];
        }
    }
}

// Save a new rmeinder or update it.
- (void)saveReminderInformation
{
	BOOL isNewReminder = NO;
    
    if (!self.currentReminder)
    {
        self.currentReminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
        [self.currentReminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];
        
        isNewReminder = YES;
    }
    
	// new information
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	[self.currentReminder setStartDateComponents:[cal components:unitFlags fromDate:[NSDate date]]];
    [self.currentReminder setTitle:self.titleTextField.text];
    [self.currentReminder setNotes:self.descriptionTextView.text];
    [self.currentReminder setPriority:self.prioritySergmentedControl.selectedSegmentIndex];
    
	// we try to save the reminder
    if ([STDReminderUtils saveReminderToStore:self.currentReminder])
    {
		// saved and new
        if (isNewReminder)
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

@end
