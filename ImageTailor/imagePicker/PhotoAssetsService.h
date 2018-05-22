//
//  PhotoAssetsService.h
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetsGroup : NSObject <IGListDiffable>
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) NSInteger assetCount;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSArray *assetsArray; // 相册下所有的照片
@end

@protocol PhotoAssetsServiceDelegate <NSObject>
- (void) loadPhotoWithDefaultAssetGroup:(AssetsGroup *)defaultAssetGroup
                      assetsGroupsArray:(NSArray<AssetsGroup *> *)assetsGroupsArray;
- (void) authorizationFailed;
@end

@interface PhotoAssetsService : NSObject

@property (nonatomic, weak) id<PhotoAssetsServiceDelegate> delegate;

@property (nonatomic, strong, readonly) AssetsGroup *allImagesAssetGroup;
@property (nonatomic, strong, readonly) NSArray<AssetsGroup *> *assetsGroupsArray;

+ (instancetype) sharedInstance;
- (void) loadPhotoAssetGroups;

@end
