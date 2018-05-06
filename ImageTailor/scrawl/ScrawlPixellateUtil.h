//
//  ScrawlPixellateUtil.h
//  ImageTailor
//
//  Created by dl on 2018/5/6.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrawlPixellateUtil : NSObject

+ (UIImage *) pixellateImageWithOriginImage:(UIImage *)originImage radius:(NSUInteger)radius;

@end
