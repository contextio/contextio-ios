//
//  CIOFilesRequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOSearchRequest.h"

@interface CIOFilesRequest : CIOFileDataRequest

/**
 If set to `YES`, the list will do an intelligent grouping of files to reflect occurrences of the same document. The
 grouping algorithm is exactly the same as the one used to get file revisions but only the occurrences matching the
 filters applied to the list will be included in the results.
 */
@property (nonatomic) BOOL group_by_revisions;

@end
