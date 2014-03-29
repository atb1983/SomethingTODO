//
//  STDEditReminderViewController.h
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDEditReminderViewController;

@protocol STDEditReminderViewControllerDelegate <NSObject>

@required

- (void)editReminderViewController:(STDEditReminderViewController *)editReminderViewController didSaveNewReminder:(EKReminder *)reminder;
- (void)editReminderViewController:(STDEditReminderViewController *)editReminderViewController didModifiedNeminder:(EKReminder *)reminder;

@end


@interface STDEditReminderViewController : UIViewController

@property (weak) id <STDEditReminderViewControllerDelegate> delegate;

@property (strong, nonatomic) EKReminder *currentReminder;

@end
