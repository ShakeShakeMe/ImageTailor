//
//  PhotoAssetsService.m
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "PhotoAssetsService.h"
#import <Photos/Photos.h>

@implementation AssetsGroup
#pragma mark - IGListDiffable
- (nonnull id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object {
    return object != nil && (self == object || [self isEqual:object]);
}
@end

@interface PhotoAssetsService() <PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@property (nonatomic, strong, readwrite) AssetsGroup *allImagesAssetGroup;
@property (nonatomic, strong, readwrite) NSArray<AssetsGroup *> *assetsGroupsArray;
@end

@implementation PhotoAssetsService

+ (instancetype) sharedInstance {
    static PhotoAssetsService *_service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _service = [[PhotoAssetsService alloc] init];
    });
    return _service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fetchOptions = [PHFetchOptions new];
        self.fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        self.fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void) dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self loadPhotoAssetGroups];
}

- (void) loadPhotoAssetGroups {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                {
                    [self tryLoadPhotoAssetGroups];
                    break;
                }
                default:
                {
                    if ([self.delegate respondsToSelector:@selector(authorizationFailed)]) {
                        [self.delegate authorizationFailed];
                    }
                    break;
                }
            }
        });
    }];
}

- (void) tryLoadPhotoAssetGroups {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //获取系统智能相册
        NSArray *albumTypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                @(PHAssetCollectionSubtypeSmartAlbumGeneric),
                                @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),
                                @(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
        
        NSMutableArray *assetGroups = [@[] mutableCopy];
        for (NSInteger i = 0; i < albumTypes.count; i++) {
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:[albumTypes[i] intValue] options:nil];
            if ([smartAlbums.firstObject isKindOfClass:[PHAssetCollection class]]) {
                AssetsGroup *group = [self extraPHAsset:smartAlbums.firstObject];
                if (group) {
                    if ([albumTypes[i] integerValue] == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        self.allImagesAssetGroup = group;
                    }
                    [assetGroups addObject:group];
                }
            }
        }
        
        //获取用户相册
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [topLevelUserCollections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                AssetsGroup *group = [self extraPHAsset:obj];
                if (group) {
                    [assetGroups addObject:group];
                }
            }
        }];
        self.assetsGroupsArray = assetGroups;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(loadPhotoWithDefaultAssetGroup:assetsGroupsArray:)]) {
                [self.delegate loadPhotoWithDefaultAssetGroup:self.allImagesAssetGroup
                                            assetsGroupsArray:self.assetsGroupsArray];
            }
        });
    });
}

- (AssetsGroup *)extraPHAsset:(PHAssetCollection *)assetCollection {
    PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
    if (assetResult.count > 0) {
        AssetsGroup *assetsGroup = [AssetsGroup new];
        assetsGroup.groupName = assetCollection.localizedTitle;
        assetsGroup.assetCount = assetResult.count;
        assetsGroup.asset = [assetResult lastObject];

        NSMutableArray *assetsArray = [@[] mutableCopy];
        for (NSInteger i = 0; i < assetResult.count; i++) {
            PHAsset *asset = assetResult[i];
            [assetsArray addObject:asset];
        }
        assetsGroup.assetsArray = assetsArray;
        return assetsGroup;
    }
    return nil;
}

@end
