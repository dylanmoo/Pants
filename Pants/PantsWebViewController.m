//
//  PantsWebViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/23/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsWebViewController.h"

@interface PantsWebViewController ()

@end

@implementation PantsWebViewController


- (void)viewDidLoad
{
    //[topBar setBackgroundColor:[UIColor primaryColor]];
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://forecast.io/"];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //[webView setScalesPageToFit:YES];
    //[self.webView loadRequest:request];
    self.webView.suppressesIncrementalRendering = YES;
    [self.webView setDelegate:self];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityIndicator.hidden= TRUE;
    [self.activityIndicator stopAnimating];
    //NSLog(@"Web View Did finish loading");
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.activityIndicator.hidden= FALSE;
    [self.activityIndicator startAnimating];
    //NSLog(@"Web View started loading...");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
