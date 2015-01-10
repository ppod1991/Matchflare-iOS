//
//  MatcheeOptionsViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/8/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface MatcheeOptionsViewController : UIViewController


@property (strong, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) Person *existingMatchee;
@property (strong, nonatomic) Person *chosenMatchee;
@property BOOL isFirstMatchee;

@end
