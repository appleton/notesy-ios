//
//  LoggerInner.m
//  Notesy
//
//  Created by Andy Appleton on 15/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "LoggerInner.h"
#import "Constants.h"
#import "FormattingHelpers.h"
#import "NSMutableURLRequest+BasicAuth.h"

@interface LoggerInner()
@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (copy) void (^success) (NSDictionary *);
@property (copy) void (^error) (NSDictionary *);
@end

@implementation LoggerInner
- (void) logInUser:(NSString *)email password:(NSString *)password
              then:(void (^)(NSDictionary *results))success
             error:(void (^)(NSDictionary *results))error {
    self.success = success;
    self.error = error;

    NSString *url = [NSString stringWithFormat:@"%@%@_users/%@", PROTOCOL, COUCH_URL,
                     [FormattingHelpers encodedUserNameFromEmail:email]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:email andPassword:password];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

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
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                            options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                              error:nil];
    self.success(results);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.error(@{@"reason": @"Network error. Please try again!"});
}
@end
