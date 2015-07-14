//
//  CIOAPIClient.h
//  
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import <Foundation/Foundation.h>
#import "CIORequest.h"

/**
 `CIOAPIClient` provides an easy to use client for interacting with the Context.IO API from Objective-C. It is built on top of AFNetworking and provides convenient asynchronous block based methods for the various calls used to interact with a user's email accounts. The client also handles authentication and all signing of requests.
 
 ## Response Parsing
 
 JSON reponses from the API are automatically parsed into dictionary or array objects depending on the particular API call.
 
 ## Subclassing Notes
 
 As with AFNetworking on which CIOAPIClient is built upon, it will generally be helpful to create a `CIOAPIClient` subclass that contains your consumer key and secret, as well as a class method that returns a singleton shared API client. This will allow you to persist your credentials and any other configuration across the entire application. Please note however, that once authenticated, nearly all API calls are scoped to the user's account. If you would like to access multiple user accounts, you will need to use separate API clients for each.
 */

typedef NS_ENUM(NSInteger, CIOEmailProviderType) {
    CIOEmailProviderTypeGenericIMAP = 0,
    CIOEmailProviderTypeGmail = 1,
    CIOEmailProviderTypeYahoo = 2,
    CIOEmailProviderTypeAOL = 3,
    CIOEmailProviderTypeHotmail = 4,
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kCIOAPIBaseURLString;

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

///---------------------------------------------
/// @name Creating and Initializing API Clients
///---------------------------------------------

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret.
 
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
 *  @param params parameters to send, will be sent as URL params for GET, otherwise sent as a x-www-form-urlencoded body
 *
 */
- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Authenticating the API Client
///---------------------------------------------

/**
 Begins the authentication process for a new account/email source by creating a connect token.
 
 @param providerType The type of email provider you would like to authenticate. Please see `CIOEmailProviderType`.
 @param callbackURLString The callback URL string that the API should redirect to after successful authentication of an email account. You will need to watch for this request in your UIWebView delegate's -webView:shouldStartLoadWithRequest:navigationType: method to intercept the connect token. See the example app for details.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the auth redirect URL that should be loaded in your UIWebView to allow the user to authenticate their email account.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
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
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the object created from the response data of request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (BOOL)completeLoginWithResponse:(NSDictionary *)responseObject saveCredentials:(BOOL)saveCredentials;

/**
 Clears the credentials stored in the keychain.
 */
- (void)clearCredentials;

///---------------------------------------------
/// @name Working With Contacts and Related Resources
///---------------------------------------------

/**
 Retrieves the current account's details.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getAccountWithParams:(nullable NSDictionary *)params;


/**
 Updates the current account's details.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateAccountWithParams:(nullable NSDictionary *)params;

/**
 Deletes the current account.
 
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteAccount;

/**
 Retrieves the account's contacts.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */ 
- (CIODictionaryRequest *)getContactsWithParams:(nullable NSDictionary *)params;
/**
 Retrieves the contact with the specified email.
 
 @param email The email address of the contact you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getContactWithEmail:(NSString *)email
                     params:(nullable NSDictionary *)params;

/**
 Retrieves any files associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
*/
- (CIOArrayRequest *)getFilesForContactWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Retrieves any messages associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated messages.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getMessagesForContactWithEmail:(NSString *)email
                                params:(nullable NSDictionary *)params;

/**
 Retrieves any threads associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated threads.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getThreadsForContactWithEmail:(NSString *)email
                               params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Working With Email Address aliases
///---------------------------------------------

/**
 Retrieves the account's email addresses.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getEmailAddressesWithParams:(nullable NSDictionary *)params;

/**
 Associates a new email address with the account.
 
 @param email The email address you would like to associate with the account.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)createEmailAddressWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Retrieves the details of a particular email address.
 
 @param email The email address for which you would like to retrieve details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getEmailAddressWithEmail:(NSString *)email
                          params:(nullable NSDictionary *)params;

/**
 Updates the details of a particular email address.
 
 @param email The email address for which you would like to update details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateEmailAddressWithEmail:(NSString *)email
                             params:(nullable NSDictionary *)params;

/**
 Disassociates a particular email address from the account.
 
 @param email The email address you would like to disassociate from the account.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteEmailAddressWithEmail:(NSString *)email;

///---------------------------------------------
/// @name Working With Files and Related Resources
///---------------------------------------------

/**
 Retrieves the account's files.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getFilesWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the file with the specified id.
 
 @param fileID The id of the file you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getFileWithID:(NSString *)fileID
               params:(nullable NSDictionary *)params;

/**
 Retrieves any changes associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve changes.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getChangesForFileWithID:(NSString *)fileID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves a public facing URL that can be used to download a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getContentsURLForFileWithID:(NSString *)fileID
                            params:(nullable NSDictionary *)params;

/**
 Retrieves the contents of a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param saveToPath The local file path where you would like to save the contents of the file.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes no arguments.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 @param progressBlock A block object to be executed during the downloading of the contents to update you on the progress. This block has no return value and takes three arguments: the bytes read since the last execution of the block, the total number of bytes read, and the total number of bytes that are expected to be read. This block will be executed multiple times during the download process.
 */
- (CIODownloadRequest *)downloadContentsOfFileWithID:(NSString *)fileID;

/**
 Retrieves other files associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getRelatedForFileWithID:(NSString *)fileID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves the revisions of a particular file.
 
 @param fileID The id of the file for which you would like to retrieve revisions.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getRevisionsForFileWithID:(NSString *)fileID
                           params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Working With Messages and Related Resources
///---------------------------------------------

/**
 Retrieves the account's messages.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getMessagesWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getMessageWithID:(NSString *)messageID
                  params:(nullable NSDictionary *)params;

/**
 Updates the message with the specified id.
 
 @param messageID The id of the message you would like to update.
 @param destinationFolder The new folder for the message.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateMessageWithID:(NSString *)messageID
          destinationFolder:(NSString *)destinationFolder
                                       params:(nullable NSDictionary *)params;

/**
 Deletes the message with the specified id.
 
 @param messageID The id of the message you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteMessageWithID:(NSString *)messageID;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getBodyForMessageWithID:(NSString *)messageID
                         params:(nullable NSDictionary *)params;

/**
 Retrieves the flags for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getFlagsForMessageWithID:(NSString *)messageID
                          params:(nullable NSDictionary *)params;

/**
 Updates the flags for a particular message.
 
 @param messageID The id of the message for which you would like to update the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateFlagsForMessageWithID:(NSString *)messageID
                             params:(nullable NSDictionary *)params;

/**
 Retrieves the folders for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getFoldersForMessageWithID:(NSString *)messageID
                            params:(nullable NSDictionary *)params;

/**
 Updates the folders for a particular message.
 
 @param messageID The id of the message for which you would like to update the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateFoldersForMessageWithID:(NSString *)messageID
                               params:(nullable NSDictionary *)params;

/**
 Sets the folders for a particular message.
 
 @param messageID The id of the message for which you would like to set the folders.
 @param folders A dictionary of the new folders for a particular message. See API documentation for details of format.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)setFoldersForMessageWithID:(NSString *)messageID
                           folders:(NSDictionary *)folders;

/**
 Retrieves the headers for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the headers.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getHeadersForMessageWithID:(NSString *)messageID
                            params:(nullable NSDictionary *)params;

/**
 Retrieves the source for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the source.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getSourceForMessageWithID:(NSString *)messageID
                           params:(nullable NSDictionary *)params;

/**
 Retrieves the thread for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the thread.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getThreadForMessageWithID:(NSString *)messageID
                           params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Working With Sources and Related Resources
///---------------------------------------------

/**
 Retrieves the account's sources.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getSourcesWithParams:(nullable NSDictionary *)params;

/**
 Creates a new source under the account. Note: It is usually preferred to use `-beginAuthForProviderType:callbackURLString:params:success:failure:` to add a new source to the account.
 
 @param email The email address of the new source.
 @param server The IMAP server of the new source.
 @param username The username to authenticate the new source.
 @param useSSL Whether the API should use SSL when connecting to this source.
 @param port The port of the new source.
 @param type The server type of the new source. Currently this can only be IMAP.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
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
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getSourceWithLabel:(NSString *)sourceLabel
                    params:(nullable NSDictionary *)params;

/**
 Updates the source with the specified label.
 
 @param sourceLabel The label of the source you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateSourceWithLabel:(NSString *)sourceLabel
                       params:(nullable NSDictionary *)params;

/**
 Deletes the source with the specified label.
 
 @param sourceLabel The label of the source you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteSourceWithLabel:(NSString *)sourceLabel;

/**
 Retrieves the folders for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                              params:(nullable NSDictionary *)params;

/**
 Retrieves a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to retrieve.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getFolderWithPath:(NSString *)folderPath
              sourceLabel:(NSString *)sourceLabel
                   params:(nullable NSDictionary *)params;

/**
 Deletes a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to delete.
 @param sourceLabel The label of the source to which the folder belongs.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel;

/**
 Creates a new folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to create.
 @param sourceLabel The label of the source where the folder should be created.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)createFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                      params:(nullable NSDictionary *)params;

/**
 Expunges a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to expunge.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)expungeFolderWithPath:(NSString *)folderPath
                  sourceLabel:(NSString *)sourceLabel
                       params:(nullable NSDictionary *)params;

/**
 Retrieve the messages for a folder belonging to a particular source.
 
 @param folderPath The path of the folder for which you would like to retrieve messages.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                         sourceLabel:(NSString *)sourceLabel
                              params:(nullable NSDictionary *)params;

/**
 Retrieves the sync status for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the sync status.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel
                                 params:(nullable NSDictionary *)params;

/**
 Force a sync for a particular source.
 
 @param sourceLabel The label of the source for which you would like to force a sync.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)forceSyncForSourceWithLabel:(NSString *)sourceLabel
                             params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Working With Sources and Related Resources
///---------------------------------------------

/**
 Retrieves the account's threads.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIOArrayRequest *)getThreadsWithParams:(nullable NSDictionary *)params;

/**
 Retrieves the thread with the specified id.
 
 @param threadID The id of the thread you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getThreadWithID:(NSString *)threadID
                 params:(nullable NSDictionary *)params;

///---------------------------------------------
/// @name Working With Webhooks and Related Resources
///---------------------------------------------

/**
 Retrieves the account's webhooks.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */

- (CIOArrayRequest *)getWebhooksWithParams:(nullable NSDictionary *)params;

/**
 Creates a new webhook.
 
 @param callbackURLString A string representing the callback URL for the new webhook.
 @param failureNotificationURLString A string representing the failure notification URL for the new webhook.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)createWebhookWithCallbackURLString:(NSString *)callbackURLString
              failureNotificationURLString:(NSString *)failureNotificationURLString
                                    params:(nullable NSDictionary *)params;

/**
 Retrieves the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)getWebhookWithID:(NSString *)webhookID
                  params:(nullable NSDictionary *)params;

/**
 Updates the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)updateWebhookWithID:(NSString *)webhookID
                     params:(nullable NSDictionary *)params;

/**
 Deletes the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (CIODictionaryRequest *)deleteWebhookWithID:(NSString *)webhookID;

@end

NS_ASSUME_NONNULL_END