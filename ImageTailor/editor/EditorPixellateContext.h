//
//  EditorPixellateContext.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TailorAssetModel.h"

@interface EditorPixellateContext : NSObject

@property (nonatomic, weak) UIView *imageContainerView;
@property (nonatomic, assign) TailorTileDirection tileDirection;

@property (nonatomic, assign, readonly) ScrawlToolBarPixellateType pixellateType;

- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType
                      assetModels:(NSArray<TailorAssetModel *> *)assetModels;
- (void) endDoPixellate;
- (void) pixellateWithdraw;
- (void) clearCache;

- (void) touchBeginWithTouch:(UITouch *)touch imagesUnionRect:(CGRect)unionRect zoomScale:(CGFloat)zoomScale;
- (void) touchMovedWithTouch:(UITouch *)touch;
- (void) touchEndedWithTouch:(UITouch *)touch;

@end
