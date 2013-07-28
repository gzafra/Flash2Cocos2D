//
//  FTCCache.m
//  TheDreamsons
//
//  Created by Guillermo Zafra on 04/02/13.
//
//

#import "FTCCache.h"

@implementation FTCCache

@synthesize xmlDictionary;

static FTCCache* _sharedFTCCache;

+ (FTCCache*) sharedFTCCache
{
    if (!_sharedFTCCache)
    {
        _sharedFTCCache = [[self alloc] init];
	}
    
	return _sharedFTCCache;
}

- (id) init
{
	if (self = [super init])
    {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        self.xmlDictionary = dict;
        [dict release];
	}
    
	return self;
}

- (void) dealloc{
    [xmlDictionary release];
    [super dealloc];
}

@end
