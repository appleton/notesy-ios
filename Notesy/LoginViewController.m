//
//  LoginViewController.m
//  Notesy
//
//  Created by Andy Appleton on 28/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "JNKeychain.h"
#import "MBProgressHUD.h"
#import "LoggerInner.h"

@interface LoginViewController()
@property (strong, nonatomic) NSString *notesDb;

@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UILabel *loginErrorLabel;
@property (strong, nonatomic) LoggerInner *loggerInner;
@end

@implementation LoginViewController

- (void) viewDidAppear:(BOOL)animated {
    [self.emailInput becomeFirstResponder];
}

- (IBAction)loginButton:(UIButton *)sender {
    [self hideLoginError];

    if ([self.emailInput.text length] == 0 || [self.passwordInput.text length] == 0) {
        [self showLoginError:@{@"reason": @"Email and password are required."}];
        return;
    }

    [self showLoginIsHappening];
    [self.loggerInner logInUser:self.emailInput.text
                       password:self.passwordInput.text
                           then:^void (NSDictionary *results) { [self onLoginSuccess:results]; }
                          error:^void (NSDictionary *results) { [self onLoginError:results]; }];
}

- (void) showLoginIsHappening {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging in…";
}

- (void) hideLoginIsHappening {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) showLoginError:(NSDictionary *)response {
    self.loginErrorLabel.text = [response objectForKey:@"reason"];
}

- (void) hideLoginError {
    self.loginErrorLabel.text = @"";
}

- (void) onLoginSuccess:(NSDictionary *)results {
    [self hideLoginIsHappening];

    if ([results objectForKey:@"error"]) {
        [self showLoginError:results];
    } else {
        self.notesDb = results[@"notes_db"];
        [self storeLoginData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) onLoginError:(NSDictionary *)results {
    [self hideLoginIsHappening];
    [self showLoginError:results];
}

- (void) storeLoginData {
    [JNKeychain saveValue:@{@"username": self.emailInput.text,
                            @"password": self.passwordInput.text,
                            @"notesDb": self.notesDb}
                   forKey:KEYCHAIN_KEY];
}

# pragma mark - Getters

- (LoggerInner *) loggerInner {
    if (!_loggerInner) _loggerInner = [[LoggerInner alloc] init];
    return _loggerInner;
}

@end
