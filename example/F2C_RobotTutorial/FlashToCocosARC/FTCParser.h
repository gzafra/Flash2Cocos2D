//
//  FTCParser.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "FTCFrameInfo.h"

@class FTCCharacter;

@interface FTCParser : NSObject

+(BOOL) parseXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;
+(BOOL) parseSheetXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;
+(BOOL) parseAnimationXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;

+(void)updateContentSizeOfCharacter:(FTCCharacter *)_character WithSprite:(CCSprite*)_sprite;
+(void)updateContentSizeOfCharacter:(FTCCharacter *)_character WithSprite:(CCSprite*)_sprite AndFrameInfo:(FTCFrameInfo*)fi;

+(BOOL) parseAndPreloadAnimationXML:(NSString *)_xmlfile;

@end
