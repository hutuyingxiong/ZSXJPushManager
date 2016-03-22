//
//  ZSXJLocalNotification.m
//  ZSXJPushManager
//
//  Created by lynulzy on 3/12/16.
//  Copyright © 2016 lynulzy. All rights reserved.
//

#import "ZSXJLocalNotification.h"

@implementation ZSXJLocalNotification
- (instancetype) initWithUserInfo:(NSDictionary *) theUserInfo
                    identifierKey:(NSString *) theIdentifierKey
                             type:(ZSXJLocalNotiType) theType {
    
//    self = [super init];
    //Tip after the remote push notification 60 sec.
    
    self.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
    self.timeZone = [NSTimeZone defaultTimeZone];
    self.alertBody = theUserInfo[@"content"];
    self.soundName = theUserInfo[@"sound"];
    self.userInfo = @{@"noti_identifier" : theUserInfo[theIdentifierKey],
                      @"noti_userInfo": theUserInfo};
    self.repeatInterval = NSCalendarUnitMinute;
    NSAssert(![self registerTheNotification], @"Register a local notification failed!!");
    if (![self registerTheNotification]) {
        return nil;
    }
    _zsxjNotiIdentifier = theUserInfo[theIdentifierKey];
    //over time date should be setted there
//    _overTimeDate = [NSDate dateWithTimeIntervalSince1970:300];
    _tipedTimes = 0;
    
    return self;
}

- (void)cancleNotify {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *noti in notifications) {
        if (![noti isKindOfClass:[UILocalNotification class]]) {
            break;
        }
        
        ZSXJLocalNotification *theNoti = (ZSXJLocalNotification *)noti;
        if (theNoti.zsxjNotiIdentifier == self.zsxjNotiIdentifier) {
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
}



#pragma mark - HELPERS
- (BOOL)registerTheNotification {
    //Register the local notification
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] scheduleLocalNotification:self];
        //TODO:添加重复的Notification会怎么样？
        return YES;
    }
    else {
        return NO;
    }
}
@end
