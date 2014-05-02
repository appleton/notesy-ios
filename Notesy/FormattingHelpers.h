//
//  URLHelpers.h
//  Notesy
//
//  Created by Andy Appleton on 02/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormattingHelpers : NSObject
+ (NSString *) urlEncode:(NSString *)string;
+ (NSString *) userNameFromEmail:(NSString *)email;
+ (NSString *) encodedUserNameFromEmail:(NSString *)email;
@end
