//
//  STDTableViewCell.m
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDTableViewCell.h"
#import "STDTableViewCellOverlay.h"

@interface STDTableViewCell ()

@property (nonatomic, strong) STDTableViewCellOverlay *overlayView;

@end

@implementation STDTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.overlayView = [[STDTableViewCellOverlay alloc] initWithFrame:self.contentView.bounds];
    [self.overlayView setHidden:YES];
    [self.contentView addSubview:self.overlayView];
}

- (void)setTaskCompleted:(BOOL)taskCompleted
{
    [self.overlayView setHidden:taskCompleted];
    
    _taskCompleted = taskCompleted;
}

@end
