//
//  STDUtils.m
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDReminderUtils.h"
#import "STDAppDelegate.h"

@implementation STDReminderUtils

+ (NSString *)getTimestampWithDateComponents:(NSDateComponents *)dateComponents
{
	NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone localTimeZone]];
    [cal setLocale:[NSLocale currentLocale]];
	
	if (dateComponents == nil)
	{
		return @"";
	}
	
	return [self getTimestampWithDate:[cal dateFromComponents:dateComponents]];
}

+ (NSString *)getTimestampWithDate:(NSDate *)reminderDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
    NSString *timestamp;
	
    int timeIntervalInHours = (int)[[NSDate date] timeIntervalSinceDate:reminderDate] / 3600;
    int timeIntervalInMinutes = [[NSDate date] timeIntervalSinceDate:reminderDate] / 60;
	

	//less than 15 minutes old
    if (timeIntervalInMinutes <= 15)
	{
        timestamp = NSLocalizedString(@"reminder_utils_just_now", nil);
    }
	//less than 1 day
	else if(timeIntervalInHours < 24)
	{
        [dateFormatter setDateFormat:@"HH:mm"];
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"reminder_utils_just_now", nil), [dateFormatter stringFromDate:reminderDate]];
    }
	//less than 2 days
	else if (timeIntervalInHours < 48)
	{
        [dateFormatter setDateFormat:@"HH:mm"];
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"reminder_utils_yesterday_now",nil), [dateFormatter stringFromDate:reminderDate]];
    }
	//less than  a week
	else if (timeIntervalInHours < 168)
	{
        [dateFormatter setDateFormat:@"EEEE"];
        timestamp = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:reminderDate]];
    }
	//less than a year
	else if (timeIntervalInHours < 8765)
	{
        [dateFormatter setDateFormat:@"d MMMM"];
        timestamp = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:reminderDate]];
    }
	//older than a year
	else
	{
        [dateFormatter setDateFormat:@"d MMMM yyyy"];
        timestamp = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:reminderDate]];
    }
	
    return timestamp;
}

+ (BOOL)saveReminderToStore:(EKReminder *)reminder
{
    BOOL result = NO;
    
    NSError *error = nil;
    
    [[STDAppDelegate shareInstance].eventStore saveReminder:reminder commit:YES error:&error];
    
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"edit_reminder_error", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        result = YES;
    }
    
    return result;
}

+ (BOOL)removeReminder:(EKReminder *)reminder
{
    BOOL result;
    
    NSError *error = nil;
    
    [[STDAppDelegate shareInstance].eventStore removeReminder:reminder commit:YES error:&error];
    
    if (error)
    {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"common_alertview_title", nil) message:NSLocalizedString(@"remove_reminder_error", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        result = YES;
    }
    
    return result;
}

@end
