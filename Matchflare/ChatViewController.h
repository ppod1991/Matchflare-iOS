//
//  ChatViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/5/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "ChatMessageData.h"
#import "Match.h"

@class ChatViewController;

@interface ChatViewController : JSQMessagesViewController

@property (strong, nonatomic) ChatMessageData *data;
@property int chat_id;
@property int pair_id;
@property int contact_id;
@property (strong, nonatomic) Match *thisMatch;
@end
