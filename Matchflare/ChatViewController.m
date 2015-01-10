//
//  ChatViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/5/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "ChatViewController.h"
#import <JSQMessagesViewController/JSQMessages.h> 
#import "Global.h"
#import "SRWebSocket.h"
#import "ChatMessage.h"

@interface ChatViewController()  <SRWebSocketDelegate, UITextViewDelegate>

@property (strong, retain) SRWebSocket *webSocket;
@property (strong, retain) NSTimer *pingTimer;

@end

@implementation ChatViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *urlString = @"ws://matchflare.herokuapp.com/liveChat";
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
    
    
    
}

- (void) sendPing {
    if (self.webSocket) {
        
        ChatMessage* pingMessage = [[ChatMessage alloc] init];
        pingMessage.content = @"ping from iOS";
        [self.webSocket send:[pingMessage toJSONString]];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    self.webSocket = newWebSocket;
    ChatMessage* initialMessage = [[ChatMessage alloc] init];
    initialMessage.type = @"set_chat_id";
    initialMessage.chat_id = self.chat_id;
    initialMessage.pair_id = self.pair_id;
    initialMessage.sender_contact_id = self.contact_id;
    
    [self.webSocket send:[initialMessage toJSONString]];
    
    //Timer for pings
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Failed to open websocket");
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed websocket");
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    self.messagesTextView.text = [NSString stringWithFormat:@"%@\n%@", self.messagesTextView.text, message];
    NSLog([NSString stringWithFormat:@"New Message: %@", message]);
    NSError *err;
    
    ChatMessage *receivedMessage = [[ChatMessage alloc] initWithString:message error:&err];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    if (!err) {
        if ([receivedMessage.type isEqualToString:@"history"]) {
            //NEED TO IMPLEMENT
            NSLog(@"Received history!");
            
            self.thisMatch = receivedMessage.pair;
            self.senderDisplayName = receivedMessage.guessed_full_name;
            for (ChatMessage *currentMessage in receivedMessage.history) {
                NSString *name = currentMessage.guessed_full_name;
                if (self.thisMatch.is_anonymous && currentMessage.sender_contact_id == self.thisMatch.matcher.contact_id.intValue) {
                        name = @"Matcher";
                }
                
                NSDate *createdAt = [df_utc dateFromString:currentMessage.created_at];
                
                JSQMessage *messageToAdd = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",currentMessage.sender_contact_id]
                                                              senderDisplayName:name
                                                                           date:createdAt
                                                                           text:currentMessage.content];
                [self.data.messages addObject:messageToAdd];
            }
            
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:true];
            [self setTitle];
            
        }
        else if ([receivedMessage.type isEqualToString:@"message"]) {
            
            NSDate *createdAt = [df_utc dateFromString:receivedMessage.created_at];
            
            NSString *name = receivedMessage.guessed_full_name;
            if (self.thisMatch.is_anonymous && receivedMessage.sender_contact_id == self.thisMatch.matcher.contact_id.intValue) {
                name = @"Matcher";
            }
            
            JSQMessage *messageToAdd = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",receivedMessage.sender_contact_id]
                                                          senderDisplayName:name
                                                                       date:createdAt
                                                                       text:receivedMessage.content];
            [self.data.messages addObject:messageToAdd];
//            [self finishSendingMessageAnimated:YES];
            
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:true];
            
        }
        else if ([receivedMessage.type isEqualToString:@"error"]) {
            NSLog(@"Error receiving message and/or chat history!");
        }

    }
    
}

- (NSString *) getFirstName: (NSString *) fullName {
    return [[fullName componentsSeparatedByString:@" "] objectAtIndex:0];
};

- (void) setTitle {
    NSString *description = @"";
    NSNumber *thisUserContactId = [NSNumber numberWithInt:self.contact_id];
    Match *m = self.thisMatch;
    
    if (m.chat_id == self.chat_id) {  //If this is the main chat
        if ([m.first_matchee.contact_id isEqualToNumber: thisUserContactId]) {  //Which user is the current user
            description = [NSString stringWithFormat:@"Talk to %@!",[self getFirstName:m.second_matchee.guessed_full_name]];
        }
        else if ([m.second_matchee.contact_id isEqualToNumber: thisUserContactId]) {
            description = [NSString stringWithFormat:@"Talk to %@!",[self getFirstName:m.first_matchee.guessed_full_name]];
        }
        
    }
    else if (m.first_matchee.matcher_chat_id == self.chat_id || m.second_matchee.matcher_chat_id == self.chat_id)  { //If this is a chat with the matcher...
        if ([m.first_matchee.contact_id isEqualToNumber: thisUserContactId]) {  //If this user is asking the matcher (and is first matchee)
            if (m.is_anonymous) {
                description = [NSString stringWithFormat:@"Ask about %@!",[self getFirstName:m.second_matchee.guessed_full_name]];
            }
            else {
                description = [NSString stringWithFormat:@"Ask %@ about %@!",[self getFirstName:m.matcher.guessed_full_name],[self getFirstName:m.second_matchee.guessed_full_name]];
            }
        }
        else if ([m.second_matchee.contact_id isEqualToNumber: thisUserContactId]) { //If this user is asking the matcher (and is second matchee)
            if (m.is_anonymous) {
                description = [NSString stringWithFormat:@"Ask about %@!",[self getFirstName:m.first_matchee.guessed_full_name]];
            }
            else {
                description = [NSString stringWithFormat:@"Ask %@ about %@!",[self getFirstName:m.matcher.guessed_full_name],[self getFirstName:m.first_matchee.guessed_full_name]];
            }
        }
        else if ([m.matcher.contact_id isEqualToNumber:  thisUserContactId]) { //If this user is the matcher
            if (m.first_matchee.matcher_chat_id == self.chat_id) { //Determine which matchee the other chatter is
                description = [NSString stringWithFormat:@"Answer %@'s ?s of %@!",[self getFirstName:m.first_matchee.guessed_full_name],[self getFirstName:m.second_matchee.guessed_full_name]];
            }
            else if (m.second_matchee.matcher_chat_id == self.chat_id) {
                description = [NSString stringWithFormat:@"Answer %@'s ?s of %@!",[self getFirstName:m.second_matchee.guessed_full_name],[self getFirstName:m.first_matchee.guessed_full_name]];
            }
        }
    }
    
    self.navigationItem.title = description;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_webSocket closeWithCode:1000 reason:nil];
    NSLog(@"Closing web socket!");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TO CHANGE 
    Global *global = [Global getInstance];
    self.contact_id = global.thisUser.contact_id.intValue; //238;
    
    
    if (!self.pair_id || !self.chat_id) {
        self.pair_id = 613;
        self.chat_id = 917;
    }

    
    
    //self.senderId = [NSString stringWithFormat:@"%d", global.thisUser.contact_id.intValue];
    self.senderId = [NSString stringWithFormat:@"%d", self.contact_id];
    self.senderDisplayName = @"Me";
    self.showLoadEarlierMessagesHeader = NO;
    
    self.data = [[ChatMessageData alloc] init];
    //self.view.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
    self.collectionView.collectionViewLayout.messageBubbleFont =[UIFont fontWithName:@"OpenSans-Light" size:15.0];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    [self.inputToolbar.contentView.rightBarButtonItem setImage:[UIImage imageNamed:@"send_button"] forState:UIControlStateNormal];
    self.inputToolbar.contentView.rightBarButtonItem.contentMode = UIViewContentModeScaleAspectFit;
    [self.inputToolbar.contentView.textView setFont:[UIFont fontWithName:@"OpenSans-Light" size:15.0]];
    self.inputToolbar.contentView.textView.delegate = self;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"Return pressed");
        [self didPressSendButton:nil withMessageText:textView.text senderId:self.senderId senderDisplayName:self.senderDisplayName date:nil];
        return NO;

    } else {
        return YES;
    }
}



- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    ChatMessage *chatToSend = [[ChatMessage alloc] init];
    chatToSend.content = text;
    chatToSend.chat_id = self.chat_id;
    chatToSend.type = @"message";
    chatToSend.sender_contact_id = self.contact_id;
    [self.webSocket send:[chatToSend toJSONString]];
    
//    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
//                                             senderDisplayName:senderDisplayName
//                                                          date:date
//                                                          text:text];
    
    //[self.data.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.data.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.data.outgoingBubbleImageData;
    }
    
    return self.data.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.data.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.data.messages objectAtIndex:indexPath.item];

    
    if (!msg.isMediaMessage) {
        cell.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.data.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end


