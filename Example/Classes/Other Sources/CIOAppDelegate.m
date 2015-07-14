//
//  CIOAppDelegate.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/15/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOAppDelegate.h"
#import <CIOAPIClient/CIOAPISession.h>
#import "CIOContactsViewController.h"

#error Please enter your Context.IO API credentials below and comment out this line.
static NSString * const kContextIOConsumerKey = @"";
static NSString * const kContextIOConsumerSecret = @"";

@implementation CIOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    CIOAPISession *client = [[CIOAPISession alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];
    CIOContactsViewController *contactsController = [[CIOContactsViewController alloc] initWithStyle:UITableViewStylePlain];
    contactsController.APIClient = client;

    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:contactsController];
    self.window.rootViewController = rootNavController;
    
    return YES;
}

@end
