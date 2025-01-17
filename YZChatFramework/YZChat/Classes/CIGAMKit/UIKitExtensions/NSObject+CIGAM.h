/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSObject+CIGAM.h
//  cigam
//
//  Created by CIGAM Team on 2016/11/1.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CIGAM)

/**
 判断当前类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)cigam_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断指定的类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
+ (BOOL)cigam_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (nullable id)cigam_performSelectorToSuperclass:(SEL)aSelector;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @param object 作为参数传过去
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (nullable id)cigam_performSelectorToSuperclass:(SEL)aSelector withObject:(nullable id)object;

/**
 *  调用一个无参数、返回值类型为非对象的 selector。如果返回值类型为对象，请直接使用系统的 performSelector: 方法。
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址，请先定义一个变量再将其指针地址传进来，例如 &result
 *
 *  @code
 *  CGFloat alpha;
 *  [view cigam_performSelector:@selector(alpha) withPrimitiveReturnValue:&alpha];
 *  @endcode
 */
- (void)cigam_performSelector:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue;

/**
 *  调用一个带参数的 selector，参数类型支持对象和非对象，也没有数量限制。返回值为对象或者 void。
 *  @param selector 要被调用的方法名
 *  @param firstArgument 参数列表，请传参数的指针地址，支持多个参数
 *  @return 方法的返回值，如果该方法返回类型为 void，则会返回 nil，如果返回类型为对象，则返回该对象。
 *
 *  @code
 *  id target = xxx;
 *  SEL action = xxx;
 *  UIControlEvents events = xxx;
 *  [control cigam_performSelector:@selector(addTarget:action:forControlEvents:) withArguments:&target, &action, &events, nil];
 *  @endcode
 */
- (nullable id)cigam_performSelector:(SEL)selector withArguments:(nullable void *)firstArgument, ...;

/**
 *  调用一个返回值类型为非对象且带参数的 selector，参数类型支持对象和非对象，也没有数量限制。
 *
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址
 *  @param firstArgument 参数列表，请传参数的指针地址，支持多个参数
 *
 *  @code
 *  CGPoint point = xxx;
 *  UIEvent *event = xxx;
 *  BOOL isInside;
 *  [view cigam_performSelector:@selector(pointInside:withEvent:) withPrimitiveReturnValue:&isInside arguments:&point, &event, nil];
 *  @endcode
 */
- (void)cigam_performSelector:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue arguments:(nullable void *)firstArgument, ...;


/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量，也不包含 superclasses 里定义的变量
 
 @param block 用于遍历的 block
 */
- (void)cigam_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量
 
 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 ivars
 @param block  用于遍历的 block
 */
+ (void)cigam_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

/**
 使用 block 遍历指定 class 的所有属性，不包含 superclasses 里定义的 property
 
 @param block 用于遍历的 block，如果要获取 property 的信息，推荐用 CIGAMPropertyDescriptor。
 */
- (void)cigam_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历指定 class 的所有属性
 
 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 property
 @param block 用于遍历的 block，如果要获取 property 的信息，推荐用 CIGAMPropertyDescriptor。
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
 */
+ (void)cigam_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历当前实例的所有方法，不包含 superclasses 里定义的 method
 */
- (void)cigam_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block;

/**
 使用 block 遍历指定的某个类的实例方法
 @param aClass   指定的 class
 @param includingInherited 是否要包含由继承链带过来的 method
 @param block    用于遍历的 block
 */
+ (void)cigam_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method method, SEL selector))block;

/**
 遍历某个 protocol 里的所有方法
 
 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)cigam_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;

@end

@interface NSObject (CIGAM_KeyValueCoding)

/**
 iOS 13 下系统禁止通过 KVC 访问私有 API，因此提供这种方式在遇到 access prohibited 的异常时可以取代 valueForKey: 使用。
 
 对 iOS 12 及以下的版本，等价于 valueForKey:。
 
 @note CIGAM 提供2种方式兼容系统的 access prohibited 异常：
 1. 通过将配置表的 IgnoreKVCAccessProhibited 置为 YES 来全局屏蔽系统的异常警告，代码中依然正常使用系统的 valueForKey:、setValue:forKey:，当开启后再遇到 access prohibited 异常时，将会用 CIGAMWarnLog 来提醒，不再中断 App 的运行，这是首选推荐方案。
 2. 使用 cigam_valueForKey:、cigam_setValue:forKey: 代替系统的 valueForKey:、setValue:forKey:，适用于不希望全局屏蔽，只针对某个局部代码自己处理的场景。
 
 @link https://github.com/Tencent/CIGAM_iOS/issues/617
 
 @param key ivar 属性名，支持下划线或不带下划线
 @return key 对应的 value，如果该 key 原本是非对象的值，会被用 NSNumber、NSValue 包裹后返回
 */
- (nullable id)cigam_valueForKey:(NSString *)key;

/**
 iOS 13 下系统禁止通过 KVC 访问私有 API，因此提供这种方式在遇到 access prohibited 的异常时可以取代 setValue:forKey: 使用。
 
 对 iOS 12 及以下的版本，等价于 setValue:forKey:。
 
 @note CIGAM 提供2种方式兼容系统的 access prohibited 异常：
 1. 通过将配置表的 IgnoreKVCAccessProhibited 置为 YES 来全局屏蔽系统的异常警告，代码中依然正常使用系统的 valueForKey:、setValue:forKey:，当开启后再遇到 access prohibited 异常时，将会用 CIGAMWarnLog 来提醒，不再中断 App 的运行，这是首选推荐方案。
 2. 使用 cigam_valueForKey:、cigam_setValue:forKey: 代替系统的 valueForKey:、setValue:forKey:，适用于不希望全局屏蔽，只针对某个局部代码自己处理的场景。
 
 @link https://github.com/Tencent/CIGAM_iOS/issues/617
 
 @param key ivar 属性名，支持下划线或不带下划线
 @return key 对应的 value，如果该 key 原本是非对象的值，会被用 NSNumber、NSValue 包裹后返回
 */
- (void)cigam_setValue:(nullable id)value forKey:(NSString *)key;

/**
 检查给定的 key 是否可以用于当前对象的 valueForKey: 调用。
 
 @note 这是针对 valueForKey: 内部查找 key 的逻辑的精简版，去掉了一些不常用的，如果按精简版查找不到，会返回 NO（但按完整版可能是能查找到的），避免抛出异常。文档描述的查找方法完整版请查看 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html
 */
- (BOOL)cigam_canGetValueForKey:(NSString *)key;

/**
检查给定的 key 是否可以用于当前对象的 setValue:forKey: 调用。

@note 对于 setter 而言这就是完整版的检查流程，可核对文档 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html
*/
- (BOOL)cigam_canSetValueForKey:(NSString *)key;

@end


@interface NSObject (CIGAM_DataBind)

/**
 给对象绑定上另一个对象以供后续取出使用，如果 object 传入 nil 则会清除该 key 之前绑定的对象
 
 @attention 被绑定的对象会被 strong 强引用
 @note 内部是使用 objc_setAssociatedObject / objc_getAssociatedObject 来实现
 
 @code
 - (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath {
 // 1）在这里给 button 绑定上 indexPath 对象
 [cell cigam_bindObject:indexPath forKey:@"indexPath"];
 }
 
 - (void)didTapButton:(UIButton *)button {
 // 2）在这里取出被点击的 button 的 indexPath 对象
 NSIndexPath *indexPathTapped = [button cigam_getBoundObjectForKey:@"indexPath"];
 }
 @endcode
 */
- (void)cigam_bindObject:(nullable id)object forKey:(NSString *)key;

/**
 给对象绑定上另一个对象以供后续取出使用，但相比于 cigam_bindObject:forKey:，该方法不会 strong 强引用传入的 object
 */
- (void)cigam_bindObjectWeakly:(nullable id)object forKey:(NSString *)key;

/**
 取出之前使用 bind 方法绑定的对象
 */
- (nullable id)cigam_getBoundObjectForKey:(NSString *)key;

/**
 给对象绑定上一个 double 值以供后续取出使用
 */
- (void)cigam_bindDouble:(double)doubleValue forKey:(NSString *)key;

/**
 取出之前用 bindDouble:forKey: 绑定的值
 */
- (double)cigam_getBoundDoubleForKey:(NSString *)key;

/**
 给对象绑定上一个 BOOL 值以供后续取出使用
 */
- (void)cigam_bindBOOL:(BOOL)boolValue forKey:(NSString *)key;

/**
 取出之前用 bindBOOL:forKey: 绑定的值
 */
- (BOOL)cigam_getBoundBOOLForKey:(NSString *)key;

/**
 给对象绑定上一个 long 值以供后续取出使用
 */
- (void)cigam_bindLong:(long)longValue forKey:(NSString *)key;

/**
 取出之前用 bindLong:forKey: 绑定的值
 */
- (long)cigam_getBoundLongForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的对象
 */
- (void)cigam_clearBindingForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的所有对象
 */
- (void)cigam_clearAllBinding;

/**
 返回当前有绑定对象存在的所有的 key 的数组，如果不存在任何 key，则返回一个空数组
 @note 数组中元素的顺序是随机的
 */
- (NSArray<NSString *> *)cigam_allBindingKeys;

/**
 返回是否设置了某个 key
 */
- (BOOL)cigam_hasBindingKey:(NSString *)key;

@end

@interface NSObject (CIGAM_Debug)

/// 获取当前对象的所有 @property、方法，父类的方法也会分别列出
- (NSString *)cigam_methodList;

/// 获取当前对象的所有 @property、方法，不包含父类的
- (NSString *)cigam_shortMethodList;

/// 获取当前对象的所有 Ivar 变量
- (NSString *)cigam_ivarList;
@end

@interface NSThread (CIGAM_KVC)

/// 是否将当前线程标记为忽略系统的 KVC access prohibited 警告，默认为 NO，当开启后，NSException 将不会再抛出 access prohibited 异常
/// @see BeginIgnoreUIKVCAccessProhibited、EndIgnoreUIKVCAccessProhibited
@property(nonatomic, assign) BOOL cigam_shouldIgnoreUIKVCAccessProhibited;
@end

NS_ASSUME_NONNULL_END
