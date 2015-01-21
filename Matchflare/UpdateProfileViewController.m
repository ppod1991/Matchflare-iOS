//
//  UpdateProfileViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/13/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "Global.h"
#import "ProfilePictureViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface UpdateProfileViewController ()
@property (strong, nonatomic) IBOutlet UIView *profileView;
@property (strong, nonatomic) IBOutlet UIView *preferencesView;
@property (strong, nonatomic) IBOutlet UIView *genderView;
@property (strong, nonatomic) IBOutlet UIImageView *profileThumbnail;
@property (strong, nonatomic) IBOutlet UISwitch *guysSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *girlsSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pictureConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *preferencesConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *genderConstraint;


@end

@implementation UpdateProfileViewController
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateButtonPressed:(id)sender {
    [Global startProgress];
    [Global postTo:@"updateProfile" withParams:nil withBody:self.toUpdatePerson
           success:^(NSURLSessionDataTask* operation, id responseObject) {
               [Global endProgress];
               NSError *err;
               Person *updatedPerson = [[Person alloc] initWithDictionary:responseObject error:&err];
               Global *global = [Global getInstance];
               
               global.thisUser.guessed_gender = updatedPerson.guessed_gender;
               global.thisUser.gender_preferences = updatedPerson.gender_preferences;
               global.thisUser.image_url = updatedPerson.image_url;
               
               if (err) {
                   NSLog(@"Unable to convert updated person, %@", err.localizedDescription);
               }
               [Global showToastWithText:@"Successfully updated!"];
               [self performSegueWithIdentifier:@"UpdateToPresent" sender:self];
           }
           failure:^(NSURLSessionDataTask * operation, NSError * error) {
               [Global endProgress];
               NSLog(@"Unable to update person, %@", error.localizedDescription);
               id tracker = [[GAI sharedInstance] defaultTracker];
               [tracker send:[[GAIDictionaryBuilder
                               createExceptionWithDescription:[NSString stringWithFormat:@"Unable to update person, %@", error.localizedDescription] withFatal:@NO] build]];
               [Global showToastWithText:@"Update failed. Try again later!"];
           }];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"UpdateUpdatePressed"
                                                           value:nil] build]];
}

- (IBAction)chooseImagePressed:(id)sender {
    [self performSegueWithIdentifier:@"UpdateToPicture" sender:self];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"UpdateChooseImagePressed"
                                                           value:nil] build]];
}

- (IBAction)nextPreferencesPressed:(id)sender {
    
    NSMutableArray *genderPreferences = [[NSMutableArray alloc] init];
    if (self.guysSwitch.isOn) {
        [genderPreferences addObject:@"MALE"];
    }
    
    if (self.girlsSwitch.isOn) {
        [genderPreferences addObject:@"FEMALE"];
    }
    
    if (genderPreferences.count < 1) {
        [Global showToastWithText:@"Must choose one preference!"];
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"UpdateInvalidPreference"
                                                               value:nil] build]];
    }
    else {
        self.toUpdatePerson.gender_preferences = genderPreferences;
        [self animateIn:self.profileView withConstraint:self.pictureConstraint withOutgoingView:self.preferencesView withConstraint:self.preferencesConstraint];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"UpdatePreferenceSubmitted"
                                                               value:nil] build]];
    }
    
}

- (IBAction)genderChosen:(id)sender {
    if (self.genderControl.selectedSegmentIndex == 0) {
        self.toUpdatePerson.guessed_gender = @"FEMALE";
    }
    else if (self.genderControl.selectedSegmentIndex == 1){
        self.toUpdatePerson.guessed_gender = @"MALE";
    }
    
    [self animateIn:self.preferencesView withConstraint:self.preferencesConstraint withOutgoingView:self.genderView withConstraint:self.genderConstraint];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"UpdateGenderSubmitted"
                                                           value:nil] build]];
    
}

- (void) animateIn:(UIView *) incomingView withConstraint: (NSLayoutConstraint *) inConstraint withOutgoingView: (UIView *) outgoingView withConstraint: (NSLayoutConstraint *) outConstraint {
    
    incomingView.hidden = NO;
    inConstraint.constant = 200.0f;
    incomingView.alpha = 0.0f;
    outConstraint.constant = 125.0f;
    outgoingView.alpha = 1.0f;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4
                          delay:0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         inConstraint.constant = 125.0f;
                         incomingView.alpha = 1.0f;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
    
    [UIView animateWithDuration:0.4
                          delay:0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         outConstraint.constant = -50.0f;
                         outgoingView.alpha = 0.0f;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             outgoingView.hidden = YES;
                         }
                     }];
    
    
}

- (IBAction) chosePictureUpdate:(UIStoryboardSegue *) segue {
    if ([segue.identifier isEqualToString:@"PictureToUpdate"]) {
        if ([segue.sourceViewController isKindOfClass:[ProfilePictureViewController class]]) {
            [self.profileThumbnail sd_cancelCurrentImageLoad];
            [self.profileThumbnail sd_setImageWithURL:[NSURL URLWithString:self.toUpdatePerson.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"UpdateDidChoosePicture"
                                                                   value:nil] build]];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIFont *font = [UIFont fontWithName:@"Opensans-Light" size:25.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.genderControl setTitleTextAttributes:attributes
                                      forState:UIControlStateNormal];
    
    
    self.toUpdatePerson = [[Global getInstance].thisUser mutableCopy];
    self.toUpdatePerson.contact_objects = nil; //To remove unnecessary overhead
    self.toUpdatePerson.contacts = nil;
    
    if ([self.toUpdatePerson.gender_preferences containsObject:@"MALE"]) {
        [self.guysSwitch setOn:YES];
    }
    
    if ([self.toUpdatePerson.gender_preferences containsObject:@"FEMALE"]) {
        [self.girlsSwitch setOn:YES];
    }
    
    [self.profileThumbnail sd_cancelCurrentImageLoad];
    [self.profileThumbnail sd_setImageWithURL:[NSURL URLWithString:self.toUpdatePerson.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
    
    self.genderView.hidden = NO;
    

    // Do any additional setup after loading the view.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UpdateToPicture"]) {
        if ([segue.destinationViewController isKindOfClass:[ProfilePictureViewController class]]) {
            ProfilePictureViewController *ppvc = segue.destinationViewController;
            ppvc.isFromRegister = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"UpdateProfileViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
