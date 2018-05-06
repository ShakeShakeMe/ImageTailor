//
//  ImagePickerItemCollectionViewCell.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerItemCollectionViewCell : UICollectionViewCell

- (void) bind:(UIImage *)image asset:(PHAsset *)asset;

@end
