//
//  EditorWatermarkContext.h
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditorWatermarkContext : NSObject

@property (nonatomic, strong, readonly) UILabel *watermarkLabel;
@property (nonatomic, weak) UIView *imageContainerView;

// 水印
- (void) showWatermarkWithType:(EditorToolBarWatermarkType)watermarkType imagesUnionRect:(CGRect)unionRect text:(NSString *)text;
- (void) hideWatermark;

- (void) clear;

@end
