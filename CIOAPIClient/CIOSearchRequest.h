//
//  CIOSearchRequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

/**
 Base set of request parameters used in Message and File searches: `CIOMessagesRequest` and `CIOFilesRequest`
 */
@interface CIOSearchRequest : CIOArrayRequest

/**
 *  Filter messages by the account source label.
 */
@property (nullable, nonatomic) NSString *source;

/**
 *  Email address or top level domain of the contact for whom you want the latest messages exchanged with. By "exchanged
 * with contact X" we mean any email received from contact X, sent to contact X or sent by anyone to both contact X and
 * the source owner.
 */
@property (nullable, nonatomic) NSString *email;

/**
 *  Email address or array of email addresses of a contact messages have been sent to.
 */
@property (nullable, nonatomic) id to;

/**
 *  Email address or array of email addresses of a contact messages have been received from.
 */
@property (nullable, nonatomic) id from;

/**
 *  Email address or array of email addresses of a contact CC'ed on the messages.
 */
@property (nullable, nonatomic) id cc;

/**
 *  Email address or array of email addresses of a contact BCC'ed on the messages.
 */
@property (nullable, nonatomic) id bcc;

/**
 *  Search for files based on their name. You can filter names using typical shell wildcards such as `*`, `?` and `[]`
 * or regular expressions by enclosing the search expression in a leading `/` and trailing `/`. For example, `*.pdf`
 * would give you all PDF files while `/\.jpe?g$/` would return all files whose name ends with .jpg or .jpeg
 */
@property (nullable, nonatomic) NSString *file_name;

/**
 *  Search for files based on their size (in bytes).
 */
@property (nullable, nonatomic) NSNumber *file_size_min;

/**
 *  Search for files based on their size (in bytes).
 */
@property (nullable, nonatomic) NSNumber *file_size_max;

/**
 *  Only include messages before a given date. The value this filter is applied to is the `Date:` header of the message
 * which refers to the time the message is sent from the origin.
 */
@property (nullable, nonatomic) NSDate *date_before;

/**
 *  Only include messages after a given date. The value this filter is applied to is the `Date:` header of the message
 * which refers to the time the message is sent from the origin.
 */
@property (nullable, nonatomic) NSDate *date_after;

/**
 *  Only include messages indexed before a given date. This is not the same as the date of the email, it is the time
 * Context.IO indexed this message.
 */
@property (nullable, nonatomic) NSDate *indexed_before;

/**
 *  Only include messages indexed after a given date. This is not the same as the date of the email, it is the time
 * Context.IO indexed this message.
 */
@property (nullable, nonatomic) NSDate *indexed_after;

/**
 *  The sort order of the returned results.
 */
@property (nonatomic) CIOSortOrder sort_order;

@end
