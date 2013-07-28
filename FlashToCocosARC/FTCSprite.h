//
//  FTCSprite.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FTCFrameInfo.h"

@class  FTCCharacter;

@interface FTCSprite : CCSprite 
{
    CCNode          *debugDrawingNode;
    NSArray         *currentAnimationInfo;
    FTCCharacter    *currentCharacter;
    
    // Abel
    NSMutableDictionary *externAnimationsArr;
}

@property (nonatomic, retain) NSString              *name;  //NOARC
@property (readwrite, assign) BOOL       ignoreRotation;    //NOARC
@property (readwrite, assign) BOOL       ignorePosition;    //NOARC
@property (readwrite, assign) BOOL       ignoreScale;   //NOARC
@property (readwrite, assign) BOOL       ignoreAlpha;   //NOARC

@property (nonatomic, retain) NSMutableDictionary   *animationsArr;
@property (nonatomic, assign) NSMutableDictionary *externAnimationsArr;

// private
-(void) setCurrentAnimation:(NSString *)_framesId forCharacter:(FTCCharacter *)_character;
-(void) setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr forCharacter:(FTCCharacter *)_character;
-(void) applyFrameInfo:(FTCFrameInfo *)_frameInfo;
-(void) playFrame:(int)_frameindex;
@end
