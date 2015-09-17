//
//  CIOLiteMessageRequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 9/17/15.
//  Copyright © 2015 Context.io. All rights reserved.
//

#import "CIOMessageRequests.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @see https://context.io/docs/lite/users/email_accounts/folders/messages
 */
@interface CIOLiteMessageRequest: CIOMessageRequestBase

/**
 If `/` isn't fancy enough as a hierarchy delimiter when specifying the folder you want to obtain, you're free to use what you want, just make sure you set this delimiter parameter to tell us what you're using.
 */
@property (nullable, strong, nonatomic) NSString *delimiter;

/**
 Move a message

 @param newFolder    Specifies the destination folder for the message move.
 */
- (CIODictionaryRequest *)moveToFolder:(NSString *)newFolder;

#pragma mark - Attachments

/**
 List email attachments

 @see https://context.io/docs/lite/users/email_accounts/folders/messages/attachments
*/
- (CIOArrayRequest *)listAttachments;

/**
 Retrieve an email attachment

 @param attachmentID The index of the file attachment.
*/
- (CIORequest *)downloadAttachmentWithID:(NSString *)attachmentID;

#pragma mark - Body

/**
 Fetch the message body of a given email

 @param bodyType Many emails are sent with both rich text and plain text versions in the message body and by default, the response of this call will include both. It is possible to only get either the plain or rich text version by setting the type parameter to `text/plain` or `text/html` respectively.
 */
- (CIOArrayRequest *)getBodyOfType:(nullable NSString *)bodyType;

#pragma mark - Flags

/**
 The Flags resource allows you set to retrieve flags that indicate, among other things, if the message has been read.
 */
- (CIODictionaryRequest *)getFlags;

#pragma mark - Headers

/**
 Get complete headers of a given email message
 */
- (CIODictionaryRequest *)getHeaders;

/**
 Get complete headers of a given email message as a raw string, rather than parsed in to a dictionary.
 */
- (CIORequest *)getRawHeaders;

#pragma mark - Raw

/**
 Returns the raw RFC-822 message source for the message (including attachments) with no parsing or decoding to any portions of the message.
 */
- (CIORequest *)getRawMessage;

#pragma mark - Read

/**
 Mark the message as read
 */
- (CIODictionaryRequest *)markRead;

/**
 Mark the message as unread
 */
- (CIODictionaryRequest *)markUnread;

@end

NS_ASSUME_NONNULL_END