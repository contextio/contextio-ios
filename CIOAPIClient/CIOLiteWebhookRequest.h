//
//  CIOLiteWebhookRequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 9/17/15.
//  Copyright © 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CIOLiteWebhookRequest : CIODictionaryRequest

/**
 Check for new messages sent to a given name or email address. Also accepts a comma delimited list of email addresses.
 */
@property (nullable, nonatomic) NSString *filter_to;
/**
 Check for new messages received from a given name or email address. Also accepts a comma delimited list of email addresses.
 */
@property (nullable, nonatomic) NSString *filter_from;
/**
 Check for new messages where a given name or email address is cc'ed. Also accepts a comma delimited list of email addresses.
 */
@property (nullable, nonatomic) NSString *filter_cc;
/**
 Check for new messages with a subject matching a given string or regular expression
 */
@property (nullable, nonatomic) NSString *filter_subject;
/**
 Check for new messages in a given thread. Value must be a email_message_id of an existing message currently in the thread.
 */
@property (nullable, nonatomic) NSString *filter_thread;
/**
 Check for new messages *automatically* tagged as important by the Gmail Priority Inbox algorithm.

 To trace *all* messages marked as important (including those manually set by the user), use `filter_folder_added` with value `\Important`. Note the leading back-slash character in the value, it is required to keep this specific to Gmail Priority Inbox. Otherwise any message placed in a folder called "Important" would trigger the WebHook.
 */
@property (nullable, nonatomic) NSString *filter_new_important;
/**
 Check for new messages where a file whose name matches the given string is attached. You can filter names using typical shell wildcards such as `*`, `?` and `[]` or regular expressions by enclosing the search expression in a leading `/` and trailing `/`. For example, `*.pdf` would give you all PDF files while `/\.jpe?g$/` would return all files whose name ends with .jpg or .jpeg
 */
@property (nullable, nonatomic) NSString *filter_file_name;
/**
 Check for messages filed in a given folder. On Gmail, this is equivalent to having a label applied to a message. The value should be the complete name (including parents if applicable) of the folder you want to track.
 */
@property (nullable, nonatomic) NSString *filter_folder_added;
/**
 Check for new messages sent to a given domain. Also accepts a comma delimited list of domains.
 */
@property (nullable, nonatomic) NSString *filter_to_domain;
/**
 Check for new messages sent from a given domain. Also accepts a comma delimited list of domains.
 */
@property (nullable, nonatomic) NSString *filter_from_domain;
/**
 Set to `YES` to include message bodies in the result.
 */
@property (nonatomic) BOOL include_body;
/**
 Used when include_body is set to get only body parts of a given MIME-type (for example `text/html`)
 */
@property (nullable, nonatomic) NSString *body_type;

@end

NS_ASSUME_NONNULL_END