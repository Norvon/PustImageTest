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
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                //2. 保存数据, 不可以存储到不存在的路径
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"logo.png"];
                UIImage *image = [UIImage imageWithData:data];
                
                NSError *err = nil;
                
                [UIImageJPEGRepresentation(image, 1) writeToFile:path options:NSAtomicWrite error:&err];
                //3. 添加附件
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"remote-atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&err];
                if (attachment) {
                    self.bestAttemptContent.attachments = @[attachment];
                }
            }
            self.contentHandler(self.bestAttemptContent);
        }];
        [task resume];

    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
