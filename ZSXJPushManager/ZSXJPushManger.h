//
//  ZSXJPushManger.h
//  ZSXJPushManager
//
//  Created by lynulzy on 3/11/16.
//  Copyright © 2016 lynulzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZSXJPushDefine.h"

/**
 *  @author lzy, 16-03-14 16:03:25
 *
 *  @brief ZSXJPushManager is a class that responsible for transform a remote notification to a local notification and handle the event when a localNotification is traggered
 */

typedef void(^ZSXJLocalHandleBlock)(UILocalNotification *localNotification);



@interface ZSXJPushManger : NSObject

@property (nonatomic, strong) ZSXJPushManger *sharedManager;
@property (nonatomic, strong) NSString * identifierKey;
//@property (nonatomic, copy) ZSXJLocalHandleBlock handleBlock;

+ (instancetype) sharedManager;

/**
 *  @author lzy, 16-03-22 15:03:32
 *
 *  @brief Convert a RemoteNotification to a Local Notification using specific policy.
 *
 *  @param userInfo the remote notification's user info dictionary
 *  @param theKey   the key to identify a push notification
 *  @param policy   Frequently or tip three times.
 */
- (void)convertRemoteNotification:(NSDictionary *) userInfo keyWord:(NSString *) theKey localPolicy:(ZSXJLocalNotiType) policy;

/**
 *  @author lzy, 16-03-22 15:03:44
 *
 *  @brief Convert a RemoteNotification to a Local Notification using specific policy.
 *
 *  @param userInfo       the remote notification's user info dictionary
 *  @param theKey         the key to identify a push notification
 *  @param policy         Frequently or tip three times.
 *  @param receiveHandler the handler block when receive a localNotification
 */
- (void)convertRemoteNotification:(NSDictionary *)userInfo keyWord:(NSString *)theKey localPolicy:(ZSXJLocalNotiType)policy receiveNotificationHandler:(ZSXJLocalHandleBlock) receiveHandler;

+ (void)cancelLocalNotification:(NSString *)key identifier:(NSString *)identifier;


@end
