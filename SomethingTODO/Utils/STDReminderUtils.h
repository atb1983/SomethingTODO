//
//  STDReminderUtils.h
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDReminderUtils : NSObject

+ (NSString *)getTimestampWithDateComponents:(NSDateComponents *)dateComponents;
+ (NSString *)getTimestampWithDate:(NSDate *)reminderDate;

+ (BOOL)saveReminderToStore:(EKReminder *)reminder;
+ (BOOL)removeReminder:(EKReminder *)reminder;

@end
