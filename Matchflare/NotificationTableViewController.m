//
//  NotificationTableViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/8/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "NotificationTableViewController.h"
#import "Global.h"
#import "Match.h"
#import "ChatViewController.h"
#import "EvaluateMatchViewController.h"
#import "ViewMatchController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface NotificationTableViewController ()

@property int chosen_pair_id;
@property int chosen_chat_id;
@property (strong, nonatomic) Match *chosenMatch;

@end

@implementation NotificationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isExpanded = [NSMutableArray arrayWithArray:@[@YES, @YES, @YES]];
    self.sectionHeaders = @[@"Notifications",@"Matches You're In",@"Matches You've Made"];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) pushNotificationReceived: (NSNotification *) notification {
    [self updateNotifications];
    
}

- (void) updateNotifications {
    
    if (!self.notifications) {
        [Global startProgress];
    }
    Global *global = [Global getInstance];
    
    [Global get:@"notificationLists" withParams:@{@"contact_id":global.thisUser.contact_id}
        success:^(NSURLSessionDataTask* operation, id responseObject) {
            if (!self.notifications) {
                [Global endProgress];
            }
            
            NSError *err;
            NSLog(@"Successfully retrieved notifications: %@", [responseObject description]);
            self.notifications = [[NotificationLists alloc] initWithDictionary:responseObject error:&err];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.notifications.notifications.count];
            [self.tableView reloadData];

            
            if (err) {
                NSLog(@"Unable to convert notifications, %@", err.localizedDescription);
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:[NSString stringWithFormat:@"Unable to convert notifications (Notification), %@", err.localizedDescription] withFatal:@NO] build]];
            }
        }
        failure:^(NSURLSessionDataTask * operation, NSError * error) {
            [Global endProgress];
            NSLog(@"Unable to retrieve notifications, %@", error.localizedDescription);
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:[NSString stringWithFormat:@"Unable to retrieve notification (Notification), %@", error.localizedDescription] withFatal:@NO] build]];
        }];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"NotificationTableViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:nil];
    
    [self updateNotifications];
}



- (NSArray *) listAtIndex: (NSNumber *) index {
    if ([index isEqualToNumber:[NSNumber numberWithInt:0]]) {
        return self.notifications.notifications;
    }
    else if ([index isEqualToNumber:[NSNumber numberWithInt:1]]) {
        return self.notifications.pending_matches;
    }
    else if ([index isEqualToNumber:[NSNumber numberWithInt:2]]) {
        return self.notifications.active_matcher_matches;
    }
    
    return nil;
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([[self.isExpanded objectAtIndex:section] boolValue]) {
        return [[self listAtIndex:[NSNumber numberWithInteger:section]] count] + 1;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
        UILabel *initLabel = cell.textLabel;
        initLabel.lineBreakMode = NSLineBreakByWordWrapping;
        initLabel.numberOfLines = 0;
    }
    

    UILabel *label = cell.textLabel;
    
    
    if (indexPath.row == 0) {
        cell.accessoryView = nil;
        NSString *arrow;
        
        label.text = [self.sectionHeaders objectAtIndex:indexPath.section];
        label.font = [UIFont fontWithName:@"OpenSans" size:17.0];
        label.textColor = [UIColor whiteColor];
        if ([[self.isExpanded objectAtIndex:indexPath.section] boolValue]) {
            arrow = @"▿";
        }
        else {
            arrow = @"▹";
        }
        NSArray *listAtIndex = (NSArray*) [self listAtIndex:[NSNumber numberWithInteger:indexPath.section] ];
        label.text = [NSString stringWithFormat:@"%@      %@ (%lu)",arrow,[self.sectionHeaders objectAtIndex:indexPath.section],(unsigned long)listAtIndex.count];
    }
    else {
        id currentObject = [[self listAtIndex:[NSNumber numberWithInteger:indexPath.section]] objectAtIndex:indexPath.row-1];
        label.text = [currentObject description];
    
        if (indexPath.section > 0) {
            Match *thisMatch = (Match *) currentObject;
            if (thisMatch.has_unseen) {
                label.textColor = [UIColor colorWithRed:250/255.0 green:69/255.0 blue:118/255.0 alpha:0.8]; //Matchflare pink
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_message.png"]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.frame = CGRectMake(0, 0, 30, 30);
                imageView.center = imageView.superview.center;
                
                cell.accessoryView = imageView;
            }
            else {
                label.textColor = [UIColor whiteColor];
                cell.accessoryView = nil;
            }
            
        }
        else {
            label.textColor = [UIColor whiteColor];
            cell.accessoryView = nil;
        }
        label.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSLog(@"%@",self.isExpanded);
        int section = indexPath.section;
        BOOL expandedThis = [[self.isExpanded objectAtIndex:section] boolValue];
        [self.isExpanded replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:!expandedThis]];
        [self.tableView reloadData];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"NotificationToggledHeaderWithSectionNumber"
                                                               value:[NSNumber numberWithInteger:indexPath.section]] build]];
    }
    else {
        //If notification...
        if (indexPath.section == 0) {
            Notification *chosenNotification = [self.notifications.notifications objectAtIndex:indexPath.row - 1];
            
            self.chosen_pair_id = chosenNotification.pair_id;
            
            if ([chosenNotification.notification_type isEqualToString:@"MATCHEE_NEW_MATCH"]) {
                [self performSegueWithIdentifier:@"NotificationToEvaluate" sender:self];
            }
            else if ([chosenNotification.notification_type isEqualToString:@"MATCHEE_MATCH_ACCEPTED"] ||
                     [chosenNotification.notification_type isEqualToString:@"MATCHER_QUESTION_ASKED"] ||
                     [chosenNotification.notification_type isEqualToString:@"MATCHEE_QUESTION_ANSWERED"] ||
                     [chosenNotification.notification_type isEqualToString:@"MATCHEE_MESSAGE_SENT"]) {
                self.chosen_chat_id = chosenNotification.chat_id;
                [self performSegueWithIdentifier:@"NotificationToChat" sender:self];
                
            }
            else if ([chosenNotification.notification_type isEqualToString:@"MATCHER_ONE_MATCH_ACCEPTED"] ||
                     [chosenNotification.notification_type isEqualToString:@"MATCHER_BOTH_ACCEPTED"]) {
                
                [self performSegueWithIdentifier:@"NotificationToView" sender:self];
                
            }
            
            //Mark notification as seen
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.notifications.notifications.count-1];
            [Global postTo:@"seeNotification" withParams:@{@"notification_id":[NSNumber numberWithInt:chosenNotification.notification_id]} withBody:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"Notification successfully marked as seen");
            } failure:^(NSURLSessionDataTask *task, NSError *err) {
                NSLog(@"Failed to mark notification as seen: %@",err.localizedDescription);
            }];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"NotificationNotificationTapped"
                                                                   value:nil] build]];
            
        }
        //Pending matches
        else if (indexPath.section == 1) {
            self.chosenMatch = [self.notifications.pending_matches objectAtIndex:indexPath.row -1];
            [self performSegueWithIdentifier:@"NotificationToEvaluate" sender:self];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"NotificationPendingMatchTapped"
                                                                   value:nil] build]];
        }
        //Active Matcher Matches
        else if (indexPath.section == 2) {
            self.chosenMatch = [self.notifications.active_matcher_matches objectAtIndex:indexPath.row -1];
            [self performSegueWithIdentifier:@"NotificationToView" sender:self];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"NotificationActiveMatcherMatchTapped"
                                                                   value:nil] build]];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NotificationToChat"]) {
        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]]) {
            ChatViewController *cvc = [segue destinationViewController];
            cvc.pair_id = self.chosen_pair_id;
            cvc.chat_id = self.chosen_chat_id;
            self.chosen_chat_id = 0;
            self.chosen_pair_id = 0;
        }
    }
    else if ([segue.identifier isEqualToString:@"NotificationToEvaluate"]) {
        if ([segue.destinationViewController isKindOfClass:[EvaluateMatchViewController class]]) {
            EvaluateMatchViewController *emvc = [segue destinationViewController];
            if (self.chosenMatch != nil) {
                emvc.thisMatch = self.chosenMatch;
                self.chosenMatch = nil;
            }
            else {
                emvc.pair_id = self.chosen_pair_id;
                self.chosen_pair_id = 0;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"NotificationToView"]) {
        if ([segue.destinationViewController isKindOfClass:[ViewMatchController class]]) {
            ViewMatchController *vmc = [segue destinationViewController];
            if (self.chosenMatch != nil) {
                vmc.thisMatch = self.chosenMatch;
                self.chosenMatch = nil;
            }
            else {
                vmc.pair_id = self.chosen_pair_id;
                self.chosen_pair_id = 0;
            }
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
