//
//  PresentMatchesViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/29/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "PresentMatchesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MatcheeOptionsViewController.h"
#import "Global.h"
#import <M13Checkbox.h>
#import "UpdateProfileViewController.h"
#import <BBBadgeBarButtonItem.h>
#import "NotificationLists.h"
#import "NotificationTableViewController.h"
#import "RegisterViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface PresentMatchesViewController() <UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) UIView *currentView;
@property (strong, nonatomic) CATransition *returnAnimation;
@property (strong, nonatomic) CATransition *quickAnimation;
@property (strong, nonatomic) NSString *currentDescription;
@property BOOL isFirst; //For long press--determines whether first or second matchee was long pressed
@property int initialX;
@property (strong, nonatomic) M13Checkbox *anonymous_checkbox;
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) NotificationLists *notifications;
@property BOOL wasChecked;
@property (strong, nonatomic) UITapGestureRecognizer *anonymousTap;
@end

@implementation PresentMatchesViewController

- (IBAction)moreOptionsPressed:(id)sender {
    
    Global *global = [Global getInstance];
    
    NSString *updateString = @"Update profile";
    
    NSString *preventString = @"Stop getting matches";
    if (global.thisUser.blocked_matches) {
        preventString = @"Resume getting matches";
    }
    
    if (!(global.thisUser.contact_id > 0)) {
        updateString = @"Register!";
        preventString = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:updateString,preventString, nil];
    [actionSheet showInView:self.view];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (([Global getInstance].thisUser.contact_id > 0)) {
            [self performSegueWithIdentifier:@"PresentToUpdate" sender:self];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentUpdatedProfilePressed"
                                                                   value:nil] build]];
        }
        else {
            [self performSegueWithIdentifier:@"PresentToRegister" sender:self];
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentRegisterPressed"
                                                                   value:nil] build]];
        }
    }
    else if (buttonIndex == 1) {
        //Change prevent Matches status
        Person* thisUser = [Global getInstance].thisUser;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentPreventStatusPressed"
                                                               value:nil] build]];
        
        [Global postTo:@"preventMatches" withParams:@{@"contact_id":thisUser.contact_id,@"toPreventMatches":[NSNumber numberWithBool:!thisUser.blocked_matches]} withBody:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Sucessfully changed prevent matches status");
            thisUser.blocked_matches = !thisUser.blocked_matches;
            if (thisUser.blocked_matches) {
                [Global showToastWithText:@"You won't receive more matches :("];
            }
            else {
                [Global showToastWithText:@"You are back on the market!"];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failed to change prevent match status: %@", error.localizedDescription);
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:[NSString stringWithFormat:@"Failed to change prevent match status, %@", error.localizedDescription] withFatal:@NO] build]];
        }];
    }
}


- (IBAction) choseNewMatchee:(UIStoryboardSegue *) segue {
    if ([segue.identifier isEqualToString:@"ChoseToPresent"]) {
        if ([segue.sourceViewController isKindOfClass:[MatcheeOptionsViewController class]]) {
            MatcheeOptionsViewController *mvc = segue.sourceViewController;
            if (mvc.isFirstMatchee) {
                self.currentMatch.first_matchee = mvc.chosenMatchee;
            }
            else {
                self.currentMatch.second_matchee = mvc.chosenMatchee;
            }
            
            if ([self.currentView isEqual:self.matchOne]) {
                [self loadMatch:self.currentMatch isFirstView:YES];
            }
            else if ([self.currentView isEqual:self.matchTwo]) {
                [self loadMatch:self.currentMatch isFirstView:NO];

            }

        }
    }
}

- (IBAction) blockedMatchee:(UIStoryboardSegue *) segue {
    if ([segue.identifier isEqualToString:@"BlockToPresent"]) {
        if ([segue.sourceViewController isKindOfClass:[MatcheeOptionsViewController class]]) {
            MatcheeOptionsViewController *mvc = segue.sourceViewController;
            NSLog([NSString stringWithFormat:@"Simulated--NOT showing %@ anymore",mvc.existingMatchee.guessed_full_name]);
            [Global postTo:@"removeContact" withParams:@{@"contact_id":[Global getInstance].thisUser.contact_id,@"to_remove_contact_id":mvc.existingMatchee.contact_id} withBody:nil success:^(NSURLSessionDataTask *task , id responseObject) {
                NSLog(@"Successfully blocked this user");
                [Global showToastWithText:@"You won't see this person anymore!"];
            } failure:^(NSURLSessionDataTask *task, NSError *err) {
                NSLog(@"Failed to block this user: %@",err.localizedDescription);
                
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:[NSString stringWithFormat:@"Failed to block matchee, %@", err.localizedDescription] withFatal:@NO] build]];
                
            }];
            [self presentNextMatch:true];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentMatcheeBlocked"
                                                                   value:nil] build]];
        }
    }
}


- (IBAction)didPanFirst:(UIPanGestureRecognizer *)sender {
    
    
    int xVelocity = [sender velocityInView:sender.view].x;
    NSLog(@"velocity: %d",xVelocity);
    int deltaX = self.currentView.center.x - self.initialX;
    NSLog(@"deltaX: %d", deltaX);
    
    if(sender.state==UIGestureRecognizerStateBegan)
    {
        self.initialX = self.currentView.center.x;
        NSLog(@"Pan began");
    }
    else if(sender.state==UIGestureRecognizerStateEnded || sender.state==UIGestureRecognizerStateCancelled || sender.state==UIGestureRecognizerStateFailed)
    {

        BOOL completed = NO;
        if (deltaX < -50 || xVelocity < -400) {
            NSLog(@"Left swipe");
            if([self passTriggered]) {
                completed = YES;
            }
        }
        else if (deltaX > 50 || xVelocity > 400) {
            NSLog(@"Right swipe");
            if ([self matchTriggered]) {
                completed = YES;
            }
        }
        
        if (!completed)
        {
            NSLog(@"Reset");
            
            self.descriptionLabel.text = self.currentDescription;
            self.descriptionLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.8];
            
            [UIView animateWithDuration:0.15
                             animations:^{
                                 if ([self.currentView isEqual:self.matchOne] ) {
                                     self.firstLeadingSpace.constant = 0.0f;
                                 }
                                 else if ([self.currentView isEqual:self.matchTwo]) {
                                     self.secondLeadingSpace.constant = 0.0f;
                                 }
                                 
                                 
                                 
                                 [sender setTranslation:CGPointMake(0, 0) inView:self.view];
                                 [self.view layoutIfNeeded];
                             }];
            
        }
    }
    else {
        
        CGPoint translation = [sender translationInView:self.view];

        
        if ([self.currentView isEqual:self.matchOne] ) {
            self.firstLeadingSpace.constant = self.firstLeadingSpace.constant + translation.x;
        }
        else if ([self.currentView isEqual:self.matchTwo]) {
            self.secondLeadingSpace.constant = self.secondLeadingSpace.constant + translation.x;
        }
        
        
        
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        [self.view layoutIfNeeded];
        
        if (deltaX < -50) {
            self.descriptionLabel.text = @"no";
            self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
        }
        else if (deltaX > 50) {
            self.descriptionLabel.text = @"yes!";
            self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
        }
        else {
            self.descriptionLabel.text = self.currentDescription;
            self.descriptionLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.8];
        }
        

    }
    

}



- (IBAction)firstTouchDown:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSLog(@"First touch down");
    if ([self.currentView isEqual:self.matchOne]) {
        [UIView transitionWithView:self.firstMatcheeName duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.firstMatcheeName.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8];
        } completion:^(BOOL finished) {
        }];
    }
    else if ([self.currentView isEqual:self.matchTwo]) {
        [UIView transitionWithView:self.nextFirstMatcheeName duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.nextFirstMatcheeName.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8];
        } completion:^(BOOL finished) {
        }];
    }
}
- (IBAction)firstTouchCancel:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"First touch cancel");
    self.firstMatcheeName.textColor = [UIColor whiteColor];
    self.nextFirstMatcheeName.textColor = [UIColor whiteColor];
    

}
- (IBAction)firstTouchUp:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"First touch up");
    self.firstMatcheeName.textColor = [UIColor whiteColor];
    self.nextFirstMatcheeName.textColor = [UIColor whiteColor];
    //[self presentNextMatch];

}

- (IBAction)secondTouchDown:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"Second touch down");
    NSLog(@"First touch down");
    if ([self.currentView isEqual:self.matchOne]) {
        [UIView transitionWithView:self.secondMatcheeName duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.secondMatcheeName.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8];
        } completion:^(BOOL finished) {
        }];
    }
    else if ([self.currentView isEqual:self.matchTwo]) {
        [UIView transitionWithView:self.nextSecondMatcheeName duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.nextSecondMatcheeName.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8];
        } completion:^(BOOL finished) {
        }];
    }

}

- (IBAction)secondTouchCancel:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"Second touch cancel");
    self.secondMatcheeName.textColor = [UIColor whiteColor];
    self.nextSecondMatcheeName.textColor = [UIColor whiteColor];


}

- (IBAction)secondTouchUp:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"Second touch up");
    self.secondMatcheeName.textColor = [UIColor whiteColor];
    self.nextSecondMatcheeName.textColor = [UIColor whiteColor];

    //[self presentNextMatch];
}


- (IBAction)firstLongLong:(UILongPressGestureRecognizer *)sender {
    

    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"First long long");
        self.firstMatcheeName.textColor = [UIColor whiteColor];
        self.nextFirstMatcheeName.textColor = [UIColor whiteColor];
        self.isFirst = YES;
        [self showMatcheeOptions];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentFirstMatcheeOptionsPressed"
                                                               value:nil] build]];
    }
}

- (IBAction)secondLongLong:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"Second long long");
        self.secondMatcheeName.textColor = [UIColor whiteColor];
        self.nextSecondMatcheeName.textColor = [UIColor whiteColor];
        self.isFirst = NO;
        [self showMatcheeOptions];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentSecondMatcheeOptionsPressed"
                                                               value:nil] build]];
    }
}

- (void) showMatcheeOptions {
    [self performSegueWithIdentifier:@"PresentToOptions" sender:self];
}

- (BOOL) passTriggered {
    NSLog(@"Pass button pressed!");
    [self presentNextMatch: true];
    [self.descriptionLabel.layer addAnimation:self.quickAnimation forKey:@"changeTextTransition"];
    self.descriptionLabel.text = @"match passed";
    self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"PresentPassMatchTriggered"
                                                           value:nil] build]];
    
    return YES;
    
}
- (IBAction)passButtonPressed:(id)sender {
    [self passTriggered];
}

- (BOOL) matchTriggered {
    BOOL isNotFirstMatchEver = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_NOT_FIRST_MATCH"];
    
    if (isNotFirstMatchEver) {
        Global *global = [Global getInstance];
        if (!(global.thisUser.contact_id > 0)) {
            UIAlertView *registerInstructionsAlert = [[UIAlertView alloc] initWithTitle:@"Hold up, Cupid!" message:@"You need to register before matching someone!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [registerInstructionsAlert show];
            [self performSegueWithIdentifier:@"PresentToRegister" sender:self];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentAttemptedMatchWithoutRegistering"
                                                                   value:nil] build]];
            
            return NO;
        }
        else if (self.currentMatch.first_matchee.contact_id == global.thisUser.contact_id || self.currentMatch.second_matchee.contact_id == global.thisUser.contact_id){
            [Global showToastWithText:@"Tricky--sorry, you can't match yourself"];
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentAttemptedSelfMatch"
                                                                   value:nil] build]];
            return NO;
        }
        else if (self.currentMatch.first_matchee.contact_id == self.currentMatch.second_matchee.contact_id) {
            [Global showToastWithText:@"You can't match the same person, silly!"];
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PresentAttemptedSamePersonMatch"
                                                                   value:nil] build]];
            return NO;
        }
        else {
            self.currentMatch.match_status = @"MATCHED";
            if (self.anonymous_checkbox.checkState == M13CheckboxStateChecked) {
                self.currentMatch.is_anonymous = YES;
                
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:@"PresentMatchTriggeredAnonymously"
                                                                       value:nil] build]];
            }
            else if (self.anonymous_checkbox.checkState == M13CheckboxStateUnchecked) {
                self.currentMatch.is_anonymous = NO;
                
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:@"PresentMatchTriggeredUnanonymously"
                                                                       value:nil] build]];
            }
            else if (self.anonymous_checkbox.checkState == M13CheckboxStateMixed) {
                self.currentMatch.is_anonymous = NO;
                if (self.wasChecked) {
                    [Global showToastWithText:@"Can't match anonymously :("];
                }
                
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:@"PresentMatchTriggeredUnanonymously"
                                                                       value:nil] build]];
            }
            

            
            [self addMatchResult];
            [self presentNextMatch: false];
            [self.descriptionLabel.layer addAnimation:self.quickAnimation forKey:@"changeTextTransition"];
            self.descriptionLabel.text = @"match made";
            self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
            return YES;
        }
    }
    else {
        UIAlertView *matchInstructionsAlert = [[UIAlertView alloc] initWithTitle:@"Go Cupid!" message:@"We're about to alert one friend (via SMS or push notification) that you think they should meet!*\n\n *std rates apply" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do it!",nil];
        [matchInstructionsAlert show];
        return NO;
    }
    
};

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentCancelUponMatchInstructions"
                                                               value:nil] build]];
    }
    else if (buttonIndex == 1) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentAcceptUponMatchInstructions"
                                                               value:nil] build]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"IS_NOT_FIRST_MATCH"];
        [defaults synchronize];
        [self matchTriggered];
    }
}
- (void) addMatchResult {
    Global *global = [Global getInstance];
    self.currentMatch.matcher.contact_id  = global.thisUser.contact_id;
    
    [Global postTo:@"postMatch" withParams:nil withBody:self.currentMatch
           success:^(NSURLSessionDataTask* operation, id responseObject) {
               NSDictionary *response = responseObject;
               NSNumber *score = [response objectForKey:@"matchflare_score"];
               self.scoreLabel.text = [NSString stringWithFormat:@"%@",score];
           }
           failure:^(NSURLSessionDataTask * operation, NSError * error) {
               NSLog(@"Error while retrieving score, %@", error.localizedDescription);
               id tracker = [[GAI sharedInstance] defaultTracker];
               [tracker send:[[GAIDictionaryBuilder
                               createExceptionWithDescription:[NSString stringWithFormat:@"Error retrieving matchflare score, %@", error.localizedDescription] withFatal:@NO] build]];
           }];
    
}

- (IBAction)matchButtonPressed:(id)sender {
    [self matchTriggered];
    NSLog(@"Match button pressed!");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //do what you need to do when animation ends...
    [NSTimer scheduledTimerWithTimeInterval:0.35
                                     target:self
                                   selector:@selector(updateCurrentDescription)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) updateCurrentDescription {
    [self.descriptionLabel.layer addAnimation:self.returnAnimation forKey:@"changeTextTransition"];
    self.descriptionLabel.text = self.currentDescription;
    self.descriptionLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.8]; //Light gray
};

- (void) notificationButtonPressed {
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id > 0) {
        [self performSegueWithIdentifier:@"PresentToNotification" sender:self];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentNotificationsPressed"
                                                               value:nil] build]];
        
    }
    else {
        UIAlertView *registerInstructionsAlert = [[UIAlertView alloc] initWithTitle:@"Hold up, Cupid!" message:@"You need to register to see your matches and notifications!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [registerInstructionsAlert show];
        [self performSegueWithIdentifier:@"PresentToRegister" sender:self];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentNotificationsPressedWhileUnregistered"
                                                               value:nil] build]];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Set-Up notification bar button
    UIButton *notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImage *notificationIcon = [UIImage imageNamed:@"notification_icon"];
    [notificationButton setContentMode:UIViewContentModeScaleAspectFill];
    notificationIcon = [notificationIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [notificationButton addTarget:self action:@selector(notificationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [notificationButton setImage:notificationIcon forState:UIControlStateNormal];
    
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:notificationButton];
    self.barButton.badgeValue = @"1";
    self.barButton.shouldHideBadgeAtZero = YES;
    self.barButton.shouldAnimateBadge = YES;
    self.barButton.badgeOriginX = 17.0f;
    self.barButton.badgeOriginY = 2.0f;
    self.barButton.badgeMinSize = 0.0f;
    //self.barButton.ba
    self.barButton.badgeBGColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:1.0]; //Matchflare pink
    self.barButton.badgeFont = [UIFont fontWithName:@"OpenSans-Light" size:8.0f];
    self.navigationItem.rightBarButtonItem = self.barButton;
    self.barButton.badgePadding = 2.0f;
    
    //Change fonts + other styling
    self.firstMatcheeName.font = [UIFont fontWithName:@"OpenSans-Light" size:26.0];
    self.secondMatcheeName.font = [UIFont fontWithName:@"OpenSans-Light" size:26.0];
    self.descriptionLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
    
    //Set-Up description animation
    self.quickAnimation = [CATransition animation];
    self.quickAnimation.duration = 0.15;
    self.quickAnimation.delegate = self;
    self.quickAnimation.type = kCATransitionMoveIn;
    self.quickAnimation.subtype = kCATransitionFromBottom;
    self.quickAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.returnAnimation = [CATransition animation];
    self.returnAnimation.duration = 0.15;
    self.returnAnimation.type = kCATransitionMoveIn;
    self.returnAnimation.subtype = kCATransitionFromBottom;
    self.returnAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.currentDescription = @"should they meet?";
    [self updateCurrentDescription];
    
    self.descriptionLabel.text = self.currentDescription;

    
    
    
    //Make images circular
    self.firstMatcheeImage.layer.cornerRadius = self.firstMatcheeImage.frame.size.width / 2;
    self.firstMatcheeImage.clipsToBounds = YES;
    self.secondMatcheeImage.layer.cornerRadius = self.secondMatcheeImage.frame.size.width / 2;
    self.secondMatcheeImage.clipsToBounds = YES;
    
    //Put gradient on imageviews
    UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    UIColor *darkColor = [UIColor colorWithRed:.05 green:.05 blue:.05 alpha:0.70];
    
    CAGradientLayer *firstGradient = [CAGradientLayer layer];
    firstGradient.frame = self.firstMatcheeImage.bounds;
    
    firstGradient.colors = [NSArray arrayWithObjects:
                            (id)[transparentColor CGColor],
                            (id)[transparentColor CGColor],
                            (id)[darkColor CGColor],
                            nil];
    
    [self.firstMatcheeImage.layer insertSublayer:firstGradient atIndex:0];
    
    CAGradientLayer *secondGradient = [CAGradientLayer layer];
    secondGradient.frame = self.secondMatcheeImage.bounds;
    secondGradient.colors = [NSArray arrayWithObjects:
                             (id)[darkColor CGColor],
                             (id)[transparentColor CGColor],
                             (id)[transparentColor CGColor],
                             nil];
    
    [self.secondMatcheeImage.layer insertSublayer:secondGradient atIndex:0];
    
    
    self.nextFirstMatcheeName.font = [UIFont fontWithName:@"OpenSans-Light" size:26.0];
    self.nextSecondMatcheeName.font = [UIFont fontWithName:@"OpenSans-Light" size:26.0];
    
    
    //Make images circular
    self.nextFirstMatcheeImage.layer.cornerRadius = self.nextFirstMatcheeImage.frame.size.width / 2;
    self.nextFirstMatcheeImage.clipsToBounds = YES;
    self.nextSecondMatcheeImage.layer.cornerRadius = self.nextSecondMatcheeImage.frame.size.width / 2;
    self.nextSecondMatcheeImage.clipsToBounds = YES;
    
    //Put gradient on imageviews
    
    CAGradientLayer *nextFirstGradient = [CAGradientLayer layer];
    nextFirstGradient.frame = self.nextFirstMatcheeImage.bounds;
    
    nextFirstGradient.colors = [NSArray arrayWithObjects:
                            (id)[transparentColor CGColor],
                            (id)[transparentColor CGColor],
                            (id)[darkColor CGColor],
                            nil];
    
    [self.nextFirstMatcheeImage.layer insertSublayer:nextFirstGradient atIndex:0];
    
    CAGradientLayer *nextSecondGradient = [CAGradientLayer layer];
    nextSecondGradient.frame = self.nextSecondMatcheeImage.bounds;
    nextSecondGradient.colors = [NSArray arrayWithObjects:
                             (id)[darkColor CGColor],
                             (id)[transparentColor CGColor],
                             (id)[transparentColor CGColor],
                             nil];
    
    [self.nextSecondMatcheeImage.layer insertSublayer:nextSecondGradient atIndex:0];
    
    self.currentView = self.matchOne;
    
    //Initialize anonymous checkbox
    self.anonymous_checkbox = [[M13Checkbox alloc] initWithTitle:@"anonymous?"];
    self.anonymous_checkbox.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
    self.anonymous_checkbox.titleLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.7];
    self.anonymous_checkbox.strokeColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.7];
    self.anonymous_checkbox.strokeWidth = 0.6;

        self.anonymous_checkbox.checkColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:1.0]; //Matchflare pink
    self.anonymous_checkbox.frame = CGRectMake(self.anonymous_checkbox.frame.origin.x,self.anonymous_checkbox.frame.origin.y,self.anonymous_checkbox.frame.size.width,self.anonymous_checkbox.frame.size.height);
    self.anonymous_checkbox.checkHeight = 13;
        //[self.anonymous_checkbox autoFitWidthToText];
    self.anonymous_checkbox.tintColor = [UIColor clearColor];
    self.anonymous_checkbox.radius = 0.7;
    [self.anonymous_checkbox setCheckAlignment:M13CheckboxAlignmentLeft];
    self.anonymousTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(anonymousTapped:)];
    //[self.anonymous_checkbox addTarget:self action:@selector(anonymousTapped:) forControlEvents:UIControlEventTouchDown];
    [self.checkboxView addSubview:self.anonymous_checkbox];
    [self.view bringSubviewToFront:self.checkboxView];

    //Add touch recognizer to the score label
    [self.scoreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreTapped:)]];
    [self.scoreLabel setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.scoreLabel];

}

- (void) scoreTapped: (id) sender {
    UIAlertView *anonymousAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your Matchflare Score:%@",self.scoreLabel.text] message:@"The more matches you make, the higher your score!\n\nThe higher your score, the more likely you are to get matched!" delegate:self cancelButtonTitle:@"got it!" otherButtonTitles:nil];
    [anonymousAlert show];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"PresentScoreLabelTapped"
                                                           value:nil] build]];
}

- (void) slideOutView:(UIView *) mView toLeft: (BOOL) toLeft{
    
//    if ([mView isEqual:self.matchOne] ) {
//        self.firstLeadingSpace.constant = 0.0f;
//    }
//    else if ([mView isEqual:self.matchTwo]) {
//        self.secondLeadingSpace.constant = 0.0f;
//    }
//    
//    [self.view layoutIfNeeded];
    float directionalConstant;
    if (toLeft) {
        directionalConstant = -1.0f;
    }
    else {
        directionalConstant = +1.0f;
    }
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         if ([mView isEqual:self.matchOne] ) {
                             
                             self.firstLeadingSpace.constant = mView.frame.size.width * directionalConstant;
                         }
                         else if ([mView isEqual:self.matchTwo]) {
                             self.secondLeadingSpace.constant = mView.frame.size.width * directionalConstant;
                         }
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [mView setHidden:true];
                             if ([mView isEqual:self.matchOne] ) {
                                 [self loadMatch:self.nextMatch isFirstView:true];
                             }
                             else if ([mView isEqual:self.matchTwo]) {
                                 [self loadMatch:self.nextMatch isFirstView:false];
                             }
                             
                         }
                     }];
}

- (void) slideInView:(UIView *) mView fromLeft:(BOOL) fromLeft {
    
    float directionalConstant;
    if (fromLeft) {
        directionalConstant = +1.0f;
    }
    else {
        directionalConstant = -1.0f;
    }
    
    [mView setHidden:false];
    if ([mView isEqual:self.matchOne] ) {
        self.firstLeadingSpace.constant = mView.frame.size.width * directionalConstant;
    }
    else if ([mView isEqual:self.matchTwo]) {
        self.secondLeadingSpace.constant = mView.frame.size.width * directionalConstant;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.15
                     animations:^{
                         if ([mView isEqual:self.matchOne] ) {
                             self.firstLeadingSpace.constant = 0.0f;
                         }
                         else if ([mView isEqual:self.matchTwo]) {
                             self.secondLeadingSpace.constant = 0.0f;
                         }
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

- (void) getMoreMatches {
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id > 0) {
        [Global postTo:@"getMatches" withParams:@{@"contact_id":global.thisUser.contact_id} withBody:global.thisUser
               success:^(NSURLSessionDataTask* operation, id responseObject) {
                   NSMutableArray *matches = [Match arrayOfModelsFromDictionaries:responseObject];
                   if (!matches) {
                       NSLog(@"Unable to convert array of matches");
                   }
                   else {
                       if (!self.matches) {
                           self.matches = (NSMutableArray <Match>*)[[NSMutableArray alloc] init];
                       }
                       
                       [self.matches addObjectsFromArray:matches];
                       
                       if (!self.currentMatch) {
                           [Global endProgress];
                           [self presentNextMatch:YES];
                       }
                   }
               }
               failure:^(NSURLSessionDataTask * operation, NSError * error) {
                   NSLog(@"Error while retrieving matches to present, %@", error.localizedDescription);
                   id tracker = [[GAI sharedInstance] defaultTracker];
                   [tracker send:[[GAIDictionaryBuilder
                                   createExceptionWithDescription:[NSString stringWithFormat:@"Error retrieving matches to present, %@", error.localizedDescription] withFatal:@NO] build]];
               }];
    }
}

- (void) pushNotificationReceived: (NSNotification *) notification {
    [self updateNotifications];
}

- (void) updateNotifications {
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id > 0) {
        [Global get:@"notificationLists" withParams:@{@"contact_id":global.thisUser.contact_id}
            success:^(NSURLSessionDataTask* operation, id responseObject) {
                NSError *err;
                
                NSLog(@"Successfully retrieved notifications: %@", [responseObject description]);
                self.notifications = [[NotificationLists alloc] initWithDictionary:responseObject error:&err];
                if (self.notifications.notifications) {
                    self.barButton.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.notifications.notifications.count];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.notifications.notifications.count];
                }
                
                if (err) {
                    NSLog(@"Unable to convert notifications, %@", err.localizedDescription);
                    id tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder
                                    createExceptionWithDescription:[NSString stringWithFormat:@"Unable convert notifications (Present), %@", err.localizedDescription] withFatal:@NO] build]];
                }
            }
            failure:^(NSURLSessionDataTask * operation, NSError * error) {
                [Global endProgress];
                NSLog(@"Unable to retrieve notifications, %@", error.localizedDescription);
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:[NSString stringWithFormat:@"Unable to retrieve notifications (Present), %@", error.localizedDescription] withFatal:@NO] build]];
            }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"PresentMatchesViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:nil];

    
    if (self.matches && self.matches.count > 0) {
        //Has matches ready to show
        if (!self.currentMatch) {
            [self presentNextMatch: true];
        }
    }
    else {
        [self getMoreMatches];
        [Global startProgress];
    }
    [self getAndSetScore];
    [self updateNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) presentNextMatch:(BOOL)toLeft {

    if (self.currentMatch == nil) {
        if (self.matches.count > 1) {
            self.currentMatch = [self.matches firstObject];
            [self.matches removeObjectAtIndex:0];
            self.nextMatch = [self.matches firstObject];
            [self.matches removeObjectAtIndex:0];
            [self loadMatch:self.currentMatch isFirstView:true];
            [self loadMatch:self.nextMatch isFirstView:false];
        }
    }
    else {
        self.currentMatch = self.nextMatch;
        self.nextMatch = [self.matches firstObject];
        [self.matches removeObjectAtIndex:0];
        
        if ([self.currentView isEqual:self.matchOne]) {
            self.nextFirstMatcheeName.textColor = [UIColor whiteColor];
            self.nextSecondMatcheeName.textColor = [UIColor whiteColor];
            [self slideOutView:self.matchOne toLeft: toLeft];
            [self slideInView:self.matchTwo fromLeft: toLeft];
//            [self loadMatch:self.nextMatch isFirstView:true];
            self.currentView = self.matchTwo;
        }
        else if ([self.currentView isEqual:self.matchTwo]) {
            self.firstMatcheeName.textColor = [UIColor whiteColor];
            self.secondMatcheeName.textColor = [UIColor whiteColor];
            [self slideOutView:self.matchTwo toLeft: toLeft];
            [self slideInView:self.matchOne fromLeft: toLeft];
//            [self loadMatch:self.nextMatch isFirstView:false];
            self.currentView = self.matchOne;
        }
    }
    
    

    
    if (self.matches.count < 10) {
        [self getMoreMatches];
    }
}

- (void) getAndSetScore {
    Global *global = [Global getInstance];
    if (global.thisUser.contact_id > 0) {
        [Global get:@"getScore" withParams:@{@"contact_id":global.thisUser.contact_id}
               success:^(NSURLSessionDataTask* operation, id responseObject) {
                   NSDictionary *response = responseObject;
                   NSNumber *score = [response objectForKey:@"matchflare_score"];
                   self.scoreLabel.text = [NSString stringWithFormat:@"%@",score];
               }
               failure:^(NSURLSessionDataTask * operation, NSError * error) {
                   NSLog(@"Error while retrieving score, %@", error.localizedDescription);
                   id tracker = [[GAI sharedInstance] defaultTracker];
                   [tracker send:[[GAIDictionaryBuilder
                                   createExceptionWithDescription:[NSString stringWithFormat:@"Error retrieving matchflare score, %@", error.localizedDescription] withFatal:@NO] build]];
               }];
    }

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PresentToOptions"]) {
        if ([segue.destinationViewController isKindOfClass:[MatcheeOptionsViewController class]]) {
            MatcheeOptionsViewController *mvc = [segue destinationViewController];
            mvc.isFirstMatchee = self.isFirst;
            if (self.isFirst) {
                mvc.existingMatchee = self.currentMatch.first_matchee;
            }
            else {
                mvc.existingMatchee = self.currentMatch.second_matchee;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"PresentToNotification"]) {
        if ([segue.destinationViewController isKindOfClass:[NotificationTableViewController class]]) {
            NotificationTableViewController *ntvc = [segue destinationViewController];
            ntvc.notifications = self.notifications;
        }
    }
    else if ([segue.identifier isEqualToString:@"PresentToRegister"]) {
        if ([segue.destinationViewController isKindOfClass:[RegisterViewController class]]) {
            RegisterViewController *rvc = [segue destinationViewController];
            rvc.isFromPresent = YES;
        }
    }
}


- (void) loadMatch:(Match*) theMatch isFirstView: (BOOL) isFirstView {
    
    //Store checkbox state
    if (self.anonymous_checkbox.checkState == M13CheckboxStateChecked) {
        self.wasChecked = YES;
    }
    else if (self.anonymous_checkbox.checkState == M13CheckboxStateUnchecked) {
        self.wasChecked = NO;
    }
    
    if (isFirstView) {
        self.firstMatcheeName.text = theMatch.first_matchee.guessed_full_name;
        self.secondMatcheeName.text = theMatch.second_matchee.guessed_full_name;
        
        
        [self.firstMatcheeImage sd_cancelCurrentImageLoad];
        [self.firstMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.first_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];

        [self.secondMatcheeImage sd_cancelCurrentImageLoad];
        [self.secondMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.second_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
        
        [self.view bringSubviewToFront:self.firstMatcheeName];
        [self.view bringSubviewToFront:self.secondMatcheeName];
    }
    else {
        self.nextFirstMatcheeName.text = theMatch.first_matchee.guessed_full_name;
        self.nextSecondMatcheeName.text = theMatch.second_matchee.guessed_full_name;
        
        [self.nextFirstMatcheeImage sd_cancelCurrentImageLoad];
        [self.nextFirstMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.first_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
        
        
        [self.nextSecondMatcheeImage sd_cancelCurrentImageLoad];
        [self.nextSecondMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.second_matchee.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
        
        [self.view bringSubviewToFront:self.nextFirstMatcheeName];
        [self.view bringSubviewToFront:self.nextSecondMatcheeName];
    }
    
    
    [self.checkboxView removeGestureRecognizer:self.anonymousTap];  //Remove gesture recognizer if it exists
    //Configure check box
    if (self.currentMatch.first_matchee.verified && self.currentMatch.second_matchee.verified) {
        if (self.wasChecked) {
            [self.anonymous_checkbox setCheckState:M13CheckboxStateChecked];
        }
        else {
            [self.anonymous_checkbox setCheckState:M13CheckboxStateUnchecked];
        }
        
        [self.anonymous_checkbox setEnabled:YES];
        self.anonymous_checkbox.titleLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.7];
        self.anonymous_checkbox.strokeColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:0.7];
        self.anonymous_checkbox.checkColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:1.0]; //Matchflare pink
       
        
    }
    else {
        [self.anonymous_checkbox setEnabled:NO];
        self.anonymous_checkbox.titleLabel.textColor = [UIColor blackColor];
        self.anonymous_checkbox.strokeColor = [UIColor blackColor];
        [self.anonymous_checkbox setCheckState:M13CheckboxStateMixed];
        self.anonymous_checkbox.checkColor = [UIColor blackColor];
        
        //Add touch event recognizer
        [self.checkboxView addGestureRecognizer:self.anonymousTap];
        
    }
}

- (void) anonymousTapped: (id) sender {
    NSLog(@"TAPPED");
    if (self.anonymous_checkbox.checkState == M13CheckboxStateMixed) {
        UIAlertView *anonymousAlert = [[UIAlertView alloc] initWithTitle:@"Can't be anonymous :(" message:@"You can only match anonymously if both friends are registered." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [anonymousAlert show];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PresentAnonymousCheckboxTappedWhileDisabled"
                                                               value:nil] build]];
    }
    
    
}

- (IBAction)homeButtonPressed:(UIStoryboardSegue*)sender
{
}

@end
