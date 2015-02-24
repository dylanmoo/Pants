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
    return 60;
}

- (void)awakeFromNib {
    // Initialization code
    
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:24]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if(selected){
        self.titleLabel.textColor = DEFAULT_BLUE_COLOR;
    }else{
        self.titleLabel.textColor = DEFAULT_SUPER_LIGHT_BLUE;
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted){
        self.titleLabel.textColor = DEFAULT_BLUE_COLOR;
    }else{
        self.titleLabel.textColor = DEFAULT_SUPER_LIGHT_BLUE;
    }
    // Configure the view for the selected state
}

@end
