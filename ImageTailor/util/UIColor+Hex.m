//
//  UIColor+Hex.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+(UIColor *)hex_colorWithStringHex:(NSString *)hexColor
{
    NSString *colorStr = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([colorStr length] < 6 || [colorStr length] > 9) {
        return [UIColor clearColor];
    }
    if ([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }
    unsigned int hex;
    [[NSScanner scannerWithString:colorStr] scanHexInt:&hex];
    return [self hex_colorWithHex:hex];
}

+(UIColor *)hex_colorWithStringHex:(NSString *)hexColor alpha:(float)alpha
{
    //删除空格
    NSString *colorStr = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 7 characters
    if ([colorStr length] < 6 || [colorStr length] > 7) {
        return [UIColor clearColor];
    }
    //
    if ([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }
    
    // Scan values
    unsigned int hex;
    [[NSScanner scannerWithString:colorStr] scanHexInt:&hex];
    return [self hex_colorWithHex:hex alpha:alpha];
}

+ (UIColor *)hex_colorWithHex:(NSUInteger)hex {
    CGFloat preAlpha = ((float)((hex & 0xFF000000) >> 24))/255.0f;
    CGFloat alpha = preAlpha > 0 ? preAlpha : 1;
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:alpha];
}


+ (UIColor *)hex_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)hex_randomColor {
    return [UIColor hex_randomColorWithAlpha:1.f];
}

+ (UIColor *)hex_randomColorWithAlpha:(float)alpha {
    return [UIColor colorWithRed:(arc4random() % 255)/255.0
                           green:(arc4random() % 255)/255.0
                            blue:(arc4random() % 255)/255.0
                           alpha:alpha];
}

@end
