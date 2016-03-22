//
//  ViewController.m
//  ZSXJPushManager
//
//  Created by lynulzy on 3/11/16.
//  Copyright © 2016 lynulzy. All rights reserved.
//

#import "ViewController.h"
#import "ZSXJPushManger.h"

typedef void (^testBlock)(id target);

@interface ViewController ()
@property (nonatomic, readwrite, copy) testBlock thetestBlock;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)traggerLocalNotification:(id)sender {
//    [ZSXJPushManger registerLocalNotification:10];
    [[ZSXJPushManger sharedManager] convertRemoteNotification:@{@"order_id":@"110111"}
                                      keyWord:@"order_id"
                                  localPolicy:ZSXJNormalLocalNoti receiveNotificationHandler:^(UILocalNotification *localNotification) {
                                      NSLog(@"receive local notification block");
                                  }];
}
- (IBAction)cacleNotification:(id)sender {
//    [ZSXJPushManger cancleLocalNotificationWithKey:@""];
    [ZSXJPushManger cancelLocalNotification:@"order_id"
                                 identifier:@"110111"];
}

@end
