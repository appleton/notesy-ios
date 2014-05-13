//
//  MarkdownTextStorage.h
//  Notesy
//
//  Created by Andy Appleton on 12/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkdownTextStorage : NSTextStorage
- (NSString *)string;
- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;
@end
