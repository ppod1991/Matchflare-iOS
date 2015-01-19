//
//  MatchflareAppDelegate.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchflareAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;

- (void) registerForRemoteNotifications;

@end
