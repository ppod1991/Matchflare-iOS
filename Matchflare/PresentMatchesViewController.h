//
//  PresentMatchesViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/29/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"

@interface PresentMatchesViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIView *matchOne;
@property (strong, nonatomic) IBOutlet UIView *matchTwo;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *firstLeadingSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *secondLeadingSpace;
@property (strong, nonatomic) IBOutlet UIImageView *firstMatcheeImage;
@property (strong, nonatomic) IBOutlet UILabel *firstMatcheeName;
@property (strong, nonatomic) IBOutlet UIImageView *secondMatcheeImage;
@property (strong, nonatomic) IBOutlet UILabel *secondMatcheeName;

@property (strong, nonatomic) IBOutlet UIImageView *nextFirstMatcheeImage;
@property (strong, nonatomic) IBOutlet UILabel *nextFirstMatcheeName;
@property (strong, nonatomic) IBOutlet UILabel *nextSecondMatcheeName;
@property (strong, nonatomic) IBOutlet UIImageView *nextSecondMatcheeImage;


@property (strong, nonatomic) NSMutableArray <Match> *matches;
@property (strong, nonatomic) Match *currentMatch;
@property (strong, nonatomic) Match *nextMatch;

@end
