//
//  PantsViewController.m
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsViewController.h"
#import "PantsOnboardingViewController.h"
#import "Mixpanel.h"
#import "UIImage+animatedGIF.h"
#import "PantsStore.h"
#import "LocationClient.h"
#import "APIClient.h"
#import "PantsInsetLabel.h"
#import "PantsSettingsViewController.h"

@interface PantsViewController (){
    NSMutableData *_responseData;
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    NSURL *pantsURL;
    NSURL *noPantsURL;
    NSURLConnection *currentConnection;
    NSDate *todaysMaxTempDate;
    BOOL pantsOn;
    BOOL viewAppeared;
    int pantsOnHour;
    float tempThreshold;
    NSTimer *loadingTimer;
}

@property (strong, nonatomic)  UILabel *pantsLabel;
@property (strong, nonatomic)  UILabel *noPantsLabel;
@property (strong, nonatomic)  UIImageView *pantsImageView;
@property (strong, nonatomic)  UIImageView *noPantsImageView;
@property (strong, nonatomic)  UILabel *timerLabel;
@property (strong, nonatomic)  UIImageView *timerView;
@property (strong, nonatomic)  UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic)  PantsInsetLabel *loadingLabel;
@property (strong, nonatomic)  PantsWeather *currentWeather;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet PantsInsetLabel *morningLabel;
@property (weak, nonatomic) IBOutlet PantsInsetLabel *nightLabel;

@end



@implementation PantsViewController

NSString *WEATHER_API_KEY = @"fb98ed1c58fd01aca10a0ede95cc4758";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pantsString = @"#PANTS";
    noPantsString = @"#NOPANTS";
    
    
    UIImageView *triangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down"]];
    
    self.timerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, triangle.height)];
    [self.timerView setBackgroundColor:[UIColor clearColor]];
    [self.timerView setCenter:self.view.center];
    
    float height = 18;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.timerView.height/2-height/2, self.timerView.width, height)];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    
    [self.timerView addSubview:lineView];
    
    [self.timerView addSubview:triangle];
    triangle.left = self.morningLabel.left;
    triangle.centerY = self.timerView.height/2+10;

    [self.view addSubview:self.timerView];

    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    [self.timerLabel setText:@""];
    [self.timerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timerLabel setCenterX:self.morningLabel.left + triangle.width/2];
    [self.timerLabel setTextColor:[UIColor blackColor]];
    [self.timerLabel setCenterY:lineView.centerY];
    [self.timerView addSubview:self.timerLabel];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicator];
    
    self.loadingLabel = [[PantsInsetLabel alloc] initWithFrame:CGRectMake(0, 0, self.timerView.bounds.size.width, self.timerView.bounds.size.height)];
    self.loadingLabel.text = @"          calculating the time to put on pants...";
    self.loadingLabel.textAlignment = NSTextAlignmentLeft;
    [self.loadingLabel setBackgroundColor:[UIColor whiteColor]];
    [self.loadingLabel setCenter:self.view.center];
    [self.loadingLabel setTextColor:[UIColor blackColor]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findLocation)];
    [self.loadingLabel addGestureRecognizer:tap];
    [self.loadingLabel setUserInteractionEnabled:NO];
    [self.view addSubview:self.loadingLabel];
    
    self.pantsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.pantsImageView setBackgroundColor:DEFAULT_BLUE_COLOR];
    [self.pantsImageView setTop:self.view.centerY];
    [self.pantsImageView setHeight:(self.view.height - self.view.centerY)];

    [self.pantsImageView setAutoresizesSubviews:YES];
    
    [self.view insertSubview:self.pantsImageView belowSubview:self.timerView];
    
    self.noPantsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.noPantsImageView setBackgroundColor:DEFAULT_YELLOW_COLOR];
    [self.noPantsImageView setTop:self.view.top];
    [self.noPantsImageView setHeight:self.view.centerY];
    
    [self.noPantsImageView setAutoresizesSubviews:YES];
    
    [self.view insertSubview:self.noPantsImageView belowSubview:self.timerView];
    
    self.pantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pantsImageView.width, self.pantsImageView.height)];
    [self.pantsLabel setText:pantsString];
    [self.pantsLabel setNumberOfLines:0];
    [self.pantsLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    [self.pantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pantsLabel setCenterY:(self.pantsImageView.height/2)];
    [self.pantsLabel setCenterX:self.view.centerX];
    [self.pantsImageView addSubview:self.pantsLabel];
    
    
    self.noPantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.noPantsImageView.width, self.noPantsImageView.height)];
    [self.noPantsLabel setText:noPantsString];
    [self.noPantsLabel setNumberOfLines:0];
    [self.noPantsLabel setTextColor:DEFAULT_RED_COLOR];
    [self.noPantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noPantsLabel setCenterY:(self.noPantsImageView.height/2)];
    [self.noPantsLabel setCenterX:self.view.centerX];
    [self.noPantsImageView addSubview:self.noPantsLabel];
    
    
    [self.morningLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.morningLabel setTextColor:DEFAULT_RED_COLOR];
    
    [self.nightLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.nightLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    //[self.view setBackgroundColor:DEFAULT_YELLOW_COLOR];
    
    [self.noPantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.pantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.timerLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:16]];
    [self.loadingLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:20]];
    
    tempThreshold = 73.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAccessDenied:) name:kNotificationLocationServicesDisabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
    
    [self.view setUserInteractionEnabled:YES];
    [self.pantsImageView setUserInteractionEnabled:YES];
    [self.noPantsImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleExplanation:)];
    [self.timerView addGestureRecognizer:tapGesture];
    [self.timerView setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    
    [self.view addGestureRecognizer:panGesture];
    
    viewAppeared = false;
    
    [self.infoButton setBackgroundImage:[UIImage imageNamed:@"smiley_blue"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.infoButton];
    [self.view bringSubviewToFront:self.morningLabel];
    [self.view bringSubviewToFront:self.nightLabel];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

-(void)showLoading
{
    [self.loadingLabel setUserInteractionEnabled:NO];
    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(changeLoadingText:) userInfo:nil repeats:YES];
}

-(void)changeLoadingText:(NSTimer*)timer{
    NSString *text = self.loadingLabel.text;
    if([text containsString:@"..."]){
        self.loadingLabel.text = @"          calculating the time to put on pants";
    }else if([text containsString:@".."]){
        self.loadingLabel.text = @"          calculating the time to put on pants...";
    }else if([text containsString:@"."]){
        self.loadingLabel.text = @"          calculating the time to put on pants..";
    }else{
        self.loadingLabel.text = @"          calculating the time to put on pants.";
    }
}

- (void)stopLoading{
    [self.loadingLabel setUserInteractionEnabled:YES];
    [loadingTimer invalidate];
    loadingTimer = nil;
}

- (void)toggleExplanation:(UITapGestureRecognizer*)recognizer
{
    if(self.loadingLabel.alpha != 1){
        
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.loadingLabel setAlpha:1];
            self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
            [[LocationClient sharedClient] updateUsersLocation];
        }];
    }
}

- (void)awakeFromNib{
    [self.timerView setCenterY:self.view.centerY];
    [self.activityIndicator setCenterY:self.view.centerY];
}

-(void)didBecomeActive:(NSNotification*)notification
{
    if([[LocationClient sharedClient] currentLocation])
    {
        [self findLocation];
        
    }
}

-(void)share:(UITapGestureRecognizer*)recognizer
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

        NSMutableArray *sharingItems = [NSMutableArray new];
    if([recognizer.view isEqual:self.pantsImageView]){
        [sharingItems addObject:@"I'm wearing #PANTS today! @SomeDumbApp told me to."];
        
        [mixpanel track:@"Sharing #PANTS"];
    }else{
        [sharingItems addObject:@"I'm wearing #NOPANTS today! @SomeDumbApp told me to."];
        
        [mixpanel track:@"Sharing #NOPANTS"];
    }
    
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void)findLocation{
    [[LocationClient sharedClient] updateUsersLocation];
    [self.activityIndicator startAnimating];
    [self showLoading];
    [self.timerView setAlpha:0];
}

-(void)locationAccessDenied:(NSNotification*)notification{
    [self showLocationError];
}

-(void)panned:(UIPanGestureRecognizer*)recognizer
{

    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"LIFT");
        [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
            self.infoButton.alpha = 0;
            self.morningLabel.alpha = 0;
            self.nightLabel.alpha = 0;
        } completion:nil];
        
        // [self findLocation];
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    [self.loadingLabel setCenterY:self.loadingLabel.centerY + translation.y];
    [self.pantsImageView setTop:self.pantsImageView.top + translation.y];
    [self.pantsImageView setHeight:self.pantsImageView.height - translation.y];
    [self.noPantsImageView setHeight:self.noPantsImageView.height + translation.y];
    [self.noPantsLabel setCenterY:self.noPantsImageView.height/2];
    [self.pantsLabel setCenterY:self.pantsImageView.height/2];
    [self.timerView setCenterY:self.timerView.center.y + translation.y];
    [self.activityIndicator setCenterY:self.activityIndicator.center.y + translation.y];
    
    //[self.gifImageView setHeight:self.timerLabel.center.y];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"LIFT");
        if(self.currentWeather){
            [self displayWeather:self.currentWeather];
        }
    
       // [self findLocation];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!viewAppeared)
    {
        if([[LocationClient sharedClient] currentLocation])
        {
            [self findLocation];
            
        }
        else{
            [self showOnboarding];
            
        }
    }
    
    viewAppeared = true;
}

-(void)showOnboarding
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                
    PantsOnboardingViewController *onb = (PantsOnboardingViewController*)[storyboard instantiateViewControllerWithIdentifier:@"pantsOnboardingView"];
    
    [self presentViewController:onb animated:YES completion:^{
        
        [onb.acceptButton setTitle:@"Okay!" forState:UIControlStateNormal];
        
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            

            [self dismissViewControllerAnimated:YES completion:^{
                [self findLocation];
            }];
            
        }];
        
        [onb.denyButton setTitle:@"Nah" forState:UIControlStateNormal];
        __weak typeof(onb) weakOnb = onb;
        [onb setDenyButtonBlock:^(UIButton *actionButton){
            NSLog(@"Deny Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Denied Location Access"];
            
            weakOnb.subtitleLabel.text = @"really needs your location so we can give you the most accurate time to put on pants...Thank you!!";
    
        }];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Onboarding"];
    }];
    
}


-(void)showLocationError
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PantsOnboardingViewController *onb = (PantsOnboardingViewController*)[storyboard instantiateViewControllerWithIdentifier:@"pantsOnboardingView"];
    
    [self presentViewController:onb animated:YES completion:^{
        onb.titleLabel.text = @"#PANTS";
        onb.subtitleLabel.text = @"really needs your location. Can you go to:\n\n->Settings\n->Privacy\n->Location\n->Pants and turn it on?";
        
        [onb.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:55]];
        [onb.acceptButton setTitle:@"I did that!" forState:UIControlStateNormal];
        
        __weak typeof(self) weakSelf = self;
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            
            [weakSelf findLocation];
        }];
        
        [onb.denyButton setTitle:@"Nah" forState:UIControlStateNormal];
        __weak typeof(onb) weakOnb = onb;
        [onb setDenyButtonBlock:^(UIButton *actionButton){
            NSLog(@"Deny Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Denied Location Access"];
            
            weakOnb.subtitleLabel.text = @"really needs your location so we can give you the most accurate time to put on pants...Thank you!!";
        }];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Location Error"];
    }];
    
}

-(void)locationUpdated:(NSNotification*)notification{
    
    
    if(![[PantsStore sharedStore] userID]){
        [[APIClient sharedClient] signIn];
    }
    
    NSDictionary *currentLocation = [[LocationClient sharedClient] currentLocation];
    
    if(!currentLocation){
        return;
    }
    
   [[APIClient sharedClient] getWeatherWithCompletion:^(PantsWeather *weather) {
       
       dispatch_async(dispatch_get_main_queue(), ^{
           if(weather){
               self.currentWeather = weather;
               [self displayWeather:self.currentWeather];
           }else{
               //[self showFailedToGetWeather];
               [self showPantsAtHour:8];
           }
       });
       
       
   }];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"opened"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!self.isFirstResponder){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showFailedToGetWeather{
    [self stopLoading];
    [self.loadingLabel setText:@"          No connection. Tap to try again."];
    [self.pantsImageView setUserInteractionEnabled:YES];
}

- (void)displayWeather:(PantsWeather*)weather{
    
    if(!weather) return;
    
    if(weather.pantsAtTime.intValue == 0)
    {
        //pants all day
        [self showPantsAllDay:weather.pantsFlavorText];
        
    }
    else if(weather.pantsAtTime.intValue == 24)
    {
        //no pants all day
        [self showNoPantsAllDay:weather.noPantsFlavorText];
        
    }
    else
    {
        [self showPantsAtHour:weather.pantsAtTime.intValue];
    
    }
    
}

- (void)showPantsAllDay:(NSString*)flavorText{
    if(!flavorText) flavorText = @"all day";
    
    [self.pantsLabel setText:[NSString stringWithFormat:@"%@\n%@",pantsString,flavorText]];

    //[self.noPantsLabel setText:@"What?\nYou don't trust me?"];
    
    [self.activityIndicator stopAnimating];
    [self stopLoading];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:0];
        [self.timerView setAlpha:0];
        [self.morningLabel setAlpha:0];
        [self.nightLabel setAlpha:0];
        [self.infoButton setAlpha:1];
        
        [self.view bringSubviewToFront:self.noPantsImageView];
        [self.view bringSubviewToFront:self.infoButton];
        [self.infoButton setBackgroundImage:[UIImage imageNamed:@"smiley_blue"] forState:UIControlStateNormal];
        [self.pantsImageView setTop:0];
        [self.pantsImageView setHeight:self.view.height];
        [self.noPantsImageView setHeight:0];
        [self.noPantsImageView setTop:0];
        
        
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, self.pantsImageView.height/2)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, self.noPantsImageView.height/2)];
        
        
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, 0)];
        [self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, 0)];
        [self.loadingLabel setCenterY:0];
        [self.loadingLabel setAlpha:0];
        self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .1);
    } completion:^(BOOL finished) {
        //[self.pantsImageView setUserInteractionEnabled:YES];
    }];

}

- (void)showNoPantsAllDay:(NSString*)flavorText{
    if(!flavorText) flavorText = @"all day!";
    
    [self.noPantsLabel setText:[NSString stringWithFormat:@"%@\n%@",noPantsString,flavorText]];
    //[self.pantsLabel setText:@"What?\nYou don't trust me?"];
    
    [self.activityIndicator stopAnimating];
    [self stopLoading];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.pantsLabel setAlpha:0];
        [self.noPantsLabel setAlpha:1];
        [self.timerView setAlpha:0];
        [self.morningLabel setAlpha:0];
        [self.nightLabel setAlpha:0];
        [self.infoButton setAlpha:1];
        
        [self.view bringSubviewToFront:self.pantsImageView];
        [self.view bringSubviewToFront:self.infoButton];
        [self.infoButton setBackgroundImage:[UIImage imageNamed:@"smiley_red"] forState:UIControlStateNormal];
        [self.pantsImageView setTop:self.view.height];
        [self.pantsImageView setHeight:0];
        [self.noPantsImageView setHeight:self.view.height];
        [self.noPantsImageView setTop:0];
        
        
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, self.pantsImageView.height/2)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, self.noPantsImageView.height/2)];
        
        
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, self.view.height)];
        [self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, self.view.height)];
        [self.loadingLabel setCenterY:self.view.height];
        [self.loadingLabel setAlpha:0];
        self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .1);
    } completion:^(BOOL finished) {
        //[self.pantsImageView setUserInteractionEnabled:YES];
    }];
}

-(void)showPantsAtHour:(int)hour{
    pantsOnHour = hour;
    //Find placement of bar
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:date];
    
    int hoursLater = hour;
    int hoursLeft = 24;
    float spacing = 200;
    
    float distanceFromTop = (hoursLater*((self.view.bounds.size.height-(2*spacing))/hoursLeft))+spacing;
    
    //distanceFromTop = self.view.height/2;
    
    float noPantsCenter = distanceFromTop/2;
    float pantsCenter = ((self.view.bounds.size.height-distanceFromTop)/2) + distanceFromTop;
    
    NSString *time = [NSString stringWithFormat:@"%d %@",(hour>12?hour-12:hour),(hour>12 ? @"PM":@"AM") ];
    [self.timerLabel setText:time];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Showing Pants Time" properties:@{@"time": time}];
    
   
    [self.pantsLabel setText:pantsString];
    [self.noPantsLabel setText:noPantsString];
    
    float heightOfBGView = self.view.height-distanceFromTop;
    
    [self.activityIndicator stopAnimating];
    [self stopLoading];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:1];
        [self.timerView setAlpha:1];
        [self.morningLabel setAlpha:1];
        [self.nightLabel setAlpha:1];
        [self.infoButton setAlpha:1];
        
        [self.pantsImageView setTop:distanceFromTop];
        [self.pantsImageView setHeight:heightOfBGView];
        [self.noPantsImageView setHeight:distanceFromTop];
        [self.noPantsImageView setTop:0];
        [self.infoButton setBackgroundImage:[UIImage imageNamed:@"smiley_blue"] forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.infoButton];
        [self.view bringSubviewToFront:self.morningLabel];
        [self.view bringSubviewToFront:self.nightLabel];
        [self.view bringSubviewToFront:self.timerView];
        
        
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, self.pantsImageView.height/2)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, self.noPantsImageView.height/2)];
        
        
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, distanceFromTop)];
        [self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, distanceFromTop)];
        [self.loadingLabel setCenterY:distanceFromTop];
        [self.loadingLabel setAlpha:0];
        self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .1);
    } completion:^(BOOL finished) {
        //[self.pantsImageView setUserInteractionEnabled:YES];
    }];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.pantsImageView setAlpha:1];
}


- (int)epochForDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    NSDate *date = [calendar dateFromComponents:components];
    return [date timeIntervalSince1970];
}

- (void)showNotificationAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Turn on Auto Pants?" message:@"The following alert will ask for permission to send you notifications in the morning so you don't even have to open up the app. Please press \"Okay\"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil] show];
}

- (void)showNotificationAlertOptions
{
    [[[UIAlertView alloc] initWithTitle:@"Auto Pants Settings" message:@"What time would you like to receive your notification in the morning?" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"While I'm asleep", @"Before noon", @"Never", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        //Cancel Pressed
        
    }else{
        
    }
}

- (IBAction)infoPressed:(id)sender {
    
        //[self showNotificationAlert];
    
    PantsSettingsViewController *settingsVc = (PantsSettingsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pantsSettingsView"];
    
    settingsVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:settingsVc animated:YES completion:nil];
    
}













#pragma mark NSURLConnection Delegate Methods


-(void)getWeatherForLat:(NSString*)lat andLon:(NSString*)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%@,%@",WEATHER_API_KEY,lat,lon];
    // Create url connection and fire request
    currentConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] delegate:self];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error = nil;
    
    NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    NSLog(@"Data: %@",weather);
    
    NSDictionary *hourly = weather[@"hourly"];
    hourlyWeather = hourly[@"data"];
    
    NSNumber *dailyMaxEpoch = weather[@"daily"][@"data"][0][@"apparentTemperatureMaxTime"];
    
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:dailyMaxEpoch.intValue];
    NSLog (@"Epoch time %d equates to UTC %@", dailyMaxEpoch.intValue, epochNSDate);
    
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSLog (@"Epoch time %d equates to %@", dailyMaxEpoch.intValue, [dateFormatter stringFromDate:epochNSDate]);
    
    todaysMaxTempDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:epochNSDate]];
    
    [self processHourlyWeatherForPants];
    
}


-(void)processHourlyWeatherForPants{
    
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:date];
    NSLog(@"COMPS;%@",comps);
    int secondsUntilMidnight = (23-comps.hour)*60*60;
    NSDate *outUntilDate = [date dateByAddingTimeInterval:secondsUntilMidnight];
    
    int hourToPutOnPants = comps.hour;
    
    bool foundFirstHourForPants = false;
    
    for(NSDictionary *hour in hourlyWeather){
        NSNumber *hourEpoch = hour[@"time"];
        
        // (Step 1) Create NSDate object
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:hourEpoch.intValue];
        NSLog (@"Epoch time %d equates to UTC %@", hourEpoch.intValue, epochNSDate);
        
        // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSLog (@"Epoch time %d equates to %@", hourEpoch.intValue, [dateFormatter stringFromDate:epochNSDate]);
        
        NSDate *hourDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:epochNSDate]];
        
        if([hourDate compare:outUntilDate]==NSOrderedAscending && [hourDate compare:todaysMaxTempDate]==NSOrderedDescending){
            //Add to average Temp
            NSLog(@"%@ is between %@ and %@",hourDate,todaysMaxTempDate,outUntilDate);
            NSNumber *temp = hour[@"temperature"];
            
            if(temp.intValue<tempThreshold){
                if(foundFirstHourForPants){
                    break;
                }else{
                    foundFirstHourForPants = true;
                    
                    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:hourDate];
                    NSLog(@"Comps for Hour ;%@",comps);
                    hourToPutOnPants = comps.hour;
                }
            }else{
                foundFirstHourForPants = false;
            }
        }
        
    }
    
    if(!foundFirstHourForPants){
        hourToPutOnPants = 23;
    }
    
    [self showPantsAtHour:hourToPutOnPants];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
