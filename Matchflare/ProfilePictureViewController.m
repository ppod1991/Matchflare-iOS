//
//  ProfilePictureViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/7/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "ProfilePictureViewController.h"
#import "RegisterViewController.h"
#import "AWSCore.h"
#import "S3.h"
#import "Cognito.h"
#import "Global.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UpdateProfileViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface ProfilePictureViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) AWSS3TransferManager* transferManager;
@property (strong, nonatomic) UIImagePickerController *uiipc;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation ProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:17.0];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:@"779249472230"
                                                          identityPoolId:@"us-east-1:08be2bd6-6938-4c95-8602-f2e033821fb6"
                                                          unauthRoleArn:@"arn:aws:iam::779249472230:role/Cognito_MatchflareUsersUnauth_DefaultRole"
                                                          authRoleArn:@"YOUR AUTHENTICATED ARN HERE"];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //TransferManager *transferManager = [AWs]
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [self choosePicture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backPressed:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];

}

- (void) choosePicture {
    //Start camera/image picker
    self.uiipc = [[UIImagePickerController alloc] init];
    self.uiipc.delegate = self;
    self.uiipc.mediaTypes = @[(NSString *) kUTTypeImage];
    self.uiipc.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        self.uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.uiipc animated:YES completion:nil];    }
    
    //[self presentViewController:uiipc animated:YES completion:NULL];

}
- (IBAction)changePicturePressed:(id)sender {
    [self choosePicture];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.uiipc animated:YES completion:nil];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PictureChooseCameraPicturePressed"
                                                               value:nil] build]];
    } else if (buttonIndex == 1) {
        self.uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.uiipc animated:YES completion:nil];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"PictureChooseLibraryPicturePressed"
                                                               value:nil] build]];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *returnedImage = info[UIImagePickerControllerEditedImage];
    
    if (!returnedImage) {
        returnedImage = info[UIImagePickerControllerOriginalImage];
    }
    self.image.image = returnedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"PictureDidChoosePicture"
                                                           value:nil] build]];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"ProfilePictureViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)rotatePressed:(id)sender {
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.image.image.size.width, self.image.image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(M_PI_2);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, M_PI_2);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.image.image.size.width / 2, -self.image.image.size.height / 2, self.image.image.size.width, self.image.image.size.height), [self.image.image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image.image = newImage;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"PictureDidRotatePicture"
                                                           value:nil] build]];
}

- (IBAction)donePressed:(id)sender {
    [Global startProgress];
    NSURL *tempPath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp"]];
    [UIImageJPEGRepresentation(self.image.image, 0.25) writeToURL:tempPath atomically:YES];
    
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"matchflare-profile-pictures";
    uploadRequest.key = [NSString stringWithFormat:@"profile-pic-%@-%f-iOS.jpg",[Global getDeviceId],CACurrentMediaTime()];
    uploadRequest.body = tempPath;
//    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            weakSelf.file1AlreadyUpload = totalBytesSent;
//            [weakSelf updateProgress];
//        });

        
    [[self.transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        [Global endProgress];
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                NSLog(@"Error uploading picture: %@",task.error.localizedDescription);
                [Global showToastWithText:@"Error uploading. Try again!"];
                
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:@"PictureUploadFailed"
                                                                       value:nil] build]];
            }
        } else {
            NSLog(@"Successfully uploaded picture!");
            self.imageURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@",uploadRequest.bucket,uploadRequest.key];
            if (self.isFromRegister) {
                [self performSegueWithIdentifier:@"PictureToRegister" sender:self];
            }
            else {
                [self performSegueWithIdentifier:@"PictureToUpdate" sender:self];
            }
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"PictureUploadSuccessful"
                                                                   value:nil] build]];
        }
        return nil;
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PictureToRegister"]) {
        if ([segue.destinationViewController isKindOfClass:[RegisterViewController class]]) {
            RegisterViewController *rvc = [segue destinationViewController];
            rvc.toVerifyPerson.image_url= self.imageURL;
        }
    }
    else if ([segue.identifier isEqualToString:@"PictureToUpdate"]) {
        if ([segue.destinationViewController isKindOfClass:[UpdateProfileViewController class]]) {
            UpdateProfileViewController *upvc = [segue destinationViewController];
            upvc.toUpdatePerson.image_url= self.imageURL;
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
