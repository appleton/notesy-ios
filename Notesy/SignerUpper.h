//
//  SignerUpper.h
//  Notesy
//
//  Created by Andy Appleton on 16/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignerUpper : NSObject
- (void) signUpUser:(NSString *)email
           password:(NSString *)password
               then:(void (^)(NSDictionary *results))success
              error:(void (^)(NSDictionary *results))error;
@end
