//
//  CIOContactsViewController.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/18/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOContactsViewController.h"
#import "CIOMessagesViewController.h"

#import "CIOExampleAPIClient.h"

@interface CIOContactsViewController ()

@property (nonatomic, strong) NSArray *contactsArray;

- (void)fetchContacts;

@end

@implementation CIOContactsViewController

@synthesize contactsArray = _contactsArray;

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Contacts", @"");
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContacts)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (![[CIOExampleAPIClient sharedClient] isAuthorized]) {
        
        CIOAuthViewController *authController = [[CIOAuthViewController alloc] initWithAPIClient:[CIOExampleAPIClient sharedClient] allowCancel:NO];
        authController.delegate = self;
        UINavigationController *authNavController = [[UINavigationController alloc] initWithRootViewController:authController];
        [self presentViewController:authNavController animated:YES completion:nil];
        
        return;
    }
    
    if (!self.contactsArray) {
        [self fetchContacts];
    }
}

#pragma mark - Actions

- (void)fetchContacts {
    
    [[CIOExampleAPIClient sharedClient] getContactsWithParams:nil success:^(NSDictionary *responseDict) {
        
        self.contactsArray = [responseDict valueForKey:@"matches"];;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error getting contacts: %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *contact = [self.contactsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact valueForKey:@"name"];
    cell.detailTextLabel.text = [contact valueForKey:@"email"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *contact = [self.contactsArray objectAtIndex:indexPath.row];
    NSString *contactEmailAddress = [contact valueForKey:@"email"];
    
    CIOMessagesViewController *messagesController = [[CIOMessagesViewController alloc] initWithContactEmailAddress:contactEmailAddress];
    [self.navigationController pushViewController:messagesController animated:YES];
}

#pragma mark - CIOAuthViewControllerDelegate

- (void)userCompletedLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userCancelledLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
