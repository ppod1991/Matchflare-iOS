//
//  EvaluateMatchViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/9/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "EvaluateMatchViewController.h"
#import "Global.h"
#import "Match.h"
#import "Person.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ChatViewController.h"
#import "EvaluateResponse.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface EvaluateMatchViewController () <UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *matcherImage;
@property (strong, nonatomic) IBOutlet UILabel *matcherLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *otherMatcheeLabel;

@property (strong, nonatomic) IBOutlet UIButton *askButton;
@property (strong, nonatomic) IBOutlet UIButton *passButton;
@property (strong, nonatomic) IBOutlet UIButton *matchButton;
@property (strong, nonatomic) IBOutlet UIButton *otherMatcheeChatButton;
@property (strong, nonatomic) IBOutlet UIImageView *otherMatcheeImage;

@property (strong, nonatomic) Person *thisMatchee;
@property (strong, nonatomic) Person *otherMatchee;

@property int chosen_chat_id;

@end

@implementation EvaluateMatchViewController

- (IBAction)optionsTouchedDown:(id)sender {
    self.matcherLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
}
- (IBAction)optionsTouchedUp:(id)sender {
    [self matcherOptionsTouched:nil];
    self.matcherLabel.textColor = [UIColor whiteColor];
}

- (IBAction) touchExit: (id) sender {
    self.matcherLabel.textColor = [UIColor whiteColor];
    
}
- (IBAction)matcherOptionsTouched:(id)sender {
    
    NSString *matcherName = @"this Matcher";
    if (!self.thisMatch.is_anonymous) {
        matcherName = self.thisMatch.matcher.guessed_full_name;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[NSString stringWithFormat:@"Block %@",matcherName], [NSString stringWithFormat:@"Ask %@ a question",matcherName], nil];
    [actionSheet showInView:self.view];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"EvaluateMatcherOptionsPressed"
                                                           value:nil] build]];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Block the matcher
        Global *global = [Global getInstance];
        

        
        [Global postTo:@"blockContact" withParams:@{@"contact_id":global.thisUser.contact_id,@"to_block_contact_id":self.thisMatch.matcher.contact_id} withBody:nil
        success:^(NSURLSessionDataTask* operation, id responseObject) {
            NSLog(@"Successfully blocked contact");
            [Global showToastWithText:@"Blocked this matcher!"];
        }
        failure:^(NSURLSessionDataTask * operation, NSError * error) {
            NSLog(@"Error blocking matcher, %@", error.localizedDescription);
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:[NSString stringWithFormat:@"Unable to block matcher, %@", error.localizedDescription] withFatal:@NO] build]];
        }];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"EvaluateBlockMatcherPressed"
                                                               value:nil] build]];

    } else if (buttonIndex == 1) {
        //Go to matcher chat
        [self askButtonPressed:nil];
    }
}

- (IBAction)askButtonPressed:(id)sender {
    self.chosen_chat_id = self.thisMatchee.matcher_chat_id;
    [self performSegueWithIdentifier:@"EvaluateToChat" sender:self];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"EvaluateMatcherChatPressed"
                                                           value:nil] build]];
}

- (IBAction)passButtonPressed:(id)sender {
    [self postWithResponse:@"REJECT"];

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"EvaluatePassButtonPressed"
                                                           value:nil] build]];
}

- (void) postWithResponse: (NSString *) decision {
    
    
    EvaluateResponse *response = [[EvaluateResponse alloc] init];
    response.contact_id = [Global getInstance].thisUser.contact_id.intValue;
    response.pair_id = self.thisMatch.pair_id;
    response.decision = decision;
    
    [Global postTo:@"match/respond" withParams:nil withBody:response success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Successfully responded");
        if ([decision isEqualToString:@"ACCEPT"]) {
            [Global showToastWithText:@"Great--you'll be notified if you both match."];
        }
        else {
            [Global showToastWithText:@"Match passed"];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *err) {
        NSLog(@"Failed to respond: %@", err.localizedDescription);
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:[NSString stringWithFormat:@"Unable to post evaluate response, %@", err.localizedDescription] withFatal:@NO] build]];
    }];
    
    [self performSegueWithIdentifier:@"EvaluateToPresent" sender:self];
    
}

- (IBAction)otherMatcheeChatButtonPressed:(id)sender {
    self.chosen_chat_id = self.thisMatch.chat_id;
    [self performSegueWithIdentifier:@"EvaluateToChat" sender:self];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"EvaluateOtherMatcheeChatButtonPressed"
                                                           value:nil] build]];

}
- (IBAction)matchButtonPressed:(id)sender {

    [self postWithResponse:@"ACCEPT"];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"EvaluateMatchButtonPressed"
                                                           value:nil] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.thisMatch == nil) {
        [Global startProgress];
        [Global get:@"match" withParams:@{@"pair_id":[NSNumber numberWithInt:self.pair_id]}
            success:^(NSURLSessionDataTask* operation, id responseObject) {
                [Global endProgress];
                NSError *err;
                NSLog(@"Successfully retrieved match: %@", [responseObject description]);
                self.thisMatch = [[Match alloc] initWithDictionary:responseObject error:&err];
                [self setParticipants];
                
                if (err) {
                    NSLog(@"Unable to convert match, %@", err.localizedDescription);
                    id tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder
                                    createExceptionWithDescription:[NSString stringWithFormat:@"Unable to convert match (evaluate), %@", err.localizedDescription] withFatal:@NO] build]];
                }
        }
            failure:^(NSURLSessionDataTask * operation, NSError * error) {
                [Global endProgress];
                NSLog(@"Error while retrieving match, %@", error.localizedDescription);
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:[NSString stringWithFormat:@"Unable to retrieve match (evaluate), %@", error.localizedDescription] withFatal:@NO] build]];
            }];
    }
    else {
        [self setParticipants];
    }

    //Put gradient on imageviews
    UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    UIColor *darkColor = [UIColor colorWithRed:.05 green:.05 blue:.05 alpha:0.70];

    
    self.otherMatcheeImage.layer.cornerRadius = self.otherMatcheeImage.frame.size.width/ 2;
    self.otherMatcheeImage.clipsToBounds = YES;
    CAGradientLayer *secondGradient = [CAGradientLayer layer];
    secondGradient.frame = self.otherMatcheeImage.bounds;
    secondGradient.colors = [NSArray arrayWithObjects:
                             (id)[darkColor CGColor],
                             (id)[transparentColor CGColor],
                             (id)[transparentColor CGColor],
                             nil];
    
    [self.otherMatcheeImage.layer insertSublayer:secondGradient atIndex:0];
    
    
    self.matcherImage.layer.cornerRadius = self.matcherImage.frame.size.height / 2.0f;
    self.matcherImage.clipsToBounds = YES;
    
    CAGradientLayer *firstGradient = [CAGradientLayer layer];
    firstGradient.frame = self.matcherImage.bounds;
    
    firstGradient.colors = [NSArray arrayWithObjects:
                            (id)[transparentColor CGColor],
                            (id)[transparentColor CGColor],
                            (id)[darkColor CGColor],
                            nil];
    [self.matcherImage.layer insertSublayer:firstGradient atIndex:0];
    
    
    //Give instructions if first time!
    BOOL isNotFirstEvaluateEver = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_NOT_FIRST_EVALUATE"];
    
    if (!isNotFirstEvaluateEver) {
        UIAlertView *evaluateInstructionsAlert = [[UIAlertView alloc] initWithTitle:@"What do you think?" message:@"Tap the ✓ if interested. If not, tap ✖︎. If you aren't sure, ask the matcher a question. \nRemember, the other person won't know your response unless you BOTH tap ✓!" delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
        [evaluateInstructionsAlert show];
    }
    
    // Do any additional setup after loading the view.
}

- (void) setParticipants {
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id.intValue == self.thisMatch.first_matchee.contact_id.intValue) {
        self.thisMatchee = self.thisMatch.first_matchee;
        self.otherMatchee = self.thisMatch.second_matchee;
    }
    else if (global.thisUser.contact_id.intValue == self.thisMatch.second_matchee.contact_id.intValue) {
        self.thisMatchee = self.thisMatch.second_matchee;
        self.otherMatchee = self.thisMatch.first_matchee;
    }
    else {
        NSLog(@"Error, this user is not in this match!");
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:[NSString stringWithFormat:@"User not in the evaluate match"] withFatal:@NO] build]];
    }
    
    if (self.thisMatch.is_anonymous) {
        UIImage *matcherImageSource;
        if ([self.thisMatch.matcher.guessed_gender isEqualToString:@"MALE"]) {
            matcherImageSource = [UIImage imageNamed:@"male"];
        }
        else if ([self.thisMatch.matcher.guessed_gender isEqualToString:@"FEMALE"]) {
            matcherImageSource = [UIImage imageNamed:@"female"];
        }
        else {
            matcherImageSource = [UIImage imageNamed:@"unknown_gender"];
        }
        self.matcherImage.image = matcherImageSource;
        self.matcherLabel.text = @"A friend";
    }
    else {
        [self.matcherImage sd_setImageWithURL:[NSURL URLWithString:self.thisMatch.matcher.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
        self.matcherLabel.text = self.thisMatch.matcher.guessed_full_name;
    }
    

    
//    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    dispatch_async(q, ^{
//        /* Fetch the image from the server... */
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.otherMatchee.image_url]];
//        UIImage *img = [[UIImage alloc] initWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            /* This is the main thread again, where we set the tableView's image to
//             be what we just fetched. */
//            
//            [self.otherMatcheeImage setImage: img];
//            
//
//
//            
//        });
//    });
    
    self.otherMatcheeLabel.text = self.otherMatchee.guessed_full_name;
    [self.otherMatcheeImage sd_setImageWithURL: [NSURL URLWithString:self.otherMatchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];

    
    NSString *statusText = @"thinks you'd be good with";
    if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"ACCEPT"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"ACCEPT"]) {
        self.otherMatcheeChatButton.hidden = NO;
        self.matchButton.hidden = YES;
        self.passButton.hidden = YES;
        statusText = [NSString stringWithFormat:@"recommended %@ and you both accepted!", self.otherMatchee.guessed_full_name];
    }
    else if ([self.thisMatchee.contact_status isEqualToString:@"NOTIFIED"]) {
        self.matchButton.hidden = NO;
        self.passButton.hidden = NO;
        self.otherMatcheeChatButton.hidden = YES;
        statusText = @"thinks you'd be good with";
    }
    else if ([self.otherMatchee.contact_status isEqualToString:@"NOTIFIED"]) {
        self.otherMatcheeChatButton.hidden = YES;
        self.matchButton.hidden = YES;
        self.passButton.hidden = YES;
        statusText = [NSString stringWithFormat:@"recommended %@ and you accepted. Waiting for...",self.otherMatchee.guessed_full_name];
    }
    self.descriptionLabel.text = statusText;
    
    [self checkChatsForUnreadMessages];
    
}


- (void) checkChatsForUnreadMessages {
    
    Global *global = [Global getInstance];
    NSNumber *contact_id = global.thisUser.contact_id;
    
    [Global get:@"hasUnread" withParams:@{@"contact_id":contact_id, @"chat_id":[NSNumber numberWithInt:self.thisMatch.chat_id]}
    success:^(NSURLSessionDataTask* operation, id responseObject) {
        NSDictionary *hasUnseen = responseObject;
        if ([[hasUnseen valueForKey:@"has_unseen"] boolValue]) {
            NSLog(@"Matchee Found unseen: %@", [responseObject description]);
            [self.otherMatcheeChatButton setImage:[UIImage imageNamed:@"new_chat_button_not_pressed"] forState:UIControlStateNormal];
        }
        else {
            NSLog(@"Matchee No Unseen: %@", [responseObject description]);
            [self.otherMatcheeChatButton setImage:[UIImage imageNamed:@"chat_button_not_pressed"] forState:UIControlStateNormal];

        }
    }
    failure:^(NSURLSessionDataTask * operation, NSError * error) {
        NSLog(@"Error while checking if other matchee has unseen, %@", error.localizedDescription);
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:[NSString stringWithFormat:@"Error checking other matchee unseen, %@", error.localizedDescription] withFatal:@NO] build]];
    }];
    
    [Global get:@"hasUnread" withParams:@{@"contact_id":contact_id, @"chat_id":[NSNumber numberWithInt:self.thisMatchee.matcher_chat_id]}
        success:^(NSURLSessionDataTask* operation, id responseObject) {
            NSDictionary *hasUnseen = responseObject;
            if ([[hasUnseen valueForKey:@"has_unseen"] boolValue]) {
                NSLog(@"Matcher Found unseen: %@", [responseObject description]);
                [self.askButton setImage:[UIImage imageNamed:@"new_chat_button_not_pressed"] forState:UIControlStateNormal];
            }
            else {
                NSLog(@"Matcher No Unseen: %@", [responseObject description]);
                [self.askButton setImage:[UIImage imageNamed:@"ask_button_not_pressed"] forState:UIControlStateNormal];

            }
        }
        failure:^(NSURLSessionDataTask * operation, NSError * error) {
            NSLog(@"Error while checking if matcher has unseen, %@", error.localizedDescription);
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:[NSString stringWithFormat:@"Error checking matcher unseen, %@", error.localizedDescription] withFatal:@NO] build]];
        }];
}

- (void) pushNotificationReceived: (NSNotification *) notification {
    [self checkChatsForUnreadMessages];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"EvaluateMatchViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:nil];
    
    [self checkChatsForUnreadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EvaluateToChat"]) {
        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]]) {
            ChatViewController *cvc = [segue destinationViewController];
            cvc.pair_id = self.thisMatch.pair_id;
            cvc.chat_id = self.chosen_chat_id;
            self.chosen_chat_id = 0;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"IS_NOT_FIRST_EVALUATE"];
        [defaults synchronize];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
