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
#import "JNKeychain.h"

@interface LoginViewController()
@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSString *notesDb;

@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@end

@implementation LoginViewController

- (IBAction)loginButton:(UIButton *)sender {
    // Set errors and return if email or password is missing
    if ([self.emailInput.text length] == 0) [self showErrorFor:self.emailInput];
    if ([self.passwordInput.text length] == 0) [self showErrorFor:self.passwordInput];
    if ([self.emailInput.text length] == 0 || [self.passwordInput.text length] == 0) return;

    [self showLoginIsHappening];
    [self logInUser:self.emailInput.text password:self.passwordInput.text];
}

- (void) logInUser:(NSString *)email password:(NSString *)password {
    NSString *url = [NSString stringWithFormat:@"%@%@_users/%@", PROTOCOL, COUCH_URL,
                                               [self encodedUserNameFromEmail:email]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:email andPassword:password];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) showErrorFor:(UITextField *)field {
// TODO: make the field go red or something
}

- (void) showLoginIsHappening {
// TODO: use MBProgressHUD
}

- (void) showLoginError:(NSError *)error {
    NSLog(@"Login error: %@", error);
}

- (void) storeLoginData {
    [JNKeychain saveValue:@{@"username": self.emailInput.text,
                            @"password": self.passwordInput.text,
                            @"notesDb": self.notesDb}
                   forKey:KEYCHAIN_KEY];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // do not store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                            options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                              error:&error];
    if (error) NSLog(@"JSON parse error: %@", error);
    NSLog(@"JSON data: %@", results);

    self.notesDb = results[@"notes_db"];
    [self storeLoginData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showLoginError:error];
}

#pragma mark Formatting helpers

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

@end
