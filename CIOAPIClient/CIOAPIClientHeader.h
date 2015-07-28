//
//  CIOAPIClientHeader.h
//
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import <Foundation/Foundation.h>
#import "CIORequest.h"
#import "CIOMessageRequests.h"
#import "CIOContactsRequest.h"
#import "CIOFilesRequest.h"
#import "CIOSourceRequests.h"
#import "CIOAPISession.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CIOEmailProviderType) {
    CIOEmailProviderTypeGenericIMAP = 0,
    CIOEmailProviderTypeGmail = 1,
    CIOEmailProviderTypeYahoo = 2,
    CIOEmailProviderTypeAOL = 3,
    CIOEmailProviderTypeHotmail = 4,
};

/**
 *  Key to use when looking up the `NSURLResponse` object of an `NSError`'s `userInfo` property.
 */
extern NSString *const CIOAPISessionURLResponseErrorKey;

/**
 `CIOAPIClient` provides an easy to use interface for constructing requests against the Context.IO API. The client
 handles authentication and all signing of requests.

 Each `CIOAPIClient` instance handles its own authentication credentials. If the credentials are saved to the keychain
 via `completeLoginWithResponse:saveCredentials:`, they are keyed off of the consumer key. `CIOAPIClient` will restore
 saved credentials if it is initalized with a previously-authenticated consumer key/secret.
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

@property (readonly, nonatomic) CIOAPISession *session;

@property (readonly, nonatomic) NSString *accountPath;

#pragma mark - Creating and Initializing API Clients


/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret, and additionally token and token
 secret. Use this method if you have already obtained a token and token secret on your own, and do not wish to use the
 built-in keychain storage.

 @param baseURLString Base URL to resolve requests against, e.g. "https://api.context.io/2.0/"
 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.
 @param token The auth token for the API client.
 @param tokenSecret The auth token secret for the API client.
 @param accountID The account ID the client should use to construct requests.

 @return The newly-initialized API client
 */
- (instancetype)initWithBaseURLString:(NSString *)baseURLString
                          consumerKey:(NSString *)consumerKey
                       consumerSecret:(NSString *)consumerSecret
                                token:(nullable NSString *)token
                          tokenSecret:(nullable NSString *)tokenSecret
                            accountID:(nullable NSString *)accountID NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Create a signed `NSURLRequest` for the context.io API using current OAuth credentials
 *
 *  @param path   path in the 2.0 API namespace, e.g. "accounts/<id>/contacts"
 *  @param method HTTP request method
 *  @param params parameters to send, will be sent as URL params for GET, otherwise sent as a `x-www-form-urlencoded`
 * body
 *
 */
- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method params:(nullable NSDictionary *)params;

- (CIODictionaryRequest *)dictionaryRequestForPath:(NSString *)path
                                            method:(NSString *)method
                                            params:(nullable NSDictionary *)params;

- (CIOArrayRequest *)arrayRequestForPath:(NSString *)path method:(NSString *)method params:(nullable NSDictionary *)params;

- (CIOArrayRequest *)arrayGetRequestWithAccountComponents:(NSArray *)pathComponents;

- (NSURLRequest *)requestForCIORequest:(CIORequest *)request;

#pragma mark - Authenticating the API Client

/**
 Begins the authentication process for a new account/email source by creating a connect token.

 @param providerType The type of email provider you would like to authenticate. Please see `CIOEmailProviderType`.
 @param callbackURLString The callback URL string that the API should redirect to after successful authentication of an
 email account. You will need to watch for this request in your UIWebView delegate's
 -webView:shouldStartLoadWithRequest:navigationType: method to intercept the connect token. See the example app for
 details.
 @param params The parameters for the request. This can be `nil` if no parameters are required.
 */
- (CIODictionaryRequest *)beginAuthForProviderType:(CIOEmailProviderType)providerType
                                 callbackURLString:(NSString *)callbackURLString
                                            params:(nullable NSDictionary *)params;

- (NSURL *)redirectURLFromResponse:(NSDictionary *)responseDict;

- (CIODictionaryRequest *)fetchAccountWithConnectToken:(NSString *)connectToken;

/**
 Uses the connect token received from the API to complete the authentication process and optionally save the credentials
 to the keychain.

 @param responseObject The full response object returned by the API after calling `fetchAccountWithConnectToken:` with a valid connect token.
 @param saveCredentials This determines if credentials are saved to the device's keychain.
 */
- (BOOL)completeLoginWithResponse:(NSDictionary *)responseObject saveCredentials:(BOOL)saveCredentials;

/**
 Clears the credentials stored in the keychain.
 */
- (void)clearCredentials;

#pragma mark - Working With Accounts

/**
 *   Retrieves the current account's details.
 *
 */
- (CIODictionaryRequest *)getAccount;

/**
 *  Modify the current account's info.
 *
 *  @param firstName new first name, optional
 *  @param lastName  new last name, optional
 *
 *  @return request to modify the account
 */
- (CIODictionaryRequest *)updateAccountWithFirstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName;


/**
 *  Deletes the current account.
 *
 *
 */
- (CIODictionaryRequest *)deleteAccount;

#pragma mark - Executing Requests

/**
 *  Execute a request against the Context.IO API which returns a dictionary of JSON data in its response.
 *
 *  @param request A request generated by any API call method returning a CIODictionaryRequest
 *  @param success Handler block that takes an `NSDictionary`
 *  @param failure Failure block
 */
- (void)executeDictionaryRequest:(CIODictionaryRequest *)request
                         success:(nullable void (^)(NSDictionary *responseDict))success
                         failure:(nullable void (^)(NSError *error))failure;

/**
 *  Execute a request against the Context.IO API which returns an Array of JSON data in its response.
 *
 *  @param request A request generated by any API call method returning a CIOArrayRequest
 *  @param success Handler block that takes an `NSArray`
 *  @param failure Failure block
 */
- (void)executeArrayRequest:(CIOArrayRequest *)request
                    success:(nullable void (^)(NSArray *responseArray))success
                    failure:(nullable void (^)(NSError *error))failure;

/**
 *  Execute a request against the Context.IO API which returns a String.
 *
 *  @param request A request generated by any API call method returning a CIOStringRequest
 *  @param success Handler block that takes a `String`
 *  @param failure Failure block
 */
- (void)executeStringRequest:(CIOStringRequest *)request
                     success:(nullable void (^)(NSString *responseString))success
                     failure:(nullable void (^)(NSError *error))failure;

/**
 *  Execute a request against the Context.IO API and save the body of the response to a file on disk. Typically used for
 * saving attachments or raw message content.
 *
 *  @param request       request to execute
 *  @param fileURL       `URL` on disk to save the destination file to. An error will be returned if a file already
 * exists at this path.
 *  @param successBlock  block to be called when the file download completes
 *  @param failureBlock  block to be called in the event of an error. No file will be written.
 *  @param progressBlock block to receive periodic progress updates during the file download
 */
- (void)downloadRequest:(CIORequest *)request
              toFileURL:(NSURL *)fileURL
                success:(nullable void (^)())successBlock
                failure:(nullable void (^)(NSError *error))failureBlock
               progress:(nullable CIOSessionDownloadProgressBlock)progressBlock;

@end


@interface CIODictionaryRequest (CIORequest)

/**
 *  Execute this request in the `CIOAPISession` which constructed it. It is an error to call
 *  this on a `CIODictionaryRequest` which was not created with a `CIOAPISession`.
 *
 *  @param success callback which takes an API response `NSDictionary`
 *  @param failure an error block, see the description of `CIOAPISession` for more details about the error returned
 */
- (void)executeWithSuccess:(nullable void (^)(NSDictionary *responseDict))success
                   failure:(nullable void (^)(NSError *error))failure;
@end


@interface CIOArrayRequest (CIORequest)

/**
 *  Execute this request in the `CIOAPISession` which constructed it. It is an error to call
 *  this on a `CIOArrayRequest` which was not created with a `CIOAPISession`.
 *
 *  @param success callback which takes an API response `NSArray`
 *  @param failure an error block, see the description of `CIOAPISession` for more details about the error returned
 */
- (void)executeWithSuccess:(nullable void (^)(NSArray *responseArray))success
                   failure:(nullable void (^)(NSError *error))failure;
@end


@interface CIOStringRequest (CIORequest)

/**
 *  Execute this request in the `CIOAPISession` which constructed it. It is an error to call
 *  this on a `CIOStringRequest` which was not created with a `CIOAPISession`.
 *
 *  @param success callback which takes an API response `NSString`
 *  @param failure an error block, see the description of `CIOAPISession` for more details about the error returned
 */
- (void)executeWithSuccess:(nullable void (^)(NSString *responseString))success
                   failure:(nullable void (^)(NSError *error))failure;
@end


NS_ASSUME_NONNULL_END
