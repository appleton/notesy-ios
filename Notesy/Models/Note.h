//
//  Note.h
//  Notesy
//
//  Created by Andy Appleton on 29/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "CouchbaseLite.h"

@interface Note : CBLModel
+ (CBLQuery*) allIn:(CBLDatabase*)db;
+ (CBLQuery*) findIn:(CBLDatabase*)db byId:(NSString *)noteId;

- (NSString *)trimmedTextAtLine:(int)line;
- (NSString *)formattedUpdatedAt;

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* createdAt;
@property (strong, nonatomic) NSString* updatedAt;
@end