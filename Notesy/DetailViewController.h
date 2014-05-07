//
//  DetailViewController.h
//  Notesy
//
//  Created by Andy Appleton on 10/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) Note* note;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
