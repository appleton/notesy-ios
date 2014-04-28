//
//  LoginViewController.m
//  Notesy
//
//  Created by Andy Appleton on 28/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "NSMutableURLRequest+BasicAuth.h"

@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@end

@implementation LoginViewController
- (IBAction)loginButton:(UIButton *)sender {
    // Set errors and return if email or password is missing
    if (!self.emailInput.text) [self setErrorFor:self.emailInput];
    if (!self.passwordInput.text) [self setErrorFor:self.passwordInput];
    if (!self.emailInput.text || !self.passwordInput.text) return;

    [self setLoginIsHappening];

    NSString *email = self.emailInput.text;
    NSString *password = self.passwordInput.text;

    NSString *url = [NSString stringWithFormat:@"%@%@_users/%@",
                                                PROTOCOL,
                                                COUCH_URL,
                                                [self encodedUserNameFromEmail:email]];
    NSLog(@"%@", url);

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSMutableURLRequest basicAuthForRequest:req withUsername:email andPassword:password];
    NSURLResponse *res = nil;
    NSError *error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:req
                                          returningResponse:&res
                                                      error:&error];
    NSLog(@"error: %@", error);
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
    NSLog(@"%@", results);
}

- (NSString *) encodedUserNameFromEmail:(NSString *)email {
    return [self urlEncode:[COUCH_USERNAME_PREFIX stringByAppendingString:email]];
}

// Source http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
- (NSString *) urlEncode:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

- (void) setErrorFor:(UITextField *)field {
// TODO: make the field go red or something
}

- (void) setLoginIsHappening {
// TODO: disable the inputs
}

@end
