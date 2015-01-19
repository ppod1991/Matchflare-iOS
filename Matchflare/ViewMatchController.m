//
//  ViewMatchController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/9/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "ViewMatchController.h"
#import "Global.h"
#import "Match.h"
#import "Person.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ChatViewController.h"

@interface ViewMatchController ()
@property (strong, nonatomic) IBOutlet UIImageView *firstMatcheeImage;
@property (strong, nonatomic) IBOutlet UILabel *firstMatcheeLabel;

@property (strong, nonatomic) IBOutlet UILabel *secondMatcheeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *secondMatcheeImage;

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property int chosen_chat_id;
@property (strong, nonatomic) IBOutlet UIButton *firstMatcheeChatButton;
@property (strong, nonatomic) IBOutlet UIButton *secondMatcheeChatButton;

@end

@implementation ViewMatchController
- (IBAction)firstMatcheeChatButtonPressed:(id)sender {
    
    self.chosen_chat_id = self.thisMatch.first_matchee.matcher_chat_id;
    [self performSegueWithIdentifier:@"ViewToChat" sender:self];

}
- (IBAction)secondMatcheeChatButtonPressed:(id)sender {
    
    self.chosen_chat_id = self.thisMatch.second_matchee.matcher_chat_id;
    [self performSegueWithIdentifier:@"ViewToChat" sender:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.thisMatch == nil) {
        [Global startProgress];
        [Global get:@"match" withParams:@{@"pair_id":[NSNumber numberWithInt:self.pair_id]}
            success:^(NSURLSessionDataTask* operation, id responseObject) {
                [Global endProgress];
                NSError *err;
                if ((BOOL) responseObject) {
                    NSLog(@"Successfully retrieved match: %@", [responseObject description]);
                    self.thisMatch = [[Match alloc] initWithDictionary:responseObject error:&err];
                    [self setParticipants];
                }
                else {
                    NSLog(@"Failed to retrieve match: %@", [responseObject description]);
                }
                
                if (err) {
                    NSLog(@"Unable to convert match, %@", err.localizedDescription);
                }
            }
            failure:^(NSURLSessionDataTask * operation, NSError * error) {
                [Global endProgress];
                NSLog(@"Error while retrieving match, %@", error.localizedDescription);
            }];
    }
    else {
        [self setParticipants];
    }
    
    //Put gradient on imageviews
    UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    UIColor *darkColor = [UIColor colorWithRed:.05 green:.05 blue:.05 alpha:0.70];
    
    
    self.firstMatcheeImage.layer.cornerRadius = self.firstMatcheeImage.frame.size.width / 2.0f;
    self.firstMatcheeImage.clipsToBounds = YES;

    CAGradientLayer *firstGradient = [CAGradientLayer layer];
    firstGradient.frame = self.firstMatcheeImage.bounds;
    
    firstGradient.colors = [NSArray arrayWithObjects:
                            (id)[transparentColor CGColor],
                            (id)[transparentColor CGColor],
                            (id)[darkColor CGColor],
                            nil];
    [self.firstMatcheeImage.layer insertSublayer:firstGradient atIndex:0];
    
    
    self.secondMatcheeImage.layer.cornerRadius = self.secondMatcheeImage.frame.size.height / 2;
    self.secondMatcheeImage.clipsToBounds = YES;
    
    CAGradientLayer *secondGradient = [CAGradientLayer layer];
    secondGradient.frame = self.secondMatcheeImage.bounds;
    secondGradient.colors = [NSArray arrayWithObjects:
                             (id)[darkColor CGColor],
                             (id)[transparentColor CGColor],
                             (id)[transparentColor CGColor],
                             nil];
    
    [self.secondMatcheeImage.layer insertSublayer:secondGradient atIndex:0];
    // Do any additional setup after loading the view.
}

- (void) setParticipants {
    
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
    
    self.firstMatcheeLabel.text = self.thisMatch.first_matchee.guessed_full_name;
    [self.firstMatcheeImage sd_setImageWithURL: [NSURL URLWithString:self.thisMatch.first_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
    
    self.secondMatcheeLabel.text = self.thisMatch.second_matchee.guessed_full_name;
    [self.secondMatcheeImage sd_setImageWithURL: [NSURL URLWithString:self.thisMatch.second_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
    
    NSString *statusText = @"waiting...";
    if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"NOTIFIED"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"NOT_SENT"]) {
        statusText = [NSString stringWithFormat:@"waiting for %@...",self.thisMatch.first_matchee.guessed_full_name];
        self.secondMatcheeChatButton.hidden = YES;
        self.firstMatcheeChatButton.hidden = NO;
    }
    else if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"NOT_SENT"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"NOTIFIED"]) {
        statusText = [NSString stringWithFormat:@"waiting for %@...",self.thisMatch.second_matchee.guessed_full_name];
        self.firstMatcheeChatButton.hidden = YES;
        self.secondMatcheeChatButton.hidden = NO;
    }
    else if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"ACCEPT"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"NOTIFIED"]) {
        statusText = [NSString stringWithFormat:@"waiting for %@...",self.thisMatch.second_matchee.guessed_full_name];
        self.firstMatcheeChatButton.hidden = YES;
        self.secondMatcheeChatButton.hidden = NO;
    }
    else if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"NOTIFIED"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"ACCEPT"]) {
        statusText = [NSString stringWithFormat:@"waiting for %@...",self.thisMatch.first_matchee.guessed_full_name];
        self.firstMatcheeChatButton.hidden = NO;
        self.secondMatcheeChatButton.hidden = YES;
    }
    else if ([self.thisMatch.first_matchee.contact_status isEqualToString:@"ACCEPT"] && [self.thisMatch.second_matchee.contact_status isEqualToString:@"ACCEPT"]) {
        statusText = [NSString stringWithFormat:@"they both accepted!"];
        self.firstMatcheeChatButton.hidden = NO;
        self.secondMatcheeChatButton.hidden = NO;
    }
    
    self.descriptionLabel.text = statusText;
    
    [self checkChatsForUnreadMessages];
    
    
    
    
    
}


- (void) checkChatsForUnreadMessages {
    
    Global *global = [Global getInstance];
    NSNumber *contact_id = global.thisUser.contact_id;
    
    [Global get:@"hasUnread" withParams:@{@"contact_id":contact_id, @"chat_id":[NSNumber numberWithInt:self.thisMatch.first_matchee.matcher_chat_id]}
        success:^(NSURLSessionDataTask* operation, id responseObject) {
            NSDictionary *hasUnseen = responseObject;
            if ([[hasUnseen valueForKey:@"has_unseen"] boolValue]) {
                NSLog(@"First Matchee Found unseen: %@", [responseObject description]);
                [self.firstMatcheeChatButton setImage:[UIImage imageNamed:@"new_chat_button_not_pressed"] forState:UIControlStateNormal];
            }
            else {
                NSLog(@"First Matchee No Unseen: %@", [responseObject description]);
                [self.firstMatcheeChatButton setImage:[UIImage imageNamed:@"chat_button_not_pressed"] forState:UIControlStateNormal];

            }
        }
        failure:^(NSURLSessionDataTask * operation, NSError * error) {
            NSLog(@"Error while checking if first matchee has unseen, %@", error.localizedDescription);
        }];
    
    [Global get:@"hasUnread" withParams:@{@"contact_id":contact_id, @"chat_id":[NSNumber numberWithInt:self.thisMatch.second_matchee.matcher_chat_id]}
        success:^(NSURLSessionDataTask* operation, id responseObject) {
            NSDictionary *hasUnseen = responseObject;
            if ([[hasUnseen valueForKey:@"has_unseen"] boolValue]) {
                NSLog(@"Second Matchee Found unseen: %@", [responseObject description]);
                [self.secondMatcheeChatButton setImage:[UIImage imageNamed:@"new_chat_button_not_pressed"] forState:UIControlStateNormal];
            }
            else {
                NSLog(@"Second Matchee No Unseen: %@", [responseObject description]);
                [self.secondMatcheeChatButton setImage:[UIImage imageNamed:@"chat_button_not_pressed"] forState:UIControlStateNormal];

            }
        }
        failure:^(NSURLSessionDataTask * operation, NSError * error) {
            NSLog(@"Error while checking if second matchee has unseen, %@", error.localizedDescription);
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:nil];
    
    [self checkChatsForUnreadMessages];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewToChat"]) {
        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]]) {
            ChatViewController *cvc = [segue destinationViewController];
            cvc.pair_id = self.thisMatch.pair_id;
            cvc.chat_id = self.chosen_chat_id;
            self.chosen_chat_id = 0;
        }
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
