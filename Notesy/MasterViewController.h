//
//  MasterViewController.h
//  Notesy
//
//  Created by Andy Appleton on 10/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate, UITextFieldDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) DetailViewController *detailViewController;

- (void)logout;
@end
