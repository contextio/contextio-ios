//
//  CIOContactsViewController.h
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/18/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIOAuthViewController.h"

@interface CIOContactsViewController : UITableViewController <CIOAuthViewController>

@property (nonnull) CIOAFNetworking1Client *APIClient;

@end
