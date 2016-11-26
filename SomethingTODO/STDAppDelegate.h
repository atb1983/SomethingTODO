//
//  STDAppDelegate.h
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic, assign) BOOL hasCloudAccess;

+ (instancetype)shareInstance;

@end
