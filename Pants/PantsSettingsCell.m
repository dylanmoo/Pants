//
//  PantsSettingsCell.m
//  Pants
//
//  Created by Dylan Moore on 2/17/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsSettingsCell.h"

@implementation PantsSettingsCell

+ (CGFloat)defaultHeight{
    return 44;
}

- (void)awakeFromNib {
    // Initialization code
    
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:24]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
