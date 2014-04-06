//
//  STDMapViewController.h
//  SomethingTODO
//
//  Created by Alex Núñez on 06/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class STDMapViewController;

// Delegate
@protocol STDMapViewControllerDelegate <NSObject>

@optional
- (void)mapViewController:(STDMapViewController *)mapViewController positionUpdated:(EKStructuredLocation *)location;
@end

@interface STDMapViewController : UIViewController

@property (weak) id <STDMapViewControllerDelegate> delegate;

// reminder to check
@property (nonatomic, strong) NSString *reminderTitle;
@property (nonatomic, strong) NSString *reminderDescription;
@property (nonatomic, strong) EKStructuredLocation *structuredLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *localizeMeButton;

- (IBAction)localizeUser:(id)sender;

@end
