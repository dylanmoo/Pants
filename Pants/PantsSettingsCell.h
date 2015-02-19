//
//  PantsSettingsCell.h
//  Pants
//
//  Created by Dylan Moore on 2/17/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PantsSettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (CGFloat)defaultHeight;

@end
