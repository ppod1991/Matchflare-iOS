//
//  NotificationLists.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/8/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "JSONModel.h"
#import "Notification.h"
#import "Match.h"

@protocol NotificationLists
@end

@interface NotificationLists : JSONModel

@property (strong, nonatomic) NSArray<Notification> *notifications;
@property (strong, nonatomic) NSArray<Match> *pending_matches;
@property (strong, nonatomic) NSArray<Match> *active_matcher_matches;

+(BOOL)propertyIsOptional:(NSString*)propertyName;


@end
