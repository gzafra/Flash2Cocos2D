//
//  ColorUtils.h
//  TheDreamsonsPhysics
//
//  Created by Guillermo Zafra on 21/01/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ColorUtils : NSObject


ccColor3B ColorFromHexString(NSString * hexString) ;
+ (BOOL) ccc3Compare:(ccColor3B)_firstColor withColor:(ccColor3B)_secondColor;

@end
