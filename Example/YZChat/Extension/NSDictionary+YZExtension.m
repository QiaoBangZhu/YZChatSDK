//
//  NSDictionary+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSDictionary+YZExtension.h"
#import "NSObject+YZTypeConversion.h"
#import "NSString+YZExtension.h"


@implementation NSDictionary (YZExtension)

- (NSDictionaryAppendBlock)APPEND {
    NSDictionaryAppendBlock block = ^NSDictionary *(NSString *key, id value) {
        if (key && value) {
            NSString *className = [[self class] description];

            if ([className isEqualToString:@"NSMutableDictionary"]) {
                [(NSMutableDictionary *) self setObject:value atPath:key];
                return self;
            }
            else {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self];
                [dict setObject:value atPath:key];
                return dict;
            }
        }

        return self;
    };

    return [block copy];
}

- (NSObject *)objectOfAny:(NSArray *)array {
    for (NSString *key in array) {
        NSObject *obj = [self objectForKey:key];
        if (obj)
            return obj;
    }

    return nil;
}

- (NSString *)stringOfAny:(NSArray *)array {
    NSObject *obj = [self objectOfAny:array];
    if (obj && [obj isKindOfClass:[NSString class]])
        return (NSString *) obj;

    return nil;
}

- (NSObject *)objectAtPath:(NSString *)path {
    return [self objectAtPath:path separator:nil];
}

- (NSObject *)objectAtPath:(NSString *)path separator:(NSString *)separator {
    return [self objectForKey:path];
    #if 0
    if (nil == separator) {
        path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        separator = @"/";
    }

#if 1

    NSArray *array = [path componentsSeparatedByString:separator];
    if (0 == [array count]) {
        return nil;
    }

    NSObject *result = nil;
    NSDictionary *dict = self;

    for (NSString *subPath in array) {
        if (0 == [subPath length])
            continue;

        result = [dict objectForKey:subPath];
        if (nil == result)
            return nil;

        if ([array lastObject] == subPath) {
            return result;
        }
        else if (NO == [result isKindOfClass:[NSDictionary class]]) {
            return nil;
        }

        dict = (NSDictionary *) result;
    }

    return (result == [NSNull null]) ? nil : result;

#else
    
    // thanks @lancy, changed: use native keyPath
    
    NSString *    keyPath = [path stringByReplacingOccurrencesOfString:separator withString:@"."];
    NSRange        range = NSMakeRange( 0, 1 );
    
    if ( [[keyPath substringWithRange:range] isEqualToString:@"."] )
    {
        keyPath = [keyPath substringFromIndex:1];
    }
    
    NSObject * result = [self valueForKeyPath:keyPath];
    return (result == [NSNull null]) ? nil : result;
    
#endif
#endif
}

- (NSObject *)objectAtPath:(NSString *)path otherwise:(NSObject *)other {
    NSObject *obj = [self objectAtPath:path];
    return obj ? obj : other;
}

- (NSObject *)objectAtPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString *)separator {
    NSObject *obj = [self objectAtPath:path separator:separator];
    return obj ? obj : other;
}

- (BOOL)boolAtPath:(NSString *)path {
    return [self boolAtPath:path otherwise:NO];
}

- (BOOL)boolAtPath:(NSString *)path otherwise:(BOOL)other {
    NSObject *obj = [self objectAtPath:path];
    if ([obj isKindOfClass:[NSNull class]]) {
        return NO;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *) obj intValue] ? YES : NO;
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        if ([(NSString *) obj hasPrefix:@"y"] ||
                [(NSString *) obj hasPrefix:@"Y"] ||
                [(NSString *) obj hasPrefix:@"T"] ||
                [(NSString *) obj hasPrefix:@"t"] ||
                [(NSString *) obj isEqualToString:@"1"]) {
            // YES/Yes/yes/TRUE/Ture/true/1
            return YES;
        }
        else {
            return NO;
        }
    }

    return other;
}

- (NSNumber *)numberAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return (NSNumber *) obj;
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithDouble:[(NSString *) obj doubleValue]];
    }

    return nil;
}

- (NSNumber *)numberAtPath:(NSString *)path otherwise:(NSNumber *)other {
    NSNumber *obj = [self numberAtPath:path];
    return obj ? obj : other;
}

- (NSString *)stringAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%d", [(NSNumber *) obj intValue]];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *) obj;
    }

    return nil;
}

- (NSString *)stringAtPath:(NSString *)path otherwise:(NSString *)other {
    NSString *obj = [self stringAtPath:path];
    return obj ? obj : other;
}

- (NSString *)stringForKey:(NSString *)path otherKey:(NSString *)other {
    NSString *obj = [self stringForKey:path];
    return obj ? obj : [self stringForKey:other];
}


- (NSArray *)arrayAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    return [obj isKindOfClass:[NSArray class]] ? (NSArray *) obj : nil;
}

- (NSArray *)arrayAtPath:(NSString *)path otherwise:(NSArray *)other {
    NSArray *obj = [self arrayAtPath:path];
    return obj ? obj : other;
}

- (NSMutableArray *)mutableArrayAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    return [obj isKindOfClass:[NSMutableArray class]] ? (NSMutableArray *) obj : nil;
}

- (NSMutableArray *)mutableArrayAtPath:(NSString *)path otherwise:(NSMutableArray *)other {
    NSMutableArray *obj = [self mutableArrayAtPath:path];
    return obj ? obj : other;
}

- (NSDictionary *)dictAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    return [obj isKindOfClass:[NSDictionary class]] ? (NSDictionary *) obj : nil;
}

- (NSDictionary *)dictAtPath:(NSString *)path otherwise:(NSDictionary *)other {
    NSDictionary *obj = [self dictAtPath:path];
    return obj ? obj : other;
}

- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path {
    NSObject *obj = [self objectAtPath:path];
    return [obj isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary *) obj : nil;
}

- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path otherwise:(NSMutableDictionary *)other {
    NSMutableDictionary *obj = [self mutableDictAtPath:path];
    return obj ? obj : other;
}

// thanks to @ilikeido
- (NSObject *)objectForClass:(Class)clazz {
    /*
    if ([clazz respondsToSelector:@selector(initFromDictionary:)]) {
        return [clazz performSelector:@selector(initFromDictionary:) withObject:self];
    }
    id object = [[clazz alloc] init];

    NSUInteger propertyCount = 0;
    
    objc_property_t *properties = class_copyPropertyList(clazz, &propertyCount);

    for (NSUInteger i = 0; i < propertyCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        const char *attr = property_getAttributes(properties[i]);
        NSUInteger type = [KH_TypeEncoding typeOf:attr];

        NSObject *tempValue = [self objectForKey:propertyName];
        NSObject *value = nil;

        if (tempValue) {
            if (KH_TypeEncoding.NSNUMBER == type) {
                value = [tempValue asNSNumber];
            }
            else if (KH_TypeEncoding.NSSTRING == type) {
                value = [tempValue asNSString];
            }
            else if (KH_TypeEncoding.NSDATE == type) {
                value = [tempValue asNSDate];
            }
            else if (KH_TypeEncoding.NSARRAY == type) {
                if ([tempValue isKindOfClass:[NSArray class]]) {
                    SEL seltemp = NSSelectorFromString([NSString stringWithFormat:@"%@ConvertClass", propertyName]);
                    if ([clazz respondsToSelector:seltemp]) {
                        Class classTemp = [clazz performSelector:seltemp];
                        NSMutableArray *arrayTemp = [NSMutableArray array];

                        for (NSObject *tempObject in (NSArray *) tempValue) {
                            if ([tempObject isKindOfClass:[NSDictionary class]]) {
                                [arrayTemp addObject:[(NSDictionary *) tempObject objectForClass:classTemp]];
                            }
                        }
                        value = arrayTemp;
                    }
                    else {
                        value = tempValue;
                    }
                }
            }
            else if (KH_TypeEncoding.NSDICTIONARY == type) {
                if ([tempValue isKindOfClass:[NSDictionary class]]) {
                    value = tempValue;
                }
            }
            else if (KH_TypeEncoding.OBJECT == type) {
                NSString *className = [KH_TypeEncoding classNameOf:attr];
                if ([tempValue isKindOfClass:NSClassFromString(className)]) {
                    value = tempValue;
                }
                else if ([tempValue isKindOfClass:[NSDictionary class]]) {
                    value = [(NSDictionary *) tempValue objectForClass:NSClassFromString(className)];
                }
            }
        }

        [object setValue:value forKey:propertyName];
    }

    free(properties);

    return object;
    */
    return nil;
}


- (NSInteger)intForKey:(NSString *)key {

    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return 0;
    }
    else if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
        [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }

    return [[self objectForKey:key] integerValue];
}

- (NSInteger)safeIntForKey:(NSString *)key {
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return 0;
    }
    else if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
            [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }
    return [[self objectForKey:key] integerValue];
}

- (NSInteger)safeIntForKey:(NSString *)key withSafeNum:(NSInteger)safenum {
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return safenum;
    }
    else if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
            [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }

    return [[self objectForKey:key] integerValue];
}

- (BOOL)safeBoolForKey:(NSString *)key withSafeVale:(BOOL)safeValue {
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return safeValue;
    }
    else if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
            [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }
    return [[self objectForKey:key] boolValue];
}

- (BOOL)boolForKey:(NSString *)key {
    if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
            [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }
    BOOL value = [[self objectForKey:key] boolValue];
    return value;
}

- (float)floatForKey:(NSString *)key {
    if ([[self objectForKey:key] isNotKindOfClass:[NSString class]] &&
            [[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }


    float value = [[self objectForKey:key] floatValue];
    return value;
}

- (NSString *)stringForKey:(NSString *)key {
    NSString *value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {   // FIX IT
        return value;
    }
    else {
        return nil;
    }
}

- (NSString *)safeStringForKey:(NSString *)key withSafeString:(NSString *)safeString {
    
    id aString = [self objectForKey:key];
    
    if ([aString isKindOfClass:[NSNumber class]]) {
        return safeString;
    }
    
    if ((NSNull *)aString == [NSNull null]) {
        return safeString;
    }
    
    if (aString == nil) {
        return safeString;
    }
    else if ([aString isNotKindOfClass:[NSString class]]) {
        return safeString;
    }
    else if ([aString length] == 0) {
        return safeString;
    } else {
        aString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([aString length] == 0) {
            return safeString;
        }
    }
    
    NSString *value = [self objectForKey:key];
    return value;
}


- (double)safeDoubleForKey:(NSString *)key {
    if (self == nil) {
        return 0;
    }
    if ([[self objectForKey:key] isNotKindOfClass:[NSNumber  class]]) {
        return 0;
    }
    return [[self objectForKey:key] doubleValue];
}

- (double)safeDoubleForKey:(NSString *)key withSafeNum:(double)safenum {
    if (self == nil){
        return safenum;
    }
    else if ([[self objectForKey:key] isNotKindOfClass:[NSNumber class]]) {        // FIX IT(magic)
        return 0;
    }
    return [[self objectForKey:key] doubleValue];
}

- (CGPoint)pointForKey:(NSString *)key {
    CGPoint point = CGPointZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dictionary, &point);
    if (success) return point;
    else return CGPointZero;
}

- (CGSize)sizeForKey:(NSString *)key {
    CGSize size = CGSizeZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGSizeMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dictionary, &size);
    if (success) return size;
    else return CGSizeZero;
}

- (CGRect)rectForKey:(NSString *)key {
    CGRect rect = CGRectZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dictionary, &rect);
    if (success) return rect;
    else return CGRectZero;
}

- (NSMutableDictionary *)convertKeyValue:(NSDictionary *)keys {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:4];
    for (NSString *key in [self allKeys]) {
        NSString *newKey = [keys stringForKey:key];
        if (newKey != nil) {
            id value = [self objectForKey:key];
            if (value != nil) {
                [result setObject:value forKey:newKey];
            }
        }
        else {
            id value = [self objectForKey:key];
            if (value != nil) {
                [result setObject:value forKey:key];
            }
        }
    }
    return result;
}

@end

#pragma mark -

@implementation NSMutableDictionary (KHExtension)

- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path {
    return [self setObject:obj atPath:path separator:nil];
}

- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path separator:(NSString *)separator {
    if (0 == [path length])
        return NO;

    if (nil == separator) {
        path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        separator = @"/";
    }

    NSArray *array = [path componentsSeparatedByString:separator];
    if (0 == [array count]) {
        [self setObject:obj forKey:path];
        return YES;
    }

    NSMutableDictionary *upperDict = self;
    NSDictionary *dict = nil;
    NSString *subPath = nil;

    for (subPath in array) {
        if (0 == [subPath length])
            continue;

        if ([array lastObject] == subPath)
            break;

        dict = [upperDict objectForKey:subPath];
        if (nil == dict) {
            dict = [NSMutableDictionary dictionary];
            [upperDict setObject:dict forKey:subPath];
        }
        else {
            if (NO == [dict isKindOfClass:[NSDictionary class]])
                return NO;

            if (NO == [dict isKindOfClass:[NSMutableDictionary class]]) {
                dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [upperDict setObject:dict forKey:subPath];
            }
        }

        upperDict = (NSMutableDictionary *) dict;
    }

    if (subPath != nil && obj != nil) {
        [upperDict setObject:obj forKey:subPath];
    }
    return YES;
}

- (BOOL)setKeyValues:(id)first, ... {
    va_list args;
    va_start( args, first );

    for (; ; first = nil ) {
        NSObject *key = first ? first : va_arg( args, NSObject * );
        if (nil == key || NO == [key isKindOfClass:[NSString class]])
            break;

        NSObject *value = va_arg( args, NSObject * );
        if (nil == value)
            break;

        BOOL ret = [self setObject:value atPath:(NSString *) key];
        if (NO == ret) {
            va_end( args );
            return NO;
        }
    }
    va_end( args );
    return YES;
}

+ (NSMutableDictionary *)keyValues:(id)first, ... {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    va_list args;
    va_start( args, first );

    for (; ; first = nil ) {
        NSObject *key = first ? first : va_arg( args, NSObject * );
        if (nil == key || NO == [key isKindOfClass:[NSString class]])
            break;

        NSObject *value = va_arg( args, NSObject * );
        if (nil == value)
            break;

        [dict setObject:value atPath:(NSString *) key];
    }
    va_end( args );
    return dict;
}


- (void)setInt:(NSInteger)value forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithInteger:value];
    [self setObject:number forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithBool:value];
    [self setObject:number forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithFloat:value];
    [self setObject:number forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithDouble:value];
    [self setObject:number forKey:key];
}

- (void)setString:(NSString *)value forKey:(NSString *)key {
    [self setObject:value forKey:key];
}

- (void)setPoint:(CGPoint)value forKey:(NSString *)key {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *) CGPointCreateDictionaryRepresentation(value);
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

- (void)setSize:(CGSize)value forKey:(NSString *)key {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *) CGSizeCreateDictionaryRepresentation(value);
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

- (void)setRect:(CGRect)value forKey:(NSString *)key {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *) CGRectCreateDictionaryRepresentation(value);
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

/**
 * Same as setObject:forKey:, but does not attempt to insert nil objects or keys
 */
- (void)safelySetObject:(id)object forKey:(id)key; {
    if (!object || !key) {
        NSLog(@"safelySetObject:forKey nil");
        return;
    }
    [self setObject:object forKey:key];
}

- (void)safelySetObjectSilence:(id)object forKey:(id)key; {
    if (!object || !key) {
        return;
    }
    [self setObject:object forKey:key];
}


@end


@implementation NSDictionary (DeepMutableCopy)


- (NSMutableDictionary *)deepMutableCopy; {
    NSMutableDictionary *newDictionary;
    NSEnumerator *keyEnumerator;
    id anObject;
    id aKey;

    newDictionary = [self mutableCopy];
    // Run through the new dictionary and replace any objects that respond to -deepMutableCopy or -mutableCopy with copies.
    keyEnumerator = [[newDictionary allKeys] objectEnumerator];
    while ((aKey = [keyEnumerator nextObject])) {
        anObject = [newDictionary objectForKey:aKey];
        if ([anObject respondsToSelector:@selector(deepMutableCopy)]) {
            anObject = [anObject deepMutableCopy];
            [newDictionary setObject:anObject forKey:aKey];
        } else if ([anObject respondsToSelector:@selector(mutableCopyWithZone:)]) {
            anObject = [anObject mutableCopyWithZone:nil];
            [newDictionary setObject:anObject forKey:aKey];
        } else {
            [newDictionary setObject:anObject forKey:aKey];
        }
    }
    return newDictionary;
}


@end
