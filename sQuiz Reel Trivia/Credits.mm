//
//  Credits.m
//  TriviaMenu
//
//  Created by mark wong on 3/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Credits.h"


@implementation Credits
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Credits *layer = [Credits node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"CreditsMusic.aif" loop:YES];

        CCLayer *menuLayerTwo = [[CCLayer alloc] init];
		menuLayerTwo.position = ccp(0, 0);
        count = 0;
		[self addChild:menuLayerTwo z:2];
		
        CreditsArray = [[NSArray alloc] initWithObjects: @"Created By", @"Mark Wong\n&\nJames Wong", @"Programmed By", @"Mark Wong", @"Written By", @"James Wong\nMark Wong\nQistina Subri\nAdam Stacey", @"Special Thanks", @"Apple    Beta Testers\nMum & Dad    Bingyan Chang\nRaywenderlich.com    Cocos2D Forums", @"Fonts", @"Broadway BT\nOpen Sans", @"Powered By", @"Cocos2D", nil];
        CCSprite *backButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
        backButtonSelected.color = ccc3(150, 150, 150);
        backButtonSelected.opacity = 100;
        CCSprite *backButton = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
        backButton.opacity = 100;
		CCMenuItemSprite *pause = [CCMenuItemSprite itemFromNormalSprite:backButton selectedSprite:backButtonSelected target:self selector:@selector(backButton:)];
		pause.position = ccp(30, 30);

		CCMenu *menuTwo = [CCMenu menuWithItems:pause, nil];
		menuTwo.position = ccp(0, 0);
		[menuLayerTwo addChild:menuTwo z:4];

        [self nameStart];
        [self schedule:@selector(rollingCredits:) interval:4.1];
    }
    return self;
}

-(void) rollingCredits:(ccTime) dt {
    if (count >= [CreditsArray count]) {
        //[CreditsArray release];
        [name stopAllActions];
        [title stopAllActions];

        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
    }
    else {
        [title setString:[CreditsArray objectAtIndex:count]];
        [name setString:[CreditsArray objectAtIndex:count + 1]];  
        count = count + 2;
    }
}

-(void) backButton: (id) sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
}

- (void) nameStart {
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:1.0 opacity:0];
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:1.0 opacity:250];
    
    id delay = [CCDelayTime actionWithDuration:0.95];

    id delayHold = [CCDelayTime actionWithDuration:1.1];
    

    CCSequence *titleSequence = [CCSequence actions:delay, fadeIn, delayHold, fadeOut, nil];
    CCSequence *nameSequence = [CCSequence actions:[[delay copy] autorelease], [[fadeIn copy] autorelease], [[delayHold copy] autorelease], [[fadeOut copy] autorelease], nil];
    
    title = [CCLabelTTF labelWithString:@"Thank you for playing\nA Whizbang Game" fontName:@"OpenSans-Regular.ttf" fontSize:19.0 dimensions:CGSizeMake(480,80) hAlignment:kCCTextAlignmentCenter];

    title.opacity = 0;
    title.position = ccp(240, 210);
    title.color = ccc3(255,255,255);
    [self addChild:title];
    name = [CCLabelTTF labelWithString:@"" fontName:@"OpenSans-Bold" fontSize:24.0 dimensions:CGSizeMake(480,160) hAlignment:kCCTextAlignmentCenter];
    name.opacity = 0;
    name.position = ccp(240, 135);
    name.color = ccc3(255,255,255);
    [self addChild:name];

    [title runAction:[CCRepeatForever actionWithAction:titleSequence]];

    [name runAction:[CCRepeatForever actionWithAction:nameSequence]];
}


- (void) dealloc
{
    [CreditsArray release];
    CreditsArray = nil;
    
	[super dealloc];
    
}
@end
