//
//  ZSXJPushManger.m
//  ZSXJPushManager
//
//  Created by lynulzy on 3/11/16.
//  Copyright © 2016 lynulzy. All rights reserved.
//

#import "ZSXJPushManger.h"
#import "ZSXJLocalNotification.h"
#import <objc/runtime.h>

@interface ZSXJPushManger()
@property (nonatomic,strong,getter=fetchNotiBlock,setter=setNotiBlockDict:)NSMutableDictionary *notiBlockDict;

@end

@implementation ZSXJPushManger
@synthesize notiBlockDict;
+ (instancetype) sharedManager {
    static ZSXJPushManger *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        notiBlockDict = [[NSMutableDictionary alloc] init];
        _identifierKey = [[NSMutableString alloc] init];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = object_getClass(self);
        swizzleAppDelegateMethod(clazz, @selector(zsxj_application: receiveLocalNotification:));
    });
    return self;
}
//- (instancetype)initWithCoder:(NSCoder *) aDecoder {
//    NSLog(@"ZSXJPushManager init with coder");
//    self = [super init];
//    if (self != nil) {
//        _identifierKey = [[aDecoder decodeObjectForKey:@"identifierKey"] copy];
//        _notiBlockDict = [[aDecoder decodeObjectForKey:@"notiBlockDict"] copy];
//    }
//    return self;
//}
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    NSLog(@"encode With Coder");
//    [aCoder encodeObject:_identifierKey forKey:@"identifierKey"];
//    [aCoder encodeObject:_notiBlockDict forKey:@"notiBlockDict"];
//}
- (void)setNotiBlockDict:(NSMutableDictionary *)theNotiBlockDict {
    if (!notiBlockDict) {
        notiBlockDict = [NSMutableDictionary alloc];
    }
    //Append the key value pair
    
    [notiBlockDict addEntriesFromDictionary:theNotiBlockDict];
    
    //Archieve the dict object
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"zsxj_noti_dict.src"];
    BOOL success = [NSKeyedArchiver archiveRootObject:notiBlockDict
                                               toFile:filePath];
    NSAssert(success, @"Failed to archieve a noti dict ");
}

- (NSMutableDictionary *)fetchNotiBlock {
    NSAssert(notiBlockDict, @"notiBlockDict is empty!!");
//    if (!notiBlockDict) {
        //fetch the dict in archiever
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent: @"zsxj_noti_dict.src"];
        NSMutableDictionary *unarchieverDict = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        [notiBlockDict addEntriesFromDictionary:unarchieverDict];
//    }
    return notiBlockDict;
}
static NSInteger maxLocalNotificationsCount = 64;
- (void)convertRemoteNotification:(NSDictionary *)userInfo
                          keyWord:(NSString *)theKey
                      localPolicy:(ZSXJLocalNotiType)policy
       receiveNotificationHandler:(ZSXJLocalHandleBlock)receiveHandler {
    
    [self convertRemoteNotification:userInfo
                            keyWord:theKey
                        localPolicy:policy];
//    NSMutableDictionary *notiDict = self.notiBlockDict;
//    if (!notiDict) {
//        notiDict = [[NSMutableDictionary alloc] init];
//    }
    [self.notiBlockDict setObject:receiveHandler forKey:userInfo[theKey]];
    
    
}
void swizzleAppDelegateMethod(Class clazz, SEL swizzledSelector) {
    //Hook the delegate method in AppDelegate
    Class appDelegateClazz = object_getClass([UIApplication sharedApplication].delegate);
    SEL appReceiveLocalNotiSelector = @selector(application: didReceiveLocalNotification:);
//    SEL zsxjReceiveLocalNotiSelector = @selector(zsxj_application: receiveLocalNotification:);
    
    Method originMethod = class_getInstanceMethod(appDelegateClazz, appReceiveLocalNotiSelector);
    Method swizzleMethod = class_getInstanceMethod(clazz, swizzledSelector);
//    BOOL addMethodSucc = class_addMethod(clazz,
//                                         appReceiveLocalNotiSelector,
//                                         method_getImplementation(swizzleMethod),
//                                         method_getTypeEncoding(swizzleMethod));
//    if (addMethodSucc) {
//        class_replaceMethod(clazz,
//                            zsxjReceiveLocalNotiSelector,
//                            method_getImplementation(originMethod),
//                            method_getTypeEncoding(originMethod));
//    }
//    else {
        method_exchangeImplementations(originMethod, swizzleMethod);
//    }
}
- (void)convertRemoteNotification:(NSDictionary *)userInfo
                          keyWord:(NSString *)theKey
                      localPolicy:(ZSXJLocalNotiType)policy {
    NSArray *localNotifcations = [[self class] getLocalNotifications];
    NSAssert(localNotifcations.count < maxLocalNotificationsCount, @"Local notifcation has beyond the limit of system defined");
    [self setIdentifierKey:theKey];
    if (localNotifcations.count > maxLocalNotificationsCount) {
        return;
    }
    else {
        UILocalNotification *noti = [self initializeLocalNotification:userInfo
                                                        identifierKey:theKey];
        NSAssert(noti, @"Initialized a local notification failed");
    }
}
- (UILocalNotification *)initializeLocalNotification:(NSDictionary *) userInfo identifierKey:(NSString *) theIdentifierKey {
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
    localNoti.timeZone = [NSTimeZone defaultTimeZone];
    localNoti.alertBody = userInfo[@"content"];
    localNoti.soundName = userInfo[@"sound"];
    localNoti.userInfo = @{@"noti_identifier" : userInfo[theIdentifierKey],
                           @"noti_userInfo": userInfo};
    localNoti.repeatInterval = NSCalendarUnitMinute;
    //Register the local notification
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
        //TODO:添加重复的Notification会怎么样？
        return localNoti;
    }
    else {
        return nil;
    }
}
+ (void)cancelLocalNotification:(NSString *)key identifier:(NSString *)identifier {
//    NSAssert(!key || !identifier, @"Can't find the local notification");
    
    NSArray *localNotifications = [self getLocalNotifications];
    if (localNotifications.count < 1) {
        return;
    }
    for (UILocalNotification *noti in localNotifications) {
        if ([noti isKindOfClass:[UILocalNotification class]]) {
            NSLog(@"%@", [noti userInfo][@"noti_identifier"]);
            if (![[noti userInfo][@"noti_identifier"] isEqualToString:identifier]) {
                continue;
            }
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
    
}
+ (NSArray *)getLocalNotifications {
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    return localNotifications;
}
#pragma mark - Archieve the block Dict

#pragma mark - Method Swizzling
- (void)zsxj_application:(UIApplication *)application receiveLocalNotification:(UILocalNotification *) localNoti {
    NSLog(@"pushmanager notiBlock Dict %@", [ZSXJPushManger sharedManager].notiBlockDict);
    NSLog(@"pushmanager identifierKey %@", [ZSXJPushManger sharedManager].identifierKey);
    ZSXJLocalHandleBlock block = [[ZSXJPushManger sharedManager].notiBlockDict objectForKey:localNoti.userInfo[@"noti_identifier"]];
    if (block) {
        block(localNoti);
    }
    NSLog(@"method swizzling receive local ");
    
}

@end
