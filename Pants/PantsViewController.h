//
//  DSMViewController.h
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PantsViewController : UIViewController <CLLocationManagerDelegate,NSURLConnectionDelegate, UIAlertViewDelegate>{

}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
