//
//  NotificationService.m
//  MyService
//
//  Created by nor on 2020/3/11.
//  Copyright © 2020 nor. All rights reserved.
//

#import "NotificationService.h"

#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    //    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    //    {
    //        "aps": {
    //            "badge": 1,
    //            "alert": {
    //                "title": "测试抬头title",
    //                "subtitle": "测试抬头subtitle",
    //                "body": "主题body 0"
    //            },
    //            "sound": "defult",
    //            "category": "realtime",
    //            "mutable-content": "1" // 为1的时候走自定义消息解析
    //        },
    //        "media": {
    //            "type": "image",
    //            "url": "https://www.baidu.com/img/bd_logo1.png"
    //        }
    //    }
    
    // 记得修改当前target 的 ats
    
    NSDictionary *dic = [request.content.userInfo valueForKey:@"media"] ;
    if ([dic isKindOfClass:[NSDictionary class]] == NO) {
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    
    NSString *type = [dic objectForKey:@"type"];
    NSString *urlStr = [dic objectForKey:@"url"];
    if (!type || !urlStr) {
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    
    if ([type isEqualToString:@"image"]) {
        
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"logo.png"];
                UIImage *image = [UIImage imageWithData:data];
                
                NSError *err = nil;
                
                [UIImageJPEGRepresentation(image, 1) writeToFile:path options:NSAtomicWrite error:&err];
                //3. 添加附件
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"remote-atta1"
                                                                                                      URL:[NSURL fileURLWithPath:path]
                                                                                                  options:nil error:&err];
                if (attachment) {
                    self.bestAttemptContent.attachments = @[attachment];
                }
            }
            self.contentHandler(self.bestAttemptContent);
        }];
        [task resume];
    }
    else {
        self.contentHandler(self.bestAttemptContent);
    }
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
