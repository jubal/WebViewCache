//
//  JHURLCache.h
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHURLCache : NSURLCache

@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@property (nonatomic, retain) NSMutableDictionary *responsesInfo;

- (void)saveInfo;

@end
