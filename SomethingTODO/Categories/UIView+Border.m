//
//  UIView+Border.m
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

- (void)applyBorderWithColor:(UIColor *)color
{
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    [self.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.layer setBorderColor: [color CGColor]];
    [self.layer setBorderWidth: 1.0];
    [self.layer setCornerRadius:8.0f];
    [self.layer setMasksToBounds:YES];
}

@end
