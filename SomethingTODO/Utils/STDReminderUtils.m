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

+ (BOOL)saveReminderToStore:(EKReminder *)reminder
{
    BOOL result;
    
    NSError *error = nil;
    
    [[STDAppDelegate shareInstance].eventStore saveReminder:reminder commit:YES error:&error];
    
    if (error)
    {
        // TODO Translate
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"We are not able to save your reminder, try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
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
        // TODO Translate
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"We are not able to remove your reminder, try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        result = YES;
    }
    
    return result;
}

@end
