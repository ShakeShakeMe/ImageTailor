//
//  CurrentSelectedAssetsManager.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentSelectedAssetsManager : NSObject

SINGLETON_INSTANCE_METHOD_DECLARATION

- (NSInteger) indexForAsset:(PHAsset *)asset;

- (void) didSelectAsset:(PHAsset *)asset;
- (void) didDeselectAsset:(PHAsset *)asset;
- (void) toggleAsset:(PHAsset *)asset;

- (NSArray<PHAsset *> *) allSelectedAssets;

- (void) clear;

@end
