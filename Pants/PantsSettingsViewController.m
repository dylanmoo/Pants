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

@interface PantsSettingsViewController ()

@end

@implementation PantsSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    
    [self.closeButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:24]];
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
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone:[NSTimeZone systemTimeZone]];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:timeForNotifications];
            
            NSString *time = [NSString stringWithFormat:@"%ld:%ld",(long)components.hour,(long)components.minute];
            [cell.titleLabel setText:[NSString stringWithFormat:@"Notifications set for %@",time]];
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
    }else if(indexPath.row == 2){
        //Review
        [cell.titleLabel setText:@"Tell us what to fix...or add"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        PantsPushSettingsViewController *pushVC = (PantsPushSettingsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pantsPushSettingsView"];
        
        pushVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:pushVC animated:YES completion:nil];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
