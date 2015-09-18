//
//  CIOLiteClient.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/28/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClient.h"
#import "CIOLiteMessageRequest.h"
#import "CIOLiteWebhookRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CIOLiteClient : CIOAPIClient

/**
 Initializes a `CIOLiteClient` object with the specified consumer key and secret. If a previously-authenticated consumer
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

#pragma mark - Users

/**
 *   Retrieves the current user's details.
 *
 */
- (CIODictionaryRequest *)getUser;

/**
 *  Modify the current account's info.
 *
 *  @param firstName new first name, optional
 *  @param lastName  new last name, optional
 *
 *  @return request to modify the account
 */
- (CIODictionaryRequest *)updateUserWithFirstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName;


/**
 *  Deletes the current account.
 *
 *
 */
- (CIODictionaryRequest *)deleteUser;

#pragma mark - Email Accounts

/**
 List email accounts assigned to the current user
 */
- (CIOArrayRequest *)getEmailAccounts;

/**
 List email accounts assigned to the current user

 @param status   Only return email accounts whose status is of a specific value. Use `CIOAccountStatusNull` for all accounts
 @param statusOK Pass `@NO` to get email accounts that are not working correctly. Pass `@YES` to get those that are, and `nil` for all
 */
- (CIOArrayRequest *)getEmailAccountsWithStatus:(CIOAccountStatus)status statusOK:(nullable NSNumber *)statusOK;

/**
 Add a new mailbox for the current user. Note: It is usually preferred to use
 `-beginAuthForProviderType:callbackURLString:params:` to add a new mailbox to the account via connect tokens.

 @see `CIOCreateSourceRequest` for futher optional parameters to this request.

 @param email The primary email address used to receive emails in this account.
 @param server Name or IP of the IMAP server, eg. `imap.gmail.com`
 @param username The username used to authenticate an IMAP connection. On some servers, this is the same thing as the primary email address.
 @param useSSL Set to `YES` if you want SSL encryption to be used when opening connections to the IMAP server. Any other value will be considered as "do not use SSL"
 @param port Port number to connect to on the server. Keep in mind that most IMAP servers will have one port for standard connection and another one for encrypted connection (see `use-ssl` parameter)
 @param type The email protocol to use for the account. Valid values are `IMAP` and `exchange`
 */
- (CIOAddMailboxRequest *)addMailboxWithEmail:(NSString *)email
                                       server:(NSString *)server
                                     username:(NSString *)username
                                       useSSL:(BOOL)useSSL
                                         port:(NSInteger)port
                                         type:(NSString *)type;

/**
 Get parameters and status for an email account.
 
 @param label   The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 */
- (CIODictionaryRequest *)statusForEmailAccountWithLabel:(nullable NSString *)label;

/**
 Update settings for an email account.
 
 @see `CIOMailboxModifyRequest` for optional parameters used to modify the account.

 @param label   The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 */
- (CIOMailboxModifyRequest *)modifyEmailAccountWithLabel:(nullable NSString *)label;

/**
 Delete an email email account with the given label.

 @param label   The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 */
- (CIODictionaryRequest *)deleteEmailAccountWithLabel:(nullable NSString *)label;

#pragma mark - Email Account Folders

/**
 List folders in an email account
 
 @see https://context.io/docs/lite/users/email_accounts/folders

 @param accountLabel     The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 @param includeNamesOnly Set to `YES` to return only folder names and no status information.
 
 */
- (CIOArrayRequest *)getFoldersForAccountWithLabel:(nullable NSString *)accountLabel includeNamesOnly:(BOOL)includeNamesOnly;

/**
 Returns information about a given folder

 @param folderName   The full folder path using `/` as the path hierarchy delimiter.
  @param accountLabel The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 @param delimiter If `/` isn't fancy enough as a hierarchy delimiter when specifying the folder you want to obtain, you're free to use what you want, just make sure you set this `delimiter` parameter to tell us what you're using. 
 */
- (CIODictionaryRequest *)getFolderNamed:(NSString *)folderName forAccountWithLabel:(nullable NSString *)accountLabel delimiter:(nullable NSString *)delimiter;

/**
Create a folder on an email account

 @param folderName   The full folder path using `/` as the path hierarchy delimiter.
 @param accountLabel The label property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 @param delimiter    If `/` isn't fancy enough as a hierarchy delimiter when specifying the folder you want to obtain, you're free to use what you want, just make sure you set this `delimiter` parameter to tell us what you're using.
 */
- (CIODictionaryRequest *)addFolderNamed:(NSString *)folderName forAccountWithLabel:(nullable NSString *)accountLabel delimiter:(nullable NSString *)delimiter;

#pragma mark - Email Account Folder Messages

/**
 Listings of email messages for a user
 
 @see https://context.io/docs/lite/users/email_accounts/folders/messages

 @param folderPath   The full folder path using `/` as the path hierarchy delimiter.
 @param accountLabel The `label` property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 */
- (CIOLiteFolderMessagesRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                                                  accountLabel:(nullable NSString *)accountLabel;

/**
 File, contact and other information about a given email message

 @param messageID    Unique id of a message. This must be a email_message_id of an existing message in the thread. The < and > at the beginning and end of the Message-ID are part of the value and should be included if you're using an `email_message_id`.
 @param folderPath   The full folder path using `/` as the path hierarchy delimiter.
 @param accountLabel The `label` property of the email account instance. You can use `"0"` or `nil` as an alias for the first email account of a user.
 */
- (CIOLiteMessageRequest *)requestForMessageWithID:(NSString *)messageID inFolder:(NSString *)folderPath accountLabel:(nullable NSString *)accountLabel delimiter:(nullable NSString *)delimiter;

#pragma mark - Webhooks

/**
 Listing of WebHook configured for the current user
 
 @see https://context.io/docs/lite/users/webhooks
 */
- (CIOArrayRequest *)listWebhooks;

/**
 Create a new WebHook on the current user
 
 See `CIOLiteWebhookRequest` for additional optional parameters that can be provided when creating a new WebHook.
 
 @see https://context.io/docs/lite/users/webhooks#callbacks

 @param callbackURL A valid URL Context.IO calls when a matching message is found.

 The callback URL is called with an HTTP POST with message information in request body
 @param failureURL  A valid URL Context.IO calls if the WebHooks fails and will no longer be active. That may happen if, for example, the server becomes unreachable or if it closes an IDLE connection and we can't re-establish it.

 The callback URL is called with an HTTP POST with more information in request body
 */
- (CIOLiteWebhookRequest *)createWebhookWithCallbackURL:(NSString *)callbackURL failureURL:(NSString *)failureURL;

/**
 Get properties of a given WebHook

 @param webhookID Unique id of the webhook instance.
 */
- (CIODictionaryRequest *)getWebhookInfoForID:(NSString *)webhookID;

/**
 Change properties of a given WebHook
 
 The only property of a WebHook that can be changed is it's active property. If you want to change the filters or callback urls, delete it and create a new one.

 Changing the `active` property can be useful in two cases:

 <h3>Pause/resume WebHooks</h3>

 If your application needs up-to-date information when users are logged in the best option is to keep a WebHook with no filters that can be activated (setting active to `YES`) when the user logs in and paused (setting active to `NO`) when the user logs out of your app.

 <h3>Acting upon a failure notification</h3>

 If a WebHook fails, your `failureURL` is called (see `createWebhookWithCallbackURL:failureURL`) and its failure property becomes true. Set the WebHook active parameter to `YES` to reset it.

 @param webhookID Unique id of the webhook instance.
 @param active    The `active` property of a WebHook allows you to pause (set to `NO`) or resume (set to `YES`) it
 */
- (CIODictionaryRequest *)setWebhookID:(NSString *)webhookID toActive:(BOOL)active;

/**
 Cancel a WebHook

 @param webhookID Unique id of the webhook instance.
 */
- (CIODictionaryRequest *)cancelWebhookWithID:(NSString *)webhookID;

#pragma mark - Discovery

/**
 Attempt to discover connection settings for a given email address

 https://context.io/docs/lite/discovery

 This is useful when you want to add an email account under your API key and you'd like to make the settings easier to fill by the user with pre-populated data.

 This will also figure out if OAuth2 over IMAP is available.

 @see https://developers.google.com/gmail/oauth_overview?csw=1

 @param sourceType The type of source you want to discover settings for. Right now, the only supported source type is `IMAP`.
 @param email      An email address you want to discover IMAP settings for. Make sure `source_type` is set to `IMAP`.
 */
- (CIODictionaryRequest *)getSettingsForSourceType:(NSString *)sourceType email:(NSString *)email;

@end

NS_ASSUME_NONNULL_END