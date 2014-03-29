//
//  STDTableViewCellOverlay.m
//  SomethingTODO
//
//  Created by Alex Núñez on 29/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDTableViewCellOverlay.h"

const CGFloat kSeparator = 20.0f;

@implementation STDTableViewCellOverlay

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint = CGPointMake(self.frame.origin.x + kSeparator, CGRectGetMidY(self.frame));
    CGPoint endPoint = CGPointMake(self.frame.origin.x + self.frame.size.width - 1 - kSeparator, CGRectGetMidY(self.frame));
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
