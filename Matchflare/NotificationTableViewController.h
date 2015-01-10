//
//  NotificationTableViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/8/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "NotificationLists.h"

@interface NotificationTableViewController : UITableViewController

@property (strong, nonatomic) NotificationLists *notifications;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableArray *isExpanded;

@end
