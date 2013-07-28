//
//  ColorUtils.m
//
//  Created by Guillermo Zafra on 21/01/13.
//
//

#import "ColorUtils.h"

@implementation ColorUtils

void ScanHexColor(NSString * hexString, float * red, float * green, float * blue, float * alpha) {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    if (red) { *red = ((baseValue >> 24) & 0xFF)/255.0f; }
    if (green) { *green = ((baseValue >> 16) & 0xFF)/255.0f; }
    if (blue) { *blue = ((baseValue >> 8) & 0xFF)/255.0f; }
    if (alpha) { *alpha = ((baseValue >> 0) & 0xFF)/255.0f; }
}

ccColor3B ColorFromHexString(NSString * hexString) {
    float red, green, blue, alpha;
    ScanHexColor(hexString, &red, &green, &blue, &alpha);
    
    GLubyte redColor = static_cast<GLubyte>(red * 255.f);
    GLubyte greenColor = static_cast<GLubyte>(green * 255.f);
    GLubyte blueColor = static_cast<GLubyte>(blue * 255.f);
    
    //NSLog(@"Parsed color: r:%f, g:%f, b:%f",red, green, blue);
    return ccc3(redColor, greenColor, blueColor);
}

+ (BOOL) ccc3Compare:(ccColor3B)_firstColor withColor:(ccColor3B)_secondColor{
    if (_firstColor.r == _secondColor.r &&
        _firstColor.g == _secondColor.g &&
        _firstColor.b == _secondColor.b) {
        return YES;
    }else{
        return NO;
    }
}

@end
