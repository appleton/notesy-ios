//
//  NoteTableViewCell.m
//  Notesy
//
//  Created by Andy Appleton on 01/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "NoteTableViewCell.h"

@implementation NoteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    self.titleLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:17];
    self.subtitleLabel.font = [UIFont fontWithName:@"SourceSansPro-Light" size:14];
    self.timeLabel.font = [UIFont fontWithName:@"SourceSansPro-Light" size:14];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
