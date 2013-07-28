//
//  FTCAnimEvent.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCAnimEvent : NSObject

@property (readwrite, assign) int  frameCount; //NOARC
@property (nonatomic, retain) NSMutableArray *eventsInfo; //NOARC

@end
