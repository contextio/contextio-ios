//
//  CIOMessageFlags.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIOMessageFlags : NSObject

/**
 Message has been read. Set to `@YES` to set the flag, `@NO` to unset it.
 */
@property (nullable, nonatomic) NSNumber *seen;

/**
 Message has been answered. Set to `@YES` to set the flag, `@NO` to unset it.
 */
@property (nullable, nonatomic) NSNumber *answered;

/**
 Message is "flagged" for urgent/special attention. Set to `@YES` to set the flag, `@NO` to unset it.
 */
@property (nullable, nonatomic) NSNumber *flagged;

/**
 Message is "deleted" for later removal. An alternative way of deleting messages is to move it to the Trash folder. Set to `@YES` to set the flag, `@NO` to unset it.
 */
@property (nullable, nonatomic) NSNumber *deleted;

/**
 Message has not completed composition (marked as a draft). Set to `@YES` to set the flag, `@NO` to unset it.
 */
@property (nullable, nonatomic) NSNumber *draft;

- (nonnull NSDictionary *)asDictionary;

@end
