//
//  CIOAPISession.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/14/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CIOSessionDownloadProgressBlock)(int64_t bytesRead, int64_t totalBytesRead,
                                                int64_t totalBytesExpectedToRead);

/**
 *  `CIOAPISession` provides the underlying support for executing requests against the Context.IO API via
 `NSURLSession` used by `CIOAPIClient`.
    The requests are typed based on their result data type: dictionary, array, and string.

    Untyped requests that are simply `CIORequest` can only be downloaded to a file via
 `downloadRequestToFile:saveToURL:success:failure:progress:`, however any request's result _may_ be downloaded to a file
 via that method. This is useful for `getSourceForMessageWithID:params:`, which will retrieve the entire raw data of an
 email, including all attachments.

    If an error is returned by the server, the best attempt will be made to populate the resulting `NSError`'s
 `localizedDescription` with the error returned by the API. The full `NSURLResponse` can be retrieved via the
 `CIOAPISessionURLResponseErrorKey` property of the error's `userInfo` property.
 */
@interface CIOAPISession : NSObject

- (void)executeRequest:(NSURLRequest *)request
               success:(void (^)(id responseObject))successBlock
               failure:(void (^)(NSError *error))failureBlock;

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
- (void)downloadRequest:(NSURLRequest *)request
              toFileURL:(NSURL *)fileURL
                success:(nullable void (^)())successBlock
                failure:(nullable void (^)(NSError *error))failureBlock
               progress:(nullable CIOSessionDownloadProgressBlock)progressBlock;

#pragma mark -

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response responseObject:(nullable id)responseObject;

- (nullable id)parseResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
