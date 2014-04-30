//
//  Note.m
//  Notesy
//
//  Created by Andy Appleton on 29/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "Note.h"

@implementation Note
@dynamic text, createdAt, updatedAt;

+ (CBLQuery*) allIn:(CBLDatabase*)db {
    return [db createAllDocumentsQuery];
}

+ (CBLQuery*) findIn:(CBLDatabase*)db byId:(NSString *)noteId {
    return [db createAllDocumentsQuery];
}

- (instancetype) initWithNewDocumentInDatabase:(CBLDatabase *)database {
    self = [super initWithNewDocumentInDatabase:database];
    if (self) {
        self.text = @"";
        self.createdAt = [NSDate date];
        self.updatedAt = [NSDate date];
    }
    return self;
}
@end
