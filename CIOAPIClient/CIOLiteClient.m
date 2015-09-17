//
//  CIOLiteClient.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/28/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOLiteClient.h"

NSString *const CIOLiteAPIBaseURLString = @"https://api.context.io/lite/";


@implementation CIOLiteClient

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
    self = [self initWithConsumerKey:consumerKey
                      consumerSecret:consumerSecret
                               token:nil
                         tokenSecret:nil
                           accountID:nil];
    return self;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret token:(NSString *)token tokenSecret:(NSString *)tokenSecret accountID:(NSString *)accountID {
    self = [self initWithBaseURLString:CIOLiteAPIBaseURLString
                           consumerKey:consumerKey
                        consumerSecret:consumerSecret
                                 token:token
                           tokenSecret:tokenSecret
                             accountID:accountID];
    return self;
}

- (NSString * __nonnull)accountPath {
    return [@"users" stringByAppendingPathComponent:self.accountID];
}

- (NSString * __nonnull)keychainPrefix {
    return @"Context-IO-Lite-";
}

#pragma mark - User

- (CIODictionaryRequest *)getUser {
    return [self dictionaryRequestForPath:self.accountPath method:@"GET" params:nil];
}

- (CIODictionaryRequest *)updateUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (firstName) {
        params[@"first_name"] = firstName;
    }
    if (lastName ) {
        params[@"last_name"] = lastName;
    }
    return [self dictionaryRequestForPath:self.accountPath method:@"PUT" params:params];
}

- (CIODictionaryRequest *)deleteUser {
    return [self dictionaryRequestForPath:self.accountPath method:@"DELETE" params:nil];
}

#pragma mark - Email Accounts

- (CIOArrayRequest *)getEmailAccounts {
    return [self getEmailAccountsWithStatus:CIOAccountStatusNull statusOK:nil];
}

- (CIOArrayRequest *)getEmailAccountsWithStatus:(CIOAccountStatus)status statusOK:(NSNumber *)statusOK {
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *statusString = [CIORequest nameForAccountStatus:status];
    if (status) {
        params[@"status"] = statusString;
    }
    if (statusOK) {
        params[@"status_ok"] = statusOK;
    }
    return [self arrayRequestForPath:[self.accountPath stringByAppendingPathComponent:@"email_accounts"]
                              method:@"GET"
                              params:params];
}

- (CIOAddMailboxRequest *)addMailboxWithEmail:(NSString *)email server:(NSString *)server username:(NSString *)username useSSL:(BOOL)useSSL port:(NSInteger)port type:(NSString *)type {
    NSDictionary *params = @{
                             @"email": email,
                             @"server": server,
                             @"username": username,
                             @"use_ssl": @(useSSL),
                             @"port": @(port),
                             @"type": type};
    return [CIOAddMailboxRequest requestWithPath:[self.accountPath stringByAppendingPathComponent:@"email_accounts"]

                                            method:@"POST"
                                        parameters:params
                                            client:self];
}

- (CIODictionaryRequest *)statusForEmailAccountWithLabel:(NSString *)label {
    if (label == nil) {
        label = @"0";
    }
    NSString *path = [self accountPath:@[@"email_accounts", label]];
    return [self dictionaryRequestForPath:path  method:@"GET" params:nil];
}

- (CIOMailboxModifyRequest *)modifyEmailAccountWithLabel:(NSString *)label {
    if (label == nil) {
        label = @"0";
    }
    NSString *path = [self accountPath:@[@"email_accounts", label]];
    return [CIOMailboxModifyRequest requestWithPath:path
                                            method:@"POST"
                                        parameters:nil
                                            client:self];
}

- (CIODictionaryRequest *)deleteEmailAccountWithLabel:(NSString *)label {
    NSString *path = [self accountPath:@[@"email_accounts", label ?: @"0"]];

    return [self dictionaryRequestForPath:path method:@"DELETE" params:nil];
}

#pragma mark - Email Account Folders

- (CIOArrayRequest *)getFoldersForAccountWithLabel:(NSString *)accountLabel includeNamesOnly:(BOOL)includeNamesOnly {
    NSString *path = [self accountPath:@[@"email_accounts", accountLabel ?: @"0", @"folders"]];
    NSDictionary *params = nil;
    if (includeNamesOnly) {
        params = @{@"include_names_only": @YES};
    }
    return [self arrayRequestForPath:path method:@"GET" params:params];
}

- (CIODictionaryRequest *)getFolderNamed:(NSString *)folderName forAccountWithLabel:(nullable NSString *)accountLabel delimiter:(nullable NSString *)delimiter {
    NSString *path = [self accountPath:@[@"email_accounts",
                                         accountLabel ?: @"0",
                                         @"folders",
                                         folderName]];
    NSDictionary *params = nil;
    if (delimiter) {
        params = @{@"delimiter": delimiter};
    }
    return [self dictionaryRequestForPath:path method:@"GET" params:params];
}

- (CIODictionaryRequest *)addFolderNamed:(NSString *)folderName forAccountWithLabel:(NSString *)accountLabel delimiter:(NSString *)delimiter {
    NSString *path = [self accountPath:@[@"email_accounts",
                                         accountLabel ?: @"0",
                                         @"folders",
                                         folderName]];
    NSDictionary *params = nil;
    if (delimiter) {
        params = @{@"delimiter": delimiter};
    }
    return [self dictionaryRequestForPath:path method:@"POST" params:params];
}

#pragma mark - Email Account Folder Messages

- (CIOLiteFolderMessagesRequest *)getMessagesForFolderWithPath:(NSString *)folderPath
                                                  accountLabel:(NSString *)accountLabel {
    NSString *path = [self accountPath:@[@"email_accounts",
                                         accountLabel ?: @"0",
                                         @"folders",
                                         folderPath,
                                         @"messages"
                                         ]];
    return [CIOLiteFolderMessagesRequest requestWithPath:path
                                                  method:@"GET"
                                              parameters:nil
                                                  client:self];
}

- (CIOLiteMessageRequest *)requestForMessageWithID:(NSString *)messageID inFolder:(NSString *)folderPath accountLabel:(NSString *)accountLabel delimiter:(nullable NSString *)delimiter {
    NSString *path = [self accountPath:@[@"email_accounts",
                                         accountLabel ?: @"0",
                                         @"folders",
                                         folderPath,
                                         @"messages",
                                         messageID
                                         ]];
    CIOLiteMessageRequest *request = [CIOLiteMessageRequest requestWithPath:path
                                           method:@"GET"
                                       parameters:nil
                                           client:self];
    request.delimiter = delimiter;
    return request;
}

@end
