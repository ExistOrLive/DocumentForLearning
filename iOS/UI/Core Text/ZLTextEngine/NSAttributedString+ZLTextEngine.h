//
//  NSMutableAttributedString+ZLTextEngine.h
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/3/5.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (ZLTextEngine)

- (CGSize) boundingRectWithWidth:(CGFloat) width;

@end


@interface NSMutableAttributedString (ZLTextEngine)

- (void) checkUrlWithAttributedString:(NSDictionary *) attributes;


+ (NSMutableAttributedString *) attributedStringWithText:(NSString *) textString
                                                    font:(UIFont *) font
                                     textForegroundColor:(UIColor *) foregroundColor
                                          paragraphStyle:(NSParagraphStyle *) paragraphStyle
                                         otherAttributes:(NSDictionary *) attributes;

@end
