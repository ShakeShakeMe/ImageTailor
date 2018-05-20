//
//  EditorBottomToolbarControl.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EditorToolbarBtnType){
    EditorToolbarBtnTypeClipNormal = 0,
    EditorToolbarBtnTypeClipBounds,
    EditorToolbarBtnTypeToolPixellate,
    EditorToolbarBtnTypeToolSpaceline,
    EditorToolbarBtnTypeToolWatermark,
    EditorToolbarBtnTypeToolPhoneBounds
};

@class EditorBottomToolbarControl;
@protocol EditorBottomToolbarControlDelegate <NSObject>
- (void) toolbarControl:(EditorBottomToolbarControl *)toolbarControl
               clickBtn:(EditorToolbarBtnType)btnType
               selected:(BOOL)selected;
@end

@interface EditorBottomToolbarControl : UIControl

@property (nonatomic, weak) id<EditorBottomToolbarControlDelegate> delegate;
- (void) switchToClip;
- (void) switchToTool;
- (void) selectBtnType:(EditorToolbarBtnType)btnType selected:(BOOL)selected;

@end

@protocol EditorBottomToolbarFloatViewDelegate <NSObject>
- (void) pixellateWithType:(ScrawlToolBarPixellateType)pixellateType;
- (void) pixellateWithdraw;

- (void) spacelineWithType:(EditorToolBarSpacelineType)spacelineType;
- (void) watermarkWithType:(EditorToolBarWatermarkType)watermarkType;
- (void) watermarkEditWord;
- (void) phoneBoundsWithType:(EditorToolBarPhoneBoundsType)phoneBoundsType;
@end

@interface EditorBottomToolbarPixellateFloatView : UIView
@property (nonatomic, weak) id<EditorBottomToolbarFloatViewDelegate> delegate;
- (void) reset;
@end

@interface EditorBottomToolbarSpacelineFloatView : UIView
@property (nonatomic, weak) id<EditorBottomToolbarFloatViewDelegate> delegate;
- (void) reset;
@end

@interface EditorBottomToolbarWatermarkFloatView : UIView
@property (nonatomic, weak) id<EditorBottomToolbarFloatViewDelegate> delegate;
- (void) reset;
@end

@interface EditorBottomToolbarPhoneBoundsFLoatView : UIView
@property (nonatomic, weak) id<EditorBottomToolbarFloatViewDelegate> delegate;
- (void) reset;
@end
