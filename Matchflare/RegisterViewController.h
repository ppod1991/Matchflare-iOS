//
//  RegisterViewController.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/30/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface RegisterViewController : UIViewController

@property (strong, nonatomic) Person* toVerifyPerson;
@property BOOL isFromPresent;
@end
