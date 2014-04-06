//
//  STDMapViewController.h
//  SomethingTODO
//
//  Created by Alex Núñez on 06/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface STDMapViewController : UIViewController

// reminder to check
@property (nonatomic, strong) EKReminder *currentReminder;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *localizeMeButton;

- (IBAction)localizeUser:(id)sender;

@end
