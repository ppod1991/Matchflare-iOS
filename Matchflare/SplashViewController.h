//
//  SplashViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Notification.h"

@interface SplashViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) NSMutableArray <Match> *matches;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property BOOL reachedLastSplashPage;
@property BOOL toPresentMatches;
@property BOOL finishedProcessingContacts;
@property BOOL toRegister;
@property Notification *initialNotification;

@end
