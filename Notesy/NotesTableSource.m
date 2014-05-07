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
@end
