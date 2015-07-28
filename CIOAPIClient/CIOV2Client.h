//
//  CIOV2Client.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/28/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const CIOV2APIBaseURLString;

@interface CIOV2Client : CIOAPIClient

/**
 Initializes a `CIOV2Client` object with the specified consumer key and secret. If a previously-authenticated consumer
 key is provided, its authentcation information will be restored from the keychain.

 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.

 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 Initializes a `CIOV2Client` object with the specified consumer key and secret, and additionally token and token
 secret. Use this method if you have already obtained a token and token secret on your own, and do not wish to use the
 built-in keychain storage.

 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.
 @param token The auth token for the API client.
 @param tokenSecret The auth token secret for the API client.
 @param accountID The account ID the client should use to construct requests.

 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                              token:(nullable NSString *)token
                        tokenSecret:(nullable NSString *)tokenSecret
                          accountID:(nullable NSString *)accountID;

#pragma mark - Contacts

/**
 Retrieves the account's contacts.

 */
- (CIOContactsRequest *)getContacts;

/**
 Retrieves the contact with the specified email.

 @param email The email address of the contact you would like to retrieve.
 */
- (CIODictionaryRequest *)getContactWithEmail:(NSString *)email;

#pragma mark Contacts/Files

/**
 List files exchanged with a contact.

 This call returns the latest attachments exchanged with one or more email addresses. By "exchanged with Mr. X" we mean any file attached to an email received from Mr. X, sent to Mr. X or sent by anyone to both Mr. X and the mailbox owner.

 @see You can get list of messages with more precise filtering using a combination of the to, from and cc filters by using `getFiles`.

 @param email The email address of the contact for which you would like to retrieve associated messages.
 */
- (CIOArrayRequest *)getFilesForContactWithEmail:(NSString *)email;

#pragma mark Contacts/Messages

/**
 Listing messages where a contact is present

 This call returns the latest email messages exchanged with one or more email addresses. By "exchanged with Mr. X" we mean any email received from Mr. X, sent to Mr. X or sent by anyone to both Mr. X and the mailbox owner.

 @see You can get list of messages with more precise filtering using a combination of the to, from and cc filters using `getMessages`.

 @param email Email address of a contact
 */
- (CIOArrayRequest *)getMessagesForContactWithEmail:(NSString *)email;

#pragma mark Contacts/Threads

/**
 Listing threads where a contact is present

 This call returns the latest email threads exchanged with one or more email addresses. By "exchanged with Mr. X" we mean any email received from Mr. X, sent to Mr. X or sent by anyone to both Mr. X and the mailbox owner.

 @see `getThreads`, you can get list of messages with more precise filtering using a combination of the to, from and cc filters

 @param email Email address of a contact
 */
- (CIOArrayRequest *)getThreadsForContactWithEmail:(NSString *)email;

#pragma mark - Email Addresses

/**
 List of email addressed used by an account

 List your configured user account emails.
 */
- (CIOArrayRequest *)getEmailAddresses;

/**
 Add a new email addresses as an alias for an account

 @param email The email address you would like to associate with the account.
 */
- (CIODictionaryRequest *)addEmailAddress:(NSString *)email;

/**
 Updates the details of a particular email address.

 @param email The email address for which you would like to update details.
 @param primary Set to `YES` to make this email address the primary one for the account
 */
- (CIODictionaryRequest *)updateEmailAddressWithEmail:(NSString *)email primary:(BOOL)primary;

/**
 Disassociates a particular email address from the account.

 @param email The email address you would like to disassociate from the account.
 */
- (CIODictionaryRequest *)deleteEmailAddressWithEmail:(NSString *)email;

#pragma mark - Files

/**

 List details of files found as email attachments.

 @see `CIOFilesRequest` and `CIOSearchRequest` for a description of the possible parameters you can pass in this method.

 @see https://context.io/docs/2.0/accounts/files
 */
- (CIOFilesRequest *)getFiles;

/**
 Retrieves details about the file with the specified id.

 @param fileID The id of the file you would like to retrieve.
 */
- (CIODictionaryRequest *)getDetailsOfFileWithID:(NSString *)fileID;

#pragma mark Files/Changes

/**
 List of files that can be compared with a given file

 @param fileID The id of the file for which you would like to retrieve changes.
 */
- (CIOArrayRequest *)getChangesForFileWithID:(NSString *)fileID;

#pragma mark Files/Content

/**
 Retrieves a public facing URL that can be used to download a particular file.

 @param fileID The id of the file that you would like to download.
 */
- (CIOStringRequest *)getContentsURLForFileWithID:(NSString *)fileID;

/**
 Retrieves the contents of a particular file.

 @param fileID The id of the file that you would like to download.
 */
- (CIORequest *)downloadContentsOfFileWithID:(NSString *)fileID;

#pragma mark Files/Related

/**
 Retrieves other files associated with a particular file.

 Returns a list of files that are related to the given file. Currently, relation between files is based on how similar their names are.

 @param fileID The id of the file for which you would like to retrieve associated files.
 */
- (CIOArrayRequest *)getRelatedForFileWithID:(NSString *)fileID;

#pragma mark Files/Revisions

/**
 Retrieves the revisions of a particular file.

 Returns a list of revisions attached to other emails in the mailbox for a given file.

 Two files are considered revisions of the same document if their file names are identical outside of revision indicators such as dates, author initials, version numbers and keywords like "final" or "draft".

 @param fileID The id of the file for which you would like to retrieve revisions.
 */
- (CIOArrayRequest *)getRevisionsForFileWithID:(NSString *)fileID;

#pragma mark - Messages

/**
 List email messages for an account.

 https://context.io/docs/2.0/accounts/messages

 @see `CIOMessagesRequest` and `CIOSearchRequest` for possible parameters to use in this call.
 */
- (CIOMessagesRequest *)getMessages;

/**
 Get file, contact and other information about a given email message.

 @see `CIOMessageRequest` for optional parameters you can set on this request.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 */
- (CIOMessageRequest *)getMessageWithID:(NSString *)messageID;

/**
 Copy or move a message

 This call allows you to copy or move a message between folders. If there are more than one sources on the account, you can use this call to copy/move the message between these sources. In this case, the `dst_label` parameter must identify the source you want to message to be copied/moved to. See `CIOMessageUpdateRequest` for further optional parameters.

 Have a look at `getFoldersForMessageWithID:` to get a more flexible way to manage which folders a message should appear in.

 @see `getFoldersForMessageWithID:`
 @see `CIOMessageUpdateRequest`

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.

 @param destinationFolder The folder within `dst_source` the message should be copied to
 */
- (CIOMessageUpdateRequest *)updateMessageWithID:(NSString *)messageID
                               destinationFolder:(NSString *)destinationFolder;

/**
 Deletes the message with the specified id.

 @discussion <h3>For standard IMAP accounts</h3>

 The `DELETE` method will delete messages from the source email server. In IMAP-speak, it will set the `\\Deleted` flag on the message and then call the `EXPUNGE` command.

 Once this is done, the message is gone forever, there's no way to bring it back.

 <blockquote>The `EXPUNGE` command removes all messages in that folder that have the `\\Deleted` flag set. If you want to avoid that, you can simply mark the message as deleted.</blockquote>

 <h3>For Gmail and Google Apps accounts</h3>

 For Gmail and Google Apps mailboxes, setting the `\\Deleted` flag and calling the `EXPUNGE` command is equivalent to removing a "label" and results in that message still showing up in the "All Mail" folder and other labels also assigned to the message. See this Gmail Support entry for details: http://support.google.com/mail/bin/answer.py?hl=en&answer=78755

 So, if you call the `DELETE` method on a message we assume it's because you wanted that message deleted. Therefore, what actually happens for Gmail or Google Apps messages is we move it to the "[Gmail]/Trash" folder.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 */
- (CIODictionaryRequest *)deleteMessageWithID:(NSString *)messageID;

#pragma mark Messages/Body

/**
 Fetch the message body of a given email.

 https://context.io/docs/2.0/accounts/messages/body

 <h3>Retrieving attachments</h3>

 This call only returns text portions of messages, attachments aren't included. To get a list of attachments on the message, look for the files property in the response of a message instance. To download the content of these attachments, use the files/content call

 <h3>On-demand data retrieval</h3>

 Since we do not keep full copies of emails on our servers, this call triggers a connection to the IMAP server to fetch the message. One thing to point out is we do fetch messages in such a way that large files attached to a message won't make any difference in the response time.

 @see `getMessageWithID:` If you want to fetch headers, body and flags for a given message, you can use the related include_* GET parameters on `CIOMessageRequest` to get them all in a single call.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 @param type Many emails are sent with both rich text and plain text versions in the message body and by default, the response of this call will include both. It is possible to only get either the plain or rich text version by setting the `type` parameter to `text/plain` or `text/html` respectively.
 */
- (CIOArrayRequest *)getBodyForMessageWithID:(NSString *)messageID type:(nullable NSString *)type;

#pragma mark Messages/Flags

/**
 Retrieves the flags for a particular message.

 The Flags resource allows you set to retrieve and set flags that indicate, among others, if the message has been read.

 You can find detailed explanation about each IMAP message flags here: http://tools.ietf.org/html/rfc3501#section-2.3.2.

 https://context.io/docs/2.0/accounts/messages/flags

 <h3>On-demand data retrieval</h3>

 To ensure up-to-date values, flags are not cached by Context.IO. This call triggers a connection to the IMAP server to fetch the current message flags before it returns.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 */
- (CIODictionaryRequest *)getFlagsForMessageWithID:(NSString *)messageID;

/**
 Updates the flags for a particular message.

 @param messageID The id of the message for which you would like to update the flags.
 @param flags A `CIOMessageFlags` object which defines which flags to add or remove from the message
 */
- (CIODictionaryRequest *)updateFlagsForMessageWithID:(NSString *)messageID flags:(CIOMessageFlags *)flags;

#pragma mark Messages/Folders

/**
 Retrieves the folders for a particular message.

 Note that for Gmail and Google Apps, this resource maps to the "labels" assigned to the message.

 https://context.io/docs/2.0/accounts/messages/folders

 @param messageID The id of the message for which you would like to retrieve the folders.
 */
- (CIOArrayRequest *)getFoldersForMessageWithID:(NSString *)messageID;

/**
 Updates the folders for a particular message.

 While you can copy/move a message in a given folder with the POST method on a given message, this allows a more flexible way to add or remove folder(s) a message should appear in.

 @warning This SDK does not currently support adding or removing more than one folder in a single API call.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 @param addFolder    New folder this thread should appear in.
 @param removeFolder Folder this thread should be removed from.
 */
- (CIODictionaryRequest *)updateFoldersForMessageWithID:(NSString *)messageID addToFolder:(nullable NSString *)addFolder removeFromFolder:(nullable NSString *)removeFolder;

/**
 Set folders a message should appear

 TODO: This is currently getting OAuth signing errors. Needs more investigation.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 @param folderNames         Array of IMAP folder names
 @param symbolicFolderNames Array of 'Special-use attribute of a folder (if and only if the server supports it and applicable to this folder)'
 */
- (CIODictionaryRequest *)setFoldersForMessageWithID:(NSString *)messageID folderNames:(NSArray *)folderNames symbolicFolderNames:(NSArray *)symbolicFolderNames;

#pragma mark Messages/Headers

/**
 Complete headers of a given email message

 https://context.io/docs/2.0/accounts/messages/headers

 Note that you only need to specify either the name or symbolic_name property for each folder the message must appear in.

 <h3>On-demand data retrieval</h3>

 Since we do not keep full copies of emails on our servers, this call triggers a connection to the IMAP server to fetch the message headers.

 <h3>Why are all values in arrays?</h3>

 It is very common to have more than one occurrence of some headers so for those, an array makes obvious sense, for the rest, yes, we could have left them as plain old strings. However, it would be seriously annoying to always test whether the value for a given header is an array or a string whevener you want to access it. Putting everything in strings makes it easy to uniformly access them.

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 */
- (CIODictionaryRequest *)getHeadersForMessageWithID:(NSString *)messageID;

/**
 Complete headers of a given email message as a raw string

 @param messageID Unique id of a message. This can be the message_id or email_message_id property of the message. The gmail_message_id (prefixed with gm-) can also be used.
 */
- (CIOStringRequest *)getRawHeadersForMessageWithID:(NSString *)messageID;

#pragma mark Messages/Source

/**
 Returns the raw RFC-822 message source for the message (including attachments) with no parsing or decoding to any portions of the message.

 @param messageID The id of the message for which you would like to retrieve the source.
 */
- (CIORequest *)getSourceForMessageWithID:(NSString *)messageID;

#pragma mark Messages/Thread

/**
 List other messages in the same thread as a given message

 This returns an array with the same structure as getting information on a single message for every message in the thread.

 @param messageID The id of the message for which you would like to retrieve the thread.
 */
- (CIOMessageThreadRequest *)getThreadForMessageWithID:(NSString *)messageID;

#pragma mark - Sources

/**
 List IMAP sources assigned for an account.

 <h3>Multiple sources on a single account</h3>

 You can have more than one source for a single account. In this case, data from all these sources are merged and considered as one data set on which the other accounts sub-resources interact.

 In other words, this is meant to handle users of your application with than one email account who always wants your application to show data from all of these accounts as if they were one.

 If you want to be able to query IMAP sources separately, create two accounts (one for each IMAP source)

 */
- (CIOSourcesRequest *)getSources;

/**
 Creates a new source under the account. Note: It is usually preferred to use
 `-beginAuthForProviderType:callbackURLString:params:` to add a new source to the account.

 @see `CIOCreateSourceRequest` for futher optional parameters to this request.

 @param email The primary email address used to receive emails in this account.
 @param server Name or IP of the IMAP server, eg. imap.gmail.com
 @param username The username used to authenticate an IMAP connection. On some servers, this is the same thing as the primary email address.
 @param useSSL Set to `YES` if you want SSL encryption to be used when opening connections to the IMAP server. Any other value will be considered as "do not use SSL"
 @param port Port number to connect to on the server. Keep in mind that most IMAP servers will have one port for standard connection and another one for encrypted connection (see `use-ssl` parameter)
 @param type Currently, the only supported type is IMAP
 */
- (CIOSourceCreateRequest *)createSourceWithEmail:(NSString *)email
                                           server:(NSString *)server
                                         username:(NSString *)username
                                           useSSL:(BOOL)useSSL
                                             port:(NSInteger)port
                                             type:(NSString *)type;

/**
 Get parameters and status for an IMAP source.

 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)getSourceWithLabel:(NSString *)sourceLabel;

/**
 Modify a data source on a given account

 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIOSourceModifyRequest *)updateSourceWithLabel:(NSString *)sourceLabel;

/**
 Deletes the source with the specified label.

 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)deleteSourceWithLabel:(NSString *)sourceLabel;

#pragma mark Sources/Folders

/**
 Returns folders existing in a given IMAP account.

 @param sourceLabel           The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 @param includeExtendedCounts Set to `YES` to include extended counts in the result (for now, the only extended count supported is number of unseen messages). Since counts must be retrieved from the IMAP server, expect a performance hit when setting this parameter.
 @param noCache               Set to `YES` to fetch the folder list directly from the IMAP server. Since data must be retrieved from the IMAP server, expect a performance hit when setting this parameter.

 */
- (CIOArrayRequest *)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                            includeExtendedCounts:(BOOL)includeExtendedCounts
                                          noCache:(BOOL)noCache;

/**
 Returns information about a given folder. This call exposes IMAP related attributes and other information for a given folder.

 @param folderPath            The full folder path using / as the path hierarchy delimiter.
 @param sourceLabel           The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 @param includeExtendedCounts Set to `YES` to include extended counts in the result (for now, the only extended count supported is number of unseen messages). Since counts must be retrieved from the IMAP server, expect a performance hit when setting this parameter.
 @param delim               If `/` isn't fancy enough as a hierarchy delimiter when specifying the folder you want to obtain, you're free to use what you want, just make sure you set this delim parameter to tell us what you're using.

 */
- (CIODictionaryRequest *)getFolderWithPath:(NSString *)folderPath
                                sourceLabel:(NSString *)sourceLabel
                      includeExtendedCounts:(BOOL)includeExtendedCounts
                                      delim:(nullable NSString *)delim;

/**
 Create a folder on an IMAP source. A new folder can be added to an IMAP source by PUTting the desired path under the sources/folders resource.

 <h3>Working with server-specific hierarchy delimiters</h3>

 IMAP servers are free to use the character they want as the folder hierarchy delimiter. The bad news is they don't use the same. The good news is you don't need to know this, we take care of it.

 <h4>Then what is that <code>delim</code> parameter for?</h4>

 Good question. By default, we expect you to specify the folder hierarchy using `/` as the hierarchy delimiter. For example, to create a folder called `my folder` under the folder `base folder`, you would call:

 `PUT /2.0/accounts/<id>/sources/<label>/folders/base+folder/my+folder`
 No matter what's the actual hierarchy delimiter the IMAP server expects, this call will work. However, say you need to use another character as the delimiter, here's how you'd do it:

 `PUT /2.0/accounts/<id>/sources/<label>/folders/base+folder.my+folder?delim=.`

 Both examples above are equivalent and will have the same result no matter what the IMAP server expects as the actual hierarchy delimiter.

 @param folderPath  The full folder path using / as the path hierarchy delimiter.
 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 @param delim       If / isn't fancy enough as a hierarchy delimiter when specifying the folder you want to create, you're free to use what you want, just make sure you set this delim parameter to tell us what you're using.
 */
- (CIODictionaryRequest *)createFolderWithPath:(NSString *)folderPath
                                   sourceLabel:(NSString *)sourceLabel
                                         delim:(nullable NSString *)delim;

/**
 Permanently removes a folder from the IMAP source

 This clears out all messages in the folder and CAN'T BE UNDONE. See IMAP specs for more information.

 @see http://tools.ietf.org/html/rfc3501#section-6.3.4

 @param folderPath The path of the folder you would like to delete.
 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)deleteFolderWithPath:(NSString *)folderPath sourceLabel:(NSString *)sourceLabel;

#pragma mark Sources/Folders/Expunge

/**
 Runs an `EXPUNGE` command on the email server. With this call, you can explicitly tell the email server to remove messages that are flagged for deletion. This will delete them permanently.

 @param folderPath  The full folder path using `/` as the path hierarchy delimiter.
 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)expungeFolderWithPath:(NSString *)folderPath
                                    sourceLabel:(NSString *)sourceLabel;

#pragma mark Sources/Folders/Messages

/**
 This call returns the same message data as the messages resource but instead of returning whatever is available from the metadata index we maintain, it checks the IMAP server for new messages and includes thoses in the response.

 The advantage is a list of message that reflects what's on the IMAP server at the moment the call is made vs. what was there the last time we synched with it. The downside is longer response time, a restricted set of parameters to filter results, and the fact the listing only works on a per-folder basis instead of all messages in the account.

 @see `CIOFolderMessagesRequest` for more optional parameters with this request.

 @warning This call will synchronously check the IMAP server for new emails and fetch them to update the index before sending the response. Don't expect to get a response in less than 1 second.

 @param folderPath  The full folder path using `/` as the path hierarchy delimiter.
 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIOFolderMessagesRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                                               sourceLabel:(NSString *)sourceLabel;

#pragma mark Sources/Sync

/**
 Sync status of a data source. This returns timestamps for the last time the source has been synced with the origin mailbox.

 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel;

/**
 Trigger a sync of a data source. This will start a sync job for the source.

 @param sourceLabel The label property of the source instance. You can use `@"0"` as an alias for the first source of an account.
 */
- (CIODictionaryRequest *)forceSyncForSourceWithLabel:(NSString *)sourceLabel;

#pragma mark - Sync

/**
 Sync status for all sources of the account. This returns timestamps for the last time a source has been synced with the origin mailbox.
 */
- (CIODictionaryRequest *)getSyncStatusForAllSources;

/**
 Trigger a sync of all sources on the account. This will start a sync job for all sources under the account.
 */
- (CIODictionaryRequest *)forceSyncForAllSources;


#pragma mark - Threads

/**
 List threads on an account.

 */
- (CIOThreadsRequest *)getThreads;

/**
 Returns files, contacts and messages on a given thread

 The purpose of this call is to allow Gmail extensions to easily retrieve data when users's load a conversation in the Gmail UI. Hence, threads are identified by the value of their Gmail thread prefixed with "gm-".

 For example, if the URL of a conversation in the Gmail UI is https://mail.google.com/mail/u/0/#mbox/13119ab37f00b826, you would obtain the details about this thread by calling `[client getThreadWithId:@"gm-13119ab37f00b826"];`.

 <h3>What about threads on non-Gmail mailboxes?</h3>

 You can retrieve thread information for any message using `getThreadForMessageWithID:`.

 @param threadID A `gmail_thread_id` prefixed with `gm-`
 */
- (CIOThreadRequest *)getThreadWithID:(NSString *)threadID;

/**
 Delete a thread

 @param threadID A `gmail_thread_id` prefixed with `gm-`
 */
- (CIODictionaryRequest *)deleteThreadWithID:(NSString *)threadID;

#pragma mark Threads/Folders

/**
 Add/remove thread to/from a folder

 You can add or remove a thread to or from a folder (or a gmail label) with this call. It does not impact the other folders that the thread is in.

 @see https://context.io/docs/2.0/accounts/threads/folders

 @param threadID    A `gmail_thread_id` prefixed with `gm-`
 @param addFolder    New folder this thread should appear in.
 @param removeFolder Folder this thread should be removed from.
 */
- (CIODictionaryRequest *)updateFoldersForThreadWithID:(NSString *)threadID addToFolder:(nullable NSString *)addFolder removeFromFolder:(nullable NSString *)removeFolder;

/**
 Sets folders that should be applied to this thread

 Sets the folders (or Gmail labels) that should be applied to this thread. Unlike the POST call which allows you to remove the thread from a given folder or add it to another without impacting other folders, this overwrites current folder assignation of the thread with what you set.

 TODO: This is currently getting OAuth signing errors. Needs more investigation.

 @param threadID    A `gmail_thread_id` prefixed with `gm-`
 @param folderNames         Array of Gmail Label names folder names
 @param symbolicFolderNames Array of 'Special-use attribute of a folder (if and only if the server supports it and applicable to this folder)'
 */
- (CIODictionaryRequest *)setFoldersForThreadWithID:(NSString *)threadID folderNames:(nullable NSArray *)folderNames symbolicFolderNames:(nullable NSArray *)symbolicFolderNames;

#pragma mark - Discovery

/**
 Attempts to discover IMAP settings for a given email address

 https://context.io/docs/2.0/discovery

 This is useful when you want to add an email account under your API key and you'd like to make the settings easier to fill by the user with pre-populated data.

 This will also figure out if OAuth2 over IMAP is available.

 @see https://developers.google.com/gmail/oauth_overview?csw=1

 @param sourceType The type of source you want to discover settings for. Right now, the only supported source type is `IMAP`.
 @param email      An email address you want to discover IMAP settings for. Make sure `source_type` is set to `IMAP`.
 */
- (CIODictionaryRequest *)getSettingsForSourceType:(NSString *)sourceType email:(NSString *)email;

@end

NS_ASSUME_NONNULL_END
