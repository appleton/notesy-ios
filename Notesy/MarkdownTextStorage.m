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
@property (nonatomic,strong) NSDictionary *defaultAttributes;
@property (nonatomic,strong) UIFont *bodyFont;
@property (nonatomic,strong) UIFont *boldFont;
@property (nonatomic,strong) UIColor *bodyColour;
@property (nonatomic,strong) UIColor *lightColour;
@property (nonatomic,strong) NSMutableParagraphStyle *bodyIndent;
@property (nonatomic,strong) NSMutableParagraphStyle *firstLineOutdent;
@end

@implementation MarkdownTextStorage {
    NSMutableAttributedString *_imp;

}

- (instancetype) initWithString:(NSString *)str {
    self = [super init];
    if (self) {
        _attributedString = [[NSMutableAttributedString alloc] initWithString:str
                                                                   attributes:self.defaultAttributes];

        // Necessary hack. NSAttributedString will not immediately apply the indent when initialized
        // with an empty string, you have to add and then delete a character in (I think) different
        // run loop cycles. This adds a space, which is then removed at the end of
        // - [DetailViewController initTextField].
        if ([str isEqualToString:@""]) {
            NSAttributedString *throwaway = [[NSMutableAttributedString alloc] initWithString:@" "
                                                                                   attributes:self.defaultAttributes];
            [self.attributedString appendAttributedString:throwaway];
        }
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
    // Handy logging to see text being highlighted
    // NSLog(@"%@", [self.string substringWithRange:paragaphRange]);

    [self resetRange:paragaphRange];
    [self applyStylesToRange:paragaphRange];
}

- (void) resetRange:(NSRange)range {
    [self setAttributes:self.defaultAttributes range:range];
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
             [self addAttributes:attributes range:match.range];
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
        NSDictionary *boldAttributes = @{NSFontAttributeName: self.boldFont};
        NSDictionary *italicAttributes = @{NSFontAttributeName: self.bodyFont};
        NSDictionary *boldItalicAttributes = @{NSFontAttributeName: self.boldFont};
        NSDictionary *codeAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
        NSDictionary *headerAttributes = @{NSFontAttributeName: self.boldFont,
                                           NSParagraphStyleAttributeName: self.firstLineOutdent};
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: self.lightColour};
        NSDictionary *linkTextAttributes = @{NSForegroundColorAttributeName: self.bodyColour};
        NSDictionary *listAttributes = @{NSParagraphStyleAttributeName: self.firstLineOutdent};
        // NSDictionary *gutterAttributes = @{NSForegroundColorAttributeName: self.lightColour};

        _attributeDictionary = @{
            @"(^#+.*)": headerAttributes,
            @"\\**(?:^|[^*])(\\*\\*(\\w+(\\s\\w+)*)\\*\\*)": boldAttributes,
            @"\\**(?:^|[^*])(\\*(\\w+(\\s\\w+)*)\\*)": italicAttributes,
            @"(\\*\\*\\*\\w+(\\s\\w+)*\\*\\*\\*)": boldItalicAttributes,
            @"(`\\w+(\\s\\w+)*`)": codeAttributes,
            @"(```\n([\\s\n\\d\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/]]*)\n```)": codeAttributes,
            @"(\\[\\w+(\\s\\w+)*\\]\\(\\w+\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/ \\w+]*\\))": linkAttributes,
            @"(?<=\\[)(.*?)(?=\\]\\()": linkTextAttributes,
            @"([0-9]|\\*\\s|\\-\\s|\\+\\s)(.*)": listAttributes,
            // TODO: do I want gutter contents to be lighter?
            // @"(^#\\s)": gutterAttributes,
            // @"(^[0-9]\\s|^\\*\\s|\\-\\s|\\+\\s)": gutterAttributes,
        };
    }
    return _attributeDictionary;
}

- (NSDictionary *) defaultAttributes {
    if (!_defaultAttributes) {
        _defaultAttributes = @{NSFontAttributeName: self.bodyFont,
                               NSForegroundColorAttributeName: self.bodyColour,
                               NSParagraphStyleAttributeName: self.bodyIndent};
    }
    return _defaultAttributes;
}

- (UIFont *) bodyFont {
    if (!_bodyFont) {
        _bodyFont = [UIFont fontWithName:@"SourceCodePro-Regular" size:16];
    }
    return _bodyFont;
}

- (UIFont *) boldFont {
    if (!_boldFont) {
        _boldFont = [UIFont fontWithName:@"SourceCodePro-Semibold" size:16];
    }
    return _boldFont;
}

- (UIColor *) bodyColour {
    if (!_bodyColour) {
        _bodyColour = [UIColor blackColor];
    }
    return _bodyColour;
}

- (UIColor *) lightColour {
    if (!_lightColour) {
        _lightColour = [UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0f];
    }
    return _lightColour;
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
