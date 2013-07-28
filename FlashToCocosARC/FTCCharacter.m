//
//  FTCCharacter.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCCharacter.h"
#import "FTCParser.h"
#import "FTCEventInfo.h"
#import "FTCCharacterInfo.h"
#import "Config.h"

@implementation FTCCharacter
{
    void (^onComplete) ();
}

@synthesize childrenTable;
@synthesize animationEventsTable;
@synthesize delegate;
@synthesize frameRate;

@synthesize top;
@synthesize left;
@synthesize right;
@synthesize bottom;
@synthesize virtualAnchorPoint;
@synthesize externAnimationEventsTable;

+(FTCCharacter *) characterFromXMLFile:(NSString *)_xmlfile
{
    FTCCharacter *_c = [[FTCCharacter alloc] init];
    [_c createCharacterFromXML:_xmlfile];
    return _c;
}

+(FTCCharacter *) characterFromXMLFile:(NSString *)_xmlfile onCharacterComplete:(void(^)())completeHandler
{
    FTCCharacter *_c = [_c initFromXMLFile:_xmlfile onCharacterComplete:completeHandler];
    return _c;
}

-(id) initFromXMLFile:(NSString *)_xmlfile {
    NSString *blankName = (suffix == nil) ? @"blank.png" : [NSString stringWithFormat:@"blank%@.png",suffix];
    self = [self initWithSpriteFrameName:blankName];
    if (self)
    {
        [self createCharacterFromXML:_xmlfile];
    }
    
    return self;
}

-(id) initFromXMLFile:(NSString *)_xmlfile onCharacterComplete:(void (^)())completeHandler {
    
    NSString *blankName = (suffix == nil) ? @"blank.png" : [NSString stringWithFormat:@"blank%@.png",suffix];
    self = [self initWithSpriteFrameName:blankName];
    if (self)
    {
        [self createCharacterFromXML:_xmlfile onCharacterComplete:completeHandler];
    }
    
    return self;
}

- (id)init
{
    NSString *blankName = (suffix == nil) ? @"blank.png" : [NSString stringWithFormat:@"blank%@.png",suffix];
    self = [self initWithSpriteFrameName:blankName];
    if (self) {
        [self initProperties];
    }
    
    return self;
}

- (void) initProperties
{
    // BEWARE! HACK to avoid childrenTable to retain objects (CCNODES) and prevening conflict in dealloc
    childrenTable = (NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &kCFCopyStringDictionaryKeyCallBacks, NULL);
    
    animationEventsTable = [[NSMutableDictionary alloc] init];
    
    currentAnimationId = @"";
}

-(void) handleScheduleUpdate:(ccTime)_dt
{
    if (currentAnimationLength == 0 || _isPaused )
        return;
    
    [self playFrame];
    intFrame ++;
    
    // end of animation
    if (intFrame == currentAnimationLength) {
        
        if (![nextAnimationId isEqualToString:@""]) {
            [self playAnimation:nextAnimationId loop:nextAnimationDoesLoop wait:NO];
            return;
            
        }
        
        if (!_doesLoop) {
            [self stopAnimation];
            // If animation only has 1 frame, stop scheduler
            if (currentAnimationLength == 1) {
                [scheduler_ unscheduleAllSelectorsForTarget:self];
                _isSchedulerRunning = NO;
            }
            return;
        }
        
        intFrame = 0;
        if ([delegate respondsToSelector:@selector(onCharacter:loopedAnimation:)])
            [delegate onCharacter:self loopedAnimation:currentAnimationId];
        
    }

}

-(void) playFrame
{
    // check if theres any event for that frame
    if ([[currentAnimEvent objectAtIndex:intFrame] class]!=[NSNull class]) {
        if ([delegate respondsToSelector:@selector(onCharacter:event:atFrame:)])
            [delegate onCharacter:self event:[(FTCEventInfo *)[currentAnimEvent objectAtIndex:intFrame] eventType] atFrame:intFrame];
    };
    
    if ([delegate respondsToSelector:@selector(onCharacter:updateToFrame:)])
        [delegate onCharacter:self updateToFrame:intFrame];
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite playFrame:intFrame];
    }    
}

-(void) pauseAnimation
{
    _isPaused = YES;
}

-(void) resumeAnimation
{
    _isPaused = NO;
}

-(int) getCurrentFrame
{
    return intFrame;
}

-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId
{
    //NSLog(@"PLAYING FRAME %i FROM %@", _frameIndex, _animationId);
    currentAnimationId = _animationId;
    if (__FTCOPTIMIZED) {
        currentAnimEvent = [[self.externAnimationEventsTable objectForKey:_animationId] eventsInfo];
        currentAnimationLength = [[self.externAnimationEventsTable objectForKey:_animationId] frameCount];
    }else{
        currentAnimEvent = [[self.animationEventsTable objectForKey:_animationId] eventsInfo];
        currentAnimationLength = [[self.animationEventsTable objectForKey:_animationId] frameCount];

    }

    intFrame = _frameIndex;
    _isPaused = YES;
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }
    [self playFrame];
}

-(void) stopAnimation
{
    currentAnimationLength = 0;
    NSString *oldAnimId = currentAnimationId;
    currentAnimationId = @"";
    
    if ([delegate respondsToSelector:@selector(onCharacter:endsAnimation:)])
        [delegate onCharacter:self endsAnimation:oldAnimId];
}

-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait
{
    if (_wait && currentAnimationLength>0) {
        nextAnimationId = _animId;
        nextAnimationDoesLoop = _isLoopable;
        return;
    }
    
    _isPaused = NO;
    
    nextAnimationId = @"";
    nextAnimationDoesLoop = NO;
    
    intFrame = 0;
    _doesLoop = _isLoopable;
    currentAnimationId = _animId;
    
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }

    if (__FTCOPTIMIZED) {
        currentAnimEvent = [[self.externAnimationEventsTable objectForKey:_animId] eventsInfo];
        currentAnimationLength = [[self.externAnimationEventsTable objectForKey:_animId] frameCount];
    }else{
        currentAnimEvent = [[self.animationEventsTable objectForKey:_animId] eventsInfo];
        currentAnimationLength = [[self.animationEventsTable objectForKey:_animId] frameCount];
    }
    
    //    NSLog(@"PLAY ANIMATION - %@ CurrentAnimLength %i", _animId, currentAnimationLength);
    
    if ([delegate respondsToSelector:@selector(onCharacter:startsAnimation:)])
        [delegate onCharacter:self startsAnimation:_animId];
    
    // If animation has more than 1 frame reschedule update
    if ([self getDurationForAnimation:_animId] > 1) {
        if (!_isSchedulerRunning) {
            [scheduler_ scheduleSelector:@selector(handleScheduleUpdate:) forTarget:self interval:frameRate/1000 paused:NO];
        }
    }
}

-(FTCSprite *) getChildByName:(NSString *)_childname
{
    // build a predicate to look in the table what object has the propery _childname in .name
    return [self.childrenTable objectForKey:_childname];
}

-(NSString *) getCurrentAnimation
{
    return currentAnimationId;
}

-(int) getDurationForAnimation:(NSString *)_animationId
{
    if (__FTCOPTIMIZED) {
        return [[self.externAnimationEventsTable objectForKey:_animationId] frameCount];
    }else{
        return [[self.animationEventsTable objectForKey:_animationId] frameCount];
    }
}

-(void) addElement:(FTCSprite *)_element withName:(NSString *)_name atIndex:(int)_index
{
    [self addChild:_element z:_index];
    
    [_element setName:_name];
    [_name release]; //NOARC
    
    [self.childrenTable setValue:_element forKey:_name];
    //[_element release]; //NOARC NOTE: childrenTable no longer retains object, just reference

    //CCLOG(@"222: _elementRT:%d _nameRT:%d",_element.retainCount, _name.retainCount);
}

-(void) reorderChildren
{
    int totalChildren = self.childrenTable.count;
    [self.childrenTable.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self reorderChild:obj z:totalChildren-idx];
        
    }];
}

-(void) createCharacterFromXML:(NSString *)_xmlfile
{
    if ([FTCParser parseXML:_xmlfile toCharacter:self])
    {
        if (__FTCOPTIMIZED) {
            // Abel: Verificar si está creado
            self.externAnimationEventsTable = [[FTCCharacterInfo sharedInstance] getAnimationEventsForCharacter:_xmlfile];
            FTCharacterSizeInfo *sizeInfo = [[FTCCharacterInfo sharedInstance] getSizeInfoForCharacter:_xmlfile];
            [self setContentSize:sizeInfo.contentSize];
            [self setVirtualAnchorPoint:sizeInfo.anchorPoint];
        }
       
#warning OJO, PRUEBA
//        [self scheduleAnimation];
        

        if (kDebugFTC){
            [self addDebugGraphics];
        }
        
        return;
    }
    
    NSLog(@"FTCCharacter: There was an error parsing xmlFile: %@", _xmlfile);
}

-(void) scheduleAnimation
{
    [scheduler_ unscheduleAllSelectorsForTarget:self];
    [scheduler_ scheduleSelector:@selector(handleScheduleUpdate:) forTarget:self interval:frameRate/1000 paused:NO];
    _isSchedulerRunning = YES;
}

-(void) createCharacterFromXML:(NSString *)_xmlfile onCharacterComplete:(void(^)())completeHandler
{
    onComplete = completeHandler;
    return [self createCharacterFromXML:_xmlfile];
}

-(void) setFirstPose
{
    if ([self.delegate respondsToSelector:@selector(onCharacterCreated:)])
        [self.delegate onCharacterCreated:self];
    
    if (onComplete)
        onComplete();
}

-(void)addDebugGraphics{
    // Marcar el "Anchor Point": En realidad es el punto (0,0) del nodo raíz
    CCSprite *apSprite;
    CGSize size = CGSizeMake(10, 10);
    
    // NOTA IMPORTANTE!
    // Este mecanismo de crearse la textura y rellenarla ya no es válido porque ahora los FTCCharacter se añaden a
    // un batchNode, por lo que solo se dibujan los gráficos que estén en el atlas asociado al batchNode.
    
//    GLubyte *buffer = (GLubyte*)malloc(sizeof(GLubyte)*4);
//    for (int i = 0; i < 4; i++){
//        buffer[i] = 255;
//    }
//    CCTexture2D *tex = [CCTexture2D new];
//    [tex initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB888 pixelsWide:1 pixelsHigh:1 contentSize:size];
//    apSprite = [CCSprite node];
//    CGRect rect = CGRectMake(0,0,10,10);
//    [apSprite initWithTexture:tex rect:rect];
//    free(buffer);
    
    apSprite = [CCSprite spriteWithSpriteFrameName:@"dot.png"];
    apSprite.position = ccp(0, 0);
    apSprite.anchorPoint = ccp(0, 0);
    apSprite.scale = 5;
    apSprite.color = ccc3(255, 0, 0);
    [self addChild:apSprite z:10000];
    
    // Marcar el rectángulo que ocupa el character
//    tex = [CCTexture2D new];
//    [tex initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB888 pixelsWide:1 pixelsHigh:1 contentSize:size];
//    apSprite = [CCSprite node];
//    rect = CGRectMake(0,0, self.contentSize.width, self.contentSize.height);
//    [apSprite initWithTexture:tex rect:rect];
//    free(buffer);
    
    apSprite = [CCSprite spriteWithSpriteFrameName:@"dot.png"];
    apSprite.scaleX = self.contentSize.width*2;
    apSprite.scaleY = self.contentSize.height*2;
    apSprite.color = ccc3(0, 0, 255);
    apSprite.opacity = 128;
    apSprite.position = ccp(0, 0);
    apSprite.anchorPoint = self.virtualAnchorPoint;
    [self addChild:apSprite z:10001];

}

- (void) destroy{
    [self unscheduleAllSelectors]; // MEMFIX
    
    for (CCNode *child in self.children) { // MEMFIX
        [child stopAllActions];
    }
}

- (void) dealloc{
    [childrenTable release]; //NOARC
//    [suffix release];
    [animationEventsTable release]; //NOARC
    
    [super dealloc];
}

@end
