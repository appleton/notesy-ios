//
//  Note.h
//  Notesy
//
//  Created by Andy Appleton on 29/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "CouchbaseLite/CouchbaseLite.h"

@interface Note : CBLModel
+ (CBLDatabase *)dbInstanceFor:(NSString *)dbName;
+ (CBLQuery *) allIn:(CBLDatabase*)db;
+ (CBLQuery *) searchIn:(CBLDatabase *)db forText:(NSString *)text;

- (NSString *)trimmedTextAtLine:(int)line;
- (NSString *)formattedUpdatedAt;

@property (strong, nonatomic) NSString* text;
@property (nonatomic) long long createdAt;
@property (nonatomic) long long updatedAt;
@end
