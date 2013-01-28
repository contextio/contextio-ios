//
//  CIOExampleAPIClient.h
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/15/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CIOAPIClient.h"

@interface CIOExampleAPIClient : CIOAPIClient

+ (CIOExampleAPIClient *)sharedClient;

@end
