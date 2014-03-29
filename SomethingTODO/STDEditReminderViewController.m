//
//  STDEditReminderViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDEditReminderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "STDAppDelegate.h"
#import "STDReminderUtils.h"

@interface STDEditReminderViewController ()

@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField        *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel            *priorityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySergmentedControl;
@property (weak, nonatomic) IBOutlet UIButton           *saveChangesButton;

@end

@implementation STDEditReminderViewController

#pragma mark - View Life's Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    titleLabel.text @"";
//    titleTextField;
//    descriptionLabel;
//    descriptionTextField;
//    priorityLabel;
//    prioritySergmentedControl;
//    saveChangesButton;
    
    // Update the view.
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

#pragma mark - Helpers

- (void)applyStyle
{
    UIColor *defaultBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    self.titleLabel.textColor = defaultBlue;
    self.titleTextField.textColor = defaultBlue;
    self.descriptionLabel.textColor = defaultBlue;
    self.descriptionTextField.textColor = defaultBlue;
    self.priorityLabel.textColor = defaultBlue;
    
    self.titleTextField.layer.cornerRadius = 5;
    self.titleTextField.clipsToBounds = YES;
    [self.titleTextField.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.titleTextField.layer setBorderColor: [defaultBlue CGColor]];
    [self.titleTextField.layer setBorderWidth: 1.0];
    [self.titleTextField.layer setCornerRadius:8.0f];
    [self.titleTextField.layer setMasksToBounds:YES];
    
    self.descriptionTextField.layer.cornerRadius = 5;
    self.descriptionTextField.clipsToBounds = YES;
    [self.descriptionTextField.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.descriptionTextField.layer setBorderColor: [defaultBlue CGColor]];
    [self.descriptionTextField.layer setBorderWidth: 1.0];
    [self.descriptionTextField.layer setCornerRadius:8.0f];
    [self.descriptionTextField.layer setMasksToBounds:YES];
}
- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.currentReminder)
    {
        EKReminder *reminder = self.currentReminder;
        
        if (reminder)
        {
            self.titleTextField.text = reminder.title;
            self.descriptionTextField.text = reminder.notes;
            [self.prioritySergmentedControl setSelectedSegmentIndex:reminder.priority];
        }
        else
        {
            
        }
    }
}

#pragma mark - Helper

- (IBAction)saveChanges:(id)sender
{
    BOOL isNewReminder = NO;
    
    if (!self.currentReminder)
    {
        self.currentReminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
        [self.currentReminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];
        
        isNewReminder = YES;
    }
    
    [self.currentReminder setTitle:self.titleTextField.text];
    [self.currentReminder setNotes:self.descriptionTextField.text];
    [self.currentReminder setPriority:self.prioritySergmentedControl.selectedSegmentIndex];
    
    if ([STDReminderUtils saveReminderToStore:self.currentReminder])
    {
        if (isNewReminder)
        {
            if ([self.delegate respondsToSelector:@selector(editReminderViewController:didSaveNewReminder:)])
            {
                [self.delegate editReminderViewController:self didSaveNewReminder:self.currentReminder];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(editReminderViewController:didModifiedNeminder:)])
            {
                [self.delegate editReminderViewController:self didModifiedNeminder:self.currentReminder];
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
