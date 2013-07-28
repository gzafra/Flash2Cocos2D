//
//  FTCSpriteAnimations.h
//  TheDreamsons
//
//  Created by Abel Campos on 3/19/13.
//
//

#import <Foundation/Foundation.h>

/*
 *  Esta clase guarda información compartida relativa a los FTCSprite, con el fin de no tener
 *  que replicar dicha información (de solo lectura) cada vez que se instancia un nuevo FTCSprite.
 *
 *  La información se rellena parseando los xml correspondientes mediante el método
 *  FTCParse::parseAndPreloadAnimationXML
 *
 *  La información que se guarda es la siguiente:
 *  - animationsDict: Diccionario indexado por sprite (character + part) que contiene diccionarios con los frames de las animaciones
 *  - spritesInfo: Diccionario indexado por sprite que contiene info del sprite (size y anchorPoint) necesaria para calcular
 *      el contentSize del character al que corresponde el sprite
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
// Este método sirve tanto para obtener la info como para establecerla.
// Para esto último hay que obtener el puntero y modificar directamente su contenido
-(FTCSpriteInfo*)getSpriteInfoForCharacter:(NSString*)characterName AndPart:(NSString*)partName;

// Dado un character devuelve un array con todos los FTCSpriteInfo de los sprites contenidos en ese Character
// Se usa para calculara el contentSize, anchorPoint, etc., del character
-(NSMutableArray*)getAllSpritesInfoForCharacter:(NSString*)characterName;
@end
