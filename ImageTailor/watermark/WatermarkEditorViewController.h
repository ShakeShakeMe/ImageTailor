//
//  WatermarkEditorViewController.h
//  ImageTailor
//
//  Created by dl on 2018/5/18.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol WatermarkEditorViewControllerDelegate <NSObject>
- (void) didChangeWatermarkText:(NSString *)text prefixType:(EditorWatermarkPrefixType)prefixType;
@end

@interface WatermarkEditorViewController : BaseViewController

@property (nonatomic, weak) id<WatermarkEditorViewControllerDelegate> delegate;
@property (nonatomic, assign) EditorWatermarkPrefixType prefixType;
@property (nonatomic, copy) NSString *text;

@end
