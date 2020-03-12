//
//  AppDelegate.m
//  PustImageTest
//
//  Created by nor on 2020/3/11.
//  Copyright © 2020 nor. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    }
    
    [self registerPushService];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    completionHandler(UNNotificationPresentationOptionSound
                      | UNNotificationPresentationOptionAlert);
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self bindPhontWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)registerPushService {

    // 前台推送
    if (@available(iOS 11.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted)
            {
            }
        }];
    }
    else
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }

    [[UIApplication sharedApplication] registerForRemoteNotifications];


//    //pushkit
//    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
//    pushRegistry.delegate = self;
//    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

    // 注册push权限，用于显示本地推送
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
}

- (void)bindPhontWithDeviceToken:(NSData *)deviceToken {
    if (!deviceToken) return;
    
    // token
    NSString *deviceTokenStr = [self getHexStringForData:deviceToken];;
    
    NSLog(@"devictToek = %@", deviceTokenStr);
}

- (NSString *)getHexStringForData:(NSData *)data {
    if (!data) return @"";
    
    NSMutableString *deviceTokenString = [NSMutableString string];
    
    const char *bytes = data.bytes;
    NSInteger count = data.length;
    for (int i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }

#if DEBUG
//    [self showTokenAlertWithDeviceTokenStr:deviceTokenString];
#endif
    
    return deviceTokenString;
}


@end
