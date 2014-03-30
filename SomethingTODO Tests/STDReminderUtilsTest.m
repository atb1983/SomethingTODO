//
//  STDReminderUtilsTest.m
//  SomethingTODO
//
//  Created by Alex Núñez on 30/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "STDAppDelegate.h"
#import "STDReminderUtils.h"

@interface STDReminderUtilsTest : XCTestCase

@property (nonatomic, strong) EKReminder *reminder;

@end

@implementation STDReminderUtilsTest

- (void)testSaveNewReminder
{
	self.reminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
	[self.reminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	[self.reminder setStartDateComponents:[cal components:unitFlags fromDate:[NSDate date]]];
    [self.reminder setTitle:@"Test Reminder Title"];
    [self.reminder setNotes:@"Test Description"];
    [self.reminder setPriority:0];
	
	XCTAssertTrue([STDReminderUtils saveReminderToStore:self.reminder]);
}

- (void)testRemoveReminder
{
    [self.reminder setTitle:@"Test Reminder Title Updated!"];
	XCTAssertTrue([STDReminderUtils saveReminderToStore:self.reminder]);
}

- (void)testUpdateReminder
{
	XCTAssertTrue([STDReminderUtils removeReminder:self.reminder]);
}

@end
