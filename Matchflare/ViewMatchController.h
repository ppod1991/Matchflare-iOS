//
//  ViewMatchController.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/9/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"

@interface ViewMatchController : UIViewController

@property (strong, nonatomic) Match *thisMatch;
@property int pair_id;

@end
