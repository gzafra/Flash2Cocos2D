//
//  FTCCharacterInfo.h
//  TheDreamsons
//
//  Created by Abel Campos on 3/25/13.
//
//

#import <Foundation/Foundation.h>

/*
 *  Esta clase guarda información compartida relativa a los FTCCharacter, con el fin de no tener
 *  que replicar dicha información (de solo lectura) cada vez que se instancia un nuevo FTCCharacter.
 *
 *  La información se rellena parseando los xml correspondientes mediante el método
 *  FTCParse::parseAndPreloadAnimationXML
 *
 *  La información que se guarda es la siguiente:
 *  - sizeInfoDict: Diccionario indexado por character que contiene el contentSize del mismo (calculado
 *      a partir de sus sprites y animaciones)
 *  - characterDict: Diccionario indexado por character que contiene información de los Events y (lo más importante), el framecount
 */

@interface FTCharacterSizeInfo : NSObject

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint anchorPoint;

// Abel: Es posible que esta información no se llegue a usar
@property (nonatomic) int top;
@property (nonatomic) int left;
@property (nonatomic) int bottom;
@property (nonatomic) int right;

@end

@interface FTCCharacterInfo : NSObject{
    // Información para el ContentSize
    NSMutableDictionary *sizeInfoDict;
    
    // Información de las animaciones y eventos
    
    // Este diccionario se indexa por character.
    // Cada charracter contendrá otro dictionary indexado por animación con la información (Events y framecount)
    // de esa animación de ese character
    NSMutableDictionary *characterDict;
}

+(FTCCharacterInfo*)sharedInstance;

-(void)addAnimationEvents:(NSMutableDictionary *)animationEventsTable ForCharacter:(NSString*)characterName;
-(NSMutableDictionary*) getAnimationEventsForCharacter:(NSString*)characterName;

// SizeInfo

// Devuelve el FTCCharecterSizeInfo del Character
// Si no existe lo calcula con la información de los sprites almacenada en FTCSpriteAnimations
-(FTCharacterSizeInfo*)getSizeInfoForCharacter:(NSString*)characterName;
-(FTCharacterSizeInfo *)calculateInfoSizeForCharacter:(NSString*)characterName;
@end
