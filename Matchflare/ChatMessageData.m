//
//  ChatMessageData.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/5/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "ChatMessageData.h"

@implementation ChatMessageData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        //JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage imageNamed:@"bubble_min_tailless"] capInsets:UIEdgeInsetsZero];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1.0]];
        
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:232/255.0 green:240/255.0 blue:255/255.0 alpha:1.0]];
        
    }
    
    return self;
}






@end
