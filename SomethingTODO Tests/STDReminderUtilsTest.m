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

@end

@implementation STDReminderUtilsTest

- (EKReminder *)createDummyReminder
{
	EKReminder *reminder = [EKReminder reminderWithEventStore:[STDAppDelegate shareInstance].eventStore];
	[reminder setCalendar:[[STDAppDelegate shareInstance].eventStore defaultCalendarForNewReminders]];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	[reminder setStartDateComponents:[cal components:unitFlags fromDate:[NSDate date]]];
    [reminder setTitle:@"Test Reminder Title"];
    [reminder setNotes:@"Test Description"];
    [reminder setPriority:0];
	
	return reminder;
}

- (void)testSaveNewReminder
{
	XCTAssertTrue([STDReminderUtils saveReminderToStore:[self createDummyReminder]]);
}

- (void)testUpdateReminder
{
	EKReminder *reminder = [self createDummyReminder];
	if ([STDReminderUtils saveReminderToStore:reminder])
	{
		reminder.title = @"Update test";
		XCTAssertTrue([STDReminderUtils saveReminderToStore:reminder]);
	}
}

- (void)testRemoveReminder
{
	EKReminder *reminder = [self createDummyReminder];
	if ([STDReminderUtils saveReminderToStore:reminder])
	{
		XCTAssertTrue([STDReminderUtils removeReminder:reminder]);
	}
}

@end
