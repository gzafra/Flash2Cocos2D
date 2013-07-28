//
//  FTCAnimationInfo.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCAnimationInfo.h"

@implementation FTCAnimationInfo

@synthesize name, frameInfoArray, partName;

- (void) dealloc{
    [name release];
    [frameInfoArray release];
    [partName release];
    [super dealloc];
}

@end
