//
//  Constants.m
//  Notesy
//
//  Created by Andy Appleton on 28/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "Constants.h"

#ifdef DEBUG
    NSString* const PROTOCOL = @"http://";
    NSString* const COUCH_URL = @"localhost:5984/";
    NSString* const APP_URL = @"localhost:1337/";
#else
    NSString* const PROTOCOL = @"https://";
    NSString* const COUCH_URL = @"db.notesy.co/";
    NSString* const APP_URL = @"app.notesy.co/";
#endif

NSString* const COUCH_USERNAME_PREFIX = @"org.couchdb.user:";

@implementation Constants
@end
