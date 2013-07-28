//
//  FTCCharacterInfo.m
//
//  Created by Abel Campos on 3/25/13.
//
//

#import "FTCCharacterInfo.h"
#import "FTCSpriteAnimations.h"

static FTCCharacterInfo *_sharedInstance = nil;

@implementation FTCharacterSizeInfo

@synthesize anchorPoint, contentSize;

@end

@implementation FTCCharacterInfo

+(FTCCharacterInfo*)sharedInstance{
    if (!_sharedInstance){
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        characterDict = [[NSMutableDictionary alloc] init];
        sizeInfoDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)addAnimationEvents:(NSMutableDictionary *)animationEventsTable ForCharacter:(NSString*)characterName{
//    [characterDict removeObjectForKey:characterName];
    [characterDict setValue:animationEventsTable forKey:characterName];
}

-(NSMutableDictionary*) getAnimationEventsForCharacter:(NSString*)characterName{
    return [characterDict valueForKey:characterName];
}



-(FTCharacterSizeInfo*)getSizeInfoForCharacter:(NSString*)characterName{
    FTCharacterSizeInfo *sizeInfo = [[sizeInfoDict valueForKey:characterName] retain];
    
    if (!sizeInfo){
        // If it hasn't been calculated, do it now
        sizeInfo = [self calculateInfoSizeForCharacter:characterName];
        [sizeInfoDict setValue:sizeInfo forKey:characterName];
    }
    
    [sizeInfo release]; //NOARC
    
    return sizeInfo;

}

-(FTCharacterSizeInfo *)calculateInfoSizeForCharacter:(NSString*)characterName{
    NSMutableArray *spriteInfoArray = [[[FTCSpriteAnimations sharedInstance] getAllSpritesInfoForCharacter:characterName] autorelease];
    FTCharacterSizeInfo *sizeInfo = [[FTCharacterSizeInfo alloc] init];
    CGSize eSize;
    CGPoint aP;
    float top = 0, bottom = 0, left = 0, right = 0;
    float topAux, bottomAux, leftAux, rightAux;
    
    for (FTCSpriteInfo *spriteInfo in spriteInfoArray) {
        eSize = spriteInfo.size;
        aP = spriteInfo.anchorPoint;
        
        // Adjust the size of the sprite based on its scale
        if (spriteInfo.scaleX != 0){
            eSize.width *= spriteInfo.scaleX;
        }
        if (spriteInfo.scaleY != 0){
            eSize.height *= spriteInfo.scaleY;
        }
        
        // Calc limit values of the sprite
        topAux = eSize.height * (1 - spriteInfo.anchorPoint.y) + spriteInfo.y;
        bottomAux = - eSize.height * spriteInfo.anchorPoint.y + spriteInfo.y;
        leftAux = -eSize.width * spriteInfo.anchorPoint.x + spriteInfo.x;
        rightAux = eSize.width * (1 - spriteInfo.anchorPoint.x) + spriteInfo.x;
        
        // Update limits of the Character
        if (topAux > top){
            top = topAux;
        }
        
        if (leftAux < left){
            left = leftAux;
        }
        
        if (rightAux > right){
            right = rightAux;
        }
        
        if (bottomAux < bottom){
            bottom = bottomAux;
        }

    }
    
    [spriteInfoArray removeAllObjects];
    
    CGSize newSize = CGSizeMake(right - left, top - bottom);
    [sizeInfo setContentSize:newSize];
    CGPoint newAnchorPoint = ccp(-(left/(right-left)), -(bottom/(top-bottom))); // Abel: ¿¿??
    [sizeInfo setAnchorPoint:newAnchorPoint];

    [sizeInfo setTop:top];
    [sizeInfo setBottom:bottom];
    [sizeInfo setLeft:left];
    [sizeInfo setRight:right];
    
    
    return sizeInfo;
}



@end
