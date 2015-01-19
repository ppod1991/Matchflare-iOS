//
//  Global.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "Global.h"
#import "AFNetworking.h"
#import "Person.h"
#import "CRToast.h"
#import "MatchflareAppDelegate.h"
#import "EvaluateMatchViewController.h"
#import "ChatViewController.h"
#import "ViewMatchController.h"
#import <SVProgressHUD.h>

@interface Global() <UIAlertViewDelegate>
@end

@implementation Global

static progressShowing = NO;
static Global *instance = nil;
static NSString *baseURL = @"http://matchflare.herokuapp.com/";

+ (void) postTo:(NSString *) path withParams:(NSDictionary *) params withBody:(id) body success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET"]];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    
    NSString *queryString = @"";
    if ([params count] > 0) {
        NSMutableArray *parts = [NSMutableArray array];
        for (id key in params) {
            id value = [params objectForKey: key];
            NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
            [parts addObject: part];
            queryString = [@"?" stringByAppendingString: [parts componentsJoinedByString: @"&"]];
        }
    }
    
    NSString* urlString = [[baseURL stringByAppendingString:path] stringByAppendingString:queryString];
    NSLog(@"My dictionary is %@", [[body toDictionary] description]);
    
    [manager POST:urlString parameters:[body toDictionary] success:success failure:failure];
}

+ (void) get:(NSString *) path withParams:(NSDictionary *) params success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json",@"text/plain"]];

    
    NSString* urlString = [baseURL stringByAppendingString:path];
    [manager GET:urlString parameters:params success:success failure:failure];
}

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (NSString *) getDeviceId {
    UIDevice *device = [UIDevice currentDevice];
    
    return [[device identifierForVendor]UUIDString];
};

+ (Global*) getInstance {
    @synchronized(self) {
        if (instance==nil) {
            instance = [Global new];
            instance.thisUser = [[Person alloc] init];
        }
    }
    return instance;
};

-(NSString*) accessToken {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    
    NSString *accessToken;
    
    if([preferences objectForKey:@"access_token"] == nil)
    {
        accessToken = nil;
    }
    else
    {
        //  Get current level
        accessToken = [preferences stringForKey:@"access_token"];
    }
    
    return accessToken;
};

-(BOOL) setAccessToken:(NSString *) mAccessToken {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
        
    NSString* accessToken = mAccessToken;
    
    [preferences setValue:accessToken forKey:@"access_token"];
    
    //  Save to disk
    return [preferences synchronize];
    
};

+ (void) showToastWithText: (NSString *) text {
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:1.0],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastTimeIntervalKey: @1,
                              kCRToastTextColorKey:[UIColor blackColor],
                              kCRToastFontKey:[UIFont fontWithName:@"OpenSans" size:13.0f]
                              };
    
    [CRToastManager dismissNotification:NO];
    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}

- (void) registerForPushNotifications {
    
    BOOL enabled;
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        enabled = [application isRegisteredForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        enabled = types & UIRemoteNotificationTypeAlert;
    }
    
    if (!enabled) {
        //If the user has not yet enabled push notifications
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Get notified?" message:@"Get notified of new matches and messages from your friends?" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Yes", nil];
        [av show];
    }
    else {
        MatchflareAppDelegate *delegate = (MatchflareAppDelegate *)[application delegate];
        [delegate registerForRemoteNotifications];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        MatchflareAppDelegate *delegate = (MatchflareAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate registerForRemoteNotifications];
    }
}

- (UIViewController *) controllerFromNotification: (Notification *) chosenNotification {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: [NSBundle mainBundle]];
    if ([chosenNotification.notification_type isEqualToString:@"MATCHEE_NEW_MATCH"]) {
        EvaluateMatchViewController *nextViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"EvaluateMatchViewController"];
        nextViewController.pair_id = chosenNotification.pair_id;
        return nextViewController;
    }
    else if ([chosenNotification.notification_type isEqualToString:@"MATCHEE_MATCH_ACCEPTED"] ||
             [chosenNotification.notification_type isEqualToString:@"MATCHER_QUESTION_ASKED"] ||
             [chosenNotification.notification_type isEqualToString:@"MATCHEE_QUESTION_ANSWERED"] ||
             [chosenNotification.notification_type isEqualToString:@"MATCHEE_MESSAGE_SENT"]) {
        ChatViewController *nextViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        nextViewController.chat_id = chosenNotification.chat_id;
        nextViewController.pair_id = chosenNotification.pair_id;
        return nextViewController;

        
    }
    else if ([chosenNotification.notification_type isEqualToString:@"MATCHER_ONE_MATCH_ACCEPTED"] ||
             [chosenNotification.notification_type isEqualToString:@"MATCHER_BOTH_ACCEPTED"]) {
        
        ViewMatchController *nextViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewMatchController"];
        nextViewController.pair_id = chosenNotification.pair_id;
        return nextViewController;
    }
    else {
        NSLog(@"No view controller found for this notification type!");
        return nil;
    }
}

+ (void) initializeProgress {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]]; //Matchflare pink
    [SVProgressHUD setRingThickness:1.5f];
}

+ (void) beginSpinning {
    if (progressShowing) {
        [SVProgressHUD show];
    }
}
+ (void) startProgress {
    progressShowing = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.25 target: self selector:@selector(beginSpinning) userInfo:nil repeats:NO];
}

+ (void) startProgressWithString: (NSString *) progressString {
    progressShowing = YES;
    [SVProgressHUD showWithStatus:progressString];
}
+ (void) endProgress {
    progressShowing = NO;
    [SVProgressHUD dismiss];
}

@end
