//
//  CIOAPIClient.m
//  
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import "CIOAPIClient.h"

#import "AFNetworking.h"
#import "OAuth.h"
#import "SSKeychain.h"

static NSString * const kCIOAPIBaseURLString = @"https://api.context.io/2.0/";

// Keychain keys
static NSString * const kCIOKeyChainServicePrefix = @"Context-IO-";
static NSString * const kCIOAccountIDKeyChainKey = @"kCIOAccountID";
static NSString * const kCIOTokenKeyChainKey = @"kCIOToken";
static NSString * const kCIOTokenSecretKeyChainKey = @"kCIOTokenSecret";

@interface CIOAPIClient () {
    
    NSString *_OAuthConsumerKey;
    NSString *_OAuthToken;
    NSString *_OAuthTokenSecret;
    NSString *_accountID;
    
    NSString *_tmpOAuthToken;
    NSString *_tmpOAuthTokenSecret;
}

@property (nonatomic, strong) OAuth *OAuthGenerator;
@property (nonatomic, readonly) NSString *accountPath;

- (void)loadCredentials;
- (void)saveCredentials;

- (NSMutableURLRequest *)signURLRequest:(NSMutableURLRequest *)mutableURLRequest parameters:(NSDictionary *)params token:(NSString *)token tokenSecret:(NSString *)tokenSecret;
- (NSMutableURLRequest *)signURLRequest:(NSMutableURLRequest *)mutableURLRequest parameters:(NSDictionary *)params useToken:(BOOL)useToken;
@end


@implementation CIOAPIClient

@synthesize HTTPClient = _HTTPClient;
@synthesize OAuthGenerator = _OAuthGenerator;
@synthesize timeoutInterval = _timeoutInterval;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _OAuthConsumerKey = consumerKey;
    
    _HTTPClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kCIOAPIBaseURLString]];
    [self.HTTPClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.timeoutInterval = 60;
    
    self.OAuthGenerator = [[OAuth alloc] initWithConsumerKey:consumerKey andConsumerSecret:consumerSecret];
    
    _isAuthorized = NO;
    
    [self loadCredentials];
    
    return self;
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                    token:(NSString *)token
              tokenSecret:(NSString *)tokenSecret
                accountID:(NSString *)accountID {
    
    self = [self initWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    if (!self) {
        return nil;
    }
    
    if (_accountID && _OAuthToken && _OAuthTokenSecret) {
        
        _OAuthToken = token;
        _OAuthTokenSecret = tokenSecret;
        _accountID = accountID;
        
        _isAuthorized = YES;
    }
    
    return self;
}

#pragma mark -

- (void)beginAuthForProviderType:(CIOEmailProviderType)providerType
               callbackURLString:(NSString *)callbackURLString
                          params:(NSDictionary *)params
                         success:(void (^)(NSURL *authRedirectURL))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *connectTokenPath = nil;
    if (_isAuthorized) {
        connectTokenPath = [[self accountPath] stringByAppendingPathComponent:@"connect_tokens"];
    } else {
        connectTokenPath = @"connect_tokens";
    }
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    switch (providerType) {
        case CIOEmailProviderTypeGenericIMAP:
            break;
        case CIOEmailProviderTypeGmail:
            [mutableParams setValue:@"@gmail.com" forKey:@"email"];
            break;
        case CIOEmailProviderTypeYahoo:
            [mutableParams setValue:@"@yahoo.com" forKey:@"email"];
            break;
        case CIOEmailProviderTypeAOL:
            [mutableParams setValue:@"@aol.com" forKey:@"email"];
            break;
        case CIOEmailProviderTypeHotmail:
            [mutableParams setValue:@"@hotmail.com" forKey:@"email"];
            break;
        default:
            break;
    }
    
    [mutableParams setValue:callbackURLString forKey:@"callback_url"];
    
    [self postPath:connectTokenPath
            params:[NSDictionary dictionaryWithDictionary:mutableParams]
           success:^(NSDictionary *responseDict) {

               if (_isAuthorized == NO) {
                   _tmpOAuthToken = [responseDict valueForKey:@"access_token"];
                   _tmpOAuthTokenSecret = [responseDict valueForKey:@"access_token_secret"];
               }
               
               if (successBlock != nil) {
                   successBlock([NSURL URLWithString:[responseDict valueForKey:@"browser_redirect_url"]]);
               }
           } failure:failureBlock];
}

- (void)finishLoginWithConnectToken:(NSString *)connectToken
                    saveCredentials:(BOOL)saveCredentials
                            success:(void (^)(id responseObject))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    // Not needed if adding a source to an existing account
    if (_isAuthorized) {
        return;
    }
    
    // This method is a bit of a one off due to the use of the temporary token/secret
    NSString *connectTokenPath = [@"connect_tokens" stringByAppendingPathComponent:connectToken];
    
    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"GET" path:connectTokenPath parameters:nil];
    NSURLRequest *signedURLRequest = [self signURLRequest:mutableURLRequest parameters:nil token:_tmpOAuthToken tokenSecret:_tmpOAuthTokenSecret];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:signedURLRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *OAuthToken = [responseObject valueForKeyPath:@"account.access_token"];
        NSString *OAuthTokenSecret = [responseObject valueForKeyPath:@"account.access_token_secret"];
        NSString *accountID = [responseObject valueForKeyPath:@"account.id"];
        
        if ((OAuthToken && ![OAuthToken isEqual:[NSNull null]]) &&
            (OAuthTokenSecret && ![OAuthTokenSecret isEqual:[NSNull null]]) &&
            (accountID && ![accountID isEqual:[NSNull null]])) {
            
            _OAuthToken = OAuthToken;
            _OAuthTokenSecret = OAuthTokenSecret;
            _accountID = accountID;
            
            if (saveCredentials) {
                [self saveCredentials];
            }
            
            if (successBlock != nil) {
                successBlock(responseObject);
            }
        } else {
            
            if (failureBlock != nil) {
                failureBlock(operation, nil);
            }
        }
    } failure:failureBlock];
    [operation start];
}

- (void)loadCredentials {
    
    NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kCIOKeyChainServicePrefix, _OAuthConsumerKey];
    
    NSString *accountID = [SSKeychain passwordForService:serviceName account:kCIOAccountIDKeyChainKey];
    NSString *OAuthToken = [SSKeychain passwordForService:serviceName account:kCIOTokenKeyChainKey];
    NSString *OAuthTokenSecret = [SSKeychain passwordForService:serviceName account:kCIOTokenSecretKeyChainKey];
    
    if (accountID && OAuthToken && OAuthTokenSecret) {
        
        _accountID = accountID;
        _OAuthToken = OAuthToken;
        _OAuthTokenSecret = OAuthTokenSecret;

        _isAuthorized = YES;
    }    
}

- (void)saveCredentials {
    
    if (_accountID && _OAuthToken && _OAuthTokenSecret) {
        
        NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kCIOKeyChainServicePrefix, _OAuthConsumerKey];
        BOOL accountIDSaved = [SSKeychain setPassword:_accountID
                     forService:serviceName
                        account:kCIOAccountIDKeyChainKey];
        BOOL tokenSaved = [SSKeychain setPassword:_OAuthToken
                     forService:serviceName
                        account:kCIOTokenKeyChainKey];
        BOOL secretSaved = [SSKeychain setPassword:_OAuthTokenSecret
                     forService:serviceName
                        account:kCIOTokenSecretKeyChainKey];
        
        if (accountIDSaved && tokenSaved && secretSaved) {
            _isAuthorized = YES;
        }
    }
}

- (void)clearCredentials {
    
    _isAuthorized = NO;
    
    _accountID = nil;
    _OAuthToken = nil;
    _OAuthTokenSecret = nil;
    
    self.OAuthGenerator.oauth_token = nil;
    self.OAuthGenerator.oauth_token_secret = nil;
    self.OAuthGenerator.oauth_token_authorized = NO;
    
    NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kCIOKeyChainServicePrefix, _OAuthConsumerKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOAccountIDKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenSecretKeyChainKey];
}

#pragma mark -

- (NSMutableURLRequest *)signURLRequest:(NSMutableURLRequest *)mutableURLRequest parameters:(NSDictionary *)params token:(NSString *)token tokenSecret:(NSString *)tokenSecret {
    
    NSMutableURLRequest *URLRequestToSign = [mutableURLRequest copy];
    
    
    if ((token != nil) && (tokenSecret != nil)) {
        
        self.OAuthGenerator.oauth_token = token;
        self.OAuthGenerator.oauth_token_secret = tokenSecret;
        self.OAuthGenerator.oauth_token_authorized = YES;
    }
    
    NSString *URLString = [mutableURLRequest.URL absoluteString];
    // Strip query string if needed
    if ([URLRequestToSign.URL query] != nil) {
        
        NSString *queryString = [@"?" stringByAppendingString:[URLRequestToSign.URL query]];
        URLString = [[URLRequestToSign.URL absoluteString] stringByReplacingOccurrencesOfString:queryString withString:@""];
    }
    
    NSString *authHeader = [self.OAuthGenerator oAuthHeaderForMethod:URLRequestToSign.HTTPMethod andUrl:URLString andParams:params];
    [URLRequestToSign addValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    return URLRequestToSign;
}

- (NSMutableURLRequest *)signURLRequest:(NSMutableURLRequest *)mutableURLRequest parameters:(NSDictionary *)params useToken:(BOOL)useToken {
    
    if (useToken) {
        return [self signURLRequest:mutableURLRequest parameters:params token:_OAuthToken tokenSecret:_OAuthTokenSecret];
    } else {        
        return [self signURLRequest:mutableURLRequest parameters:params token:nil tokenSecret:nil];
    }
}

- (NSString *)accountPath {
    return [@"accounts" stringByAppendingPathComponent:_accountID];
}

#pragma mark -

- (void)getPath:(NSString *)path
         params:(NSDictionary *)params
        success:(void (^)(id responseObject))successBlock
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"GET" path:path parameters:params];
    
    mutableURLRequest = [self signURLRequest:mutableURLRequest parameters:params useToken:_isAuthorized];
    
    mutableURLRequest.timeoutInterval = self.timeoutInterval;
    
    AFHTTPRequestOperation *requestOperation = [self.HTTPClient HTTPRequestOperationWithRequest:mutableURLRequest
                                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                        
                                                                                            if (successBlock) {
                                                                                                successBlock(responseObject);
                                                                                            }
                                                                                        } failure:failureBlock];
    [self.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

- (void)postPath:(NSString *)path
          params:(NSDictionary *)params
         success:(void (^)(id responseObject))successBlock
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {

    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"POST" path:path parameters:params];
    
    mutableURLRequest = [self signURLRequest:mutableURLRequest parameters:params useToken:_isAuthorized];
    
    mutableURLRequest.timeoutInterval = self.timeoutInterval;
    
    AFHTTPRequestOperation *requestOperation = [self.HTTPClient HTTPRequestOperationWithRequest:mutableURLRequest
                                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                            
                                                                                            if (successBlock) {
                                                                                                successBlock(responseObject);
                                                                                            }
                                                                                        } failure:failureBlock];
    [self.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

- (void)putPath:(NSString *)path
         params:(NSDictionary *)params
        success:(void (^)(id responseObject))successBlock
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {

    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"PUT" path:path parameters:params];

    mutableURLRequest = [self signURLRequest:mutableURLRequest parameters:params useToken:_isAuthorized];
    
    mutableURLRequest.timeoutInterval = self.timeoutInterval;
    
    AFHTTPRequestOperation *requestOperation = [self.HTTPClient HTTPRequestOperationWithRequest:mutableURLRequest
                                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                            
                                                                                            if (successBlock) {
                                                                                                successBlock(responseObject);
                                                                                            }
                                                                                        } failure:failureBlock];

    [self.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

- (void)deletePath:(NSString *)path
           success:(void (^)(id responseObject))successBlock
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {

    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"DELETE" path:path parameters:nil];
    
    mutableURLRequest = [self signURLRequest:mutableURLRequest parameters:nil useToken:_isAuthorized];
    
    mutableURLRequest.timeoutInterval = self.timeoutInterval;
    
    AFHTTPRequestOperation *requestOperation = [self.HTTPClient HTTPRequestOperationWithRequest:mutableURLRequest
                                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                            
                                                                                            if (successBlock) {
                                                                                                successBlock(responseObject);
                                                                                            }
                                                                                        } failure:failureBlock];
    [self.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

#pragma mark -

- (void)getAccountWithParams:(NSDictionary *)params
                     success:(void (^)(NSDictionary *responseDict))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:self.accountPath
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateAccountWithParams:(NSDictionary *)params
                        success:(void (^)(NSDictionary *responseDict))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self postPath:self.accountPath
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)deleteAccountWithSuccess:(void (^)(NSDictionary *responseDict))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self deletePath:self.accountPath
             success:successBlock
             failure:failureBlock];
}

- (void)getContactsWithParams:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"contacts"]
           params:params
          success:successBlock
           failure:failureBlock];
}

- (void)getContactWithEmail:(NSString *)email
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    
    [self getPath:[contactsURLPath stringByAppendingPathComponent:email]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getFilesForContactWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSArray *responseArray))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    
    [self getPath:[contactURLPath stringByAppendingPathComponent:@"files"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getMessagesForContactWithEmail:(NSString *)email
                                params:(NSDictionary *)params
                               success:(void (^)(NSArray *responseArray))successBlock
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    
    [self getPath:[contactURLPath stringByAppendingPathComponent:@"messages"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getThreadsForContactWithEmail:(NSString *)email
                               params:(NSDictionary *)params
                              success:(void (^)(NSArray *responseArray))successBlock
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    
    [self getPath:[contactURLPath stringByAppendingPathComponent:@"threads"]
           params:params
          success:successBlock
          failure:failureBlock];
}

#pragma mark - 

- (void)getEmailAddressesWithParams:(NSDictionary *)params
                            success:(void (^)(NSArray *responseArray))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"email_addresses"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)createEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:email forKey:@"email_address"];
    
    [self postPath:[self.accountPath stringByAppendingPathComponent:@"email_addresses"]
            params:[NSDictionary dictionaryWithDictionary:mutableParams]
           success:successBlock
           failure:failureBlock];
}

- (void)getEmailAddressWithEmail:(NSString *)email
                          params:(NSDictionary *)params
                         success:(void (^)(NSDictionary *responseDict))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    [self getPath:[emailAddressesURLPath stringByAppendingPathComponent:email]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    [self postPath:[emailAddressesURLPath stringByAppendingPathComponent:email]
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)deleteEmailAddressWithEmail:(NSString *)email
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    [self deletePath:[emailAddressesURLPath stringByAppendingPathComponent:email]
             success:successBlock
             failure:failureBlock];
}

#pragma mark -

- (void)getFilesWithParams:(NSDictionary *)params
                   success:(void (^)(NSArray *responseArray))successBlock
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"files"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getFileWithID:(NSString *)fileID
               params:(NSDictionary *)params
              success:(void (^)(NSDictionary *responseDict))successBlock
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    
    [self getPath:[filesURLPath stringByAppendingPathComponent:fileID]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getChangesForFileWithID:(NSString *)fileID
                         params:(NSDictionary *)params
                        success:(void (^)(NSArray *responseArray))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    [self getPath:[fileURLPath stringByAppendingPathComponent:@"changes"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getContentsURLForFileWithID:(NSString *)fileID
                            params:(NSDictionary *)params
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:[NSNumber numberWithBool:YES] forKey:@"as_link"];
    
    [self getPath:[fileURLPath stringByAppendingPathComponent:@"content"]
           params:[NSDictionary dictionaryWithDictionary:mutableParams]
          success:successBlock
          failure:failureBlock];
}

- (void)downloadContentsOfFileWithID:(NSString *)fileID
                          saveToPath:(NSString *)saveToPath
                              params:(NSDictionary *)params
                             success:(void (^)())successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
                            progress:(void (^) (NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead ))progressBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"GET"
                                                                           path:[fileURLPath stringByAppendingPathComponent:@"content"]
                                                                     parameters:params];
    
    NSURLRequest *signedURLRequest = [self signURLRequest:mutableURLRequest parameters:params useToken:YES];
    
    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:signedURLRequest];
    downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:saveToPath append:NO];
    [downloadOperation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    [downloadOperation setDownloadProgressBlock:progressBlock];
    [downloadOperation start];
}

- (void)getRelatedForFileWithID:(NSString *)fileID
                         params:(NSDictionary *)params
                        success:(void (^)(NSArray *responseArray))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    [self getPath:[fileURLPath stringByAppendingPathComponent:@"related"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getRevisionsForFileWithID:(NSString *)fileID
                           params:(NSDictionary *)params
                          success:(void (^)(NSArray *responseArray))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    [self getPath:[fileURLPath stringByAppendingPathComponent:@"revisions"]
           params:params
          success:successBlock
          failure:failureBlock];
}

#pragma mark -

- (void)getMessagesWithParams:(NSDictionary *)params
                      success:(void (^)(NSArray *responseArray))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"messages"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getMessageWithID:(NSString *)messageID
                  params:(NSDictionary *)params
                 success:(void (^)(NSDictionary *responseDict))successBlock
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    
    [self getPath:[messagesURLPath stringByAppendingPathComponent:messageID]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateMessageWithID:(NSString *)messageID
          destinationFolder:(NSString *)destinationFolder
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:destinationFolder forKey:@"dst_folder"];
    
    [self postPath:[messagesURLPath stringByAppendingPathComponent:messageID]
            params:[NSDictionary dictionaryWithDictionary:mutableParams]
           success:successBlock
           failure:failureBlock];
}

- (void)deleteMessageWithID:(NSString *)messageID
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];

    [self deletePath:[messagesURLPath stringByAppendingPathComponent:messageID]
             success:successBlock
             failure:failureBlock];
}

- (void)getBodyForMessageWithID:(NSString *)messageID
                         params:(NSDictionary *)params
                        success:(void (^)(NSDictionary *responseDict))successBlock
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"body"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getFlagsForMessageWithID:(NSString *)messageID
                          params:(NSDictionary *)params
                         success:(void (^)(NSDictionary *responseDict))successBlock
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"flags"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateFlagsForMessageWithID:(NSString *)messageID
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self postPath:[messageURLPath stringByAppendingPathComponent:@"flags"]
            params:params
           success:successBlock
          failure:failureBlock];
}

- (void)getFoldersForMessageWithID:(NSString *)messageID
                            params:(NSDictionary *)params
                           success:(void (^)(NSArray *responseArray))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"folders"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateFoldersForMessageWithID:(NSString *)messageID
                               params:(NSDictionary *)params
                              success:(void (^)(NSDictionary *responseDict))successBlock
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self postPath:[messageURLPath stringByAppendingPathComponent:@"folders"]
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)setFoldersForMessageWithID:(NSString *)messageID
                           folders:(NSDictionary *)folders
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self putPath:[messageURLPath stringByAppendingPathComponent:@"folders"]
           params:folders
          success:successBlock
          failure:failureBlock];
}

- (void)getHeadersForMessageWithID:(NSString *)messageID
                            params:(NSDictionary *)params
                           success:(void (^)(NSDictionary *responseDict))successBlock
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"headers"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getSourceForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params
                          success:(void (^)(NSDictionary *responseDict))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"source"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getThreadForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params
                          success:(void (^)(NSDictionary *responseDict))successBlock
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    [self getPath:[messageURLPath stringByAppendingPathComponent:@"thread"]
           params:params
          success:successBlock
          failure:failureBlock];
}

#pragma mark -

- (void)getSourcesWithParams:(NSDictionary *)params
                     success:(void (^)(NSArray *responseArray))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"sources"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)createSourceWithEmail:(NSString *)email
                       server:(NSString *)server
                     username:(NSString *)username
                       useSSL:(BOOL)useSSL
                         port:(NSInteger)port
                         type:(NSString *)type
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:email forKey:@"email"];
    [mutableParams setValue:server forKey:@"server"];
    [mutableParams setValue:username forKey:@"username"];
    [mutableParams setValue:[NSNumber numberWithBool:useSSL] forKey:@"use_ssl"];
    [mutableParams setValue:[NSNumber numberWithInteger:port] forKey:@"port"];
    [mutableParams setValue:type forKey:@"type"];
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"sources"]
           params:[NSDictionary dictionaryWithDictionary:mutableParams]
          success:successBlock
          failure:failureBlock];
}

- (void)getSourceWithLabel:(NSString *)sourceLabel
                    params:(NSDictionary *)params
                   success:(void (^)(NSDictionary *responseDict))successBlock
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    [self getPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateSourceWithLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    [self postPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel]
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)deleteSourceWithLabel:(NSString *)sourceLabel
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    [self deletePath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel]
             success:successBlock
             failure:failureBlock];
}

- (void)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                              params:(NSDictionary *)params
                             success:(void (^)(NSArray *responseArray))successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    [self getPath:[sourceURLPath stringByAppendingPathComponent:@"folders"]
              params:params
             success:successBlock
             failure:failureBlock];
}

- (void)getFolderWithPath:(NSString *)folderPath
              sourceLabel:(NSString *)sourceLabel
                   params:(NSDictionary *)params
                  success:(void (^)(NSDictionary *responseDict))successBlock
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    
    [self getPath:[foldersURLPath stringByAppendingPathComponent:folderPath]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)deleteFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                     success:(void (^)(NSDictionary *responseDict))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    
    [self deletePath:[foldersURLPath stringByAppendingPathComponent:folderPath]
             success:successBlock
             failure:failureBlock];
}

- (void)createFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                      params:(NSDictionary *)params
                     success:(void (^)(NSDictionary *responseDict))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    
    [self putPath:[foldersURLPath stringByAppendingPathComponent:folderPath]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)expungeFolderWithPath:(NSString *)folderPath
                  sourceLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params
                      success:(void (^)(NSDictionary *responseDict))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    NSString *folderURLPath = [foldersURLPath stringByAppendingPathComponent:folderPath];
    
    [self postPath:[folderURLPath stringByAppendingPathComponent:@"expunge"]
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)getMessagesForFolderWithPath:(NSString *)folderPath
                         sourceLabel:(NSString *)sourceLabel
                              params:(NSDictionary *)params
                             success:(void (^)(NSArray *responseArray))successBlock
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    NSString *folderURLPath = [foldersURLPath stringByAppendingPathComponent:folderPath];
    
    [self getPath:[folderURLPath stringByAppendingPathComponent:@"messages"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel
                                 params:(NSDictionary *)params
                                success:(void (^)(NSDictionary *responseDict))successBlock
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    [self getPath:[sourceURLPath stringByAppendingPathComponent:@"sync"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)forceSyncForSourceWithLabel:(NSString *)sourceLabel
                             params:(NSDictionary *)params
                            success:(void (^)(NSDictionary *responseDict))successBlock
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    [self postPath:[sourceURLPath stringByAppendingPathComponent:@"sync"]
            params:params
           success:successBlock
           failure:failureBlock];
}

#pragma mark -

- (void)getThreadsWithParams:(NSDictionary *)params
                     success:(void (^)(NSArray *responseArray))successBlock
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"threads"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)getThreadWithID:(NSString *)threadID
                 params:(NSDictionary *)params
                success:(void (^)(NSDictionary *responseDict))successBlock
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *threadsURLPath = [self.accountPath stringByAppendingPathComponent:@"threads"];
    
    [self getPath:[threadsURLPath stringByAppendingPathComponent:threadID]
           params:params
          success:successBlock
          failure:failureBlock];
}

#pragma mark -

- (void)getWebhooksWithParams:(NSDictionary *)params
                      success:(void (^)(NSArray *responseArray))successBlock
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    [self getPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)createWebhookWithCallbackURLString:(NSString *)callbackURLString
              failureNotificationURLString:(NSString *)failureNotificationURLString
                                    params:(NSDictionary *)params
                                   success:(void (^)(NSDictionary *responseDict))successBlock
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params ];
    [mutableParams setValue:callbackURLString forKey:@"callback_url"];
    [mutableParams setValue:failureNotificationURLString forKey:@"failure_notif_url"];
    
    [self postPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"]
            params:[NSDictionary dictionaryWithDictionary:mutableParams]
           success:successBlock
           failure:failureBlock];
}

- (void)getWebhookWithID:(NSString *)webhookID
                  params:(NSDictionary *)params
                 success:(void (^)(NSDictionary *responseDict))successBlock
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    [self getPath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
           params:params
          success:successBlock
          failure:failureBlock];
}

- (void)updateWebhookWithID:(NSString *)webhookID
                     params:(NSDictionary *)params
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    [self postPath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
            params:params
           success:successBlock
           failure:failureBlock];
}

- (void)deleteWebhookWithID:(NSString *)webhookID
                    success:(void (^)(NSDictionary *responseDict))successBlock
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    [self deletePath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
             success:successBlock
             failure:failureBlock];
}

@end
