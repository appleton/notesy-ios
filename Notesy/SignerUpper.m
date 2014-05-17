//
//  SignerUpper.m
//  Notesy
//
//  Created by Andy Appleton on 16/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "SignerUpper.h"
#import "Constants.h"
#import "FormattingHelpers.h"

@interface SignerUpper()
@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (copy) void (^success) (NSDictionary *);
@property (copy) void (^error) (NSDictionary *);
@end

@implementation SignerUpper
- (void) signUpUser:(NSString *)email
           password:(NSString *)password
               then:(void (^)(NSDictionary *results))success
              error:(void (^)(NSDictionary *results))error {
    self.success = success;
    self.error = error;

    NSString *url = [NSString stringWithFormat:@"%@%@users", PROTOCOL, APP_URL];
    NSDictionary *postBody = @{@"email": email, @"password": password};

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postBody
                                                       options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                         error:nil];

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
    self.error(@{@"errors": @[@{@"param": @"Network error.", @"msg": @"Would you like to retry?"}]});
}

@end
