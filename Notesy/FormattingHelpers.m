//
//  URLHelpers.m
//  Notesy
//
//  Created by Andy Appleton on 02/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "FormattingHelpers.h"
#import "Constants.h"

@implementation FormattingHelpers
// Source http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
+ (NSString *) urlEncode:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

+ (NSString *) userNameFromEmail:(NSString *)email {
    return [COUCH_USERNAME_PREFIX stringByAppendingString:email];
}

+ (NSString *) encodedUserNameFromEmail:(NSString *)email {
    return [FormattingHelpers urlEncode:[self userNameFromEmail:email]];
}

@end
