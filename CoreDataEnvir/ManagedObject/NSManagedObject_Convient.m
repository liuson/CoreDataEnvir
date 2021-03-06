//
//  NSManagedObject_Convient.m
//  CoreDataEnvirSample
//
//  Created by NicholasXu on 15/8/30.
//  Copyright (c) 2015年 Nicholas.Xu. All rights reserved.
//

#import "NSManagedObject_Convient.h"
#import "CoreDataEnvir_Private.h"
#import "CoreDataEnvir_Main.h"
#import "CoreDataEnvir_Background.h"

@implementation NSManagedObject (Convient)

#pragma mark - Insert item record

+ (id)insertItemInContext:(CoreDataEnvir *)cde
{
#if DEBUG
    NSLog(@"%s thread :%u, %@", __func__, [NSThread isMainThread], [NSString stringWithCString:dispatch_queue_get_label(dispatch_get_current_queue()) encoding:NSUTF8StringEncoding]);
#endif
    id item = nil;
    item = [cde buildManagedObjectByClass:self];
    return item;
}

+ (id)insertItemInContext:(CoreDataEnvir *)cde fillData:(void (^)(id item))fillingBlock
{
#if DEBUG
    NSLog(@"%s thread :%u, %@", __func__, [NSThread isMainThread], [NSString stringWithCString:dispatch_queue_get_label(dispatch_get_current_queue()) encoding:NSUTF8StringEncoding]);
#endif
    id item = [self insertItemInContext:cde];
    fillingBlock(item);
    return item;
}

#pragma mark - fetch items

+ (NSArray *)itemsInContext:(CoreDataEnvir *)cde
{
    NSArray *items = [cde fetchItemsByEntityDescriptionName:NSStringFromClass(self)];
    return items;
}

+ (NSArray *)itemsInContext:(CoreDataEnvir *)cde usingPredicate:(NSPredicate *)predicate
{
    NSArray *items = [cde fetchItemsByEntityDescriptionName:NSStringFromClass(self) usingPredicate:predicate];
    return items;
}

+ (NSArray *)itemsInContext:(CoreDataEnvir *)cde withFormat:(NSString *)fmt, ...
{
    va_list args;
    va_start(args, fmt);
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    
    NSArray *items = [cde fetchItemsByEntityDescriptionName:NSStringFromClass(self) usingPredicate:pred];
    return items;
}

+ (NSArray *)itemsInContext:(CoreDataEnvir *)cde sortDescriptions:(NSArray *)sortDescriptions withFormat:(NSString *)fmt, ...
{
    va_list args;
    va_start(args, fmt);
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    NSArray *items = [cde fetchItemsByEntityDescriptionName:NSStringFromClass(self) usingPredicate:pred usingSortDescriptions:sortDescriptions];
    return items;
}

+ (NSArray *)itemsInContext:(CoreDataEnvir *)cde sortDescriptions:(NSArray *)sortDescriptions fromOffset:(NSUInteger)offset limitedBy:(NSUInteger)limitNumber withFormat:(NSString *)fmt, ...
{
    va_list args;
    va_start(args, fmt);
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    NSArray *items = [cde fetchItemsByEntityDescriptionName:NSStringFromClass(self) usingPredicate:pred usingSortDescriptions:sortDescriptions fromOffset:offset LimitedBy:limitNumber];
    return items;
}

#pragma mark - fetch last item

+ (id)lastItemInContext:(CoreDataEnvir *)cde
{
    return [[self itemsInContext:cde] lastObject];
}

+ (id)lastItemInContext:(CoreDataEnvir *)cde usingPredicate:(NSPredicate *)predicate
{
    return [[self itemsInContext:cde usingPredicate:predicate] lastObject];
}

+ (id)lastItemInContext:(CoreDataEnvir *)cde withFormat:(NSString *)fmt, ...
{
    va_list args;
    va_start(args, fmt);
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    
    return [[self itemsInContext:cde usingPredicate:pred] lastObject];
}

#pragma mark - merge context when update

- (id)update
{
    if ([NSThread isMainThread]) {
        return [[CoreDataEnvir instance] updateDataItem:self];
    }
    return nil;
}

- (id)updateInContext:(CoreDataEnvir *)cde
{
    return [cde updateDataItem:self];
}

- (void)removeFrom:(CoreDataEnvir *)cde
{
    if (!cde) {
        return;
    }
    [cde deleteDataItem:self];
}

- (void)remove
{
    if (![NSThread isMainThread]) {
#if DEBUG
        NSLog(@"Remove data failed, cannot run on non-main thread!");
#endif
        [[NSException exceptionWithName:@"CoreDataEnviroment" reason:@"Remove data failed, must run on main thread!" userInfo:nil] raise];
        return;
    }
    if (![CoreDataEnvir mainInstance]) {
        return;
    }
    [[CoreDataEnvir mainInstance] deleteDataItem:self];
}

- (BOOL)saveTo:(CoreDataEnvir *)cde
{
    if (!cde) {
        return NO;
    }
    
    return [cde saveDataBase];
}

- (BOOL)save
{
    if (![NSThread isMainThread]) {
#if DEBUG
        NSLog(@"Save data failed, cannot run on non-main thread!");
#endif
        [[NSException exceptionWithName:@"CoreDataEnviroment" reason:@"Save data failed, must run on main thread!" userInfo:nil] raise];
        return NO;
    }
    if (![CoreDataEnvir mainInstance]) {
        return NO;
    }
    
    return [[CoreDataEnvir mainInstance] saveDataBase];
}

@end
