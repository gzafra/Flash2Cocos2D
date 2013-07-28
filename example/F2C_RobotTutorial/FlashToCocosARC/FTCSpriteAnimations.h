//
//  FTCSpriteAnimations.h
//
//  Created by Abel Campos on 3/19/13.
//
//

#import <Foundation/Foundation.h>

/*
 *  This class contains shared info relative to FTCSprite, in order to avoid having that info replicated (readonly) 
 *  every time a FTCSprite is created.
 *
 *  The information is filled parsing the related xml using method
 *  FTCParse::parseAndPreloadAnimationXML
 *
 *  The information saved is the following:
 *  - animationsDict: Indexed dictionary by sprite (character + part) that contains dictionaries with all frames 
 *    from animations
 *  - spritesInfo: Index dictionary by sprite that contains info from sprite (size y anchorPoint) needed to 
 *    calculate contentSize of the character that the sprites belongs to
 */
@interface FTCSpriteInfo : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;
@property (nonatomic) float x;
@property (nonatomic) float y;

@end

@interface FTCSpriteAnimations : NSObject{
    NSMutableDictionary *animationsDict;
    NSMutableDictionary *spritesInfo;
}

+(FTCSpriteAnimations*)sharedInstance;

// Sprite Animations
-(NSMutableDictionary*) getAnimationsForCharacter:(NSString*)characterName AndPart:(NSString*)partName;
-(void)addFrames:(NSMutableArray*)partFrames ToCharacter:(NSString*)characterName AndPart:(NSString*)partName ForAnimation:(NSString*)animName;


// Sprite Info
// This methods works both to obtain and set the info.
// For the latter we have to get the pointer and modify directly its content
-(FTCSpriteInfo*)getSpriteInfoForCharacter:(NSString*)characterName AndPart:(NSString*)partName;

// Given a character, it returns the array with all FTCSpriteInfo from the sprites contained in that character
// It's used to calculate the contentSize, anchorPoint, etc.. of the character
-(NSMutableArray*)getAllSpritesInfoForCharacter:(NSString*)characterName;
@end
