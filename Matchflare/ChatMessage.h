//
//  ChatMessage.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"
#import "Match.h"

@protocol ChatMessage
@end

@interface ChatMessage : JSONModel

@property (nonatomic, strong) NSString *content;
@property int sender_contact_id;
@property (nonatomic, strong) NSString *guessed_full_name;
@property int chat_id;
@property int pair_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSMutableArray<ChatMessage> *history;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) Match *pair;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end
