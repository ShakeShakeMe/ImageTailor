//
//  ScrawlZoomingScollView.h
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TailorAssetModel.h"

@interface ScrawlZoomingScollView : UIScrollView

@property (nonatomic, assign, readonly) TailorTileDirection tileDirection;
@property (nonatomic, strong, readonly) NSArray<TailorAssetModel *> *assetModels;

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection
               defaultZoomScale:(CGFloat) zoomScale
           defaultContentOffset:(CGPoint)contentOffset;

- (void) viewDidAppear;

- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType;
- (void) endDoPixllate;
- (void) pixellateWithdraw;

- (void) saveToPhoto;

@end
