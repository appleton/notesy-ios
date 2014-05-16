//
//  SignupViewController.m
//  Notesy
//
//  Created by Andy Appleton on 15/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "SignupViewController.h"
#import "SignerUpper.h"
#import "Constants.h"
#import "JNKeychain.h"
#import "MBProgressHUD.h"

@interface SignupViewController ()
@property (strong, nonatomic) NSString *notesDb;
@property (strong, nonatomic) SignerUpper *signerUpper;

@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UILabel *signupErrorLabel;
@end

@implementation SignupViewController

- (void) viewDidAppear:(BOOL)animated {
    [self.emailInput becomeFirstResponder];
}

- (IBAction)signupButton:(id)sender {
    [self hideSignupError];

    if ([self.emailInput.text length] == 0 || [self.passwordInput.text length] == 0) {
        [self showSignupError:@{@"reason": @"Email and password are required."}];
        return;
    }

    [self showSignupIsHappening];
    [self.signerUpper signUpUser:self.emailInput.text
                       password:self.passwordInput.text
                           then:^void (NSDictionary *results) { [self onSignupSuccess:results]; }
                          error:^void (NSDictionary *results) { [self onSignupError:results]; }];
}

- (void) showSignupIsHappening {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Signing up…";
}

- (void) hideSignupIsHappening {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) showSignupError:(NSDictionary *)response {
    NSMutableArray *errorMsgStrings = [[NSMutableArray alloc] init];
    for (NSDictionary *error in response[@"errors"]) {
        [errorMsgStrings addObject:[NSString stringWithFormat:@"%@ %@", error[@"param"], error[@"msg"]]];
    }
    self.signupErrorLabel.text = [errorMsgStrings componentsJoinedByString:@" "];
}

- (void) hideSignupError {
    self.signupErrorLabel.text = @"";
}

- (void) onSignupSuccess:(NSDictionary *)results {
    [self hideSignupIsHappening];

    if ([results objectForKey:@"errors"]) {
        [self showSignupError:results];
    } else {
        self.notesDb = results[@"notes_db"];
        [self storeLoginData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) onSignupError:(NSDictionary *)results {
    [self hideSignupIsHappening];
    [self showSignupError:results];
}

- (void) storeLoginData {
    [JNKeychain saveValue:@{@"username": self.emailInput.text,
                            @"password": self.passwordInput.text,
                            @"notesDb": self.notesDb}
                   forKey:KEYCHAIN_KEY];
}

# pragma mark - Getters

- (SignerUpper *) signerUpper {
    if (!_signerUpper) _signerUpper = [[SignerUpper alloc] init];
    return _signerUpper;
}

@end
