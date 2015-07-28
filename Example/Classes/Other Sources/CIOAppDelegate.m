//
//  CIOAppDelegate.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/15/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOAppDelegate.h"
#import <CIOAPIClient/CIOAPIClient.h>
#import "CIOContactsViewController.h"

//#error Please enter your Context.IO API credentials below and comment out this line.
static NSString * const kContextIOConsumerKey = @"kcjtxbdq";
static NSString * const kContextIOConsumerSecret = @"WHkt47kB7KjP4hPG";

@implementation CIOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    CIOV2Client *client = [[CIOV2Client alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];
    CIOContactsViewController *contactsController = [[CIOContactsViewController alloc] initWithStyle:UITableViewStylePlain];
    contactsController.APIClient = client;

    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:contactsController];
    self.window.rootViewController = rootNavController;
    
    return YES;
}

@end
