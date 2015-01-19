//
//  SplashViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "SplashViewController.h"
#import "Global.h"
#import "AFNetworking.h"
#import "SplashPageViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import "Contacts.h"
#import "MatchesAndPairs.h"
#import "PresentMatchesViewController.h"
#import "MatchflareAppDelegate.h"

@interface SplashViewController ()
@property (strong, nonatomic) IBOutlet UIView *spashImage;

@end

@implementation SplashViewController

    

- (IBAction)nextButtonClicked:(UIButton *)sender {
        
    if (!self.reachedLastSplashPage) {
        //Move to next page
    }
    else {
        //Go to present matches
        self.toPresentMatches = true;
        if (self.finishedProcessingContacts) {
            [self performSegueWithIdentifier:@"SplashToNavigation" sender:self];
        }
        else {
            [Global startProgress];
        }
        NSLog(@"Going to present matches");
    }

}

- (IBAction)registerButtonClicked:(UIButton *)sender {
    
    NSLog(@"Going to register");
    self.toRegister = true;
    if (self.finishedProcessingContacts) {
        [self performSegueWithIdentifier:@"SplashToRegister" sender:self];
    }
    else {
        [Global startProgress];
    }

}


//- (IBAction)nextButtonPressed {
//    NSUInteger currentIndex = [[self.pageController.viewControllers lastObject] index];
//    
//    if (currentIndex < 2) {
//        //Move to next page
//    }
//    else {
//        //Go to present matches
//        NSLog(@"Going to present matches");
//    }
//}
//
//- (IBAction)registerButtonPressed {
//    NSLog(@"Going to register");
//}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    
    //Change fonts
    self.nextButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
    
//    .detailTextLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
    //--Begin Page View Initialization
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    
    [[self.pageController view] setFrame:[[self view] bounds]];
    //self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);

    SplashPageViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

    [self.view bringSubviewToFront:self.spashImage];
    //--End Page View Initialization
    
    // Do any additional setup after loading the view.
}


- (void) checkContactsPermission {
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self retrievePhoneContacts:true withAddressBook:addressBook];
                }
                else {
                    [self retrievePhoneContacts:false withAddressBook:addressBook];
                }
                
            });
            
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // If the user user has earlier provided the access, then add the contact
            [self retrievePhoneContacts:true withAddressBook:addressBook];
        }
        else {
            [self retrievePhoneContacts:false withAddressBook:addressBook];

        }
    }
    else { // we're on iOS 5 or older
        [self retrievePhoneContacts:true withAddressBook:addressBook];
    }

}

- (void) retrievePhoneContacts:(BOOL) permissionGranted withAddressBook:(ABAddressBookRef) addressBook {
    
    
    if (permissionGranted) {
        
        #ifdef DEBUG
            NSLog(@"Fetching contact info ----> ");
        #endif
            
        
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, source);
        //CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        CFIndex nPeople = CFArrayGetCount(allPeople);
        __block NSMutableArray<Person> *contactObjects = (NSMutableArray<Person> *)[NSMutableArray arrayWithCapacity:nPeople];

        for (int i = 0; i < nPeople; i++)
        {
            Person *thisPerson = [[Person alloc] init];
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            if (person == nil) {
                break;
            }
            //get First Name and Last Name
            
            NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!firstName) {
                firstName = @"";
            }
            if (!lastName) {
                lastName = @"";
            }
            thisPerson.guessed_full_name = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
            
//            // get contacts picture, if pic doesn't exists, show standart one
//            
//            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
//            contacts.image = [UIImage imageWithData:imgData];
//            if (!contacts.image) {
//                contacts.image = [UIImage imageNamed:@"NOIMG.png"];
//            }
            
            //get Phone Number
            
            NSString *mobileLabel;
            NSString *rawPhoneNumber;
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(multiPhones, i);
                if ([mobileLabel isEqualToString:(NSString* )kABPersonPhoneMobileLabel]) {
                    rawPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multiPhones,i);
                    thisPerson.raw_phone_number = rawPhoneNumber;
                    [contactObjects addObject:thisPerson];
                    break;
                }
            }
        }
        
        /////////////
        //Check and verify access token
        Global *global = [Global getInstance];
        
        NSString *accessToken = [global accessToken];
        
        if (accessToken != nil) {
            [Global get:@"verifyAccessToken"
             withParams:@{@"access_token":accessToken}
                success:^(NSURLSessionDataTask* operation, id responseObject) {
                    NSError *err;
                    if ((BOOL) responseObject) {
                        NSLog(@"Successfully verified access token: %@", [responseObject description]);
                        global.thisUser = [[Person alloc] initWithDictionary:responseObject error:&err];
                        [global registerForPushNotifications];
                    }
                    else {
                        NSLog(@"Failed verification test of access token: %@", [responseObject description]);
                        self.spashImage.hidden = YES;
                    }
                    [self processContacts:contactObjects];
                    
                    if (err) {
                        NSLog(@"Unable to initialize user from verify access token, %@", err.localizedDescription);
                    }
                }
                failure:^(NSURLSessionDataTask * operation, NSError * error) {
                    NSLog(@"Unable to verify access token, %@", error.localizedDescription);
                    self.spashImage.hidden = YES;
                    [self processContacts:contactObjects];
                }];
            
        }
        else {
            self.spashImage.hidden = YES;
            [self processContacts:contactObjects];
        }

        
        //////////////
    }
    else {
        __block UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Make Matches"
                                                        message:@"Must enable 'Contacts' for Matchflare in your general Phone settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        #ifdef DEBUG
                NSLog(@"Cannot fetch Contacts :( ");
        #endif
        dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
        });
    }
}

- (void) processContacts:(NSMutableArray <Person> *) mContacts {
    __block Global *global = [Global getInstance];
    NSDictionary *options;
    void (^successBlock) (NSURLSessionDataTask *operation, id responseObject);
    
    void (^failureBlock) (NSURLSessionDataTask *operation, NSError *error) = ^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"Error processing contacts: %@", error.localizedDescription);
    };
    
    if (global.thisUser && global.thisUser.contact_id > 0) {
        [self performSegueWithIdentifier:@"SplashToNavigation" sender:self]; //Start without waiting for processing contacts
        options = @{@"contact_id":global.thisUser.contact_id};
        successBlock = ^(NSURLSessionDataTask *operation, id responseObject){
            //If registered and logged-in user, then do nothing upon finishing processing contacts
            NSLog(@"Finished processing contacts for this logged-in user");
            
        };
        
    }
    else {
        options = @{};
        successBlock = ^(NSURLSessionDataTask *operation, id responseObject){
            //If unregistered or not logged-in user, then pass matches into PresentMatchesViewController to start matching
            NSError *err;
            MatchesAndPairs *matchesAndPairs = [[MatchesAndPairs alloc] initWithDictionary: responseObject error: &err];
            if (err) {
                NSLog(@"Unable to process contacts, %@", err.localizedDescription);
            }
            else {
                global.thisUser.contact_objects = matchesAndPairs.contact_objects;
                self.matches = matchesAndPairs.matches;
                self.finishedProcessingContacts = true;
                if (self.toPresentMatches) {
                    [Global endProgress];
                    [self performSegueWithIdentifier:@"SplashToNavigation" sender:self];
                }
                else if (self.toRegister) {
                    [Global endProgress];
                    [self performSegueWithIdentifier:@"SplashToRegister" sender:self];

                }
                
            }
            
            NSLog(@"Finished processing contacts for this non-logged-in user...presenting matches!");
        };
    }
    
    Contacts *contacts = [[Contacts alloc] init];
    contacts.contacts = mContacts;
    
    [Global postTo:@"processContacts"
        withParams:options
        withBody:contacts
        success:successBlock
        failure:failureBlock];
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    self.spashImage.hidden = NO;
    
    //Retrieve the contacts for processing
    
    [self checkContactsPermission];

    
        //    String accessToken = ((Global) getApplication()).getAccessToken();
        //    if (accessToken != null) {
        //        Map options = new HashMap<String, String>();
        //        options.put("access_token",accessToken);
        //        ((Global)getApplication()).ui.verifyAccessToken(options, this);
        //    }
        //    else {
        //        splashLogo.setVisibility(View.GONE);
        //        instructionPager.setVisibility(View.VISIBLE);
        //        ProcessContactsTask task = new ProcessContactsTask();
        //        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
        //            task.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        //        else
        //            task.execute();
        //    }

    
    }

- (SplashPageViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    SplashPageViewController *childViewController = [[SplashPageViewController alloc] initWithNibName:@"SplashPageViewController" bundle:nil];
    childViewController.index = index;
    
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(SplashPageViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(SplashPageViewController *)viewController index];
    
    
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SplashToNavigation"]) {

        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = segue.destinationViewController;
            
            
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

            
            PresentMatchesViewController *controller = (PresentMatchesViewController * )navigationController.topViewController;
            if (!controller.matches) {
                controller.matches = (NSMutableArray<Match>*)[[NSMutableArray alloc] init];
            }
            [controller.matches addObjectsFromArray:self.matches];
            
            if (self.initialNotification) {
                UIViewController *nextController = [[Global getInstance] controllerFromNotification:self.initialNotification];
                if (nextController) {
                    [navigationController pushViewController:nextController animated:YES];
                }
            }
            
        }
    }
    
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    
        NSUInteger currentIndex = [[self.pageController.viewControllers lastObject] index];
        
        if (currentIndex == 2) {
            [self.registerButton setEnabled:true];
            self.reachedLastSplashPage = true;
            
            [self.view bringSubviewToFront:self.nextButton];
            [self.view bringSubviewToFront:self.registerButton];
            NSString *title = @"Try it Now!";
            [self.nextButton setTitle: title forState: UIControlStateNormal];
            [self.nextButton setTitle: title forState: UIControlStateApplication];
            [self.nextButton setTitle: title forState: UIControlStateHighlighted];
            [self.nextButton setTitle: title forState: UIControlStateReserved];
            [self.nextButton setTitle: title forState: UIControlStateSelected];
            [self.nextButton setTitle: title forState: UIControlStateDisabled];
        }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
