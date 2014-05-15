//
//  LoggerInner.h
//  Notesy
//
//  Created by Andy Appleton on 15/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggerInner : NSObject <NSURLConnectionDelegate>
- (void) logInUser:(NSString *)email password:(NSString *)password
              then:(void (^)(NSDictionary *results))success
             error:(void (^)(NSDictionary *results))error;
@end
