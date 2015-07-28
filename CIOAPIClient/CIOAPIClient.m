//
//  CIOAPIClient.m
//
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import "CIOAPIClientHeader.h"

#import <SSKeychain/SSKeychain.h>
#import <TDOAuth/TDOAuth.h>
#import "CIOAPISession.h"

// Keychain keys
static NSString *const kCIOKeyChainServicePrefix = @"Context-IO-";
static NSString *const kCIOAccountIDKeyChainKey = @"kCIOAccountID";
static NSString *const kCIOTokenKeyChainKey = @"kCIOToken";
static NSString *const kCIOTokenSecretKeyChainKey = @"kCIOTokenSecret";

@interface CIOAPIClient () {

    NSString *_OAuthConsumerKey;
    NSString *_OAuthConsumerSecret;
    NSString *_OAuthToken;
    NSString *_OAuthTokenSecret;
    NSString *_accountID;

    NSString *_tmpOAuthToken;
    NSString *_tmpOAuthTokenSecret;
}

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSString *basePath;
@property (nonatomic) CIOAPISession *session;

- (void)loadCredentials;
- (void)saveCredentials;

@end

@implementation CIOAPIClient

- (instancetype)init {
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ must be constructed with a consumer key and secret.", NSStringFromClass(self.class)];
    return nil;
}

- (instancetype)initWithBaseURLString:(NSString *)baseURLString
                          consumerKey:(NSString *)consumerKey
                       consumerSecret:(NSString *)consumerSecret
                                token:(nullable NSString *)token
                          tokenSecret:(nullable NSString *)tokenSecret
                            accountID:(nullable NSString *)accountID {

    self = [super init];
    if (!self) {
        return nil;
    }
    _OAuthConsumerKey = consumerKey;
    _OAuthConsumerSecret = consumerSecret;

    self.baseURL = [NSURL URLWithString:baseURLString];
    self.basePath = [self.baseURL path];

    self.timeoutInterval = 60;

    _isAuthorized = NO;

    [self loadCredentials];

    if (accountID && token && tokenSecret) {

        _OAuthToken = token;
        _OAuthTokenSecret = tokenSecret;
        _accountID = accountID;

        _isAuthorized = YES;
    }

    return self;
}

#pragma mark -

- (CIODictionaryRequest *)beginAuthForProviderType:(CIOEmailProviderType)providerType
                                 callbackURLString:(NSString *)callbackURLString
                                            params:(NSDictionary *)params {

    NSString *connectTokenPath = nil;
    if (_isAuthorized) {
        connectTokenPath = [[self accountPath] stringByAppendingPathComponent:@"connect_tokens"];
    } else {
        connectTokenPath = @"connect_tokens";
    }

    NSMutableDictionary *mutableParams = [params ?: @{} mutableCopy];

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

    mutableParams[@"callback_url"] = callbackURLString;
    return [self dictionaryRequestForPath:connectTokenPath method:@"POST" params:mutableParams];
}

- (NSURL *)redirectURLFromResponse:(NSDictionary *)responseDict {
    if (_isAuthorized == NO) {
        _tmpOAuthToken = responseDict[@"access_token"];
        _tmpOAuthTokenSecret = responseDict[@"access_token_secret"];
    }

    return [NSURL URLWithString:responseDict[@"browser_redirect_url"]];
}

- (CIODictionaryRequest *)fetchAccountWithConnectToken:(NSString *)connectToken {
    return [CIOConnectTokenRequest requestWithToken:connectToken client:self];
}

- (BOOL)completeLoginWithResponse:(NSDictionary *)responseObject saveCredentials:(BOOL)saveCredentials {
    NSString *OAuthToken = [responseObject valueForKeyPath:@"account.access_token"];
    NSString *OAuthTokenSecret = [responseObject valueForKeyPath:@"account.access_token_secret"];
    NSString *accountID = [responseObject valueForKeyPath:@"account.id"];

    if ((OAuthToken && ![OAuthToken isEqual:[NSNull null]]) &&
        (OAuthTokenSecret && ![OAuthTokenSecret isEqual:[NSNull null]]) &&
        (accountID && ![accountID isEqual:[NSNull null]])) {

        _OAuthToken = OAuthToken;
        _OAuthTokenSecret = OAuthTokenSecret;
        _accountID = accountID;

        _isAuthorized = YES;
        if (saveCredentials) {
            [self saveCredentials];
        }
        return YES;
    } else {
        return NO;
    }
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
        BOOL accountIDSaved =
            [SSKeychain setPassword:_accountID forService:serviceName account:kCIOAccountIDKeyChainKey];
        BOOL tokenSaved = [SSKeychain setPassword:_OAuthToken forService:serviceName account:kCIOTokenKeyChainKey];
        BOOL secretSaved =
            [SSKeychain setPassword:_OAuthTokenSecret forService:serviceName account:kCIOTokenSecretKeyChainKey];

        if (accountIDSaved && tokenSaved && secretSaved) {
            _isAuthorized = YES;
        }
    }
}

- (void)clearCredentials {

    _isAuthorized = NO;
    _accountID = nil;

    NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kCIOKeyChainServicePrefix, _OAuthConsumerKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOAccountIDKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenSecretKeyChainKey];
}

#pragma mark -

- (NSURLRequest *)signedRequestForPath:(NSString *)path
                                method:(NSString *)method
                            parameters:(NSDictionary *)params
                                 token:(NSString *)token
                           tokenSecret:(NSString *)tokenSecret
                           contentType:(TDOAuthContentType)contentType {

    NSMutableURLRequest *signedRequest = [[TDOAuth URLRequestForPath:[self.basePath stringByAppendingPathComponent:path]
                                                          parameters:params
                                                                host:self.baseURL.host
                                                         consumerKey:_OAuthConsumerKey
                                                      consumerSecret:_OAuthConsumerSecret
                                                         accessToken:token
                                                         tokenSecret:tokenSecret
                                                              scheme:@"https"
                                                       requestMethod:method
                                                        dataEncoding:contentType
                                                        headerValues:@{
                                                            @"Accept": @"application/json"
                                                        }
                                                     signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    signedRequest.timeoutInterval = self.timeoutInterval;
    return signedRequest;
}

- (NSString *)accountPath {
    return [@"accounts" stringByAppendingPathComponent:self.accountID];
}

#pragma mark -

- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {
    NSString *token = self.isAuthorized ? _OAuthToken : nil;
    NSString *tokenSecret = self.isAuthorized ? _OAuthTokenSecret : nil;
    return [self signedRequestForPath:path method:method parameters:params token:token tokenSecret:tokenSecret contentType:TDOAuthContentTypeUrlEncodedForm];
}

- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method body:(id)body {
    // TDOAuth does not support JSON encoded body for GETs
    NSParameterAssert(![method isEqualToString:@"GET"]);
    NSString *token = self.isAuthorized ? _OAuthToken : nil;
    NSString *tokenSecret = self.isAuthorized ? _OAuthTokenSecret : nil;
    return [self signedRequestForPath:path method:method parameters:body token:token tokenSecret:tokenSecret contentType:TDOAuthContentTypeJsonObject];
}

- (NSURLRequest *)requestForCIORequest:(CIORequest *)request {
    if ([request isKindOfClass:[CIOConnectTokenRequest class]]) {
        // This is a special case due to the use of the temporary token/secret during auth
        return [self signedRequestForPath:request.path method:request.method parameters:request.parameters token:_tmpOAuthToken tokenSecret:_tmpOAuthTokenSecret contentType:TDOAuthContentTypeUrlEncodedForm];
    } else if (request.requestBody != nil) {
        return [self requestForPath:request.path method:request.method body:request.requestBody];
    } else {
        return [self requestForPath:request.path method:request.method params:request.parameters];
    }
}

- (CIODictionaryRequest *)dictionaryRequestForPath:(NSString *)path
                                            method:(NSString *)method
                                            params:(NSDictionary *)params {
    return [CIODictionaryRequest requestWithPath:path method:method parameters:params client:self];
}

- (CIOArrayRequest *)arrayRequestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {
    return [CIOArrayRequest requestWithPath:path method:method parameters:params client:self];
}

- (CIOArrayRequest *)arrayGetRequestWithAccountComponents:(NSArray *)pathComponents {
    NSArray *finalPath = [@[self.accountPath] arrayByAddingObjectsFromArray:pathComponents];
    return [self arrayRequestForPath:[NSString pathWithComponents:finalPath]
                              method:@"GET"
                              params:nil];
}


#pragma mark - Account

- (CIODictionaryRequest *)getAccount {
    return [self dictionaryRequestForPath:self.accountPath method:@"GET" params:nil];
}

- (CIODictionaryRequest *)updateAccountWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (firstName) {
        params[@"first_name"] = firstName;
    }
    if (lastName ) {
        params[@"last_name"] = lastName;
    }
    return [self dictionaryRequestForPath:self.accountPath method:@"PUT" params:params];
}

- (CIODictionaryRequest *)deleteAccount {
    return [self dictionaryRequestForPath:self.accountPath method:@"DELETE" params:nil];
}

#pragma mark - Executing Requests

- (CIOAPISession *)session {
    if (_session == nil) {
        _session = [[CIOAPISession alloc] init];
    }
    return _session;
}

- (void)executeRequest:(CIORequest *)request success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    [self.session executeRequest:[self requestForCIORequest:request] success:^(id result) {
        NSError *error = [request validateResponseObject:result];
        if (error) {
            failure(error);
        } else {
            success(result);
        }
    } failure:failure];
}

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request
                         success:(void (^)(NSDictionary *))success
                         failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)executeArrayRequest:(CIOArrayRequest *)request
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)executeStringRequest:(CIOStringRequest *)request
                     success:(void (^)(NSString *))success
                     failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)downloadRequest:(CIORequest * __nonnull)request toFileURL:(NSURL * __nonnull)fileURL success:(nullable void (^)())successBlock failure:(nullable void (^)(NSError * __nonnull))failureBlock progress:(nullable CIOSessionDownloadProgressBlock)progressBlock {
    [self.session downloadRequest:[self requestForCIORequest:request]
                        toFileURL:fileURL
                          success:successBlock
                          failure:failureBlock
                         progress:progressBlock];
}

@end


@implementation CIODictionaryRequest (CIORequest)

- (void)executeWithSuccess:(nullable void (^)(NSDictionary * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    [self.client executeDictionaryRequest:self success:success failure:failure];
}

@end

@implementation CIOArrayRequest (CIORequest)

- (void)executeWithSuccess:(nullable void (^)(NSArray * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    [self.client executeArrayRequest:self success:success failure:failure];
}

@end

@implementation CIOStringRequest (CIORequest)

- (void)executeWithSuccess:(nullable void (^)(NSString * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    [self.client executeStringRequest:self success:success failure:failure];
}

@end