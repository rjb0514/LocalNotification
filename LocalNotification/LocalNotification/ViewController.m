//
//  ViewController.m
//  LocalNotification
//
//  Created by ru on 2018/3/20.
//  Copyright © 2018年 GMJK. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import<MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UNUserNotificationCenterDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"本地推送";
    
}




- (IBAction)posh:(id)sender {
    
    
    NSLog(@"点击推送");
    [self creatLocalPush];
//    [self creatLocalPushIOS10];

    
    
}
- (IBAction)cancel:(id)sender {
    
    NSLog(@"取消推送");
    
    [self deleteLocalPush];
    
}

// 关闭本地推送
- (void)deleteLocalPush{
    // 获取该app上所有的本地推送
    NSArray *allLocalNotifi = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // 取消特定的本地推送
    UILocalNotification *localNotifi  = nil;
    for (UILocalNotification *item in allLocalNotifi) {
        NSDictionary *userInfo = item.userInfo;
        if ([[userInfo objectForKey:@"name"] isEqualToString:@"loaclPushOne"]) {
            localNotifi = item;
            break;
        }
    }
    [[UIApplication sharedApplication] cancelLocalNotification:localNotifi];
    
    // 取消所有的本地推送
    [[UIApplication sharedApplication]  cancelAllLocalNotifications];
    
}
#pragma mark - 创建本地推送 ios10之后

#pragma mark - 创建ios10之前的推送
- (void)creatLocalPush {
    // 注册本地通知
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge) categories:nil];
    
    //注册通知
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
    UILocalNotification *localnotifit = [[UILocalNotification alloc] init];
    
    if (localnotifit) {
        
        // 获取通知时间
        NSDate *now = [NSDate date];
        
        localnotifit.timeZone = [NSTimeZone defaultTimeZone];
        
        // 10秒后开始通知
        localnotifit.fireDate = [now dateByAddingTimeInterval:10.0];
        
        // 重复间隔 (下限为每分钟通知一次)
        localnotifit.repeatInterval = kCFCalendarUnitMinute;
        
        // 提醒内容
        localnotifit.alertBody = @"十秒后手机将会爆炸,赶快扔掉";
        
        // 锁屏状态下,“滑动来”(这三个字是系统自动出现的)后面紧接着文字就是alertAction
        localnotifit.alertAction = @"解锁(进入App)";
        
        // 通知栏里的通知标题
        localnotifit.alertTitle = @"提示";
        
        // 默认的通知声音(只有在真机上才会听到)
        localnotifit.soundName = UILocalNotificationDefaultSoundName;
        
        // 红色圈圈数字
        localnotifit.applicationIconBadgeNumber = 1;
        
        // 通知标识
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:@"LocalNotificationID" forKey:@"key"];
        localnotifit.userInfo = dic;
       
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:localnotifit];
        
        
    }
}

- (void)creatLocalPushIOS10{
    
    
    //注册
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center setDelegate:self];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge |UNAuthorizationOptionSound ) completionHandler:^(BOOL granted, NSError * _Nullable error) {

        if (granted) {
            NSLog(@"授权成功");
        }else {
            NSLog(@"没有授权");
        }

    }];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"%@",settings);
    }];
    
    
    // 创建本地通知也需要在appdelegate中心进行注册
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"本地通知标题";
  
    content.subtitle = @"本地通知副标题";
    content.body = @"本地通知内容";
    content.badge = @1;
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"imageName@2x" ofType:@"png"];
    // 2.设置通知附件内容
    NSMutableDictionary *optionsDict = [NSMutableDictionary dictionary];
    // 一个包含描述文件的类型统一类型标识符（UTI）一个NSString。如果不提供该键，附件的文件扩展名来确定其类型，常用的类型标识符有 kUTTypeImage,kUTTypeJPEG2000,kUTTypeTIFF,kUTTypePICT,kUTTypeGIF ,kUTTypePNG,kUTTypeQuickTimeImage等。
    
    // 需要导入框架 #import<MobileCoreServices/MobileCoreServices.h>
    optionsDict[UNNotificationAttachmentOptionsTypeHintKey] = (__bridge id _Nullable)(kUTTypeImage);
    // 是否隐藏缩略图
//    optionsDict[UNNotificationAttachmentOptionsThumbnailHiddenKey] = @YES;
    // 剪切缩略图
    optionsDict[UNNotificationAttachmentOptionsThumbnailClippingRectKey] = (__bridge id _Nullable)((CGRectCreateDictionaryRepresentation(CGRectMake(0.25, 0.25, 0.5 ,0.5))));
    // 如果附件是影片，则以第几秒作为缩略图
//    optionsDict[UNNotificationAttachmentOptionsThumbnailTimeKey] = @1;
    // optionsDict如果不需要，可以不设置，直接传nil即可
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"identifier" URL:[NSURL fileURLWithPath:path] options:optionsDict error:&error];
    if (error) {
        NSLog(@"attachment error %@", error);
    }
    content.attachments = @[att];
    content.launchImageName = @"imageName@2x";
    // 2.设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    // 3.触发模式 多久触发，是否重复
    // 3.1 按秒
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:61  repeats:YES];
    // 3.2 按日期
    //    // 周二早上 9：00 上班
    //    NSDateComponents *components = [[NSDateComponents alloc] init];
    //    // 注意，weekday是从周日开始的计数的
    //    components.weekday = 3;
    //    components.hour = 9;
    //    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    // 3.3 按地理位置
    // 一到某个经纬度就通知，判断包含某一点么
    // 不建议使用！！！！！！CLRegion *region = [[CLRegion alloc] init];
    
    //    CLCircularRegion *circlarRegin = [[CLCircularRegion alloc] init];
    //    // 经纬度
    //    CLLocationDegrees latitudeDegrees = 123.00; // 维度
    //    CLLocationDegrees longitudeDegrees = 123.00; // 经度
    //
    //    [circlarRegin containsCoordinate:CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees)];
    //    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:circlarRegin repeats:NO];
    
    
    // 4.设置UNNotificationRequest
    NSString *requestIdentifer = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
    
    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
        NSLog(@"添加成功");
    }];
    
}


//Ios 10之后如果设置了代理 就会走这个方法
#pragma mark - UNUserNotificationCenterDelegate
// iOS10 推送回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary *userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; //收到推送消息的全部内容
    NSNumber *badge = content.badge; // 推送消息的角标
    NSString *body = content.body; // 收到推送消息具体内容
    UNNotificationSound *sound = content.sound; //声音
    NSString *subTitle = content.subtitle; // 推送收到的副标题
    NSString *title = content.title; // 推送收到的标题
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知");
    }else{
        NSLog(@"ios10 收到本地通知%@%@%@%@%@",title,subTitle,body,badge,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound |
                      UNNotificationPresentationOptionAlert );
    // 需要执行此方法，选择是否提醒用户，有以上三种那个类型可选
    
}
// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request;
    UNNotificationContent *content = request.content; //收到推送消息的全部内容
    NSNumber *badge = content.badge; // 推送消息的角标
    NSString *body = content.body; // 收到推送消息具体内容
    UNNotificationSound *sound = content.sound; //声音
    NSString *subTitle = content.subtitle; // 推送收到的副标题
    NSString *title = content.title; // 推送收到的标题
    NSLog(@">>>通知的点击事件");
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知");
    }else{
        NSLog(@"ios10 收到本地通知%@%@%@%@%@",title,subTitle,body,badge,userInfo);
    }
    completionHandler(); //系统要求执行此方法
    
}



@end
