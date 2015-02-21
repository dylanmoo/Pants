//
//  PantsSettingsViewController.h
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PantsSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end
