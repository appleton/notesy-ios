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
@property (strong, nonatomic) NSDictionary *startWrapMap;
@property (strong, nonatomic) NSDictionary *endWrapMap;
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

- (void) initSwipes {
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                                   action:@selector(moveCursorLeft)];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                                    action:@selector(moveCursorRight)];

    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;

    [self.textView addGestureRecognizer:leftSwipe];
    [self.textView addGestureRecognizer:rightSwipe];
}

- (void) moveCursorLeft {
    NSRange selected = self.textView.selectedRange;
    if (selected.location > 0) self.textView.selectedRange = NSMakeRange(selected.location - 1, 0);
}

- (void) moveCursorRight {
    NSRange selected = self.textView.selectedRange;
    int length = self.textView.text.length;
    if (selected.location < length) self.textView.selectedRange = NSMakeRange(selected.location + 1, 0);
}

- (void) keypress:(UIButton *)sender {
    NSString *keyValue = sender.titleLabel.text;

    // TODO: handle wrapping with a link
    if ([keyValue isEqualToString:@"[ ]()"]) {
        [self handleLinkKey];
        return;
    }

    if ([self keyCanWrapSelection:keyValue] && self.textView.selectedRange.length > 0) {
        NSString *wrappedText = [NSString stringWithFormat:@"%@%@%@",
                                                           self.startWrapMap[keyValue],
                                                           [self.textView.text substringWithRange:self.textView.selectedRange],
                                                           self.endWrapMap[keyValue]];
        [self.textView replaceRange:self.textView.selectedTextRange withText:wrappedText];
        return;
    }

    [self.textView replaceRange:self.textView.selectedTextRange withText:keyValue];
}

- (void) handleLinkKey {
    NSString *pbContents = [UIPasteboard generalPasteboard].string;

    if (![self isALink:pbContents]) {
        [self insertLinkWithContents:@""];
        return;
    }

    [[[UIAlertView alloc] initWithTitle:pbContents
                                message:@"Link detected on your clipboard. Would you like to insert it now?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}

- (void) insertLinkWithContents:(NSString *)contents {
    NSRange selected = self.textView.selectedRange;

    [self.textView replaceRange:self.textView.selectedTextRange
                       withText:[NSString stringWithFormat:@"[](%@)", contents]];
    self.textView.selectedRange = NSMakeRange(selected.location + 1, 0);
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *contents = @"";
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        contents = [UIPasteboard generalPasteboard].string;
    }
    [self insertLinkWithContents:contents];
}

- (BOOL) isALink:(NSString *)str {
    return [str hasPrefix:@"http://"] || [str hasPrefix:@"https://"];
}

- (BOOL) keyCanWrapSelection:(NSString *)key {
    return [key isEqualToString:@"["] || [key isEqualToString:@"]"] ||
           [key isEqualToString:@"("] || [key isEqualToString:@")"] ||
           [key isEqualToString:@"*"];
}

# pragma mark - Setters

- (void) setTextView:(UITextView *)textView {
    _textView = textView;
    [self initSwipes];
}

# pragma mark - Getters

- (NSDictionary *) startWrapMap {
    if (!_startWrapMap) {
        _startWrapMap = @{@"[": @"[",
                          @"]": @"[",
                          @"(": @"(",
                          @")": @"(",
                          @"*": @"*"};
    }
    return _startWrapMap;
}

- (NSDictionary *) endWrapMap {
    if (!_endWrapMap) {
        _endWrapMap = @{@"[": @"]",
                        @"]": @"]",
                        @"(": @")",
                        @")": @")",
                        @"*": @"*"};
    }
    return _endWrapMap;
}

@end
