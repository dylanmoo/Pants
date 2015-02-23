//
//  PantsSettingsViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsSettingsViewController.h"
#import "PantsSettingsCell.h"
#import "PantsStore.h"
#import "PantsPushSettingsViewController.h"
#import "Mixpanel.h"
#import <Appirater.h>

@interface PantsSettingsViewController ()

@end

@implementation PantsSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.titleLabel setTextColor:DEFAULT_SUPER_LIGHT_BLUE];
    
    [self.closeButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:22]];
    [self.closeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    UINib *settingsNib = [UINib nibWithNibName:NSStringFromClass([PantsSettingsCell class]) bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:settingsNib forCellReuseIdentifier:NSStringFromClass([PantsSettingsCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [PantsSettingsCell defaultHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PantsSettingsCell *cell = (PantsSettingsCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PantsSettingsCell class])];
    
    if(indexPath.row == 0){
        
        //Notifications
        NSDate *timeForNotifications = [[PantsStore sharedStore] timeForNotifications];
        if(timeForNotifications)
        {
            [cell.titleLabel setText:[NSString stringWithFormat:@"Notifications set for %@",[self stringFromDate:timeForNotifications]]];
        }
        else
        {
            [cell.titleLabel setText:@"No Notifications. Tap to Set"];
        }
    }else if(indexPath.row == 1){
        //Share with a friend
        [cell.titleLabel setText:@"Share with a friend"];
    }else if(indexPath.row == 2){
        //Review
        [cell.titleLabel setText:@"Review us!"];
    }else if(indexPath.row == 3){
        //Email
        [cell.titleLabel setText:@"Tell us what to fix...or add"];
    }
    
    return cell;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        PantsPushSettingsViewController *pushVC = (PantsPushSettingsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pantsPushSettingsView"];
        
        pushVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:pushVC animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }else if(indexPath.row == 1){
        //Share with a friend
        [self openSMS];
    }else if(indexPath.row == 2){
        //Review
        [Appirater rateApp];
    }else if(indexPath.row == 3){
        //Email
        [self sendEmail];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)stringFromDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSString *ampm = components.hour>12 ? @"P.M." :@"A.M.";
    
    NSInteger hour = components.hour%12 == 0 ? 12 : components.hour%12;
    NSString *minute = components.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)components.minute] : [NSString stringWithFormat:@"%ld", (long)components.minute];
    
    NSString *time = [NSString stringWithFormat:@"%ld:%@ %@",(long)hour,minute, ampm];
    return time;
}


- (void)openSMS;
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.messageComposeDelegate = self;
        controller.delegate = self;
        controller.body = [NSString stringWithFormat:@"Hey, this app told me not to wear pants today. Sorry, I'm not sorry"];
        
        [self presentViewController:controller animated:YES completion:nil];
        [[Mixpanel sharedInstance] track:@"Send SMS Pressed"];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    switch (result) {
        case MessageComposeResultCancelled:{
            [[Mixpanel sharedInstance] track:@"=Send SMS Cancelled"];
        }
            break;
        case MessageComposeResultFailed:{
            [[Mixpanel sharedInstance] track:@"Send SMS Failed"];
        }
            break;
        case MessageComposeResultSent:{
            [[Mixpanel sharedInstance] track:@"Sent SMS Finished"];
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}

-(void)sendEmail{
    NSArray *recipients = [[NSArray alloc] initWithObjects:@"team@letsat.com", nil];

    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
        [mailController setMessageBody:@"" isHTML:YES];
        [mailController setSubject:@"Pants is great, but..."];
        [mailController setToRecipients:recipients];
        mailController.mailComposeDelegate = self;
        [self presentViewController:mailController animated:YES completion:nil];
    }
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled){
        NSLog(@"Message cancelled");
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:[NSString stringWithFormat:@"Your feedback is very important to us, thank you for helping us make Pants better!"] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
