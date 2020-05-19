//
//  SplashScreen.m
//  TriviaMenu
//
//  Created by mark wong on 12/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplashScreen.h"
#import "DeviceFile.h"
#import "GKAchievementHandler.h"
#import "GKAchievementNotification.h"

@implementation SplashScreen

+(id) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	SplashScreen *layer = [SplashScreen node];
	// add layer as a child to scene
	[scene addChild: layer];
	//[scene addChild: scoreLayer];
	// return the scene
	return scene;
}

-(id) init {
	if( (self = [super init] )) {
		CCSprite *splashBG = [CCSprite spriteWithFile:@"TitleScreen.png"];
		splashBG.position = ADJUST_XY(240, 160); //ccp(240,160);
		[self addChild:splashBG];

        CCLabelTTF *startFlash = [CCLabelTTF labelWithString:@"Start" fontName:@"Broadway BT" fontSize:40];
        startFlash.position = ADJUST_XY(240, 100);//ccp(240, 100);
        [self addChild:startFlash];
        
		CCSequence *startSequence = [CCSequence actions:[CCFadeTo actionWithDuration:0.6 opacity:140], [CCFadeTo actionWithDuration:0.5 opacity:0], [CCDelayTime actionWithDuration:0.5], nil];
		CCRepeatForever *repeat = [CCRepeatForever actionWithAction:startSequence];
		[startFlash runAction:repeat];

        //cache countdown sprites, main menu, music, sound
        
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.3f scene:[mainMenu scene]]];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
	
    return TRUE;    
}

-(void) dealloc {
	[super dealloc];
}
@end
