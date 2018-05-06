//
//  LazyProperty.h
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#ifndef LazyProperty_h
#define LazyProperty_h

/* 业务开发纯代码布局，经常要写大量的getter方法，用宏替代重复代码的成本
 ps:
 1.xcode8有source editor extentions,但配置起来成本较高 http://www.jianshu.com/p/030b46492d5a
 2.codesnip使用成本也高，需要手动替换多个
 -((clsname) *)<#(varname)#>
 {
 if (_<#(varname)#> == nil) {
 _<#(varname)#> = [<#(clsname)#> new];
 }
 return _<#(varname)#>;
 }
 */

#ifndef LazyProperty
#define LazyProperty(cls,var) -(cls *)var{if (_##var == nil) {_##var = [cls new];}return _##var;}
#endif

#ifndef LazyPropertyWithInit
#define LazyPropertyWithInit(cls,var,code) -(cls *)var{if (_##var == nil) {_##var = [cls new];{code}}return _##var;}
#endif

/* 用法
 
 // 不用设置
 LazyProperty(NSDictionary, dict);
 
 // 普通对象
 LazyPropertyWithInit(NSMutableArray, mutableArray, {
 [_mutableArray addObject:@"1"];
 });
 
 // UI控件
 LazyPropertyWithInit(UILabel, titleLabel, {
 _titleLabel.text = @"abc";
 _titleLabel.font = [UIFont systemFontOfSize:18];
 });
 
 */

#endif /* LazyProperty_h */
