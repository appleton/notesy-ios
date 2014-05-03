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
    cell.titleLabel.text = [note trimmedTextAtLine:0];
    cell.subtitleLabel.text = [note trimmedTextAtLine:1];
    cell.timeLabel.text = [note formattedUpdatedAt];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //        Note *note = self.notes[indexPath.row];
        self.detailViewController.note = nil;
    }
}
@end
