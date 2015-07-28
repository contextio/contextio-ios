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

@end
