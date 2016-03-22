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
@property (nonatomic,strong)NSMutableDictionary *notiBlockDict;

@end

@implementation ZSXJPushManger
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
        _notiBlockDict = [[NSMutableDictionary alloc] init];
        _identifierKey = [[NSMutableString alloc] init];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = object_getClass(self);
        swizzleAppDelegateMethod(clazz, @selector(zsxj_application: receiveLocalNotification:));
    });
    return self;
}
//+ (void)load {
//    
//}
static NSInteger maxLocalNotificationsCount = 64;
- (void)convertRemoteNotification:(NSDictionary *)userInfo
                          keyWord:(NSString *)theKey
                      localPolicy:(ZSXJLocalNotiType)policy
       receiveNotificationHandler:(ZSXJLocalHandleBlock)receiveHandler {
    
    [self convertRemoteNotification:userInfo
                            keyWord:theKey
                        localPolicy:policy];
    NSMutableDictionary *notiDict = _notiBlockDict;
    if (!notiDict) {
        notiDict = [[NSMutableDictionary alloc] init];
    }
    [notiDict setObject:receiveHandler forKey:userInfo[theKey]];
    
    
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

/**
 *  @author lzy, 16-03-18 11:03:55
 *
 *  @brief Fetch the LocalNotifications in the system at current time.
 *
 *  @return Array of the local notifications.
 */
+ (NSArray *)getLocalNotifications {
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    return localNotifications;
}

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
