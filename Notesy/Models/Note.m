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

+ (CBLDatabase *)dbInstanceFor:(NSString *)dbName {
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    CBLDatabase *database = [manager databaseNamed:dbName error: &error];

    if (error) {
        NSLog(@"error getting database %@", error);
        exit(-1);
    }

    return database;
}

+ (CBLQuery*) allIn:(CBLDatabase*)db {
    CBLView* view = [db viewNamed: @"notesByDate"];

    if (!view.mapBlock) {
        // On first query after launch, register the map function:
        [view setMapBlock: MAPBLOCK({
            NSString* date = doc[@"updatedAt"];
            emit(@[date], doc);
        }) reduceBlock: nil version: @"2"]; // bump version any time you change the MAPBLOCK body!
    }

    CBLQuery* query = [view createQuery];
    query.descending = YES;

    return query;
}

+ (CBLQuery*) findIn:(CBLDatabase*)db byId:(NSString *)noteId {
    return [db createAllDocumentsQuery];
}

- (NSTimeInterval)autosaveDelay {
    return 0.5;
}

- (BOOL) save:(NSError **)error {
    long long now = [[[NSDate alloc] init] timeIntervalSince1970] * 1000;

    self.updatedAt = now;
    if (!self.createdAt) self.createdAt = now;
    if (!self.text) self.text = @"";

    return [super save:error];
}

- (NSString *)trimmedTextAtLine:(int)line {
    NSArray *lines = [self.text componentsSeparatedByString:@"\n"];
    lines = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];

    if ([lines count] < line + 1) return nil;

    return [[lines objectAtIndex:line]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - Presenters

- (NSString *)formattedUpdatedAt {
    // TODO: match Mail.app for date formatting
    long long secondsFromEpoch = self.updatedAt / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsFromEpoch];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:date];
}

@end
