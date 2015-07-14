//
//  CIOMessagesViewController.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/18/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOMessagesViewController.h"

@interface CIOMessagesViewController ()

@property (nonatomic) NSString *contactEmailAddress;
@property (nonatomic) NSArray *messagesArray;
@property (nonatomic) CIOAPISession *APIClient;

- (void)fetchMessages;

@end

@implementation CIOMessagesViewController

@synthesize contactEmailAddress = _contactEmailAddress;
@synthesize messagesArray = _messagesArray;

- (id)initWithContactEmailAddress:(NSString *)contactEmailAddress CIOClient:(CIOAPISession *)CIOClient {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Messages", @"");
        self.contactEmailAddress = contactEmailAddress;
        self.APIClient = CIOClient;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchMessages)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!self.messagesArray) {
        [self fetchMessages];
    }
}

#pragma mark - Actions

- (void)fetchMessages {
    
    CIOArrayRequest *messagesRequest = [self.APIClient getMessagesForContactWithEmail:self.contactEmailAddress params:nil];
    [self.APIClient executeArrayRequest:messagesRequest success:^(NSArray *response) {
        self.messagesArray = response;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error getting messages: %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *message = [self.messagesArray objectAtIndex:indexPath.row];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSNumber *unixTime = [message valueForKey:@"date"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[unixTime integerValue]];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    cell.textLabel.text = formattedDateString;
    cell.detailTextLabel.text = [message valueForKey:@"subject"];
    
    return cell;
}

@end
