//
//  STDMapViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 06/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDMapViewController.h"

@interface STDMapViewController () <MKMapViewDelegate>

@end

@implementation STDMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"map_title_vc", nil);
	
	self.mapView.delegate = self;
	
	// Gesture
	UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.mapView addGestureRecognizer:tapGesture];
	
	
	self.mapView.showsUserLocation = YES;
	[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	[self zoomToUserLocation:self.mapView.userLocation];
	
	[self configureView];
}

#pragma mark TapGesture

- (void)handleGesture:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded )
	{
		CGPoint point = [recognizer locationInView:self.mapView];
		CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
		NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
		
		BOOL annotionAddedAlready = NO;
		
		if (visibleAnnotations.count == 0)
		{
			// create annocation
			[self createReminderAnnotation:tapPoint];
		}
		else
		{
			for (id<MKAnnotation> annotation in visibleAnnotations.allObjects)
			{
				if (![annotation isKindOfClass:[MKUserLocation class]])
				{
					annotionAddedAlready = YES;

					UIView *av = [self.mapView viewForAnnotation:annotation];
					CGPoint point = [recognizer locationInView:av];
					
					if (![av pointInside:point withEvent:nil])
					{
						// we update the existing annotation
						annotation.coordinate = tapPoint;
						
						[self updateReminder:tapPoint];
						return;
					}
				}
			}
			
			// if there is not a annotation created , we add it.
			if (!annotionAddedAlready)
			{
				[self createReminderAnnotation:tapPoint];
			}
			
		}
	}
}

#pragma mark - Helpers

- (void)configureView
{
	if (self.currentReminder.alarms.count > 0)
	{
		EKAlarm *alarm = [self.currentReminder.alarms lastObject];
		[self createReminderAnnotation:alarm.structuredLocation.geoLocation.coordinate];
	}
}

- (void)createReminderAnnotation:(CLLocationCoordinate2D)point
{
	[self updateReminder:point];
	
	MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
	pointAnnotation.coordinate = point;
	pointAnnotation.title = [self.currentReminder.title length] == 0 ? NSLocalizedString(@"map_reminder_title", nil) : self.currentReminder.title;
	pointAnnotation.subtitle = self.currentReminder.notes;
	[self.mapView addAnnotation:pointAnnotation];
}

- (void)updateReminder:(CLLocationCoordinate2D)point
{
	EKStructuredLocation *location = [EKStructuredLocation locationWithTitle:@"Reminder Location"];
	location.geoLocation = [[CLLocation alloc] initWithCoordinate:point altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
	
	EKAlarm *alarm = [[EKAlarm alloc] init];
	alarm.structuredLocation = location;
	self.currentReminder.alarms = @[alarm];
}

- (void)zoomToUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
	
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(2.0, 2.0);	//Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)theMapView didUpdateToUserLocation:(MKUserLocation *)location
{
    [self zoomToUserLocation:location];
}

#pragma mark Action

- (IBAction)localizeUser:(id)sender
{
	[self zoomToUserLocation:self.mapView.userLocation];
}

@end
