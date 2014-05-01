//
//  NoteTableViewCell.h
//  Notesy
//
//  Created by Andy Appleton on 01/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
