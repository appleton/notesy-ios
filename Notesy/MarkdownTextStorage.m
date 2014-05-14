//
//  MarkdownTextStorage.m
//  Notesy
//
//  Created by Andy Appleton on 12/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "MarkdownTextStorage.h"

@interface MarkdownTextStorage()
@property (nonatomic,strong) NSMutableAttributedString *attributedString;
@property (nonatomic,strong) NSDictionary *attributeDictionary;
@property (nonatomic,strong) UIFont *bodyFont;
@property (nonatomic,strong) UIColor *bodyColour;
@property (nonatomic,strong) NSMutableParagraphStyle *bodyIndent;
@property (nonatomic,strong) NSMutableParagraphStyle *firstLineOutdent;
@end

@implementation MarkdownTextStorage {
    NSMutableAttributedString *_imp;

}

- (instancetype) initWithString:(NSString *)str {
    self = [super init];
    if (self) {
        _attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [self resetRange:NSMakeRange(0, self.string.length)];
    }
    return self;
}

- (void) replaceCharactersInRange:(NSRange)range withString:(NSString*)str {
    [self beginEditing];

    [_attributedString replaceCharactersInRange:range withString:str];

    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void) setAttributes:(NSDictionary*)attrs range:(NSRange)range {
    [self beginEditing];

    [_attributedString setAttributes:attrs range:range];

    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

-(void) processEditing {
    [super processEditing];
    NSRange paragaphRange = [self.string paragraphRangeForRange:self.editedRange];
    NSLog(@"%@", [self.string substringWithRange:paragaphRange]);

    [self resetRange:paragaphRange];
    [self applyStylesToRange:paragaphRange];
}

- (void) resetRange:(NSRange)range {
    [self addAttribute:NSFontAttributeName value:self.bodyFont range:range];
    [self addAttribute:NSForegroundColorAttributeName value:self.bodyColour range:range];
    // TODO: this can't apply to an empty string, how to get around that on initial load?
    [self addAttribute:NSParagraphStyleAttributeName value:self.bodyIndent range:range];
}

- (void) applyStylesToRange:(NSRange)searchRange {
    for (NSString *key in self.attributeDictionary) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:0 error:nil];
        NSDictionary *attributes = self.attributeDictionary[key];

        [regex enumerateMatchesInString:[_attributedString string]
                                options:0
                                  range:searchRange
                             usingBlock:
         ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
             NSRange matchRange = [match rangeAtIndex:1];
             [self addAttributes:attributes range:matchRange];
        }];
    }
}

#pragma mark - Getters

- (NSString *) string {
    return [_attributedString string];
}

- (NSDictionary *) attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_attributedString attributesAtIndex:location effectiveRange:range];
}

- (NSDictionary *)attributeDictionary {
    if (!_attributeDictionary) {
        NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"SourceCodePro-Bold" size:17]};
        NSDictionary *italicAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"SourceCodePro-Regular" size:17]};
        NSDictionary *boldItalicAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"SourceCodePro-Bold" size:17]};
        NSDictionary *codeAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
        NSDictionary *headerAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"SourceCodePro-Bold" size:17],
                                           NSParagraphStyleAttributeName: self.firstLineOutdent};
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.255 green:0.514 blue:0.769 alpha:1.00]};
        NSDictionary *listAttributes = @{NSParagraphStyleAttributeName: self.firstLineOutdent};

        _attributeDictionary = @{
            @"(#+.*)": headerAttributes,
            @"\\**(?:^|[^*])(\\*\\*(\\w+(\\s\\w+)*)\\*\\*)": boldAttributes,
            @"\\**(?:^|[^*])(\\*(\\w+(\\s\\w+)*)\\*)": italicAttributes,
            @"(\\*\\*\\*\\w+(\\s\\w+)*\\*\\*\\*)": boldItalicAttributes,
            @"(`\\w+(\\s\\w+)*`)": codeAttributes,
            @"(```\n([\\s\n\\d\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/]]*)\n```)": codeAttributes,
            @"(\\[\\w+(\\s\\w+)*\\]\\(\\w+\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/ \\w+]*\\))": linkAttributes,
            @"(\\*|\\-|\\+\\s)(.*)": listAttributes
        };
    }
    return _attributeDictionary;
}

- (UIFont *) bodyFont {
    if (!_bodyFont) {
        _bodyFont = [UIFont fontWithName:@"SourceCodePro-Regular" size:17];
    }
    return _bodyFont;
}

- (UIColor *) bodyColour {
    if (!_bodyColour) {
        _bodyColour = [UIColor colorWithRed:0/255.0f green:4/255.0f blue:68/255.0f alpha:1.0f];
    }
    return _bodyColour;
}

- (NSMutableParagraphStyle *) bodyIndent {
    if (!_bodyIndent) {
        _bodyIndent = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        _bodyIndent.firstLineHeadIndent = 20.0;
        _bodyIndent.headIndent = 20.0;
    }
    return _bodyIndent;
}

- (NSMutableParagraphStyle *) firstLineOutdent {
    if (!_firstLineOutdent) {
        _firstLineOutdent = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        _firstLineOutdent.firstLineHeadIndent = 0.0;
        _firstLineOutdent.headIndent = 20.0;
    }
    return _firstLineOutdent;
}

@end
