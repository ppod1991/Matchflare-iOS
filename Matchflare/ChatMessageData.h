//
//  ChatMessageData.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/5/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessages.h>


@interface ChatMessageData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;


@end
