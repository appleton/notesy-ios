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
#import "JNKeychain.h"
#import "Constants.h"

@interface SettingsViewController ()
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@implementation SettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                  target:self
                                  action:@selector(close)];
    self.navigationItem.leftBarButtonItem = addButton;
    self.navigationItem.title = self.userInfo[@"username"];
}

- (void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) websiteLinkButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://notesy.co"]];
}

- (IBAction) logoutButton:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Log out"
                                message:@"Are you sure?"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Log out", nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Log out"]) [self logout];
}

- (void) logout {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutMessage object:nil];
    }];
}

- (IBAction) followButton:(id)sender {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"https://twitter.com/intent/user?screen_name=appltn"]];
}

#pragma mark - Getters

- (NSDictionary *) userInfo {
    if (!_userInfo) _userInfo = [JNKeychain loadValueForKey:KEYCHAIN_KEY];
    return _userInfo;
}

@end
