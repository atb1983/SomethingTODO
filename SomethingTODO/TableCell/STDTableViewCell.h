//
//  STDTableViewCell.h
//  SomethingTODO
//
//  Created by Alex Núñez on 28/03/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@end
