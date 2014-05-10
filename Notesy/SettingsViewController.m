//
//  SettingsViewController.m
//  Notesy
//
//  Created by Andy Appleton on 09/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "SettingsViewController.h"
#import "MasterViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                  target:self
                                  action:@selector(close)];
    self.navigationItem.leftBarButtonItem = addButton;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutMessage object:nil];
    }];
}

- (IBAction)followButton:(id)sender {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"https://twitter.com/intent/user?screen_name=appltn"]];
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
