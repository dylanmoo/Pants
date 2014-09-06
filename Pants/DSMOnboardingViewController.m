//
//  DSMOnboardingViewController.m
//  Pants
//
//  Created by Dylan Moore on 9/1/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "DSMOnboardingViewController.h"

@interface DSMOnboardingViewController ()


@end

@implementation DSMOnboardingViewController

- (id)init
{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:DEFAULT_YELLOW_COLOR];
    
    self.titleLabel = [[DSMInsetLabel alloc] initWithFrame:CGRectMake(0, 30, self.view.width, 60)];
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:80]];
    [self.titleLabel setTextColor:DEFAULT_RED_COLOR];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setCenterX:self.view.centerX];
    
    self.subtitleLabel = [[DSMInsetLabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, self.view.width-40, self.view.height-80-80-20-140)];
    [self.subtitleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:35]];
    [self.subtitleLabel setTextColor:DEFAULT_RED_COLOR];
    [self.subtitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.subtitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.subtitleLabel setNumberOfLines:0];
    [self.subtitleLabel setTop:self.titleLabel.bottom];
    [self.subtitleLabel setCenterX:self.view.centerX];
    
    
    self.acceptButton = [[LetterTileButton alloc] initWithFrame:CGRectMake(0, self.subtitleLabel.bottom+20, self.view.width-100, 90)];
    
    [self.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:70]];
    [self.acceptButton setTitleColor:DEFAULT_YELLOW_COLOR forState:UIControlStateSelected];
    [self.acceptButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.acceptButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.acceptButton setCenterX:self.view.centerX];
    [self.acceptButton setUserInteractionEnabled:YES];
    [self.acceptButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    self.acceptButton.layer.cornerRadius = 7;
    self.acceptButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.acceptButton.layer.borderWidth = 2;
    
    
    
    self.denyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width-100, 20)];
    [self.denyButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:16]];
    [self.denyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.denyButton setCenterX:self.view.centerX];
    [self.denyButton setBottom:self.view.bottom-20];
    
    [self.acceptButton setBottom:self.denyButton.top -20];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.acceptButton];
    [self.view addSubview:self.denyButton];
    
    [self.denyButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.acceptButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(id)button
{
    
    if(self.acceptButtonBlock && [button isEqual:self.acceptButton]){
        self.acceptButtonBlock(self.acceptButton);
    }
    
    if(self.denyButtonBlock && [button isEqual:self.denyButton]){
        self.denyButtonBlock(self.denyButton);
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
