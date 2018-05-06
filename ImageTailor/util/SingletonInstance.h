//
//  SingletonInstance.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#ifndef SingletonInstance_h
#define SingletonInstance_h

#define SINGLETON_INSTANCE_METHOD_DECLARATION_NAMED(methodName) + (instancetype)methodName;
#define SINGLETON_INSTANCE_METHOD_DECLARATION + (instancetype)sharedInstance;
#define SINGLETON_INSTANCE_METHOD_DECLARATION_NONNULL + (instancetype _Nonnull)sharedInstance;
#define SINGLETON_INSTANCE_METHOD_DECLARATION_NULLABLE + (instancetype _Nullable)sharedInstance;

#define SINGLETON_INSTANCE_METHOD_IMPLEMENTATION_NAMED(methodName) \
+ (instancetype)methodName \
{\
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = [[self alloc] init]; \
}); \
return _sharedObject; \
}\

#define SINGLETON_INSTANCE_METHOD_IMPLEMENTATION SINGLETON_INSTANCE_METHOD_IMPLEMENTATION_NAMED(sharedInstance)

#define SINGLETON_INSTANCE_METHOD SINGLETON_INSTANCE_METHOD_IMPLEMENTATION


#endif /* SingletonInstance_h */
