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
    [self animateIn:self.nameView withConstraint:self.nameConstraint withOutgoingView:self.phoneNumberView withConstraint:self.phoneConstraint];
    [self.nameField becomeFirstResponder];
}

- (IBAction)nextNamePressed:(id)sender {
    [self animateIn:self.genderView withConstraint:self.genderConstraint withOutgoingView:self.nameView withConstraint:self.nameConstraint];
    [self.nameField resignFirstResponder];
}
- (IBAction)genderChosen:(id)sender {
    [self animateIn:self.preferencesView withConstraint:self.preferencesConstraint withOutgoingView:self.genderView withConstraint:self.genderConstraint];
}

- (IBAction)nextPreferencesPressed:(id)sender {
    [self animateIn:self.profileView withConstraint:self.pictureConstraint withOutgoingView:self.preferencesView withConstraint:self.preferencesConstraint];
}
- (IBAction)chooseImagePressed:(id)sender {
}
- (IBAction)nextImagePressed:(id)sender {
    [self animateIn:self.verificationView withConstraint:self.verificationConstraint withOutgoingView:self.profileView withConstraint:self.pictureConstraint];
    [self.codeField becomeFirstResponder];
}

- (IBAction)nextCodePressed:(id)sender {
    [self animateIn:self.phoneNumberView withConstraint:self.phoneConstraint withOutgoingView:self.verificationView withConstraint:self.verificationConstraint];
    [self.phoneNumberField becomeFirstResponder];
}

- (IBAction) chosePicture:(UIStoryboardSegue *) segue {
    if ([segue.identifier isEqualToString:@"PictureToRegister"]) {
        if ([segue.sourceViewController isKindOfClass:[ProfilePictureViewController class]]) {
            
            [self.profileThumbnail sd_cancelCurrentImageLoad];
            [self.profileThumbnail sd_setImageWithURL:[NSURL URLWithString:self.imageURL] placeholderImage:nil];
        }
    }
}

@end
