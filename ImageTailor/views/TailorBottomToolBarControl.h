//
//  TailorBottomToolBarControl.h
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TailorBottomToolBarControl;

@protocol TailorBottomToolBarControlDelegate <NSObject>

- (void) toolBarControl:(TailorBottomToolBarControl *)toolBarControl actionClip:(TailorToolActionClipState)clipState;

@end

@interface TailorBottomToolBarControl : UIControl

@property (nonatomic, weak) id<TailorBottomToolBarControlDelegate> delegate;
- (void) setActionClip:(TailorToolActionClipState)clipState;

@end
