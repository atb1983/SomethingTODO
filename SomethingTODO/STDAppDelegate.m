//
//  STDAppDelegate.m
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDAppDelegate.h"

@implementation STDAppDelegate

+ (instancetype)shareInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.eventStore = [[EKEventStore alloc] init];
    
    return YES;
}

@end
