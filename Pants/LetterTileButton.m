//
//  LetterTileButton.m
//  Pants
//
//  Created by Dylan Moore on 9/5/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "LetterTileButton.h"

@implementation LetterTileButton
//implement initWithFrame to instantiate your button class from code.  Use initWithCoder to instantiate from IB
-(id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        //make the label and format it the way you want, add it as a subview to the button
        buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -5, self.frame.size.width, self.frame.size.height + 10)];
        buttonTitleLabel.backgroundColor = [UIColor clearColor];
        buttonTitleLabel.textColor = [UIColor blackColor];
        buttonTitleLabel.textAlignment = UITextAlignmentCenter;
        buttonTitleLabel.clipsToBounds = NO;
        [self addSubview:buttonTitleLabel];
    }
    return self;
}
//
- (void)drawRect:(CGRect)rect
{
    buttonTitleLabel.text = buttonTitle;
    //update the frame of your label in case the button frame has changed
    buttonTitleLabel.frame = CGRectMake(0, -5, self.frame.size.width, self.frame.size.height);
}
//
//override all of the button methods you need and apply the formatting changes to your label
-(void)setTitle:(NSString *)title forState:(UIControlState)state {
    buttonTitle = title;
    buttonTitleLabel.text = title;
    [self setNeedsDisplay];
}
//
-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    titleColor = color;
    buttonTitleLabel.textColor = color;
    [self setNeedsDisplay];
}
//
-(NSString *)titleForState:(UIControlState)state {
    return buttonTitleLabel.text;
}
//
-(void)setSelected:(BOOL)selected {
    if (selected) {
        buttonTitleLabel.textColor = DEFAULT_YELLOW_COLOR;
    }
    else {
        buttonTitleLabel.textColor = titleColor;
    }
    [self setNeedsDisplay];
}
//
-(void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        buttonTitleLabel.textColor = DEFAULT_YELLOW_COLOR;
    }
    else {
        buttonTitleLabel.textColor = titleColor;
    }
    [self setNeedsDisplay];
}
//
//my custom title font setter and getter
-(void)setTitleFont:(UIFont *)font {
    buttonTitleLabel.font = font;
    [self setNeedsDisplay];
}
//
-(UIFont *)getTitleFont {
    return buttonTitleLabel.font;
}
@end

