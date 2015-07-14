//
//  CIOAPIClient.h
//  
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import <Foundation/Foundation.h>
#import "CIORequest.h"



typedef NS_ENUM(NSInteger, CIOEmailProviderType) {
    CIOEmailProviderTypeGenericIMAP = 0,
    CIOEmailProviderTypeGmail = 1,
    CIOEmailProviderTypeYahoo = 2,
    CIOEmailProviderTypeAOL = 3,
    CIOEmailProviderTypeHotmail = 4,
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CIOAPIBaseURLString;

/**
 `CIOAPIClient` provides an easy to use interface for constructing requests against the Context.IO API. The client handles authentication and all signing of requests.

 Each `CIOAPIClient` instance handles its own authentication credentials. If the credentials are saved to the keychain via `completeLoginWithResponse:saveCredentials:`, they are keyed off of the consumer key. `CIOAPIClient` will restore saved credentials if it is initalized with a previously-authenticated consumer key/secret.
 */
@interface CIOAPIClient : NSObject

@property (readonly, nonatomic, nullable) NSString *accountID;

/**
 The current authorization status of the API client.
 */
@property (nonatomic, readonly) BOOL isAuthorized;

/**
 The timeout interval for all requests made. Defaults to 60 seconds.
 */
@property (nonatomic) NSTimeInterval timeoutInterval;

#pragma mark - Creating and Initializing API Clients

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret. If a previously-authenticated consumer key is provided, its authentcation information will be restored from the keychain.
 
 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.
 
 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret;

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret, and additionally token and token secret. Use this method if you have already obtained a token and token secret on your own, and do not wish to use the built-in keychain storage.
 
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
                accountID:(nullable NSString *)accountID NS_DESIGNATED_INITIALIZER;

/**
 *  Create a signed `NSURLRequest` for the context.io API using current OAuth credentials
 *
 *  @param path   path in the 2.0 API namespace, e.g. "accounts/<id>/contacts"
 *  @param method HTTP request method
 *  @param params parameters to send, will be sent as URL params for GET, otherwise sent as a `x-www-form-urlencoded` body
 *
 */
- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method params:(nullable NSDictionary *)params;

#pragma mark - Authenticating the API Client

/**
 Begins the authentication process for a new account/email source by creating a connect token.
 
 @param providerType The type of email provider you would like to authenticate. Please see `CIOEmailProviderType`.
 @param callbackURLString The callback URL string that the API should redirect to after successful authentication of an email account. You will need to watch for this request in your UIWebView delegate's -webView:shouldStartLoadWithRequest:navigationType: method to intercept the connect token. See the example app for details.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 */
- (CIODictionaryRequest *)beginAuthForProviderType:(CIOEmailProviderType)providerType
                         callbackURLString:(NSString *)callbackURLString
                                    params:(nullable NSDictionary *)params;

- (NSURL *)redirectURLFromResponse:(NSDictionary *)responseDict;

- (CIODictionaryRequest *)fetchAccountWithConnectToken:(NSString *)connectToken;

/**
 Uses the connect token received from the API to complete the authentication process and optionally save the credentials to the keychain.
 
 @param connectToken The connect token returned by the API after the user successfully authenticates an email account. This is returned as a query parameter appended to the callback URL that the API uses as a final redirect.
 @param saveCredentials This determines if credentials are saved to the device's keychain.
 */
- (BOOL)completeLoginWithResponse:(NSDictionary *)responseObject saveCredentials:(BOOL)saveCredentials;

/**
 Clears the credentials stored in the keychain.
 */
- (void)clearCredentials;

#pragma mark - Working With Contacts and Related Resources

/**
 Retrieves the current account's details.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getAccountWithParams:(nullable NSDictionary *)params;


/**
 Updates the current account's details.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateAccountWithParams:(nullable NSDictionary *)params;

/**
 Deletes the current account.
 
 */
- (CIODictionaryRequest *)deleteAccount;

/**
 Retrieves the account's contacts.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */ 
- (CIODictionaryRequest *)getContactsWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the contact with the specified email.
 
 @param email The email address of the contact you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getContactWithEmail:(NSString *)email
                     params:(nullable NSDictionary *)params;

/**
 Retrieves any files associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
*/
- (CIOArrayRequest *)getFilesForContactWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Retrieves any messages associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated messages.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getMessagesForContactWithEmail:(NSString *)email
                                params:(nullable NSDictionary *)params;

/**
 Retrieves any threads associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated threads.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getThreadsForContactWithEmail:(NSString *)email
                               params:(nullable NSDictionary *)params;

#pragma mark - Working With Email Address Aliases

/**
 Retrieves the account's email addresses.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getEmailAddressesWithParams:(nullable NSDictionary *)params;

/**
 Associates a new email address with the account.
 
 @param email The email address you would like to associate with the account.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)createEmailAddressWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Retrieves the details of a particular email address.
 
 @param email The email address for which you would like to retrieve details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getEmailAddressWithEmail:(NSString *)email
                          params:(nullable NSDictionary *)params;

/**
 Updates the details of a particular email address.
 
 @param email The email address for which you would like to update details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateEmailAddressWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Disassociates a particular email address from the account.
 
 @param email The email address you would like to disassociate from the account.
 */
- (CIODictionaryRequest *)deleteEmailAddressWithEmail:(NSString *)email;

#pragma mark - Working With Files and Related Resources

/**
 Retrieves the account's files.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getFilesWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the file with the specified id.
 
 @param fileID The id of the file you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getFileWithID:(NSString *)fileID
               params:(nullable NSDictionary *)params;

/**
 Retrieves any changes associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve changes.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getChangesForFileWithID:(NSString *)fileID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves a public facing URL that can be used to download a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOStringRequest *)getContentsURLForFileWithID:(NSString *)fileID
                            params:(nullable NSDictionary *)params;

/**
 Retrieves the contents of a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param saveToPath The local file path where you would like to save the contents of the file.
 */
- (CIORequest *)downloadContentsOfFileWithID:(NSString *)fileID;

/**
 Retrieves other files associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getRelatedForFileWithID:(NSString *)fileID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves the revisions of a particular file.
 
 @param fileID The id of the file for which you would like to retrieve revisions.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getRevisionsForFileWithID:(NSString *)fileID
                           params:(nullable NSDictionary *)params;

#pragma mark - Working With Messages and Related Resources

/**
 Retrieves the account's messages.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getMessagesWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getMessageWithID:(NSString *)messageID
                  params:(nullable NSDictionary *)params;

/**
 Updates the message with the specified id.
 
 @param messageID The id of the message you would like to update.
 @param destinationFolder The new folder for the message.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateMessageWithID:(NSString *)messageID
          destinationFolder:(NSString *)destinationFolder
                                       params:(nullable NSDictionary *)params;

/**
 Deletes the message with the specified id.
 
 @param messageID The id of the message you would like to delete.
 */
- (CIODictionaryRequest *)deleteMessageWithID:(NSString *)messageID;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getBodyForMessageWithID:(NSString *)messageID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves the flags for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getFlagsForMessageWithID:(NSString *)messageID
                          params:(nullable NSDictionary *)params;

/**
 Updates the flags for a particular message.
 
 @param messageID The id of the message for which you would like to update the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateFlagsForMessageWithID:(NSString *)messageID
                             params:(nullable NSDictionary *)params;

/**
 Retrieves the folders for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getFoldersForMessageWithID:(NSString *)messageID
                            params:(nullable NSDictionary *)params;

/**
 Updates the folders for a particular message.
 
 @param messageID The id of the message for which you would like to update the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateFoldersForMessageWithID:(NSString *)messageID
                               params:(nullable NSDictionary *)params;

/**
 Sets the folders for a particular message.
 
 @param messageID The id of the message for which you would like to set the folders.
 @param folders A dictionary of the new folders for a particular message. See API documentation for details of format.
 */
- (CIODictionaryRequest *)setFoldersForMessageWithID:(NSString *)messageID
                           folders:(NSDictionary *)folders;

/**
 Retrieves the headers for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the headers.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getHeadersForMessageWithID:(NSString *)messageID
                            params:(nullable NSDictionary *)params;

/**
 Retrieves the source for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the source.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOStringRequest *)getSourceForMessageWithID:(NSString *)messageID
                           params:(nullable NSDictionary *)params;

/**
 Retrieves the thread for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the thread.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getThreadForMessageWithID:(NSString *)messageID
                           params:(nullable NSDictionary *)params;

#pragma mark - Working With Sources and Related Resources

/**
 Retrieves the account's sources.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getSourcesWithParams:(nullable NSDictionary *)params;

/**
 Creates a new source under the account. Note: It is usually preferred to use `-beginAuthForProviderType:callbackURLString:params:` to add a new source to the account.
 
 @param email The email address of the new source.
 @param server The IMAP server of the new source.
 @param username The username to authenticate the new source.
 @param useSSL Whether the API should use SSL when connecting to this source.
 @param port The port of the new source.
 @param type The server type of the new source. Currently this can only be IMAP.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)createSourceWithEmail:(NSString *)email
                       server:(NSString *)server
                     username:(NSString *)username
                       useSSL:(BOOL)useSSL
                         port:(NSInteger)port
                         type:(NSString *)type
                       params:(nullable NSDictionary *)params;

/**
 Retrieves the source with the specified label.
 
 @param sourceLabel The label of the source you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getSourceWithLabel:(NSString *)sourceLabel
                    params:(nullable NSDictionary *)params;

/**
 Updates the source with the specified label.
 
 @param sourceLabel The label of the source you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateSourceWithLabel:(NSString *)sourceLabel
                       params:(nullable NSDictionary *)params;

/**
 Deletes the source with the specified label.
 
 @param sourceLabel The label of the source you would like to delete.
 */
- (CIODictionaryRequest *)deleteSourceWithLabel:(NSString *)sourceLabel;

/**
 Retrieves the folders for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                              params:(nullable NSDictionary *)params;

/**
 Retrieves a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to retrieve.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getFolderWithPath:(NSString *)folderPath
              sourceLabel:(NSString *)sourceLabel
                   params:(nullable NSDictionary *)params;

/**
 Deletes a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to delete.
 @param sourceLabel The label of the source to which the folder belongs.
 */
- (CIODictionaryRequest *)deleteFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel;

/**
 Creates a new folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to create.
 @param sourceLabel The label of the source where the folder should be created.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)createFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                      params:(nullable NSDictionary *)params;

/**
 Expunges a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to expunge.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)expungeFolderWithPath:(NSString *)folderPath
                  sourceLabel:(NSString *)sourceLabel
                       params:(nullable NSDictionary *)params;

/**
 Retrieve the messages for a folder belonging to a particular source.
 
 @param folderPath The path of the folder for which you would like to retrieve messages.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                         sourceLabel:(NSString *)sourceLabel
                              params:(nullable NSDictionary *)params;

/**
 Retrieves the sync status for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the sync status.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel
                                 params:(nullable NSDictionary *)params;

/**
 Force a sync for a particular source.
 
 @param sourceLabel The label of the source for which you would like to force a sync.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)forceSyncForSourceWithLabel:(NSString *)sourceLabel
                             params:(nullable NSDictionary *)params;

#pragma mark - Working With Sources and Related Resources

/**
 Retrieves the account's threads.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIOArrayRequest *)getThreadsWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the thread with the specified id.
 
 @param threadID The id of the thread you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getThreadWithID:(NSString *)threadID
                 params:(nullable NSDictionary *)params;

#pragma mark - Working With Webhooks and Related Resources

/**
 Retrieves the account's webhooks.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */

- (CIOArrayRequest *)getWebhooksWithParams:(nullable NSDictionary *)params;

/**
 Creates a new webhook.
 
 @param callbackURLString A string representing the callback URL for the new webhook.
 @param failureNotificationURLString A string representing the failure notification URL for the new webhook.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)createWebhookWithCallbackURLString:(NSString *)callbackURLString
              failureNotificationURLString:(NSString *)failureNotificationURLString
                                    params:(nullable NSDictionary *)params;

/**
 Retrieves the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)getWebhookWithID:(NSString *)webhookID
                  params:(nullable NSDictionary *)params;

/**
 Updates the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 */
- (CIODictionaryRequest *)updateWebhookWithID:(NSString *)webhookID
                     params:(nullable NSDictionary *)params;

/**
 Deletes the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to delete.
 */
- (CIODictionaryRequest *)deleteWebhookWithID:(NSString *)webhookID;

@end

NS_ASSUME_NONNULL_END