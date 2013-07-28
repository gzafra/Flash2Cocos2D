//
//  FTCParser.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCParser.h"
#import "FTCCharacter.h"
#import "FTCSprite.h"
#import "FTCFrameInfo.h"
#import "FTCAnimEvent.h"
#import "FTCEventInfo.h"
#import "ColorUtils.h"
#import "FTCCache.h"
#import "Dimens.h"  // Abel
#import "FTCCharacterInfo.h"
#import "FTCSpriteAnimations.h"

@implementation FTCParser


+(BOOL) parseXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    if ([_xmlfile rangeOfString:@"oniro"].location != NSNotFound) {
//        NSLog(@"Parsing Oniro");
    }
    // sheets file
    BOOL sheetParse = [self parseSheetXML:_xmlfile toCharacter:_character];
    
//  [_character reorderChildren];
    
    // animations file
    BOOL animParse = YES;
    if (!__FTCOPTIMIZED) {
        animParse  = [self parseAnimationXML:_xmlfile toCharacter:_character];
    }

    [_character setFirstPose];
    
    return (sheetParse && animParse);
}


+(BOOL) parseSheetXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    NSString *baseFile = [NSString stringWithFormat:@"%@_sheets.xml", _xmlfile];
    
    FTCSpriteAnimations *spriteAnimations = [FTCSpriteAnimations sharedInstance];
    
    float pf = [Dimens getDeviceFactor];  // Abel

    NSError *error = nil;
    TBXML *_xmlMaster = nil;
    
    // Check if xml is already loaded
    if ([[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile] != nil) {
        _xmlMaster = (TBXML*)[[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile];
    }else{
        _xmlMaster = [TBXML tbxmlWithXMLFile:baseFile error:&error];
        [[FTCCache sharedFTCCache].xmlDictionary setValue:_xmlMaster forKey:baseFile];
        [_xmlMaster release]; //NOARC
    }

    // root    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;

    if (!_root) return NO;
    
    TBXMLElement *_texturesheet = [TBXML childElementNamed:@"TextureSheet" parentElement:_root];
    
    TBXMLElement *_texture = [TBXML childElementNamed:@"Texture" parentElement:_texturesheet];
    
    do {
        NSString *nName     = [TBXML valueOfAttributeNamed:@"name" forElement:_texture];

        NSRange NghostNameRange;
        
        NghostNameRange = [nName rangeOfString:@"ftcghost"];
        
        if (NghostNameRange.location != NSNotFound) continue;
        
        float nAX           = [[TBXML valueOfAttributeNamed:@"registrationPointX" forElement:_texture] floatValue]*pf;  // Abel
        float nAY           = -([[TBXML valueOfAttributeNamed:@"registrationPointY" forElement:_texture] floatValue]*pf);  // Abel
        NSString *nImage    = [TBXML valueOfAttributeNamed:@"path" forElement:_texture];
        int     zIndex      = [[TBXML valueOfAttributeNamed:@"zIndex" forElement:_texture] intValue];
        NSString *tint = [TBXML valueOfAttributeNamed:@"tint" forElement:_texture];
        
        // no support for sprite sheets yet
        FTCSprite *_sprite = nil;

        _sprite = [FTCSprite spriteWithSpriteFrameName:nImage];
        
        // SET ANCHOR P
        CGSize eSize = [_sprite boundingBox].size;
        
        CGPoint aP = CGPointMake(nAX/eSize.width, (eSize.height - (-nAY))/eSize.height);
        
        [_sprite setAnchorPoint:aP];
        
        // Añadirlo a la info compartida de ese sprite
        FTCSpriteInfo *spriteInfo = [spriteAnimations getSpriteInfoForCharacter:_xmlfile AndPart:nName];
        [spriteInfo setSize:eSize];
        [spriteInfo setAnchorPoint:aP];
        
        
        // Apply tint, if any
        if (![tint isEqualToString:@""] && (tint != NULL) && (![tint isEqualToString:@"0"])){
            _sprite.color = ColorFromHexString(tint);
        }
        
        //CCLOG(@"111: _sprite.retainCount:%d nName.retainCount:%d",_sprite.retainCount, nName.retainCount);
        [_character addElement:_sprite withName:nName atIndex:zIndex];
        
        // Asociarle el dictionary con las animaciones
        NSMutableDictionary *temp = [[FTCSpriteAnimations sharedInstance] getAnimationsForCharacter:_xmlfile AndPart:nName];
        [_sprite setExternAnimationsArr:temp];
        
    } while ((_texture = _texture->nextSibling));
    
    return YES;
}

// Parsea y precarga en FTCSpriteAnimations todas las animaciones del character indicado (_xmlfile)
+(BOOL) parseAndPreloadAnimationXML:(NSString *)_xmlfile{
    
    NSString *baseFile = [NSString stringWithFormat:@"%@_animations.xml", _xmlfile];
    FTCSpriteAnimations *spriteAnimations = [FTCSpriteAnimations sharedInstance];
    
    float pf = [Dimens getDeviceFactor];  // Abel

    NSError *error = nil;
    TBXML *_xmlMaster = nil;
    
    // Check if xml is already loaded
    if ([[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile] != nil) {
        _xmlMaster = (TBXML*)[[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile];
    }else{
        _xmlMaster = [TBXML tbxmlWithXMLFile:baseFile error:&error];
        [[FTCCache sharedFTCCache].xmlDictionary setValue:_xmlMaster forKey:baseFile];
    }
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;
    if (!_root) return NO;
    
    //*    // Abel: Este frameRate no está en ningún XML. Supongo que tendrá algún valor por defecto
    //*    _character.frameRate = [[TBXML valueOfAttributeNamed:@"frameRate" forElement:_root] floatValue];
    
    TBXMLElement *_animation = [TBXML childElementNamed:@"Animation" parentElement:_root];
    
    NSMutableDictionary *animationEventsTableAux = [[NSMutableDictionary alloc] init];
    
    // set the character animation (it will be filled with events)
    do {
        NSString *animName = [TBXML valueOfAttributeNamed:@"name" forElement:_animation];
        if ([animName isEqualToString:@""]) animName = @"_init";
        
        TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
        do {
            
            NSString *partName = [TBXML valueOfAttributeNamed:@"name" forElement:_part];
            NSString *tint = [TBXML valueOfAttributeNamed:@"tint" forElement:_part];
            //NSLog(@"Color:%@",tint);
            
            if ([animName isEqualToString:@""]) animName = @"_init";
            
            NSRange ghostNameRange;
            
            ghostNameRange = [partName rangeOfString:@"ftcghost"];
            
            if (ghostNameRange.location != NSNotFound) continue;
            
            NSMutableArray *__partFrames = [[NSMutableArray alloc] init];
            
            TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];
            
            //*            FTCSprite *__sprite = [_character getChildByName:partName];
            
            if (_frameInfo) {
                do {
                    FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
                    
                    
                    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
                    
                    fi.x = [[TBXML valueOfAttributeNamed:@"x" forElement:_frameInfo] floatValue] * pf;  // Abel
                    fi.y = -([[TBXML valueOfAttributeNamed:@"y" forElement:_frameInfo] floatValue] * pf);  // Abel
                    
                    
                    fi.scaleX = [[TBXML valueOfAttributeNamed:@"scaleX" forElement:_frameInfo] floatValue];
                    fi.scaleY = [[TBXML valueOfAttributeNamed:@"scaleY" forElement:_frameInfo] floatValue];
                    
                    fi.rotation = [[TBXML valueOfAttributeNamed:@"rotation" forElement:_frameInfo] floatValue];
                    
                    NSError *noAlpha = nil;
                    
                    fi.alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:_frameInfo error:&noAlpha] floatValue];
                    
                    // Save tint, if any (Duplicated in every frameInfo when it's not necessary. MUST MOVE TO _sheets.xml INSTEAD
                    fi.mustTint = NO; // Indicates wether it must use tint property to tint or just ignore it, disabled by default
                    if (![tint isEqualToString:@""] && (tint != NULL) && (![tint isEqualToString:@"0"])){
                        fi.tint = ColorFromHexString([NSString stringWithString:tint]);
                        fi.mustTint = YES;
                    }else{
                        NSString *frameTint = [TBXML valueOfAttributeNamed:@"tint" forElement:_frameInfo];
                        if (![frameTint isEqualToString:@""] && (tint != NULL) && (![tint isEqualToString:@"0"])){
                            fi.tint =  ColorFromHexString([NSString stringWithString:frameTint]);
                            fi.mustTint = YES;
                        }
                    }
                    
                    if (noAlpha) fi.alpha = 1.0f;
                    
                    [__partFrames addObject:fi];
                    
                    
                    /*
                     * Cálculo de ContentSize
                     */
                    // Guardamos la información necesaria de los sprites para poder calcular posteriormente
                    // el contentSize y anchorPoint de FTCCharacter
                    FTCSpriteInfo *spriteInfo = [spriteAnimations getSpriteInfoForCharacter:_xmlfile AndPart:partName];
                    [spriteInfo setScaleX:fi.scaleX];
                    [spriteInfo setScaleY:fi.scaleY];
                    [spriteInfo setX:fi.x];
                    [spriteInfo setY:fi.y];
                    
                } while ((_frameInfo = _frameInfo->nextSibling));
            }
            
            // Abel. Esto creo que no tiene mucho sentido, ya que sobreescribirá el tintado de la última animación
            // de este sprite. Es posible que esta cualidad pertenezca por tanto al sprite, pero no a la animación
            // TODO: Ver que se hace con este Tint. Probablemente meterlo en FTCSharedInfo como el tamaño.
            //*            if (![tint isEqualToString:@""] && (tint != NULL) && (![tint isEqualToString:@"0"])){
            //*                __sprite.color = ColorFromHexString(tint);
            //*            }
            
            // Optimización aquí: crear un dictionary en vez de usar el del sprite
            [spriteAnimations addFrames:__partFrames ToCharacter:_xmlfile AndPart:partName ForAnimation:animName];
            
        } while ((_part = _part->nextSibling));
        
        /******* EVENTS INFO ********/
        int _animationLength = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] intValue];
        
        NSMutableArray  *__eventsArr = [[NSMutableArray alloc] initWithCapacity:_animationLength];
        for (int ea=0; ea<_animationLength; ea++) { [__eventsArr addObject:[NSNull null]];};
        
        TBXMLElement *_eventXML = [TBXML childElementNamed:@"Marker" parentElement:_animation];
        
        if (_eventXML) {
            do {
                NSString *eventType = [TBXML valueOfAttributeNamed:@"name" forElement:_eventXML];
                int     frameIndex   = [[TBXML valueOfAttributeNamed:@"frame" forElement:_eventXML] intValue];
                
                FTCEventInfo *_eventInfo = [[FTCEventInfo alloc] init];
                [_eventInfo setFrameIndex:frameIndex];
                [_eventInfo setEventType:eventType];
                
                [__eventsArr insertObject:_eventInfo atIndex:frameIndex];
                
            } while ((_eventXML = [TBXML nextSiblingNamed:@"Marker" searchFromElement:_eventXML]));
        }
        
        FTCAnimEvent *__eventInfo = [[FTCAnimEvent alloc] init];
        [__eventInfo setFrameCount:_animationLength];
        [__eventInfo setEventsInfo:__eventsArr];
        
        //        [_character.animationEventsTable setValue:__eventInfo forKey:animName];
        [animationEventsTableAux setValue:__eventInfo forKey:animName];
        
        __eventsArr = nil;
        __eventInfo = nil;
        
    } while ((_animation = _animation->nextSibling));
    
    [[FTCCharacterInfo sharedInstance] addAnimationEvents:animationEventsTableAux ForCharacter:_xmlfile];
    
    return YES;
}


+(void)updateContentSizeOfCharacter:(FTCCharacter *)_character WithSprite:(CCSprite*)_sprite{
    float top, left, right, bottom;

    CGSize eSize = [_sprite boundingBox].size;
    CGPoint aP = _sprite.anchorPoint;
    
    top = eSize.height * (1 - aP.y);
    bottom = - eSize.height * aP.y;
    left = -eSize.width * aP.x;
    right = eSize.width * (1 - aP.x);
    
    // Update limits of the Character
    if (top > _character.top){
        _character.top = top;
    }
    
    if (left < _character.left){
        _character.left = left;
    }
    
    if (right > _character.right){
        _character.right = right;
    }
    
    if (bottom < _character.bottom){
        _character.bottom = bottom;
    }
    
    // Update content size
    CGSize newSize = CGSizeMake(_character.right - _character.left, _character.top - _character.bottom);
    [_character setContentSize:newSize];
    
}

+(BOOL) parseAnimationXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    NSString *baseFile = [NSString stringWithFormat:@"%@_animations.xml", _xmlfile];
    
//    CCLOG(@"Parseando animacion %@", baseFile);
    
    float pf = [Dimens getDeviceFactor];  // Abel
    
    NSError *error = nil;
    TBXML *_xmlMaster = nil;
    
    // Check if xml is already loaded
    if ([[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile] != nil) {
        _xmlMaster = (TBXML*)[[FTCCache sharedFTCCache].xmlDictionary objectForKey:baseFile];
    }else{
        _xmlMaster = [TBXML tbxmlWithXMLFile:baseFile error:&error];
        [[FTCCache sharedFTCCache].xmlDictionary setValue:_xmlMaster forKey:baseFile];
        [_xmlMaster release]; //NOARC
    }
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;
    if (!_root) return NO;

    _character.frameRate = [[TBXML valueOfAttributeNamed:@"frameRate" forElement:_root] floatValue];
    
    TBXMLElement *_animation = [TBXML childElementNamed:@"Animation" parentElement:_root];
    
    // set the character animation (it will be filled with events)
    do {                
        NSString *animName = [TBXML valueOfAttributeNamed:@"name" forElement:_animation];
        if ([animName isEqualToString:@""]) animName = @"_init";
        
        TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
        do {
        
            NSString *partName = [TBXML valueOfAttributeNamed:@"name" forElement:_part];
            NSString *tint = [TBXML valueOfAttributeNamed:@"tint" forElement:_part];
            //NSLog(@"Color:%@",tint);
            
            if ([animName isEqualToString:@""]) animName = @"_init";
            
            NSRange ghostNameRange;
            
            ghostNameRange = [partName rangeOfString:@"ftcghost"];
             
            if (ghostNameRange.location != NSNotFound) continue;
                 
            NSMutableArray *__partFrames = [[NSMutableArray alloc] init];
            
            TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];

            FTCSprite *__sprite = [_character getChildByName:partName];

            if (_frameInfo) {
                do {
                    FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
                    

                    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
                    
                    fi.x = [[TBXML valueOfAttributeNamed:@"x" forElement:_frameInfo] floatValue] * pf;  // Abel
                    fi.y = -([[TBXML valueOfAttributeNamed:@"y" forElement:_frameInfo] floatValue] * pf);  // Abel
                    

                    fi.scaleX = [[TBXML valueOfAttributeNamed:@"scaleX" forElement:_frameInfo] floatValue];                
                    fi.scaleY = [[TBXML valueOfAttributeNamed:@"scaleY" forElement:_frameInfo] floatValue];
                    
                    fi.rotation = [[TBXML valueOfAttributeNamed:@"rotation" forElement:_frameInfo] floatValue];
                    
                    NSError *noAlpha = nil;
                    
                    fi.alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:_frameInfo error:&noAlpha] floatValue];
                    
                    if (noAlpha) fi.alpha = 1.0f;
             
                    [__partFrames addObject:fi];
                    [fi release]; //NOARC
            
                    
                    [self updateContentSizeOfCharacter:_character WithSprite:__sprite AndFrameInfo:fi];
                } while ((_frameInfo = _frameInfo->nextSibling));
            }
            
            if (![tint isEqualToString:@""] && (tint != NULL) && (![tint isEqualToString:@"0"])){
                __sprite.color = ColorFromHexString(tint);
            }

            
            [__sprite.animationsArr setValue:__partFrames forKey:animName];
            [__partFrames release]; //NOARC
            
            
        } while ((_part = _part->nextSibling));        
        
        // Process Events if needed
        int _animationLength = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] intValue];
        
        NSMutableArray  *__eventsArr = [[NSMutableArray alloc] initWithCapacity:_animationLength];
        for (int ea=0; ea<_animationLength; ea++) { [__eventsArr addObject:[NSNull null]];};
            
        TBXMLElement *_eventXML = [TBXML childElementNamed:@"Marker" parentElement:_animation];
        
        if (_eventXML) {
            do {
                NSString *eventType = [TBXML valueOfAttributeNamed:@"name" forElement:_eventXML];
                int     frameIndex   = [[TBXML valueOfAttributeNamed:@"frame" forElement:_eventXML] intValue];

                FTCEventInfo *_eventInfo = [[FTCEventInfo alloc] init];
                [_eventInfo setFrameIndex:frameIndex];
                [_eventInfo setEventType:eventType];
                
                [__eventsArr insertObject:_eventInfo atIndex:frameIndex];
                
            } while ((_eventXML = [TBXML nextSiblingNamed:@"Marker" searchFromElement:_eventXML]));                                  
        }
        
        FTCAnimEvent *__eventInfo = [[FTCAnimEvent alloc] init];
        [__eventInfo setFrameCount:_animationLength];            
        [__eventInfo setEventsInfo:__eventsArr];
        
        [__eventsArr release]; //NOARC
        
        [_character.animationEventsTable setValue:__eventInfo forKey:animName];
        
        [__eventInfo release]; //NOARC

        __eventsArr = nil;
        __eventInfo = nil;


    } while ((_animation = _animation->nextSibling));

    
    //CCLOG(@"Nuevo content size: %f, %f", _character.contentSize.width, _character.contentSize.height);
    //[_character addDebugGraphics];
   
    return YES;
}

+(void)updateContentSizeOfCharacter:(FTCCharacter *)_character WithSprite:(CCSprite*)_sprite AndFrameInfo:(FTCFrameInfo*)fi{
    float top, left, right, bottom;
    
    // Obtener el tamaño del sprite y su anchor point
    CGSize eSize = [_sprite boundingBox].size;
    CGPoint aP = _sprite.anchorPoint;
    
    // Ajustar el tamaño del sprite en función de su escalado
    if (fi.scaleX != 0){
        eSize.width *= fi.scaleX;
    }
    if (fi.scaleY != 0){
        eSize.height *= fi.scaleY;
    }
    
    // Calcular los valores de los límites del sprite
    top = eSize.height * (1 - aP.y) + fi.y;
    bottom = - eSize.height * aP.y + fi.y;
    left = -eSize.width * aP.x + fi.x;
    right = eSize.width * (1 - aP.x) + fi.x;
    
    // Update limits of the Character
    if (top > _character.top){
        _character.top = top;
    }
    
    if (left < _character.left){
        _character.left = left;
    }
    
    if (right > _character.right){
        _character.right = right;
    }
    
    if (bottom < _character.bottom){
        _character.bottom = bottom;
    }
    
    // Update content size
    CGSize newSize = CGSizeMake(_character.right - _character.left, _character.top - _character.bottom);
    [_character setContentSize:newSize];
    
}



@end
