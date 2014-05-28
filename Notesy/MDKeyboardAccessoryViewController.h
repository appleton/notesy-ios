//
//  MDKeyboardAccesoryView.h
//  Notesy
//
//  Created by Andy Appleton on 23/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMDKeypressNotification @"MDKeypress"

@interface MDKeyboardAccessoryViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) UITextView *textView;
- (void) initButtons;
@end
