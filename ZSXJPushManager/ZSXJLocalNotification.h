//
//  ZSXJLocalNotification.h
//  ZSXJPushManager
//
//  Created by lynulzy on 3/12/16.
//  Copyright © 2016 lynulzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSXJPushDefine.h"
//typedef NS_ENUM(NSInteger, ZSXJLocalNotiType) {
//    ZSXJNormalLocalNoti,
//    ZSXJFrequentLocalNoti,
//    
//};

typedef void (^ZSXJLocalNotiBlock)(NSString *identifier, NSDictionary *userInfo);

@interface ZSXJLocalNotification : UILocalNotification

@property (nonatomic, readonly, copy) NSString *zsxjNotiIdentifier;
@property (nonatomic, readonly, assign) ZSXJLocalNotiType *zsxjNotiType;
@property (nonatomic, readonly, strong) NSDate *overTimeDate;
@property (nonatomic, readwrite, assign) NSInteger *tipedTimes;
@property (nonatomic, readwrite, copy) ZSXJLocalNotiBlock completionBlock;

/**
 *  @author lzy, 16-03-13 23:03:29
 *
 *  @brief Initialize a instance of LocalNotification and register it in the system notification.
 *
 *  @param theUserInfo      the remote push notification that is useful for local notification
 *  @param theIdentifierKey the identifier of a local notification
 *  @param theType          stand for the type of how notifications was traggered
 *
 *  @return a instance of LocalNotification
 */
- (instancetype) initWithUserInfo:(NSDictionary *) theUserInfo
                    identifierKey:(NSString *) theIdentifierKey
                             type:(ZSXJLocalNotiType) theType;

/**
 *  @author lzy, 16-03-13 23:03:45
 *
 *  @brief Cancle a specific Local Notification
 */
- (void)cancleNotify;
@end
