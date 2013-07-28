//
//  FTCCharacterInfo.h
//
//  Created by Abel Campos on 3/25/13.
//
//

#import <Foundation/Foundation.h>

/*
 *  This class contains shared info relative to FTCCharacter, in order to avoid having that info replicated (readonly) 
 *  every time a FTCCharacter is created.
 *
 *  The information is filled parsing the related xml using method: 
 *  FTCParse::parseAndPreloadAnimationXML
 *
 *  The information saved is the following:
 *  - sizeInfoDict: Indexed dictionary by character that contains its contentSize (calculated using sprites and 
 *   its animations)
 *  - characterDict: Indexed dictionary by character that contains information from Events and (more important) 
 *   the framecount.
 */

@interface FTCharacterSizeInfo : NSObject

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint anchorPoint;

@property (nonatomic) int top;
@property (nonatomic) int left;
@property (nonatomic) int bottom;
@property (nonatomic) int right;

@end

@interface FTCCharacterInfo : NSObject{
    // Information for contentSize
    NSMutableDictionary *sizeInfoDict;
    
    // Information of animations and events
    
    // Dictionary indexed by character.
    // Every character will contain another indexed by animation dict with the information (events and framecount) of that animation
    NSMutableDictionary *characterDict;
}

+(FTCCharacterInfo*)sharedInstance;

-(void)addAnimationEvents:(NSMutableDictionary *)animationEventsTable ForCharacter:(NSString*)characterName;
-(NSMutableDictionary*) getAnimationEventsForCharacter:(NSString*)characterName;

// SizeInfo

// Returns the FTCCharacterSizeInfo of that character 
// If it doesn't exist it will be calculated with the information of the sprites stored in FTCSpriteAnimations
-(FTCharacterSizeInfo*)getSizeInfoForCharacter:(NSString*)characterName;
-(FTCharacterSizeInfo *)calculateInfoSizeForCharacter:(NSString*)characterName;
@end
