//
//  MatcheeOptionsViewController.m
//  Matchflare
//
//  Created by Piyush Poddar on 1/8/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "MatcheeOptionsViewController.h"
#import "Person.h"
#import "Global.h"

@interface MatcheeOptionsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray<Person> *contacts;
@property (strong, nonatomic) NSArray *displayedContacts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *stopShowingButton;

@end

@implementation MatcheeOptionsViewController

- (IBAction)cancelButtonPressed:(id)sender {
    
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"guessed_full_name contains[c] %@", searchText];
        self.displayedContacts = [self.contacts filteredArrayUsingPredicate:resultPredicate];
        
    }
    else {
        self.displayedContacts = self.contacts;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Global *global = [Global getInstance];
    self.contacts = global.thisUser.contact_objects;
    self.displayedContacts = self.contacts;
    self.orLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
    self.stopShowingButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:20.0];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"OpenSans-Light" size:15.0]];
    [self.stopShowingButton setTitle:[NSString stringWithFormat:@"Stop showing %@",self.existingMatchee.guessed_full_name] forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedContacts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"Creating new cell");
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Person *person = [self.displayedContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = person.guessed_full_name;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];

    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.chosenMatchee = [self.displayedContacts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ChoseToPresent" sender:self];
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
