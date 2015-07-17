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
    [messagesRequest executeWithSuccess:^(NSArray *response) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = self.messagesArray[indexPath.row];
    NSArray *files = message[@"files"];
    if ([files count] > 0) {
        NSDictionary *file = files.firstObject;
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *fileURL = [documentsURL URLByAppendingPathComponent:file[@"file_name"]];
        if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
        [self.APIClient downloadRequest:[self.APIClient downloadContentsOfFileWithID:file[@"file_id"]]
                              toFileURL:fileURL
                                success:^{
                                    NSLog(@"File downloaded: %@", [fileURL path]);
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download Complete"
                                                                                        message:nil
                                                                                       delegate:nil
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                    [alertView show];
                                }
                                failure:^(NSError *error) {
                                    NSLog(@"Download error: %@", error);
                                }
                               progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                                   NSLog(@"Download progress: %0.2f%%", ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                               }];

    }
}

@end
