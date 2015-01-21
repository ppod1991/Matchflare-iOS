//
//  RegisterViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/30/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "RegisterViewController.h"
#import "ProfilePictureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Global.h"
#import "StringResponse.h"
#import "MatchflareAppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface RegisterViewController()
@property (strong, nonatomic) IBOutlet UIView *phoneNumberView;
@property (strong, nonatomic) IBOutlet UIView *nameView;
@property (strong, nonatomic) IBOutlet UIView *genderView;
@property (strong, nonatomic) IBOutlet UIView *preferencesView;
@property (strong, nonatomic) IBOutlet UIView *profileView;
@property (strong, nonatomic) IBOutlet UIView *verificationView;

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UIButton *sendSMSButton;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIButton *nextNameButton;

@property (strong, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (strong, nonatomic) IBOutlet UILabel *genderInstructions;

@property (strong, nonatomic) IBOutlet UILabel *preferencesInstructions;
@property (strong, nonatomic) IBOutlet UISwitch *guysSwitch;
@property (strong, nonatomic) IBOutlet UILabel *guysLabel;
@property (strong, nonatomic) IBOutlet UISwitch *girlsSwitch;
@property (strong, nonatomic) IBOutlet UILabel *girlsLabel;
@property (strong, nonatomic) IBOutlet UIButton *nextPreferencesButton;

@property (strong, nonatomic) IBOutlet UIImageView *profileThumbnail;
@property (strong, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (strong, nonatomic) IBOutlet UIButton *nextImageButton;

@property (strong, nonatomic) IBOutlet UITextField *codeField;
@property (strong, nonatomic) IBOutlet UIButton *nextCodeButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *phoneConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *genderConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *preferencesConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pictureConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verificationConstraint;

@property (strong, nonatomic) NSString *rawPhoneNumber;

@end
@implementation RegisterViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.phoneNumberField.font = [UIFont fontWithName:@"Opensans-Light" size:20.0];
    self.sendSMSButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    [self.sendSMSButton sizeToFit];
    self.nameField.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    self.nextNameButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:20.0];
    [self.nextNameButton sizeToFit];
    self.genderInstructions.font = [UIFont fontWithName:@"Opensans-Light" size:40.0];

    UIFont *font = [UIFont fontWithName:@"Opensans-Light" size:25.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.genderControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    self.preferencesInstructions.font = [UIFont fontWithName:@"Opensans-Light" size:40.0];
    self.guysLabel.font = [UIFont fontWithName:@"Opensans-Light" size:20.0];
    self.girlsLabel.font = [UIFont fontWithName:@"Opensans-Light" size:20.0];
    self.nextPreferencesButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:26.0];
    
    self.chooseImageButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    [self.chooseImageButton sizeToFit];
    self.nextImageButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    [self.nextImageButton sizeToFit];
    
    self.codeField.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    self.nextCodeButton.titleLabel.font = [UIFont fontWithName:@"Opensans-Light" size:22.0];
    [self.nextCodeButton sizeToFit];
    
    [self.phoneNumberField becomeFirstResponder];
    self.toVerifyPerson = [[Person alloc] init];

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

- (IBAction)sendSMSPressed:(id)sender {

    
    NSString *potentialPhoneNumber = self.phoneNumberField.text;
    if (potentialPhoneNumber.length < 10) {
        [Global showToastWithText:@"Must enter valid phone number with area code!"];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"RegisterInvalidPhoneNumber"
                                                               value:nil] build]];
    }
    else {
        self.rawPhoneNumber = potentialPhoneNumber;
        NSString *deviceID = [Global getDeviceId];
        
        //Send verification SMS
        [Global postTo:@"sendSMSVerification" withParams:@{@"device_id":deviceID,@"phone_number":self.rawPhoneNumber} withBody:nil
               success:^(NSURLSessionDataTask* operation, id responseObject) {
                   NSLog(@"Sent Verification sms");
                   [Global showToastWithText:@"Sending verification SMS!"];
               }
               failure:^(NSURLSessionDataTask * operation, NSError * error) {
                   NSLog(@"Error sending verification SMS: %@", error.localizedDescription);
                   id tracker = [[GAI sharedInstance] defaultTracker];
                   [tracker send:[[GAIDictionaryBuilder
                                   createExceptionWithDescription:[NSString stringWithFormat:@"Error sending verification sms, %@", error.localizedDescription] withFatal:@NO] build]];
               }];
        
        //Check if there is a picture associated with this phone number already
        [Global get:@"pictureURL" withParams:@{@"device_id":deviceID,@"phone_number":self.rawPhoneNumber}
            success:^(NSURLSessionDataTask* operation, id responseObject) {
                NSError *err;
                StringResponse *response = [[StringResponse alloc] initWithDictionary:responseObject error:&err];
                
                if (err) {
                    NSLog(@"Unable to convert image string response, %@", err.localizedDescription);
                }
                else {
                    self.toVerifyPerson.image_url = response.response;
                    self.nextImageButton.titleLabel.text = @"next";
                    [self.nextImageButton sizeToFit];
                    [self.profileThumbnail sd_cancelCurrentImageLoad];
                    [self.profileThumbnail sd_setImageWithURL:[NSURL URLWithString:self.toVerifyPerson.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
                }
            }
            failure:^(NSURLSessionDataTask * operation, NSError * error) {
                NSLog(@"No verified image found, %@", error.localizedDescription);
            }];
        
        [self animateIn:self.nameView withConstraint:self.nameConstraint withOutgoingView:self.phoneNumberView withConstraint:self.phoneConstraint];
        [self.nameField becomeFirstResponder];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"RegisterPhoneNumberSubmitted"
                                                               value:nil] build]];
    }
}

- (IBAction)nextNamePressed:(id)sender {
    
    NSString *trimmedString = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (whiteSpaceRange.location == NSNotFound) {
        [Global showToastWithText:@"Must enter your real first and last name!"];
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"RegisterInvalidName"
                                                               value:nil] build]];
    }
    else {
        self.toVerifyPerson.guessed_full_name = trimmedString;
        [self animateIn:self.genderView withConstraint:self.genderConstraint withOutgoingView:self.nameView withConstraint:self.nameConstraint];
        [self.nameField resignFirstResponder];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"RegisterNameSubmitted"
                                                               value:nil] build]];
    }
    

}
- (IBAction)genderChosen:(id)sender {
    
    if (self.genderControl.selectedSegmentIndex == 0) {
        self.toVerifyPerson.guessed_gender = @"FEMALE";
    }
    else if (self.genderControl.selectedSegmentIndex == 1){
        self.toVerifyPerson.guessed_gender = @"MALE";
    }
    
    [self animateIn:self.preferencesView withConstraint:self.preferencesConstraint withOutgoingView:self.genderView withConstraint:self.genderConstraint];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"RegisterGenderSubmitted"
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
                                                               label:@"RegisterInvalidPreference"
                                                               value:nil] build]];
    }
    else {
        self.toVerifyPerson.gender_preferences = genderPreferences;
        [self animateIn:self.profileView withConstraint:self.pictureConstraint withOutgoingView:self.preferencesView withConstraint:self.preferencesConstraint];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"RegisterPreferenceSubmitted"
                                                               value:nil] build]];
    }

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"RegisterViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}
- (IBAction)chooseImagePressed:(id)sender {
    [self performSegueWithIdentifier:@"RegisterToPicture" sender:self];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"RegisterChooseImagePressed"
                                                           value:nil] build]];
}

- (IBAction)nextImagePressed:(id)sender {
    [self animateIn:self.verificationView withConstraint:self.verificationConstraint withOutgoingView:self.profileView withConstraint:self.pictureConstraint];
    [self.codeField becomeFirstResponder];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"RegisterImageChosen"
                                                           value:nil] build]];
}

- (IBAction)nextCodePressed:(id)sender {
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"RegisterCodeSubmitted"
                                                           value:nil] build]];
    
    Global *global = [Global getInstance];
    [Global startProgress];
    self.toVerifyPerson.contact_objects = global.thisUser.contact_objects;
    
    [Global postTo:@"verifyVerificationSMS" withParams:@{@"device_id":[Global getDeviceId],@"phone_number":self.rawPhoneNumber,@"input_verification_code":self.codeField.text} withBody:self.toVerifyPerson
           success:^(NSURLSessionDataTask* operation, id responseObject) {
               [Global endProgress];
               NSError *err;
               Person *receivedPerson = [[Person alloc] initWithDictionary:responseObject error:&err];
               
               if (err) {
                   NSLog(@"Unable to convert response to person, %@", err.localizedDescription);
                   [Global showToastWithText:@"Invalid or expired code. Argh--try again!"];
                   [self animateIn:self.phoneNumberView withConstraint:self.phoneConstraint withOutgoingView:self.verificationView withConstraint:self.verificationConstraint];
                   [self.phoneNumberField becomeFirstResponder];
                   
                   id tracker = [[GAI sharedInstance] defaultTracker];
                   [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                         action:@"button_press"
                                                                          label:@"RegisterCodeDenied"
                                                                          value:nil] build]];
               }
               else {
                   
                   global.thisUser = receivedPerson;
                   [global setAccessToken:global.thisUser.access_token];
                   if (self.isFromPresent) {
                       [self performSegueWithIdentifier:@"RegisterToPresent" sender:self];
                   }
                   else {
                       [self performSegueWithIdentifier:@"RegisterToNavigation" sender:self];

                   }
                   [global registerForPushNotifications];
                   
                   id tracker = [[GAI sharedInstance] defaultTracker];
                   [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                         action:@"button_press"
                                                                          label:@"RegisterCodeAccepted"
                                                                          value:nil] build]];
               }
           }
           failure:^(NSURLSessionDataTask * operation, NSError * error) {
               [Global endProgress];
               NSLog(@"Failed to verify user, %@", error.localizedDescription);
               [Global showToastWithText:@"Invalid or expired code. Argh--try again!"];
               [self animateIn:self.phoneNumberView withConstraint:self.phoneConstraint withOutgoingView:self.verificationView withConstraint:self.verificationConstraint];
               [self.phoneNumberField becomeFirstResponder];
               [self.genderControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
               
               id tracker = [[GAI sharedInstance] defaultTracker];
               [tracker send:[[GAIDictionaryBuilder
                               createExceptionWithDescription:[NSString stringWithFormat:@"Failed to verify user, %@", error.localizedDescription] withFatal:@NO] build]];
    }];
    

}

- (IBAction) chosePicture:(UIStoryboardSegue *) segue {
    if ([segue.identifier isEqualToString:@"PictureToRegister"]) {
        if ([segue.sourceViewController isKindOfClass:[ProfilePictureViewController class]]) {
            
            [self.profileThumbnail sd_cancelCurrentImageLoad];
            [self.profileThumbnail sd_setImageWithURL:[NSURL URLWithString:self.toVerifyPerson.image_url] placeholderImage:[UIImage imageNamed:@"profile_template"]];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RegisterToNavigation"]) {
        
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = segue.destinationViewController;
            
            Global *global = [Global getInstance];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:@"&uid"
                   value:[NSString stringWithFormat:@"%@",global.thisUser.contact_id]];
            
            //Change color of navigation bar
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                
                // do stuff for iOS 7 and newer
                [navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
            }
            else {
                
                // do stuff for older versions than iOS 7
                [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            }
            
            navigationController.navigationBar.tintColor = [UIColor grayColor];
            ((MatchflareAppDelegate *)[UIApplication sharedApplication].delegate).navigationController = navigationController;
            
            [navigationController.navigationBar
             setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:17.0]}];
            
            [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Light" size:16.0]} forState:UIControlStateNormal];
        }
    }
    else if ([segue.identifier isEqualToString:@"RegisterToPicture"]) {
        if ([segue.destinationViewController isKindOfClass:[ProfilePictureViewController class]]) {
            ProfilePictureViewController *ppvc = segue.destinationViewController;
            ppvc.isFromRegister = YES;
        }
    }
    

}
@end
