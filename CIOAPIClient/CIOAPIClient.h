//
//  CIOAPIClient.h
//  
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

/**
 `CIOAPIClient` provides an easy to use client for interacting with the Context.IO API from Objective-C. It is built on top of AFNetworking and provides convenient asynchronous block based methods for the various calls used to interact with a user's email accounts. The client also handles authentication and all signing of requests.
 
 ## Response Parsing
 
 JSON reponses from the API are automatically parsed into dictionary or array objects depending on the particular API call.
 
 ## Subclassing Notes
 
 As with AFNetworking on which CIOAPIClient is built upon, it will generally be helpful to create a `CIOAPIClient` subclass that contains your consumer key and secret, as well as a class method that returns a singleton shared API client. This will allow you to persist your credentials and any other configuration across the entire application. Please note however, that once authenticated, nearly all API calls are scoped to the user's account. If you would like to access multiple user accounts, you will need to use separate API clients for each.
 */

typedef enum {
    CIOEmailProviderTypeGenericIMAP = 0,
    CIOEmailProviderTypeGmail = 1,
    CIOEmailProviderTypeYahoo = 2,
    CIOEmailProviderTypeAOL = 3,
    CIOEmailProviderTypeHotmail = 4,
} CIOEmailProviderType;

@interface CIOAPIClient : NSObject

/**
 The current authorization status of the API client.
 */
@property (nonatomic, readonly) BOOL isAuthorized;

///---------------------------------------------
/// @name Creating and Initializing API Clients
///---------------------------------------------

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret.
 
 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.
 
 @return The newly-initialized API client
 */
- (id)initWithConsumerKey:(NSString *)consumerKey
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
- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                    token:(NSString *)token
              tokenSecret:(NSString *)tokenSecret
                accountID:(NSString *)accountID;

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
- (void)beginAuthForProviderType:(CIOEmailProviderType)providerType
               callbackURLString:(NSString *)callbackURLString
                          params:(NSDictionary *)params
                         success:(void (^)(NSURL *authRedirectURL))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Uses the connect token received from the API to complete the authentication process and optionally save the credentials to the keychain.
 
 @param connectToken The connect token returned by the API after the user successfully authenticates an email account. This is returned as a query parameter appended to the callback URL that the API uses as a final redirect.
 @param saveCredentials This determines if credentials are saved to the device's keychain.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes no arguments.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)finishLoginWithConnectToken:(NSString *)connectToken
                    saveCredentials:(BOOL)saveCredentials
                            success:(void (^)(id responseObject))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Clears the credentials stored in the keychain.
 */
- (void)clearCredentials;

///---------------------------------------------
/// @name Self Constructing API Calls
///---------------------------------------------

/**
 Constructs and enqueues a GET request to the API.
 
 @param path The path for the request.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the object created from the response data of request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getPath:(NSString *)path
         params:(NSDictionary *)params
        success:(void (^)(id responseObject))successBlock
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Constructs and enqueues a POST request to the API.
 
 @param path The path for the request.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the object created from the response data of request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)postPath:(NSString *)path
          params:(NSDictionary *)params
         success:(void (^)(id responseObject))successBlock
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Constructs and enqueues a PUT request to the API.
 
 @param path The path for the request.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the object created from the response data of request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)putPath:(NSString *)path
         params:(NSDictionary *)params
        success:(void (^)(id responseObject))successBlock
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Constructs and enqueues a DELETE request to the API.
 
 @param path The path for the request.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: the object created from the response data of request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deletePath:(NSString *)path
           success:(void (^)(id responseObject))successBlock
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Contacts and Related Resources
///---------------------------------------------

/**
 Retrieves the account's contacts.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */ 
- (void)getContactsWithParams:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the contact with the specified email.
 
 @param email The email address of the contact you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getContactWithEmail:(NSString *)email
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves any files associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
*/
- (void)getFilesForContactWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSArray *responseArray))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves any messages associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated messages.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getMessagesForContactWithEmail:(NSString *)email
                                params:(NSDictionary *)params
                               success:(void (^)(NSArray *responseArray))successBlock
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves any threads associated with a particular contact.
 
 @param email The email address of the contact for which you would like to retrieve associated threads.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getThreadsForContactWithEmail:(NSString *)email
                               params:(NSDictionary *)params
                              success:(void (^)(NSArray *responseArray))successBlock
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Email Address aliases
///---------------------------------------------

/**
 Retrieves the account's email addresses.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getEmailAddressesWithParams:(NSDictionary *)params
                            success:(void (^)(NSArray *responseArray))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Associates a new email address with the account.
 
 @param email The email address you would like to associate with the account.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)createEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the details of a particular email address.
 
 @param email The email address for which you would like to retrieve details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getEmailAddressWithEmail:(NSString *)email
                          params:(NSDictionary *)params
                         success:(void (^)(NSDictionary *responseDict))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the details of a particular email address.
 
 @param email The email address for which you would like to update details.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Disassociates a particular email address from the account.
 
 @param email The email address you would like to disassociate from the account.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteEmailAddressWithEmail:(NSString *)email
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;


///---------------------------------------------
/// @name Working With Files and Related Resources
///---------------------------------------------

/**
 Retrieves the account's files.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFilesWithParams:(NSDictionary *)params
                   success:(void (^)(NSArray *responseArray))successBlock
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the file with the specified id.
 
 @param fileID The id of the file you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFileWithID:(NSString *)fileID
               params:(NSDictionary *)params
              success:(void (^)(NSDictionary *responseDict))successBlock
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves any changes associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve changes.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getChangesForFileWithID:(NSString *)fileID
                         params:(NSDictionary *)params
                        success:(void (^)(NSArray *responseArray))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves a public facing URL that can be used to download a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getContentsURLForFileWithID:(NSString *)fileID
                            params:(NSDictionary *)params
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the contents of a particular file.
 
 @param fileID The id of the file that you would like to download.
 @param saveToPath The local file path where you would like to save the contents of the file.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes no arguments.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 @param progressBlock A block object to be executed during the downloading of the contents to update you on the progress. This block has no return value and takes three arguments: the bytes read since the last execution of the block, the total number of bytes read, and the total number of bytes that are expected to be read. This block will be executed multiple times during the download process.
 */
- (void)downloadContentsOfFileWithID:(NSString *)fileID
                          saveToPath:(NSString *)saveToPath
                              params:(NSDictionary *)params
                             success:(void (^)())successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
                            progress:(void (^) (NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead ))progressBlock;

/**
 Retrieves other files associated with a particular file.
 
 @param fileID The id of the file for which you would like to retrieve associated files.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getRelatedForFileWithID:(NSString *)fileID
                         params:(NSDictionary *)params
                        success:(void (^)(NSArray *responseArray))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the revisions of a particular file.
 
 @param fileID The id of the file for which you would like to retrieve revisions.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getRevisionsForFileWithID:(NSString *)fileID
                           params:(NSDictionary *)params
                          success:(void (^)(NSArray *responseArray))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Messages and Related Resources
///---------------------------------------------

/**
 Retrieves the account's messages.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getMessagesWithParams:(NSDictionary *)params
                      success:(void (^)(NSArray *responseArray))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getMessageWithID:(NSString *)messageID
                  params:(NSDictionary *)params
                 success:(void (^)(NSDictionary *responseDict))successBlock
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the message with the specified id.
 
 @param messageID The id of the message you would like to update.
 @param destinationFolder The new folder for the message.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateMessageWithID:(NSString *)messageID
          destinationFolder:(NSString *)destinationFolder
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Deletes the message with the specified id.
 
 @param messageID The id of the message you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteMessageWithID:(NSString *)messageID
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the message with the specified id.
 
 @param messageID The id of the message you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getBodyForMessageWithID:(NSString *)messageID
                         params:(NSDictionary *)params
                        success:(void (^)(NSDictionary *responseDict))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the flags for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFlagsForMessageWithID:(NSString *)messageID
                          params:(NSDictionary *)params
                         success:(void (^)(NSDictionary *responseDict))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the flags for a particular message.
 
 @param messageID The id of the message for which you would like to update the flags.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateFlagsForMessageWithID:(NSString *)messageID
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the folders for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFoldersForMessageWithID:(NSString *)messageID
                            params:(NSDictionary *)params
                           success:(void (^)(NSArray *responseArray))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the folders for a particular message.
 
 @param messageID The id of the message for which you would like to update the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateFoldersForMessageWithID:(NSString *)messageID
                               params:(NSDictionary *)params
                              success:(void (^)(NSDictionary *responseDict))successBlock
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Sets the folders for a particular message.
 
 @param messageID The id of the message for which you would like to set the folders.
 @param folders A dictionary of the new folders for a particular message. See API documentation for details of format.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)setFoldersForMessageWithID:(NSString *)messageID
                           folders:(NSDictionary *)folders
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the headers for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the headers.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getHeadersForMessageWithID:(NSString *)messageID
                            params:(NSDictionary *)params
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the source for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the source.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getSourceForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params
                          success:(void (^)(NSDictionary *responseDict))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the thread for a particular message.
 
 @param messageID The id of the message for which you would like to retrieve the thread.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getThreadForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params
                          success:(void (^)(NSDictionary *responseDict))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Sources and Related Resources
///---------------------------------------------

/**
 Retrieves the account's sources.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getSourcesWithParams:(NSDictionary *)params
                     success:(void (^)(NSArray *responseArray))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

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
- (void)createSourceWithEmail:(NSString *)email
                       server:(NSString *)server
                     username:(NSString *)username
                       useSSL:(BOOL)useSSL
                         port:(NSInteger)port
                         type:(NSString *)type
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the source with the specified label.
 
 @param sourceLabel The label of the source you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getSourceWithLabel:(NSString *)sourceLabel
                    params:(NSDictionary *)params
                   success:(void (^)(NSDictionary *responseDict))successBlock
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the source with the specified label.
 
 @param sourceLabel The label of the source you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateSourceWithLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Deletes the source with the specified label.
 
 @param sourceLabel The label of the source you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteSourceWithLabel:(NSString *)sourceLabel
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the folders for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the folders.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                              params:(NSDictionary *)params
                             success:(void (^)(NSArray *responseArray))successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to retrieve.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getFolderWithPath:(NSString *)folderPath
              sourceLabel:(NSString *)sourceLabel
                   params:(NSDictionary *)params
                  success:(void (^)(NSDictionary *responseDict))successBlock
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Deletes a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to delete.
 @param sourceLabel The label of the source to which the folder belongs.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                     success:(void (^)(NSDictionary *responseDict))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Creates a new folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to create.
 @param sourceLabel The label of the source where the folder should be created.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)createFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                      params:(NSDictionary *)params
                     success:(void (^)(NSDictionary *responseDict))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Expunges a folder belonging to a particular source.
 
 @param folderPath The path of the folder you would like to expunge.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)expungeFolderWithPath:(NSString *)folderPath
                  sourceLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieve the messages for a folder belonging to a particular source.
 
 @param folderPath The path of the folder for which you would like to retrieve messages.
 @param sourceLabel The label of the source to which the folder belongs.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getMessagesForFolderWithPath:(NSString *)folderPath
                         sourceLabel:(NSString *)sourceLabel
                              params:(NSDictionary *)params
                             success:(void (^)(NSArray *responseArray))successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the sync status for a particular source.
 
 @param sourceLabel The label of the source for which you would like to retrieve the sync status.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel
                                 params:(NSDictionary *)params
                                success:(void (^)(NSDictionary *responseDict))successBlock
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Force a sync for a particular source.
 
 @param sourceLabel The label of the source for which you would like to force a sync.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)forceSyncForSourceWithLabel:(NSString *)sourceLabel
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Sources and Related Resources
///---------------------------------------------

/**
 Retrieves the account's threads.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getThreadsWithParams:(NSDictionary *)params
                     success:(void (^)(NSArray *responseArray))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the thread with the specified id.
 
 @param threadID The id of the thread you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getThreadWithID:(NSString *)threadID
                 params:(NSDictionary *)params
                success:(void (^)(NSDictionary *responseDict))successBlock
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

///---------------------------------------------
/// @name Working With Webhooks and Related Resources
///---------------------------------------------

/**
 Retrieves the account's webhooks.
 
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: an array representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */

- (void)getWebhooksWithParams:(NSDictionary *)params
                      success:(void (^)(NSArray *responseArray))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Creates a new webhook.
 
 @param callbackURLString A string representing the callback URL for the new webhook.
 @param failureNotificationURLString A string representing the failure notification URL for the new webhook.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)createWebhookWithCallbackURLString:(NSString *)callbackURLString
              failureNotificationURLString:(NSString *)failureNotificationURLString
                                    params:(NSDictionary *)params
                                   success:(void (^)(NSDictionary *responseDict))successBlock
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Retrieves the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to retrieve.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getWebhookWithID:(NSString *)webhookID
                  params:(NSDictionary *)params
                 success:(void (^)(NSDictionary *responseDict))successBlock
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Updates the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to update.
 @param params A dictionary of parameters to be sent with the request. See the API documentation for possible parameters.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateWebhookWithID:(NSString *)webhookID
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

/**
 Deletes the webhook with the specified id.
 
 @param webhookID The id of the webhook you would like to delete.
 @param successBlock A block object to be executed when the request finishes successfully. This block has no return value and takes one argument: a dictionary representation of the API response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully, or that finishes successfully, but encounters an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteWebhookWithID:(NSString *)webhookID
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

@end
