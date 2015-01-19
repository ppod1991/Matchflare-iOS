//
//  MatchflareAppDelegate.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "MatchflareAppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "Global.h"
#import "Notification.h"
#import "SplashViewController.h"
#import "NotificationLists.h"

@implementation MatchflareAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Global initializeProgress];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    
    // now that everything about the App's UI is setup, let's determine what deep linking or notification data was sent
    // first, extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notificationPayload) {
        NSLog(@"Notification Payload: %@", notificationPayload);
        [self interpretPayload:notificationPayload forApplication:application];
        // figure out what's in the notificationPayload dictionary
    }
    
    
    // Override point for customization after application launch.
    return YES;
}


- (void) interpretPayload: (NSDictionary *) payload forApplication: (UIApplication *) application {
    NSString *json = [payload objectForKey:@"data"];
    JSONModelError *err;
    Notification* chosenNotification = [[Notification alloc] initWithString:json error:&err];
    if (err) {
        NSLog(@"Error intepreting remote notification payload");
        return;
    }
    else {
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive)
        {
            //When your app was active and it got push notification
            [Global showToastWithText:chosenNotification.push_message];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil  userInfo:payload];
            
        }
        else if (state == UIApplicationStateInactive)
        {
            Global* global = [Global getInstance];
            
            if (global.thisUser.contact_id > 0 && self.navigationController) {
                [self.navigationController pushViewController:[global controllerFromNotification:chosenNotification] animated:YES];
            }
            else {
                SplashViewController *rootController = (SplashViewController *)(self.window.rootViewController);
                rootController.initialNotification = chosenNotification;
            }
            //When your app was in background and it got push notification
            
        }
    }
}





- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    Global *global = [Global getInstance];
    
    //Convert NSData to string for server
    NSString *deviceTokenString;
    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];
    
    if (!dataBuffer)
        deviceTokenString = [NSString string];
    
    NSUInteger          dataLength  = [deviceToken length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    deviceTokenString = [NSString stringWithString:hexString];
    
    global.thisUser.apn_device_token = deviceTokenString;
    if (global.thisUser.contact_id > 0) {
        [Global postTo:@"apns/registrationId" withParams:nil withBody:global.thisUser
            success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"Successfully updated apns registration id");
        }
            failure:^(NSURLSessionDataTask *task, NSError *err) {
                NSLog(@"Failed to update apns registration id: %@",err.localizedDescription);
        }];
    }
    else {
        NSLog(@"User did not register yet so cannot store apn device token");
    }
    
}

- (void) registerForRemoteNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [application registerForRemoteNotifications];
        
    } else {
        // use registerForRemoteNotifications
        // Register for Remote Notifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    NSLog(@"Received remote notification with contents: %@",userInfo.description);
    
    [self interpretPayload:userInfo forApplication:application];
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id > 0) {
        [Global get:@"notificationLists" withParams:@{@"contact_id":global.thisUser.contact_id}
            success:^(NSURLSessionDataTask* operation, id responseObject) {
                NSError *err;
                if ((BOOL) responseObject) {
                    NSLog(@"Successfully retrieved notifications: %@", [responseObject description]);
                    NotificationLists *notifications = [[NotificationLists alloc] initWithDictionary:responseObject error:&err];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notifications.notifications.count];
                    
                }
                else {
                    NSLog(@"Failed to retrieve notifications: %@", [responseObject description]);
                }
                
                if (err) {
                    NSLog(@"Unable to convert notifications, %@", err.localizedDescription);
                }
            }
            failure:^(NSURLSessionDataTask * operation, NSError * error) {
                [Global endProgress];
                NSLog(@"Unable to retrieve notifications, %@", error.localizedDescription);
            }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
