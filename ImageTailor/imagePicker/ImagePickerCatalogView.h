//
//  ImagePickerCatalogView.h
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAssetsService.h"

@protocol ImagePickerCatalogViewDelegate<NSObject>
- (void) didSelectedAssetGroup:(AssetsGroup *)assetGroup;
@end

@interface ImagePickerCatalogView : UIView

@property (nonatomic, weak) id<ImagePickerCatalogViewDelegate> delegate;
@property (nonatomic, strong) AssetsGroup *currentAssetsGroup;
- (void) forceReload;

@end
