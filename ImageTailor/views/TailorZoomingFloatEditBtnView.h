//
//  TailorZoomingFloatEditBtnView.h
//  ImageTailor
//
//  Created by dl on 2018/5/1.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TailorZoomingFloatEditBtnView;
@protocol TailorZoomingFloatEditBtnViewDelegate <NSObject>
- (void) floatEditBtnView:(TailorZoomingFloatEditBtnView *)floatEditBtnView isEditing:(BOOL)isEditing;
@end

@interface TailorZoomingFloatEditBtnView : UIView

@property (nonatomic, weak) id<TailorZoomingFloatEditBtnViewDelegate> delegate;
@property (nonatomic, assign, getter=isEditing) BOOL editing;
@property (nonatomic, assign, readonly) TailorZommingFloatEditAlignment alignment;

- (instancetype) initWithAlignment:(TailorZommingFloatEditAlignment)alignment;

- (void) reset;

@end
