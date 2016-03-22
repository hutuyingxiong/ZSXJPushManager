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
@property (nonatomic, copy) ZSXJLocalHandleBlock handleBlock;

+ (instancetype) sharedManager;


- (void)convertRemoteNotification:(NSDictionary *) userInfo keyWord:(NSString *) theKey localPolicy:(ZSXJLocalNotiType) policy;


- (void)convertRemoteNotification:(NSDictionary *)userInfo keyWord:(NSString *)theKey localPolicy:(ZSXJLocalNotiType)policy receiveNotificationHandler:(ZSXJLocalHandleBlock) receiveHandler;

+ (void)cancelLocalNotification:(NSString *)key identifier:(NSString *)identifier;


@end
