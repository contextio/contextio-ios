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

NSString *const CIOAPIBaseURLString = @"https://api.context.io/2.0/";

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

@property (nonatomic, readonly) NSString *accountPath;

- (void)loadCredentials;
- (void)saveCredentials;

@end

@implementation CIOAPIClient

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
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

    self.baseURL = [NSURL URLWithString:CIOAPIBaseURLString];
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
                           tokenSecret:(NSString *)tokenSecret {

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
    return [self signedRequestForPath:path method:method parameters:params token:token tokenSecret:tokenSecret];
}

- (NSURLRequest *)requestForPath:(NSString *)path method:(NSString *)method body:(id)body {
    // TDOAuth does not support JSON encoded body for GETs
    NSParameterAssert(![method isEqualToString:@"GET"]);
    NSString *token = self.isAuthorized ? _OAuthToken : nil;
    NSString *tokenSecret = self.isAuthorized ? _OAuthTokenSecret : nil;
    NSMutableURLRequest *signedRequest = [[TDOAuth URLRequestForPath:[self.basePath stringByAppendingPathComponent:path]
                                                          parameters:body
                                                                host:self.baseURL.host
                                                         consumerKey:_OAuthConsumerKey
                                                      consumerSecret:_OAuthTokenSecret
                                                         accessToken:token
                                                         tokenSecret:tokenSecret
                                                              scheme:@"https"
                                                       requestMethod:method
                                                        dataEncoding:TDOAuthContentTypeJsonObject
                                                        headerValues:@{
                                                                       @"Accept": @"application/json"
                                                                       }
                                                     signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    signedRequest.timeoutInterval = self.timeoutInterval;
    return signedRequest;
}

- (NSURLRequest *)requestForCIORequest:(CIORequest *)request {
    if ([request isKindOfClass:[CIOConnectTokenRequest class]]) {
        // This is a special case due to the use of the temporary token/secret during auth
        return [self signedRequestForPath:request.path method:request.method parameters:request.parameters token:_tmpOAuthToken tokenSecret:_tmpOAuthTokenSecret];
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

#pragma mark Contacts

- (CIOContactsRequest *)getContacts {
    return [CIOContactsRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"contacts"]
                                        method:@"GET"
                                    parameters:nil
                                        client:self];
}

- (CIODictionaryRequest *)getContactWithEmail:(NSString *)email {
    NSString *contactsURLPath = [self.accountPath stringByAppendingPathComponent:@"contacts"];
    return [self dictionaryRequestForPath:[contactsURLPath stringByAppendingPathComponent:email]
                                   method:@"GET"
                                   params:nil];
}

- (CIOArrayRequest *)getFilesForContactWithEmail:(NSString *)email{
    return [self arrayGetRequestWithAccountComponents:@[@"contacts", email, @"files"]];
}

- (CIOArrayRequest *)getMessagesForContactWithEmail:(NSString *)email {
    return [self arrayGetRequestWithAccountComponents:@[@"contacts", email, @"messages"]];
}

- (CIOArrayRequest *)getThreadsForContactWithEmail:(NSString *)email {
    return [self arrayGetRequestWithAccountComponents:@[@"contacts", email, @"threads"]];
}

#pragma mark - Email Addresses

- (CIOArrayRequest *)getEmailAddresses {
    return [self arrayGetRequestWithAccountComponents:@[@"email_addresses"]];
}

- (CIODictionaryRequest *)addEmailAddress:(NSString *)email {
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"email_addresses"]
                                   method:@"POST"
                                   params:@{@"email_address": email}];
}

- (CIODictionaryRequest *)updateEmailAddressWithEmail:(NSString *)email primary:(BOOL)primary {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"email_addresses", email]];
    return [self dictionaryRequestForPath:path
                                   method:@"POST"
                                   params:@{@"primary": @(primary)}];
}

- (CIODictionaryRequest *)deleteEmailAddressWithEmail:(NSString *)email {

    NSString *emailAddressesURLPath = [self.accountPath stringByAppendingPathComponent:@"email_addresses"];

    return [self dictionaryRequestForPath:[emailAddressesURLPath stringByAppendingPathComponent:email]
                                   method:@"DELETE"
                                   params:nil];
}

#pragma mark - Files

- (CIOFilesRequest *)getFiles {
    return [CIOFilesRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"files"]
                                     method:@"GET"
                                 parameters:nil
                                     client:self];
}

- (CIODictionaryRequest *)getDetailsOfFileWithID:(NSString *)fileID {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"files", fileID]];
    return [self dictionaryRequestForPath:path
                                   method:@"GET"
                                   params:nil];
}

- (CIOArrayRequest *)getChangesForFileWithID:(NSString *)fileID {
    return [self arrayGetRequestWithAccountComponents:@[@"files", fileID, @"changes"]];
}

- (CIOStringRequest *)getContentsURLForFileWithID:(NSString *)fileID {

    NSString *requestPath = [NSString pathWithComponents:@[self.accountPath, @"files", fileID, @"content"]];
    return [CIOStringRequest requestWithPath:requestPath
                                      method:@"GET" 
                                  parameters:@{@"as_link": @YES}
                                      client:self];
}

- (CIORequest *)downloadContentsOfFileWithID:(NSString *)fileID {

    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"files", fileID, @"content"]];
    return [CIORequest requestWithPath:path method:@"GET" parameters:nil client:self];
}

- (CIOArrayRequest *)getRelatedForFileWithID:(NSString *)fileID {

    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];

    return
        [self arrayRequestForPath:[fileURLPath stringByAppendingPathComponent:@"related"] method:@"GET" params:nil];
}

- (CIOArrayRequest *)getRevisionsForFileWithID:(NSString *)fileID {

    NSString *filesURLPath = [self.accountPath stringByAppendingPathComponent:@"files"];
    NSString *fileURLPath = [filesURLPath stringByAppendingPathComponent:fileID];

    return [self arrayRequestForPath:[fileURLPath stringByAppendingPathComponent:@"revisions"]
                              method:@"GET"
                              params:nil];
}

#pragma mark - Messages

- (CIOMessagesRequest *)getMessages {

    return [CIOMessagesRequest requestForAccountId:self.accountID client:self];
}

- (CIOMessageRequest *)getMessageWithID:(NSString *)messageID {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID]];
    return [CIOMessageRequest requestWithPath:path
                                       method:@"GET"
                                   parameters:nil
                                       client:self];
}

- (CIOMessageUpdateRequest *)updateMessageWithID:(NSString *)messageID
                            destinationFolder:(NSString *)destinationFolder {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID]];
    return [CIOMessageUpdateRequest requestWithPath:path
                                             method:@"POST"
                                         parameters:@{@"dst_folder": destinationFolder}
                                             client:self];
}

- (CIODictionaryRequest *)deleteMessageWithID:(NSString *)messageID {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];

    return [self dictionaryRequestForPath:[messagesURLPath stringByAppendingPathComponent:messageID]
                                   method:@"DELETE"
                                   params:nil];
}

- (CIOArrayRequest *)getBodyForMessageWithID:(NSString *)messageID type:(nullable NSString *)type {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    NSDictionary *params = nil;
    if (type) {
        params = @{@"type": type};
    }
    return [self arrayRequestForPath:[messageURLPath stringByAppendingPathComponent:@"body"]
                                   method:@"GET"
                                   params:params];
}

#pragma mark Messages/Flags

- (CIODictionaryRequest *)getFlagsForMessageWithID:(NSString *)messageID {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];

    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"flags"]
                                   method:@"GET"
                                   params:nil];
}

- (CIODictionaryRequest *)updateFlagsForMessageWithID:(NSString *)messageID flags:(CIOMessageFlags *)flags {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];

    return [self dictionaryRequestForPath:[messageURLPath stringByAppendingPathComponent:@"flags"]
                                   method:@"POST"
                                   params:[flags asDictionary]];
}

#pragma mark Messages/Folders

- (CIOArrayRequest *)getFoldersForMessageWithID:(NSString *)messageID {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];

    return [self arrayRequestForPath:[messageURLPath stringByAppendingPathComponent:@"folders"]
                              method:@"GET"
                              params:nil];
}

- (CIODictionaryRequest *)updateFoldersForMessageWithID:(NSString *)messageID addToFolder:(nullable NSString *)addFolder removeFromFolder:(nullable NSString *)removeFolder {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"folders"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (addFolder) {
        params[@"add"] = addFolder;
    }
    if (removeFolder) {
        params[@"remove"] = removeFolder;
    }
    return [self dictionaryRequestForPath:path
                                   method:@"POST"
                                   params:params];
}

- (CIODictionaryRequest *)setFoldersForMessageWithID:(NSString *)messageID folderNames:(NSArray *)folderNames symbolicFolderNames:(NSArray *)symbolicFolderNames {

    NSString *folderPath = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"folders"]];
    CIODictionaryRequest *request = [self dictionaryRequestForPath:folderPath method:@"PUT" params:nil];
    NSMutableArray *requestBody = [NSMutableArray array];
    for (NSString *name in folderNames) {
        [requestBody addObject:@{@"name": name}];
    }
    for (NSString *symbolicName in symbolicFolderNames) {
        [requestBody addObject:@{@"symbolic_name": symbolicName}];
    }
    request.requestBody = requestBody;
    return request;
}

#pragma mark Messages/Headers

- (CIODictionaryRequest *)getHeadersForMessageWithID:(NSString *)messageID {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"headers"]];
    return [self dictionaryRequestForPath:path
                                   method:@"GET"
                                   params:nil];
}

- (CIOStringRequest *)getRawHeadersForMessageWithID:(NSString *)messageID {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"headers"]];
    return [CIOStringRequest requestWithPath:path
                                      method:@"GET"
                                  parameters:@{@"raw": @YES}
                                      client:self];
}

#pragma mark Messages/Source

- (CIORequest *)getSourceForMessageWithID:(NSString *)messageID {

    NSString *requestPath = [NSString pathWithComponents:@[self.accountPath, @"messages", messageID, @"source"]];
    return [CIORequest requestWithPath:requestPath method:@"GET" parameters:nil client:self];
}

#pragma mark Messages/Thread

- (CIOThreadRequest *)getThreadForMessageWithID:(NSString *)messageID {

    NSString *messagesURLPath = [self.accountPath stringByAppendingPathComponent:@"messages"];
    NSString *messageURLPath = [messagesURLPath stringByAppendingPathComponent:messageID];
    return [CIOThreadRequest requestWithPath:[messageURLPath stringByAppendingPathComponent:@"thread"]
                                      method:@"GET"
                                  parameters:nil
                                      client:self];
}

#pragma mark - Sources

- (CIOArrayRequest *)getSources {
    return [CIOSourcesRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"sources"]
                                       method:@"GET"
                                   parameters:nil
                                       client:self];
}

- (CIODictionaryRequest *)createSourceWithEmail:(NSString *)email
                                         server:(NSString *)server
                                       username:(NSString *)username
                                         useSSL:(BOOL)useSSL
                                           port:(NSInteger)port
                                           type:(NSString *)type {

    NSDictionary *params = @{
                             @"email": email,
                             @"server": server,
                             @"username": username,
                             @"use_ssl": @(useSSL),
                             @"port": @(port),
                             @"type": type};

    return [CIOSourceCreateRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"sources"]

                                            method:@"POST"
                                        parameters:params
                                            client:self];
}

- (CIODictionaryRequest *)getSourceWithLabel:(NSString *)sourceLabel {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel]];

    return [self dictionaryRequestForPath:path
                                   method:@"GET"
                                   params:nil];
}

- (CIOSourceModifyRequest *)updateSourceWithLabel:(NSString *)sourceLabel {

    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel]];
    return [CIOSourceModifyRequest requestWithPath:path
                                            method:@"POST"
                                        parameters:nil
                                            client:self];
}

- (CIODictionaryRequest *)deleteSourceWithLabel:(NSString *)sourceLabel {

    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];

    return [self dictionaryRequestForPath:[sourcesURLPath stringByAppendingPathComponent:sourceLabel]
                                   method:@"DELETE"
                                   params:nil];
}

- (CIOArrayRequest *)getFoldersForSourceWithLabel:(NSString *)sourceLabel
                            includeExtendedCounts:(BOOL)includeExtendedCounts
                                          noCache:(BOOL)noCache {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel, @"folders"]];
    NSDictionary *params = @{@"include_extended_counts": @(includeExtendedCounts),
                             @"no_cache": @(noCache)};
    return [self arrayRequestForPath:path method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFolderWithPath:(NSString *)folderPath
                                sourceLabel:(NSString *)sourceLabel
                      includeExtendedCounts:(BOOL)includeExtendedCounts
                                      delim:(nullable NSString *)delim {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel, @"folders", folderPath]];
    NSMutableDictionary *params = [@{@"include_extended_counts": @(includeExtendedCounts)} mutableCopy];
    if (delim) {
        params[@"delim"] = delim;
    }
    return [self dictionaryRequestForPath:path
                                   method:@"GET"
                                   params:params];
}

- (CIODictionaryRequest *)createFolderWithPath:(NSString *)folderPath
                                   sourceLabel:(NSString *)sourceLabel
                                         delim:(nullable NSString *)delim {

    NSString *foldersURLPath =
    [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel, @"folders", folderPath]];
    NSDictionary *params = nil;
    if (delim) {
        params = @{@"delim": delim};
    }
    return [self dictionaryRequestForPath:foldersURLPath method:@"PUT" params:params];
}

- (CIODictionaryRequest *)deleteFolderWithPath:(NSString *)folderPath sourceLabel:(NSString *)sourceLabel {

    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];
    NSString *foldersURLPath = [sourceURLPath stringByAppendingPathComponent:@"folders"];

    return [self dictionaryRequestForPath:[foldersURLPath stringByAppendingPathComponent:folderPath]
                                   method:@"DELETE"
                                   params:nil];
}

- (CIODictionaryRequest *)expungeFolderWithPath:(NSString *)folderPath
                                    sourceLabel:(NSString *)sourceLabel {

    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"sources", sourceLabel, @"folders", folderPath, @"expunge"]];
    return [self dictionaryRequestForPath:path
                                   method:@"POST"
                                   params:nil];
}
- (CIOFolderMessagesRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                                               sourceLabel:(NSString *)sourceLabel {

    NSString *path = [NSString pathWithComponents:@[self.accountPath,
                                                    @"sources", sourceLabel, @"folders", folderPath, @"messages"]];
    return [CIOFolderMessagesRequest requestWithPath:path
                                              method:@"GET"
                                          parameters:nil
                                              client:self];
}

- (CIODictionaryRequest *)getSyncStatusForSourceWithLabel:(NSString *)sourceLabel {

    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];

    return [self dictionaryRequestForPath:[sourceURLPath stringByAppendingPathComponent:@"sync"]
                                   method:@"GET"
                                   params:nil];
}

- (CIODictionaryRequest *)forceSyncForSourceWithLabel:(NSString *)sourceLabel {

    NSString *sourcesURLPath = [self.accountPath stringByAppendingPathComponent:@"sources"];
    NSString *sourceURLPath = [sourcesURLPath stringByAppendingPathComponent:sourceLabel];

    return [self dictionaryRequestForPath:[sourceURLPath stringByAppendingPathComponent:@"sync"]
                                   method:@"POST"
                                   params:nil];
}

#pragma mark Sync

- (CIODictionaryRequest *)getSyncStatusForAllSources {
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"sync"]
                                   method:@"GET"
                                   params:nil];
}

- (CIODictionaryRequest *)forceSyncForAllSources {
    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"sync"]
                                   method:@"POST"
                                   params:nil];
}


#pragma mark - Threads

- (CIOThreadsRequest *)getThreads {
    return [CIOThreadsRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"threads"]
                                       method:@"GET"
                                   parameters:nil
                                       client:self];
}

- (CIOThreadRequest *)getThreadWithID:(NSString *)threadID {

    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"threads", threadID]];
    return [CIOThreadRequest requestWithPath:path method:@"GET" parameters:nil client:self];
}

- (CIODictionaryRequest * __nonnull)deleteThreadWithID:(NSString * __nonnull)threadID {

    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"threads", threadID]];
    return [self dictionaryRequestForPath:path
                                   method:@"DELETE"
                                   params:nil];
}

- (CIODictionaryRequest * __nonnull)updateFoldersForThreadWithID:(NSString * __nonnull)threadID addToFolder:(nullable NSString *)addFolder removeFromFolder:(nullable NSString *)removeFolder {
    NSString *path = [NSString pathWithComponents:@[self.accountPath, @"threads", threadID, @"folders"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (addFolder) {
        params[@"add"] = addFolder;
    }
    if (removeFolder) {
        params[@"remove"] = removeFolder;
    }
    return [self dictionaryRequestForPath:path
                                   method:@"POST"
                                   params:params];

}

- (CIODictionaryRequest *)setFoldersForThreadWithID:(NSString *)threadID folderNames:(NSArray *)folderNames symbolicFolderNames:(NSArray *)symbolicFolderNames {
    NSString *folderPath = [NSString pathWithComponents:@[self.accountPath, @"threads", threadID, @"folders"]];
    CIODictionaryRequest *request = [self dictionaryRequestForPath:folderPath method:@"PUT" params:nil];
    NSMutableArray *requestBody = [NSMutableArray array];
    if (folderNames) {
        [requestBody addObject:@{@"name": folderNames}];
    }
    if (symbolicFolderNames) {
        [requestBody addObject:@{@"symbolic_name": symbolicFolderNames}];
    }
    request.requestBody = requestBody;
    return request;

}

#pragma mark - Webhooks
// TODO: Is there a practical reason to make webhooks API available to iOS apps?

- (CIOArrayRequest *)getWebhooks {

    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"]
                              method:@"GET"
                              params:nil];
}

- (CIODictionaryRequest *)createWebhookWithCallbackURLString:(NSString *)callbackURLString
                                failureNotificationURLString:(NSString *)failureNotificationURLString
                                                      params:(NSDictionary *)params {

    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    mutableParams[@"callback_url"] = callbackURLString;
    mutableParams[@"failure_notif_url"] = failureNotificationURLString;

    return [self dictionaryRequestForPath:[self.accountPath stringByAppendingPathComponent:@"webhooks"]
                                   method:@"POST"
                                   params:[NSDictionary dictionaryWithDictionary:mutableParams]];
}

- (CIODictionaryRequest *)getWebhookWithID:(NSString *)webhookID params:(NSDictionary *)params {

    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];

    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
                                   method:@"GET"
                                   params:params];
}

- (CIODictionaryRequest *)updateWebhookWithID:(NSString *)webhookID params:(NSDictionary *)params {

    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];

    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
                                   method:@"POST"
                                   params:params];
}

- (CIODictionaryRequest *)deleteWebhookWithID:(NSString *)webhookID {

    NSString *webhooksURLPath = [self.accountPath stringByAppendingPathComponent:@"webhooks"];

    return [self dictionaryRequestForPath:[webhooksURLPath stringByAppendingPathComponent:webhookID]
                                   method:@"DELETE"
                                   params:nil];
}

@end
