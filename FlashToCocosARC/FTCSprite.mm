//
//  FTCSprite.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCSprite.h"
#import "FTCCharacter.h"
#import "ColorUtils.h"

@implementation FTCSprite

@synthesize name;
@synthesize ignorePosition = _ignorePosition;
@synthesize ignoreRotation = _ignoreRotation;
@synthesize ignoreScale = _ignoreScale;
@synthesize ignoreAlpha = _ignoreAlpha;
@synthesize animationsArr = _animationsArr;
@synthesize externAnimationsArr;

-(void) setCurrentAnimation:(NSString *)_framesId forCharacter:(FTCCharacter *)_character
{
    currentCharacter = _character;
    if (__FTCOPTIMIZED) {
        currentAnimationInfo = [self.externAnimationsArr objectForKey:_framesId];
    }else{
        currentAnimationInfo = [self.animationsArr objectForKey:_framesId];
    }
}

-(NSMutableDictionary*) animationsArr
{
    if (_animationsArr == nil)
    {
        _animationsArr = [[NSMutableDictionary alloc] init];
    }
    
    return _animationsArr;
}

-(void) setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr forCharacter:(FTCCharacter *)_character
{
    currentCharacter = _character;
    currentAnimationInfo = _framesInfoArr;
}


-(void) applyFrameInfo:(FTCFrameInfo *)_frameInfo
{
    if (!_ignorePosition)
        [self setPosition:CGPointMake(_frameInfo.x, _frameInfo.y)];   
    
    if (!_ignoreRotation)
        [self setRotation:_frameInfo.rotation];   
    
    if (!_ignoreScale) {
        if (_frameInfo.scaleX!=0)   [self setScaleX:_frameInfo.scaleX];
        if (_frameInfo.scaleY!=0)   [self setScaleY:_frameInfo.scaleY];
    }
    
    if (!_ignoreAlpha){
        if (self.opacity != (_frameInfo.alpha * 255)) {
            [self setOpacity:_frameInfo.alpha * 255];
        }
    }

    if (_frameInfo.mustTint) {
        if (![ColorUtils ccc3Compare:self.color withColor:_frameInfo.tint]) {
            self.color = _frameInfo.tint;
        }
    }
}


-(void) playFrame:(int)_frameindex
{
    if (!currentAnimationInfo) return;
    if (_frameindex < currentAnimationInfo.count) 
        [self applyFrameInfo:[currentAnimationInfo objectAtIndex:_frameindex]];
}

-(void) dealloc{
    currentCharacter = nil; //NOARC

    [_animationsArr release]; //NOARC
    [super dealloc];
}

@end
