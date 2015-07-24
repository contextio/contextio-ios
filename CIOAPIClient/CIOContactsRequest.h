//
//  CIOContactsRequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

@interface CIOContactsRequest : CIODictionaryRequest

/**
 String identifying the name or the email address of the contact(s) you are looking for.
 */
@property (nullable, nonatomic) NSString *search;
/**
 Only include contacts included in at least one email dated before a given time.
 */
@property (nullable, nonatomic) NSDate *active_before;
/**
 Only include contacts included in at least one email dated after a given time.
 */
@property (nullable, nonatomic) NSDate *active_after;
/**
 The field by which to sort the returned results. Possible values are `email`, `count`, `received_count` and `sent_count`.
 */
@property (nullable, nonatomic) NSString *sort_by;
/**
 The sort order of the returned results.
 */
@property (nonatomic) CIOSortOrder sort_order;
/**
 The maximum number of results to return. The maximum limit is `250`.
 */
@property (nonatomic) NSInteger limit;
/**
 Start the list at this offset (zero-based).
 */
@property (nonatomic) NSInteger offset;


@end
