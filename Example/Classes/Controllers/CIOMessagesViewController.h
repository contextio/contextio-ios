//
//  CIOMessagesViewController.h
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/18/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CIOAPIClient/CIOAFNetworking1Client.h>

@interface CIOMessagesViewController : UITableViewController

- (id)initWithContactEmailAddress:(NSString *)contactEmailAddress CIOClient:(CIOAFNetworking1Client *)CIOClient;

@end
