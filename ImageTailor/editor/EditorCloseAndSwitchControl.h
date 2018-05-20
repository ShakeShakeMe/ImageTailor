//
//  EditorCloseAndSwitchControl.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditorCloseAndSwitchControlDelegate <NSObject>
- (void) editorClose;
- (void) editorSwitchToState:(BOOL)normalState;
@end

@interface EditorCloseAndSwitchControl : UIControl

@property (nonatomic, weak) id<EditorCloseAndSwitchControlDelegate> delegate;

@end
