//
//  FTCCache.h
//
//  Created by Guillermo Zafra on 04/02/13.
//
//

#import <Foundation/Foundation.h>

@interface FTCCache : NSObject{
    NSDictionary *xmlDictionary;
}

@property (nonatomic, retain) NSDictionary *xmlDictionary;

+ (FTCCache*) sharedFTCCache;

@end
