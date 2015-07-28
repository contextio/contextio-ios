//
//  CIOSourceRequests.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

/**
 *  A request to fetch a list of sources in an account.
 
 @see https://context.io/docs/2.0/accounts/sources
 */
@interface CIOSourcesRequest : CIOArrayRequest

/**
 * Only return accounts with sources whose status is of a specific value. If an account has many sources, only those
 * matching the given value will be included in the response. See `CIOAccountStatus` for possible values.
 */
@property (nonatomic) CIOAccountStatus status;

/**
 * Set to `@NO` to get all accounts with sources that are not working correctly. Set to `@YES` for the opposite. As for
 * the status filter, only sources matching the specific value are included in the response.
 */
@property (nullable, nonatomic) NSNumber *status_ok;

@end


/**
 Request to create a new source in an existing Context.IO account.
 
 @see https://context.io/docs/2.0/accounts/sources
 */
@interface CIOSourceCreateRequest : CIODictionaryRequest

/**
 IP address of the end user requesting the account to be created
 */
@property (nullable, nonatomic) NSString *origin_ip;

/**
 By default, we don't filter out messages flagged as deleted. Set this to `YES` to turn on this filtering.
 */
@property (nonatomic) BOOL expunge_on_deleted_flag;

/**
 By default, we filter out some folders like 'Deleted Items' and 'Drafts'. Set this parameter to `YES` to turn off this filtering and show every single folder.
 */
@property (nonatomic) BOOL sync_all_folders;

/**
 By default, we filter out some folders like 'Deleted Items' and 'Drafts'. Set this parameter to `All,Trash` to show the 'Deleted Items' folder.
 */
@property (nullable, nonatomic) NSString *sync_folders;

/**
 By default, we don't synchronize IMAP flags. Enable this parameter to turn on IMAP flag syncing for the 'seen' and 'flagged' flags.
 */
@property (nonatomic) BOOL sync_flags;

/**
 By default, we filter out files like signature images or those winmail.dat files form the files list. Set this parameter to `YES` to turn off this filtering and show every single file attachments.
 */
@property (nonatomic) BOOL raw_file_list;

/**
 Password for authentication on the IMAP server. Ignored if any of the `provider_*` parameters are set.
 */
@property (nullable, nonatomic) NSString *password;

/**
 An OAuth2 refresh token obtained from the IMAP account provider to authenticate this email account.
 */
@property (nullable, nonatomic) NSString *provider_refresh_token;

/**
 The OAuth2 Client ID used to obtain the the refresh token for the above account. That consumer key and secret must be configured in your Context.IO account.
 
 @see https://context.io/docs/2.0/oauth_providers
 */
@property (nullable, nonatomic) NSString *provider_consumer_key;

/**
 If specified, we'll make a POST request to this URL when the initial sync is completed.
 */
@property (nullable, nonatomic) NSString *callback_url;

/**
 If specified, we'll make a POST request to this URL if the connection status of the source changes.
 */
@property (nullable, nonatomic) NSString *status_callback_url;

@end


@interface CIOSourceModifyRequest: CIODictionaryRequest


/**
 If the status of the source is `TEMP_DISABLED` or `DISABLED`. You can do a POST/PUT with status set to `YES` to reset it.
 */
@property (nonatomic) BOOL status;

/**
 Set to `YES` to create an IMAP connection and reset the source status to to one reported by the IMAP backend. Don't combine this with other parameters.
 */
@property (nonatomic) BOOL force_status_check;
/**
 By default, we don't filter out messages flagged as deleted. Set this to `YES` to turn on this filtering.
 */
@property (nonatomic) BOOL expunge_on_deleted_flag;

/**
 By default, we filter out some folders like 'Deleted Items' and 'Drafts'. Set this parameter to `YES` to turn off this filtering and show every single folder.
 */
@property (nonatomic) BOOL sync_all_folders;
/**
 Password for authentication on the IMAP server. Ignored if any of the `provider_*` parameters are set.
 */
@property (nullable, nonatomic) NSString *password;

/**
 An OAuth2 refresh token obtained from the IMAP account provider to authenticate this email account.
 */
@property (nullable, nonatomic) NSString *provider_refresh_token;

/**
 The OAuth2 Client ID used to obtain the the refresh token for the above account. That consumer key and secret must be configured in your Context.IO account.

 @see https://context.io/docs/2.0/oauth_providers
 */
@property (nullable, nonatomic) NSString *provider_consumer_key;

/**
 If specified, we'll make a POST request to this URL if the connection status of the source changes.
 */
@property (nullable, nonatomic) NSString *status_callback_url;


@end