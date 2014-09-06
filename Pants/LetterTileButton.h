//
//  LetterTileButton.h
//  Pants
//
//  Created by Dylan Moore on 9/5/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LetterTileButton : UIButton {
    UILabel *buttonTitleLabel; //This is the custom label so that I can calculate my own width
    UIColor *titleColor; //Remember the color of the label in case I call setHighlighted or setSelected manually
    NSString *buttonTitle; //Save the title for later reference, if needed
}
//Manual setter and getter for the font because for UIButton, the font is a property of the title label.  You could also override the UIButton methods, but this was better for my situation
-(void)setTitleFont:(UIFont *)font;
-(UIFont *)getTitleFont;
@end