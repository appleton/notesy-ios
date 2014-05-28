//
//  MDKeyboardAccesoryView.m
//  Notesy
//
//  Created by Andy Appleton on 23/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "MDKeyboardAccessoryViewController.h"

@interface MDKeyboardAccessoryViewController()
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keys;
@end

@implementation MDKeyboardAccessoryViewController

- (void) initButtons {
    for (UIButton *key in self.keys) {
        key.clipsToBounds = YES;
        key.layer.cornerRadius = 3;
        [key addTarget:self
                action:@selector(keypress:)
      forControlEvents:UIControlEventTouchUpInside];
    }
}

// TODO: this should be smarter about inserting link brackets
- (void) keypress:(UIButton *)sender {
    [self.textView replaceRange:self.textView.selectedTextRange withText:sender.titleLabel.text];
}

@end
