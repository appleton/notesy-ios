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
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation SignupViewController

- (void) viewDidAppear:(BOOL)animated {
    [self.emailInput becomeFirstResponder];
    [self.emailInput addTarget:self action:@selector(hideSignupError) forControlEvents:UIControlEventEditingChanged];
    [self.passwordInput addTarget:self action:@selector(hideSignupError) forControlEvents:UIControlEventEditingChanged];
}

- (IBAction)signupButton:(id)sender {
    [self hideSignupError];

    if ([self.emailInput.text length] == 0 || [self.passwordInput.text length] == 0) {
        [self showSignupError:@{@"errors": @[@{@"param": @"Email and password", @"msg": @"are required"}]}];
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
    self.signupButton.enabled = NO;
    [self.signupButton setTitle:[self formatErrors:response[@"errors"]] forState:UIControlStateNormal];
    self.signupButton.backgroundColor = [UIColor colorWithRed:222/255.0f green:65/255.0f blue:47/255.0f alpha:1.0f];
}

- (void) hideSignupError {
    self.signupButton.enabled = YES;
    [self.signupButton setTitle:@"Sign up" forState:UIControlStateNormal];
    self.signupButton.backgroundColor = [UIColor colorWithRed:43/255.0f green:184/255.0f blue:158/255.0f alpha:1.0f];
}

- (void) showNetworkError:(NSDictionary *)response {
    self.signupButton.enabled = YES;
    [self.signupButton setTitle:[self formatErrors:response[@"errors"]] forState:UIControlStateNormal];
    self.signupButton.backgroundColor = [UIColor colorWithRed:43/255.0f green:184/255.0f blue:158/255.0f alpha:1.0f];
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
    [self showNetworkError:results];
}

- (void) storeLoginData {
    [JNKeychain saveValue:@{@"username": self.emailInput.text,
                            @"password": self.passwordInput.text,
                            @"notesDb": self.notesDb}
                   forKey:KEYCHAIN_KEY];
}

# pragma mark - Helpers

- (NSString *) formatErrors:(NSArray *)errors {
    NSMutableArray *errorMsgStrings = [[NSMutableArray alloc] init];
    for (NSDictionary *error in errors) {
        [errorMsgStrings addObject:[NSString stringWithFormat:@"%@ %@", error[@"param"], error[@"msg"]]];
    }

    NSString *message = [errorMsgStrings componentsJoinedByString:@" "];
    message = [message stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                               withString:[[message substringToIndex:1] capitalizedString]];
    return message;
}

# pragma mark - Getters

- (SignerUpper *) signerUpper {
    if (!_signerUpper) _signerUpper = [[SignerUpper alloc] init];
    return _signerUpper;
}

@end
