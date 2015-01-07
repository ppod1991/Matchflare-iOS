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

@interface PresentMatchesViewController()

@property (weak, nonatomic) UIView *currentView;
@property (strong, nonatomic) CATransition *returnAnimation;
@property (strong, nonatomic) CATransition *quickAnimation;
@property (strong, nonatomic) NSString *currentDescription;

@property int initialX;
@end

@implementation PresentMatchesViewController


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

        
        if (deltaX < -50 || xVelocity < -400) {
            NSLog(@"Left swipe");
            [self passTriggered];
        }
        else if (deltaX > 50 || xVelocity > 400) {
            NSLog(@"Right swipe");
            [self matchTriggered];
        }
        else {
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
            self.descriptionLabel.text = @"no.";
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
        [self showMatcheeOptions];
    }
}

- (IBAction)secondLongLong:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"Second long long");
        self.secondMatcheeName.textColor = [UIColor whiteColor];
        self.nextSecondMatcheeName.textColor = [UIColor whiteColor];
        [self showMatcheeOptions];
    }
}

- (void) showMatcheeOptions {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Ayo"
                                          message:@"woo"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) passTriggered {
    NSLog(@"Pass button pressed!");
    [self presentNextMatch: true];
    [self.descriptionLabel.layer addAnimation:self.quickAnimation forKey:@"changeTextTransition"];
    self.descriptionLabel.text = @"match passed";
    self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
    
}
- (IBAction)passButtonPressed:(id)sender {
    [self passTriggered];

//    [self.descriptionLabel.layer addAnimation:self.animation forKey:@"changeTextTransition"];
//
//    self.descriptionLabel.text = @"Should they meet?!";
}

- (void) matchTriggered {
    [self presentNextMatch: false];
    [self.descriptionLabel.layer addAnimation:self.quickAnimation forKey:@"changeTextTransition"];
    self.descriptionLabel.text = @"match made";
    self.descriptionLabel.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink

}

- (IBAction)matchButtonPressed:(id)sender {
    [self matchTriggered];
    
    NSLog(@"Match button pressed!");
    //    [self.descriptionLabel.layer addAnimation:self.animation forKey:@"changeTextTransition"];
//    self.descriptionLabel.text = @"Should they meet?!";
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

- (void) viewDidLoad {
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

    
    self.currentView = self.matchOne;
    
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

- (void) viewWillAppear:(BOOL)animated {
    if (self.matches) {
        //Has matches ready to show
        if (!self.currentMatch) {
            [self presentNextMatch: true];
        }
    }
    else {
        //Load matches -- NEED TO IMPLEMENT
    }
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
    
    
    
    //NEED TO IMPLMENT -- IF MATCHES IS < 10, then load more matches
}

- (void) loadMatch:(Match*) theMatch isFirstView: (BOOL) isFirstView {
    
    if (isFirstView) {
        self.firstMatcheeName.text = theMatch.first_matchee.guessed_full_name;
        self.secondMatcheeName.text = theMatch.second_matchee.guessed_full_name;
        
        
        [self.firstMatcheeImage sd_cancelCurrentImageLoad];
        [self.firstMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.first_matchee.image_url] placeholderImage:nil];

        
         [self.secondMatcheeImage sd_cancelCurrentImageLoad];
         [self.secondMatcheeImage sd_setImageWithURL:[NSURL URLWithString:theMatch.second_matchee.image_url] placeholderImage:nil];
        
        
        [self.view bringSubviewToFront:self.firstMatcheeName];
        [self.view bringSubviewToFront:self.secondMatcheeName];
    }
    else {
        self.nextFirstMatcheeName.text = theMatch.first_matchee.guessed_full_name;
        self.nextSecondMatcheeName.text = theMatch.second_matchee.guessed_full_name;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURL = theMatch.first_matchee.image_url;
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
            
            //set your image on main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nextFirstMatcheeImage setImage:[UIImage imageWithData:data]];
                
            });
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURL = theMatch.second_matchee.image_url;
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
            
            //set your image on main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nextSecondMatcheeImage setImage:[UIImage imageWithData:data]];
            });
        });
        
        [self.view bringSubviewToFront:self.nextFirstMatcheeName];
        [self.view bringSubviewToFront:self.nextSecondMatcheeName];
    }


    
}
@end
