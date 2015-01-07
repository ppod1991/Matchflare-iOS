//
//  Notification.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"

@protocol Notification
@end

@interface Notification : JSONModel

@property int notification_id;
@property (nonatomic, strong) NSString *push_message;
@property (nonatomic, strong) NSString *notification_type;
@property int pair_id;
@property int chat_id;
@property BOOL seen;
@property int target_contact_id;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end
