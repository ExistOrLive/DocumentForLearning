# UITabBarItem

> An item in a tab bar

## Overview 
> tabbar严格执行单选模式，每次选择tabbaritem都会切换view。你也可以指定一个标记（badge）值来添加额外的可见信息。

```
@property(nullable, nonatomic,strong) UIImage *selectedImage NS_AVAILABLE_IOS(7_0);

@property(nullable, nonatomic, copy) NSString *badgeValue;    // default is nil


/**
 * 未选图片 由image参数生成；
 * 已选图片 由selectedImage参数生成
 * 为了防止系统渲染，将image设置为UIImageRenderingModeAlwaysOriginal
 **/
- (instancetype)initWithTitle:(nullable NSString *)title image:(nullable UIImage *)image tag:(NSInteger)tag;
- (instancetype)initWithTitle:(nullable NSString *)title image:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage NS_AVAILABLE_IOS(7_0);
- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag;

```

## 自定义外观 （Customzing Appearence）
> 在iOS 5 和之后的版本，你可以通过设置text attribute来定制tab bar的外观。
> 你可以使用UIBarItem的
`- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state`定制外观，也可以使用外观代理`[UITabBarItem appearance]`来实现定制

```
#include "UIBarItem.h"

/* You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in NSAttributedString.h.
 */
- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (nullable NSDictionary<NSString *,id> *)titleTextAttributesForState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

```
#include "NSAttributedString.h"

// Predefined character attributes for text. If the key is not present in the dictionary, it indicates the default value described below.
UIKIT_EXTERN NSAttributedStringKey const NSFontAttributeName NS_AVAILABLE(10_0, 6_0);                // UIFont, default Helvetica(Neue) 12
UIKIT_EXTERN NSAttributedStringKey const NSParagraphStyleAttributeName NS_AVAILABLE(10_0, 6_0);      // NSParagraphStyle, default defaultParagraphStyle
UIKIT_EXTERN NSAttributedStringKey const NSForegroundColorAttributeName NS_AVAILABLE(10_0, 6_0);     // UIColor, default blackColor
UIKIT_EXTERN NSAttributedStringKey const NSBackgroundColorAttributeName NS_AVAILABLE(10_0, 6_0);     // UIColor, default nil: no background
UIKIT_EXTERN NSAttributedStringKey const NSLigatureAttributeName NS_AVAILABLE(10_0, 6_0);            // NSNumber containing integer, default 1: default ligatures, 0: no ligatures
UIKIT_EXTERN NSAttributedStringKey const NSKernAttributeName NS_AVAILABLE(10_0, 6_0);                // NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
UIKIT_EXTERN NSAttributedStringKey const NSStrikethroughStyleAttributeName NS_AVAILABLE(10_0, 6_0);  // NSNumber containing integer, default 0: no strikethrough
UIKIT_EXTERN NSAttributedStringKey const NSUnderlineStyleAttributeName NS_AVAILABLE(10_0, 6_0);      // NSNumber containing integer, default 0: no underline
UIKIT_EXTERN NSAttributedStringKey const NSStrokeColorAttributeName NS_AVAILABLE(10_0, 6_0);         // UIColor, default nil: same as foreground color
UIKIT_EXTERN NSAttributedStringKey const NSStrokeWidthAttributeName NS_AVAILABLE(10_0, 6_0);         // NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
UIKIT_EXTERN NSAttributedStringKey const NSShadowAttributeName NS_AVAILABLE(10_0, 6_0);              // NSShadow, default nil: no shadow
UIKIT_EXTERN NSAttributedStringKey const NSTextEffectAttributeName NS_AVAILABLE(10_10, 7_0);          // NSString, default nil: no text effect

UIKIT_EXTERN NSAttributedStringKey const NSAttachmentAttributeName NS_AVAILABLE(10_0, 7_0);          // NSTextAttachment, default nil
UIKIT_EXTERN NSAttributedStringKey const NSLinkAttributeName NS_AVAILABLE(10_0, 7_0);                // NSURL (preferred) or NSString
UIKIT_EXTERN NSAttributedStringKey const NSBaselineOffsetAttributeName NS_AVAILABLE(10_0, 7_0);      // NSNumber containing floating point value, in points; offset from baseline, default 0
UIKIT_EXTERN NSAttributedStringKey const NSUnderlineColorAttributeName NS_AVAILABLE(10_0, 7_0);      // UIColor, default nil: same as foreground color
UIKIT_EXTERN NSAttributedStringKey const NSStrikethroughColorAttributeName NS_AVAILABLE(10_0, 7_0);  // UIColor, default nil: same as foreground color
UIKIT_EXTERN NSAttributedStringKey const NSObliquenessAttributeName NS_AVAILABLE(10_0, 7_0);         // NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
UIKIT_EXTERN NSAttributedStringKey const NSExpansionAttributeName NS_AVAILABLE(10_0, 7_0);           // NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion

UIKIT_EXTERN NSAttributedStringKey const NSWritingDirectionAttributeName NS_AVAILABLE(10_6, 7_0);    // NSArray of NSNumbers representing the nested levels of writing direction overrides as defined by Unicode LRE, RLE, LRO, and RLO characters.  The control characters can be obtained by masking NSWritingDirection and NSWritingDirectionFormatType values.  LRE: NSWritingDirectionLeftToRight|NSWritingDirectionEmbedding, RLE: NSWritingDirectionRightToLeft|NSWritingDirectionEmbedding, LRO: NSWritingDirectionLeftToRight|NSWritingDirectionOverride, RLO: NSWritingDirectionRightToLeft|NSWritingDirectionOverride,

UIKIT_EXTERN NSAttributedStringKey const NSVerticalGlyphFormAttributeName NS_AVAILABLE(10_7, 6_0);   // An NSNumber containing an integer value.  0 means horizontal text.  1 indicates vertical text.  If not specified, it could follow higher-level vertical orientation settings.  Currently on iOS, it's always horizontal.  The behavior for any other value is undefined.

```

### Example

```



```

