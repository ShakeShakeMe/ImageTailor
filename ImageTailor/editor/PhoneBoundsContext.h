//
//  PhoneBoundsContext.h
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneBoundsContext : NSObject

@property (nonatomic, strong, readonly) UIImageView *phoneBoundsImageView;
@property (nonatomic, weak) UIView *imageContainerView;
@property (nonatomic, assign) CGRect imageViewsUnionRect;

- (void) showWithPhoneBoundsType:(EditorToolBarPhoneBoundsType)phoneBoundsType;
- (void) hide;

@end
