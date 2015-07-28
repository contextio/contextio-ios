//
//  CIOLiteClient.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/28/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface CIOLiteClient : CIOAPIClient

/**
 Initializes a `CIOLiteClient` object with the specified consumer key and secret. If a previously-authenticated consumer
 key is provided, its authentcation information will be restored from the keychain.

 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.

 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 Initializes a `CIOV2Client` object with the specified consumer key and secret, and additionally token and token
 secret. Use this method if you have already obtained a token and token secret on your own, and do not wish to use the
 built-in keychain storage.

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
                          accountID:(nullable NSString *)accountID;

#pragma mark - Users

/**
 *   Retrieves the current user's details.
 *
 */
- (CIODictionaryRequest *)getUser;

/**
 *  Modify the current account's info.
 *
 *  @param firstName new first name, optional
 *  @param lastName  new last name, optional
 *
 *  @return request to modify the account
 */
- (CIODictionaryRequest *)updateUserWithFirstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName;


/**
 *  Deletes the current account.
 *
 *
 */
- (CIODictionaryRequest *)deleteUser;

#pragma mark - Email Accounts

/**
 List email accounts assigned to the current user
 */
- (CIOArrayRequest *)getEmailAccounts;

/**
 List email accounts assigned to the current user

 @param status   Only return email accounts whose status is of a specific value. Use CIOAccountStatusNull for all accounts
 @param statusOK Set to @NO to get email accounts that are not working correctly. Set to @NO to get those that are, set to nil for all
 */
- (CIOArrayRequest *)getEmailAccountsWithStatus:(CIOAccountStatus)status statusOK:(nullable NSNumber *)statusOK;


@end

NS_ASSUME_NONNULL_END