//
//  CIOAPIClient.m
//  
//
//  Created by Kevin Lord on 1/10/13.
//
//

#import "CIOAPIClient.h"

#import <SSKeychain/SSKeychain.h>
#import <TDOAuth/TDOAuth.h>

NSString * const kCIOAPIBaseURLString = @"https://api.context.io/2.0/";

// Keychain keys
static NSString * const kCIOKeyChainServicePrefix = @"Context-IO-";
static NSString * const kCIOAccountIDKeyChainKey = @"kCIOAccountID";
static NSString * const kCIOTokenKeyChainKey = @"kCIOToken";
static NSString * const kCIOTokenSecretKeyChainKey = @"kCIOTokenSecret";

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

@property (nonatomic, readonly) NSString *accountPath;

- (void)loadCredentials;
- (void)saveCredentials;

- (void)signURLRequest:(NSMutableURLRequest *)request parameters:(NSDictionary *)params token:(NSString *)token tokenSecret:(NSString *)tokenSecret;
- (void)signURLRequest:(NSMutableURLRequest *)request parameters:(NSDictionary *)params useToken:(BOOL)useToken;
@end


@implementation CIOAPIClient

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret {
    self = [self initWithConsumerKey:consumerKey consumerSecret:consumerSecret token:nil tokenSecret:nil accountID:nil];
    return self;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                    token:(NSString *)token
              tokenSecret:(NSString *)tokenSecret
                accountID:(NSString *)accountID {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    _OAuthConsumerKey = consumerKey;
    _OAuthConsumerSecret = consumerSecret;

    self.baseURL = [NSURL URLWithString:kCIOAPIBaseURLString];
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
    
    NSMutableDictionary *mutableParams = [(params ?: @{}) mutableCopy];
    
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
    // This method is a bit of a one off due to the use of the temporary token/secret
    NSString *connectTokenPath = [@"connect_tokens" stringByAppendingPathComponent:connectToken];
    NSURLRequest *URLRequest = [self signedRequestForPath:connectTokenPath
                                                   method:@"GET"
                                               parameters:nil
                                                    token:_tmpOAuthToken
                                              tokenSecret:_tmpOAuthTokenSecret];
    return [CIODictionaryRequest withURLRequest:URLRequest];
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

    NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kCIOKeyChainServicePrefix, _OAuthConsumerKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOAccountIDKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenKeyChainKey];
    [SSKeychain deletePasswordForService:serviceName account:kCIOTokenSecretKeyChainKey];
}

#pragma mark -

- (NSURLRequest *)signedRequestForPath:(NSString *)path method:(NSString *)method parameters:(NSDictionary *)params token:(NSString *)token tokenSecret:(NSString *)tokenSecret {

    NSMutableURLRequest *signedRequest = [[TDOAuth URLRequestForPath:[self.basePath stringByAppendingPathComponent:path]
                                                          parameters:params
                                                                host:self.baseURL.host
                                                         consumerKey:_OAuthConsumerKey
                                                      consumerSecret:_OAuthConsumerSecret
                                                         accessToken:token
                                                         tokenSecret:tokenSecret
                                                              scheme:@"https"
                                                       requestMethod:method
                                                        dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                                        headerValues:@{@"Accept": @"application/json"}
                                                     signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    signedRequest.timeoutInterval = self.timeoutInterval;
    return signedRequest;
}

- (void)signURLRequest:(NSMutableURLRequest *)request parameters:(NSDictionary *)params token:(NSString *)token tokenSecret:(NSString *)tokenSecret {

    NSURL *url = request.URL;
    NSString *urlPath = [url path];
    // Strip query string if needed
    if ([url query] != nil) {
        NSString *queryString = [@"?" stringByAppendingString:[url query]];
        urlPath = [urlPath stringByReplacingOccurrencesOfString:queryString withString:@""];
    }
    
    NSURLRequest *signedRequest = [TDOAuth URLRequestForPath:urlPath
                                                  parameters:params
                                                        host:url.host
                                                 consumerKey:_OAuthConsumerKey
                                              consumerSecret:_OAuthConsumerSecret
                                                 accessToken:token
                                                 tokenSecret:tokenSecret
                                                      scheme:url.scheme
                                               requestMethod:request.HTTPMethod
                                                dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                                headerValues:@{@"Accept": @"application/json"}
                                             signatureMethod:TDOAuthSignatureMethodHmacSha1];
    
    [request addValue:[signedRequest valueForHTTPHeaderField:@"Authorization"] forHTTPHeaderField:@"Authorization"];
}

- (void)signURLRequest:(NSMutableURLRequest *)mutableURLRequest parameters:(NSDictionary *)params useToken:(BOOL)useToken {
    
    if (useToken) {
        [self signURLRequest:mutableURLRequest parameters:params token:_OAuthToken tokenSecret:_OAuthTokenSecret];
    } else {        
        [self signURLRequest:mutableURLRequest parameters:params token:nil tokenSecret:nil];
    }
}

- (NSString *)accountPath {
    return [@"accounts" stringByAppendingPathComponent:_accountID];
}

#pragma mark -

- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {
    NSString *token = _isAuthorized ? _OAuthToken : nil;
    NSString *tokenSecret = _isAuthorized ? _OAuthTokenSecret : nil;
    return [self signedRequestForPath:path method:method parameters:params token:token tokenSecret:tokenSecret];
}

- (CIODictionaryRequest *)dictionaryRequestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {
    return [CIODictionaryRequest withURLRequest:[self requestForPath:path method:method params:params]];
}

- (CIOArrayRequest *)arrayRequestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {
    return [CIOArrayRequest withURLRequest:[self requestForPath:path method:method params:params]];
}


#pragma mark - Account

- (CIODictionaryRequest *)getAccountWithParams:(NSDictionary *)params {
    return [self dictionaryRequestForPath:self.accountPath method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateAccountWithParams:(NSDictionary *)params {
    return [self dictionaryRequestForPath:self.accountPath method:@"POST" params:params];
}

- (CIODictionaryRequest *)deleteAccount {
    return [self dictionaryRequestForPath:self.accountPath method:@"DELETE" params:nil];
}

#pragma mark Contacts

- (CIODictionaryRequest *)getContactsWithParams:(NSDictionary *)params {
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"contacts"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getContactWithEmail:(NSString *)email
                     params:(NSDictionary *)params {
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    return [self dictionaryRequestForPath:[contactsURLPath stringByAppendingPathComponent:email] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFilesForContactWithEmail:(NSString *)email
                                               params:(NSDictionary *)params {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    return [self dictionaryRequestForPath:[contactURLPath stringByAppendingPathComponent:@"files"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getMessagesForContactWithEmail:(NSString *)email
                                params:(NSDictionary *)params {
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    return [self dictionaryRequestForPath:[contactURLPath stringByAppendingPathComponent:@"messages"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getThreadsForContactWithEmail:(NSString *)email
                               params:(NSDictionary *)params {
    
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    NSString *contactURLPath = [contactsURLPath stringByAppendingPathComponent:email];
    
    return [self dictionaryRequestForPath:[contactURLPath stringByAppendingPathComponent:@"threads"] method:@"GET" params:params];
}

#pragma mark - Email Addresses

- (CIOArrayRequest *)getEmailAddressesWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"email_addresses"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)createEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    mutableParams[@"email_address"] = email;
    
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"email_addresses"] method:@"POST" params:[NSDictionary dictionaryWithDictionary:mutableParams]];
}

- (CIODictionaryRequest *)getEmailAddressWithEmail:(NSString *)email
                          params:(NSDictionary *)params {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    return [self dictionaryRequestForPath:[emailAddressesURLPath stringByAppendingPathComponent:email] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateEmailAddressWithEmail:(NSString *)email
                             params:(NSDictionary *)params {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    return [self dictionaryRequestForPath:[emailAddressesURLPath stringByAppendingPathComponent:email] method:@"POST" params:params];
}

- (CIODictionaryRequest *)deleteEmailAddressWithEmail:(NSString *)email {
    
    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];
    
    return [self dictionaryRequestForPath:[emailAddressesURLPath stringByAppendingPathComponent:email] method:@"DELETE" params:nil];
}

#pragma mark - Files

- (CIOArrayRequest *)getFilesWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"files"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFileWithID:(NSString *)fileID
               params:(NSDictionary *)params {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    
    return [self dictionaryRequestForPath:[filesURLPath stringByAppendingPathComponent:fileID] method:@"GET" params:params];
}

- (CIOArrayRequest *)getChangesForFileWithID:(NSString *)fileID
                                      params:(NSDictionary *)params {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    return [self arrayRequestForPath:[fileURLPath stringByAppendingPathComponent:@"changes"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getContentsURLForFileWithID:(NSString *)fileID
                            params:(NSDictionary *)params {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:[NSNumber numberWithBool:YES] forKey:@"as_link"];
    
    return [self dictionaryRequestForPath:[fileURLPath stringByAppendingPathComponent:@"content"] method:@"GET" params:[NSDictionary dictionaryWithDictionary:mutableParams]];
}

//- (void)downloadContentsOfFileWithID:(NSString *)fileID
//                          saveToPath:(NSString *)saveToPath
//                              params:(NSDictionary *)params
//                             success:(void (^)())successBlock
//                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
//                            progress:(void (^) (NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead ))progressBlock {
//    
//    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
//    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
//    
//    NSMutableURLRequest *mutableURLRequest = [self.HTTPClient requestWithMethod:@"GET"
//                                                                           path:[fileURLPath stringByAppendingPathComponent:@"content"]
//                                                                     parameters:params];
//    
//    [self signURLRequest:mutableURLRequest parameters:params useToken:YES];
//    
//    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:mutableURLRequest];
//    downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:saveToPath append:NO];
//    [downloadOperation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
//    [downloadOperation setDownloadProgressBlock:progressBlock];
//    [downloadOperation start];
//}

- (CIOArrayRequest *)getRelatedForFileWithID:(NSString *)fileID
                                      params:(NSDictionary *)params {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    return [self arrayRequestForPath:[fileURLPath stringByAppendingPathComponent:@"related"] method:@"GET" params:params];
}

- (CIOArrayRequest *)getRevisionsForFileWithID:(NSString *)fileID
                                        params:(NSDictionary *)params {
    
    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];
    
    return [self arrayRequestForPath:[fileURLPath stringByAppendingPathComponent:@"revisions"] method:@"GET" params:params];
}

#pragma mark - Messages

- (CIOArrayRequest *)getMessagesWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"messages"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getMessageWithID:(NSString *)messageID
                  params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    
    return [self dictionaryRequestForPath:[messagesURLPath stringByAppendingPathComponent:messageID] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateMessageWithID:(NSString *)messageID
          destinationFolder:(NSString *)destinationFolder
                     params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    mutableParams[@"dst_folder"] = destinationFolder;
    
    return [self dictionaryRequestForPath:[messagesURLPath stringByAppendingPathComponent:messageID]
                                   method:@"POST"
                                   params:mutableParams];
}

- (CIODictionaryRequest *)deleteMessageWithID:(NSString *)messageID {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];

    return [self dictionaryRequestForPath:[messagesURLPath stringByAppendingPathComponent:messageID] method:@"DELETE" params:nil];
}

- (CIODictionaryRequest *)getBodyForMessageWithID:(NSString *)messageID
                         params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"body"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFlagsForMessageWithID:(NSString *)messageID
                          params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"flags"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateFlagsForMessageWithID:(NSString *)messageID
                             params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"flags"] method:@"POST" params:params];
}

- (CIOArrayRequest *)getFoldersForMessageWithID:(NSString *)messageID
                                         params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self arrayRequestForPath:[messageURLPath stringByAppendingPathComponent:@"folders"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateFoldersForMessageWithID:(NSString *)messageID
                               params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"folders"] method:@"POST" params:params];
}

- (CIODictionaryRequest *)setFoldersForMessageWithID:(NSString *)messageID
                           folders:(NSDictionary *)folders {
    
    NSString *folderPath = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"folders"]];
    return [self dictionaryRequestForPath:folderPath method:@"PUT" params:nil];
}

- (CIODictionaryRequest *)getHeadersForMessageWithID:(NSString *)messageID
                            params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"headers"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getSourceForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"source"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getThreadForMessageWithID:(NSString *)messageID
                           params:(NSDictionary *)params {
    
    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    
    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"thread"] method:@"GET" params:params];
}

#pragma mark - Source

- (CIOArrayRequest *)getSourcesWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"sources"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)createSourceWithEmail:(NSString *)email
                       server:(NSString *)server
                     username:(NSString *)username
                       useSSL:(BOOL)useSSL
                         port:(NSInteger)port
                         type:(NSString *)type
                       params:(NSDictionary *)params {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    mutableParams[@"email"] = email;
    mutableParams[@"server"] = server;
    mutableParams[@"username"] = username;
    mutableParams[@"use_ssl"] = @(useSSL);
    mutableParams[@"port"] = @(port);
    mutableParams[@"type"] = type;
    
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"sources"]
                                   method:@"GET"
                                   params:mutableParams];
}

- (CIODictionaryRequest *)getSourceWithLabel:(NSString *)sourceLabel
                    params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    return [self dictionaryRequestForPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateSourceWithLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    return [self dictionaryRequestForPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel] method:@"POST" params:params];
}

- (CIODictionaryRequest *)deleteSourceWithLabel:(NSString *)sourceLabel {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    
    return [self dictionaryRequestForPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel] method:@"DELETE" params:nil];
}

- (CIOArrayRequest *)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                                           params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    return [self arrayRequestForPath:[sourceURLPath stringByAppendingPathComponent:@"folders"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFolderWithPath:(NSString *)folderPath
              sourceLabel:(NSString *)sourceLabel
                   params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    
    return [self dictionaryRequestForPath:[foldersURLPath stringByAppendingPathComponent:folderPath] method:@"GET" params:params];
}

- (CIODictionaryRequest *)deleteFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    
    return [self dictionaryRequestForPath:[foldersURLPath stringByAppendingPathComponent:folderPath] method:@"DELETE" params:nil];
}

- (CIODictionaryRequest *)createFolderWithPath:(NSString *)folderPath
                 sourceLabel:(NSString *)sourceLabel
                      params:(NSDictionary *)params {
    
    NSString *foldersURLPath = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel, @"folders", folderPath]];
    return [self dictionaryRequestForPath:foldersURLPath method:@"PUT" params:params];
}

- (CIODictionaryRequest *)expungeFolderWithPath:(NSString *)folderPath
                  sourceLabel:(NSString *)sourceLabel
                       params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    NSString *folderURLPath = [foldersURLPath stringByAppendingPathComponent:folderPath];
    
    return [self dictionaryRequestForPath:[folderURLPath stringByAppendingPathComponent:@"expunge"] method:@"POST" params:params];
}

- (CIOArrayRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                         sourceLabel:(NSString *)sourceLabel
                                           params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];
    NSString *folderURLPath = [foldersURLPath stringByAppendingPathComponent:folderPath];
    
    return [self arrayRequestForPath:[folderURLPath stringByAppendingPathComponent:@"messages"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel
                                 params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    return [self dictionaryRequestForPath:[sourceURLPath stringByAppendingPathComponent:@"sync"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)forceSyncForSourceWithLabel:(NSString *)sourceLabel
                             params:(NSDictionary *)params {
    
    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    
    return [self dictionaryRequestForPath:[sourceURLPath stringByAppendingPathComponent:@"sync"] method:@"POST" params:params];
}

#pragma mark - Threads

- (CIOArrayRequest *)getThreadsWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"threads"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)getThreadWithID:(NSString *)threadID
                 params:(NSDictionary *)params {
    
    NSString *threadsURLPath = [self.accountPath stringByAppendingPathComponent:@"threads"];
    
    return [self dictionaryRequestForPath:[threadsURLPath stringByAppendingPathComponent:threadID] method:@"GET" params:params];
}

#pragma mark - Webhooks
// TODO: Is there a practical reason to make webhooks API available to iOS apps?

- (CIOArrayRequest *)getWebhooksWithParams:(NSDictionary *)params {
    
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"] method:@"GET" params:params];
}

- (CIODictionaryRequest *)createWebhookWithCallbackURLString:(NSString *)callbackURLString
              failureNotificationURLString:(NSString *)failureNotificationURLString
                                    params:(NSDictionary *)params {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params ];
    mutableParams[@"callback_url"] = callbackURLString;
    mutableParams[@"failure_notif_url"] = failureNotificationURLString;
    
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"] method:@"POST" params:[NSDictionary dictionaryWithDictionary:mutableParams]];
}

- (CIODictionaryRequest *)getWebhookWithID:(NSString *)webhookID
                  params:(NSDictionary *)params {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID] method:@"GET" params:params];
}

- (CIODictionaryRequest *)updateWebhookWithID:(NSString *)webhookID
                     params:(NSDictionary *)params {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID] method:@"POST" params:params];
}

- (CIODictionaryRequest *)deleteWebhookWithID:(NSString *)webhookID {
    
    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];
    
    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID] method:@"DELETE" params:nil];
}

@end
