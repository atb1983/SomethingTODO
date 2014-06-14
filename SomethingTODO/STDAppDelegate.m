//
//  STDAppDelegate.m
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDAppDelegate.h"
#import <PLCrashReport.h>
#import <PLCrashReporter.h>

@implementation STDAppDelegate

+ (instancetype)shareInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.eventStore = [[EKEventStore alloc] init];
    
	PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
	NSError *error;
	
	// Check if we previously crashed
	if ([crashReporter hasPendingCrashReport])
		[self handleCrashReport];
	
	// Enable the Crash Reporter
	if (![crashReporter enableCrashReporterAndReturnError: &error])
		NSLog(@"Warning: Could not enable crash reporter: %@", error);
	
    return YES;
}

#pragma mark PlCrashReporter
/**
 * Called to handle a pending crash report.
 */
- (void) handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
	
    /* Try loading the crash report */
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
		[crashReporter purgePendingCrashReport];
		return;
    }
	
    /* We could send the report from here, but we'll just print out
     * some debugging info instead */
    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error] ;
    if (report == nil) {
        NSLog(@"Could not parse crash report");
		[crashReporter purgePendingCrashReport];
		return;
    }
	
    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
          report.signalInfo.code, report.signalInfo.address);
	
	[crashReporter purgePendingCrashReport];
	
    return;
}

@end
