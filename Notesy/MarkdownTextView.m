//
//  MarkdownTextView.m
//  Notesy
//
//  Created by Andy Appleton on 15/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "MarkdownTextView.h"
#import "MarkdownTextStorage.h"

@implementation MarkdownTextView {
    NSString *_initialString;
    NSLayoutManager *_layoutManager;
    NSTextStorage *_textStorage;
    NSTextContainer *_textContainer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    // TODO: how to make this work with no frame?!
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568) textContainer:self.textContainer];

    return self;
}

#pragma mark - Getters

- (NSTextStorage *) textStorage {
    if (!_textStorage) _textStorage = [[MarkdownTextStorage alloc] initWithString:@""];
    return _textStorage;
}

- (NSLayoutManager *) layoutManager {
    if (!_layoutManager) {
        _layoutManager = [NSLayoutManager new];
        [self.textStorage addLayoutManager:_layoutManager];
    }
    return _layoutManager;
}

- (NSTextContainer *) textContainer {
    if (!_textContainer) {
        _textContainer = [NSTextContainer new];
        [self.layoutManager addTextContainer:_textContainer];
    }
    return _textContainer;
}

@end
