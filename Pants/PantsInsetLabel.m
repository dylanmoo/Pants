//
//  DSMInsetLabel.m
//  Pants
//
//  Created by Dylan Moore on 9/2/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsInsetLabel.h"

@implementation PantsInsetLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 5, 5, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
