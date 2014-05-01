//
//  Note.m
//  Notesy
//
//  Created by Andy Appleton on 29/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "Note.h"

@implementation Note
//@synthesize createdAt = _createdAt;
//@synthesize updatedAt = _updatedAt;
@dynamic text, createdAt, updatedAt;

+ (CBLQuery*) allIn:(CBLDatabase*)db {
    CBLView* view = [db viewNamed: @"notesByDate"];

    if (!view.mapBlock) {
        // On first query after launch, register the map function:
        [view setMapBlock: MAPBLOCK({
            NSString* date = doc[@"createdAt"];
            emit(@[date], doc);
        }) reduceBlock: nil version: @"1"]; // bump version any time you change the MAPBLOCK body!
    }

    CBLQuery* query = [view createQuery];
    query.descending = YES;

    return query;
}

+ (CBLQuery*) findIn:(CBLDatabase*)db byId:(NSString *)noteId {
    return [db createAllDocumentsQuery];
}

- (instancetype) initWithNewDocumentInDatabase:(CBLDatabase *)database {
    self = [super initWithNewDocumentInDatabase:database];
    if (self) {
        self.text = @"";
        // TODO: all data needs to be converted to ISO date strings
        // self.createdAt = [NSDate date];
        // self.updatedAt = [NSDate date];
    }
    return self;
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
    // TODO: refactor when data is in ISO date strings
    // TODO: match Mail.app for date formatting
    long long secondsFromEpoch = [self.updatedAt longLongValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsFromEpoch];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:date];
}

@end
