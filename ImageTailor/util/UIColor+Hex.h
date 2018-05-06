//
//  UIColor+Hex.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 * 支持从HEX值扩展获取alpha + color
 * 如0xFF00FF00 等于 0x00FF00 的色值加上  0xFF/255.0f 的alpha
 *
 * @param hex hex值
 */

+ (UIColor *)hex_colorWithHex:(NSUInteger)hex;

/**
 * 功能同 +hb_colorWithExtendHex:
 *
 * @param  hexColor 颜色值字符串 如"#FF00FF00"
 */
+ (UIColor *)hex_colorWithStringHex:(NSString *)hexColor;

/**
 * 从HEX值获取颜色值
 *
 * @param hex     颜色值，如 0xFFFFF
 * @param alpha   透明度
 */
+ (UIColor *)hex_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

/**
 * 从HEX 字符串获取颜色值
 *
 * @param hexColor  颜色值 如 @"#00FF00"
 * @param alpha     透明度
 */
+ (UIColor *)hex_colorWithStringHex:(NSString *)hexColor alpha:(float)alpha;

+ (UIColor *)hex_randomColor;
+ (UIColor *)hex_randomColorWithAlpha:(float)alpha;

@end
