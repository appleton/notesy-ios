//
//  NotesTableSource.m
//  Notesy
//
//  Created by Andy Appleton on 03/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "NotesTableSource.h"
#import "NoteTableViewCell.h"
#import "Note.h"
#import "NoDataView.h"

@interface NotesTableSource()
@property (nonatomic) BOOL isSearching;
@end

@implementation NotesTableSource

static NSString* CellIdentifier = @"CellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                              forIndexPath:indexPath];

    Note *note = [Note modelForDocument:[self documentAtIndexPath:indexPath]];
    NSString *text = [note trimmedTextAtLine:0];
    cell.titleLabel.text = [text length] > 0 ? text : @"untitled";
    cell.subtitleLabel.text = [note trimmedTextAtLine:1];
    cell.timeLabel.text = [note formattedUpdatedAt];

    return cell;
}

- (void) couchTableSource:(CBLUITableSource *)source willUpdateFromQuery:(CBLLiveQuery *)query {
    [self.rows count] > 0 ? [self hideEmptyState] : [self showEmptyState];
}

- (void) showEmptyState {
    self.isSearching ? [self showEmptySearch] : [self showWelcome];
}

- (void) showWelcome {
    // TODO: maybe check if it's a welcome view?
    if (self.tableView.tableHeaderView) return;
    NoDataView *view = [[[NSBundle mainBundle] loadNibNamed:@"NoDataView"
                                                      owner:nil
                                                    options:nil] lastObject];
    view.frame = self.tableView.frame;
    self.tableView.tableHeaderView = view;
    self.tableView.scrollEnabled = NO;
}

- (void) showEmptySearch {
    // TODO: maybe check if it's an empty search view?
    if (self.tableView.tableHeaderView) return;
    NoDataView *view = [[[NSBundle mainBundle] loadNibNamed:@"EmptySearchView"
                                                      owner:nil
                                                    options:nil] lastObject];
//    view.frame = self.tableView.frame;
    self.tableView.tableHeaderView = view;
    self.tableView.scrollEnabled = NO;
}

- (void) hideEmptyState {
    if (!self.tableView.tableHeaderView) return;
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
}

# pragma mark - Setters

- (void) setQuery:(CBLLiveQuery *)query {
    self.isSearching = query.fullTextQuery ? YES : NO;
    [super setQuery:query];
}

@end
