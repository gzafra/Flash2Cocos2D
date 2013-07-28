//
//  FTCSpriteAnimations.m
//  TheDreamsons
//
//  Created by Abel Campos on 3/19/13.
//
//

#import "FTCSpriteAnimations.h"
#import "FTCParser.h"

static FTCSpriteAnimations *_sharedInstance = nil;

@implementation FTCSpriteInfo

@synthesize size, anchorPoint, scaleX, scaleY, x, y;

@end

@implementation FTCSpriteAnimations

+(FTCSpriteAnimations*)sharedInstance{
    if (!_sharedInstance){
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        animationsDict = [[NSMutableDictionary alloc] init];
        spritesInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSMutableDictionary*) getAnimationsForCharacter:(NSString*)characterName AndPart:(NSString*)partName{
    NSString *key = [NSString stringWithFormat:@"%@_%@", characterName, partName];
    NSMutableDictionary*ret = [animationsDict valueForKey:key];
    if (!ret) { // TODO: Comprobar que realmente devuelve nil
        // Precargar TODAS las animaciones de ese character, lo que precargará TODAS las partes de ese character
        [FTCParser parseAndPreloadAnimationXML:characterName];
        ret = [animationsDict valueForKey:key];
    }
        
    return ret;
}

-(void)addFrames:(NSMutableArray*)partFrames ToCharacter:(NSString*)characterName AndPart:(NSString*)partName ForAnimation:(NSString*)animName{
    NSString *key = [NSString stringWithFormat:@"%@_%@", characterName, partName];
    NSMutableDictionary* spriteDict = [animationsDict valueForKey:key];
    if (!spriteDict) {
        spriteDict = [[NSMutableDictionary alloc] init];
        [animationsDict setValue:spriteDict forKey:key];
        [spriteDict release];
    }
    
    [spriteDict setValue:partFrames forKey:animName];
}


-(FTCSpriteInfo*)getSpriteInfoForCharacter:(NSString*)characterName AndPart:(NSString*)partName{
    NSString *key = [NSString stringWithFormat:@"%@_%@", characterName, partName];
    FTCSpriteInfo *spriteInfo = [spritesInfo valueForKey:key];
    if (!spriteInfo){
        spriteInfo = [[FTCSpriteInfo alloc] init];
        [spritesInfo setValue:spriteInfo forKey:key];
        [spriteInfo release];   // Abel: ¿¿??
    }
    
    return spriteInfo;
}

-(NSMutableArray*)getAllSpritesInfoForCharacter:(NSString*)characterName{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
#warning spritesInfo could be accessed and modified by two threads at the same time, MUST WATCH
    @synchronized(spritesInfo){
        for (NSString *key in spritesInfo) {
            if ([key hasPrefix:characterName]){
                NSValue *value = [[spritesInfo valueForKey:key] retain];
                [retArray addObject:value];
                [value release];
            }
        }
    }
    
    return retArray;
}







@end
