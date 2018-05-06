//
//  ImagePickerBottomToolBarView.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImagePickerBottomToolBarView;

@protocol ImagePickerBottomToolBarViewDelegate <NSObject>
- (void) didClickClear:(ImagePickerBottomToolBarView *)toolBarView;
- (void) didClickClip:(ImagePickerBottomToolBarView *)toolBarView;
- (void) didClickSpliceHorizontally:(ImagePickerBottomToolBarView *)toolBarView;
- (void) didClickSpliceVertically:(ImagePickerBottomToolBarView *)toolBarView;
@end

@interface ImagePickerBottomToolBarView : UIView

@property (nonatomic, weak) id<ImagePickerBottomToolBarViewDelegate> delegate;

- (void) show:(BOOL)show onlyClip:(BOOL)onlyClip;

@end
