//
//  ProfilePictureViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/7/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePictureViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) NSString* imageURL;
@property BOOL isFromRegister;

@end
