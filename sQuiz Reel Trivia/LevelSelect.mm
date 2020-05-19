//
//  Singleplayer.m
//  Trivia
//
//  Created by mark wong on 12/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LevelSelect.h"

#define MENU_SELECT_FORWARD @"MenuSelectForward.caf"
#define MENU_SELECT_BACK @"MenuSelectBack.caf"

#define BMFONTREGULAR @"OpenSans-Regular.fnt"
#define BMFONTBOLD12 @"OpenSans-Bold12.fnt"
#define TTFBOLD @"OpenSans-Regular.ttf"
#define TTFREGULAR @"OpenSans-Bold.ttf"

@implementation LevelSelect
static int save;

+(id) scene:(int) saveSlot {
	
	save = saveSlot;
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelSelect *layer = [LevelSelect node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

-(void) SoundSettings {
    
    SettingsManager *soundSettings = [SettingsManager sharedSettingsManager];
    [soundSettings loadFromFileInLibraryDirectory:@"SoundSettings.plist"];
    BOOL fileCreated = [soundSettings getBool:@"FileCreated"];
    
    if (fileCreated) {
        NSLog(@"sound %d", [soundSettings getBool:@"Sound"]);
        SFX = [soundSettings getBool:@"Sound"];
        BGM = [soundSettings getBool:@"Music"];
    }
    else {
        [soundSettings setBool:TRUE keyString:@"Sound"];
        [soundSettings setBool:TRUE keyString:@"Music"];
        [soundSettings setBool:TRUE keyString:@"FileCreated"];
        [soundSettings saveToFileInLibraryDirectory:@"SoundSettings.plist"];
    }
}

-(id) init {
	if ((self = [super init])) {
		id target = self;
        [self SoundSettings];
        
        if (BGM) {
            if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && BGM) {
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuMusic.m4a" loop:YES];
            }
        }
        else {
            [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
        }

        
        if (SFX) {
            [SimpleAudioEngine sharedEngine].effectsVolume = 1;
        }
        else {
            [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        }
        
        
        
        page = 1;
        
        levelSelectSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"LevelSelectSpriteSheet.pvr"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelSelectSpriteSheet.plist" texture:levelSelectSpriteSheet];
        CCMenuItemSprite *nowShowing2;
        CCMenuItemSprite *nowShowing3;
        
        [self levelChecks];
        
        GameLayer = [[CCLayer alloc] init];
        [self addChild:GameLayer z:1];
        TutorialLayer = [[CCLayer alloc] init];
        [self addChild:TutorialLayer z:2];
        

        
		CCSprite* menuBGPage1 = [CCSprite spriteWithSpriteFrameName:@"LevelSelectBG.png"];
		menuBGPage1.position = ccp(240, 160);
        menuBGPage1.scale = 1.01;
		[GameLayer addChild:menuBGPage1];
		
        CCSprite *greyBackground = [CCSprite spriteWithSpriteFrameName:@"BackgroundGrey.png"];
        greyBackground.position = ccp(240, 180);
        [GameLayer addChild:greyBackground];
        
		CCSprite* level1SpriteSelected = [CCSprite spriteWithSpriteFrameName:@"Level1.png"];
        level1SpriteSelected.color = ccc3(130, 130, 130);
		level1Page1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Level1.png"] selectedSprite:level1SpriteSelected target:target selector:@selector(LaunchLevel:)];
		level1Page1.position = ccp(85, 155);
		level1Page1.tag = 1;
              
        
        
        /*********FIX THIS*************/
		if (FALSE) {

            CCSprite* level2SpriteSelected = [CCSprite spriteWithSpriteFrameName:@"LockedLevel.png"];

            level2SpriteSelected.color = ccc3(130, 130, 130);
            level2Page1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LockedLevel.png"] selectedSprite:level2SpriteSelected target:target selector:@selector(LaunchLevel:)];
            level2Page1.position = ccp(240, 155);
            level2Page1.tag = 1;
            [level2Page1 setIsEnabled:FALSE];

            nowShowing2 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Coming Soon.png"] selectedSprite:nil target:nil selector:nil];

        }
        else {

            CCSprite* level2SpriteSelected = [CCSprite spriteWithSpriteFrameName:@"Level2.png"];

            level2SpriteSelected.color = ccc3(130, 130, 130);
            level2Page1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Level2.png"] selectedSprite:level2SpriteSelected target:target selector:@selector(LaunchLevel:)];
            level2Page1.position = ccp(240, 155);
            level2Page1.tag = 2;
            [level2Page1 setIsEnabled:TRUE];

            nowShowing2 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Now Showing.png"] selectedSprite:nil target:nil selector:nil];

        }
        
        if (FALSE) {

            CCSprite* level3SpriteSelected = [CCSprite spriteWithSpriteFrameName:@"LockedLevel.png"];

            level3SpriteSelected.color = ccc3(130, 130, 130);
            level3Page1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"LockedLevel.png"] selectedSprite:level3SpriteSelected target:target selector:@selector(LaunchLevel:)];
            level3Page1.position = ccp(394, 155);
            level3Page1.tag = 3;
            [level3Page1 setIsEnabled:FALSE];
            nowShowing3 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Coming Soon.png"] selectedSprite:nil target:nil selector:nil];

        }
        else {

            CCSprite* level3SpriteSelected = [CCSprite spriteWithSpriteFrameName:@"Level3.png"];

            level3SpriteSelected.color = ccc3(130, 130, 130);
            level3Page1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Level3.png"] selectedSprite:level3SpriteSelected target:target selector:@selector(LaunchLevel:)];
            level3Page1.position = ccp(394, 155);
            level3Page1.tag = 3;

            
            nowShowing3 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Now Showing.png"] selectedSprite:nil target:nil selector:nil];

        }

		CCMenu *menuPage1 = [CCMenu menuWithItems:level1Page1, level2Page1, level3Page1, nil];
        menuPage1.position = ccp(240, 180);
        [menuPage1 alignItemsHorizontallyWithPadding:15.0f];
		[GameLayer addChild:menuPage1 z:1];
        
        CCMenuItemSprite *nowShowing1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Now Showing.png"] selectedSprite:nil target:nil selector:nil];
        
        
        CCMenu *nowShowingTitles = [CCMenu menuWithItems:nowShowing1, nowShowing2, nowShowing3, nil];
        nowShowingTitles.position = ccp(240, 230);
        [nowShowingTitles alignItemsHorizontallyWithPadding:50.0f];
		[GameLayer addChild:nowShowingTitles z:1];
        
        CCSprite *backButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
        backButtonSelected.color = ccc3(150, 150, 150);
        CCMenuItemSprite *backButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:backButtonSelected target:self selector:@selector(back:)];
        backButton.position = ccp(30, 30);
        backButton.scale = 0.9;
        
        CCMenu *escapeMenu = [CCMenu menuWithItems:backButton, nil];
        escapeMenu.position = ccp(0, 0);
        [GameLayer addChild:escapeMenu z:4];
        
        //[self tutorialPage1];
	}
	return self;
}




-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

    page++;

    switch (page) {
        case 2:
            [tutorialText runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(tutorialPage2:)], [CCFadeIn actionWithDuration:0.5f], nil ]];
            break;
        case 3:
            [gameTint runAction:[CCFadeTo actionWithDuration:1.0f opacity:0]];
            
            [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
            [tutorialBG runAction:[CCFadeOut actionWithDuration:1.0f]];
            [tutorialText runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
            [TouchToContinue stopAllActions];
            [TouchToContinue runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
            //[GameLayer removeChild:gameTint cleanup:YES];
            [level1Page1 setIsEnabled:TRUE];
            [level2Page1 setIsEnabled:TRUE];
            [level3Page1 setIsEnabled:TRUE];
            break;
        default:
            break;
    }
    
}

/*        case 3:
 [tutorialText runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(tutorialPage2:)], [CCFadeIn actionWithDuration:0.5f], nil ]];
 break; */

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    return TRUE;    
}



-(void) tutorialPage1 {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];


    [level1Page1 setIsEnabled:FALSE];
    [level2Page1 setIsEnabled:FALSE];
    [level3Page1 setIsEnabled:FALSE];

    gameTint = [CCLayerColor layerWithColor:ccc4(10, 10, 10, 170)];
    [GameLayer addChild:gameTint z:10];
    
    tutorialBG = [CCSprite spriteWithSpriteFrameName:@"AlertBG.png"];
    tutorialBG.scale = 0.9;
    
    tutorialBG.position = ccp(240, 160);
    [TutorialLayer addChild: tutorialBG];
    //"Welcome to sQuiz: Reel Trivia\n\nThere are 3 levels to play with 9 categories to explore."
    //"
    tutorialText = [CCLabelBMFontMultiline labelWithString:@"Welcome to sQuiz: Reel Trivia\n\n There are 3 levels to play, along with 9 popular categories to explore.\n\n " fntFile:BMFONTBOLD12 width:280 alignment:UITextAlignmentCenter];
    //tutorialTextBMTest.scale = 0.7;
    tutorialText.position = ccp(240, 160);
    [TutorialLayer addChild:tutorialText];
    
    TouchToContinue = [CCLabelTTF labelWithString:@"Touch To Continue" fontName:@"OpenSans-Bold.ttf" fontSize:20];
    TouchToContinue.tag = 12;
    TouchToContinue.position = ccp(240, 50);
    
    [TutorialLayer addChild:TouchToContinue];
    
    [TouchToContinue runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], [CCFadeIn actionWithDuration:1.0f], nil]]];
}

-(void) tutorialPage2:(id) sender {
    [tutorialText setString:@"Playing a higher level will earn you more points.\n\nAnswering more than one question in a row will also award a greater amount of points.\n\n "];
}

-(void) tutorialPage3:(id) sender {
    [tutorialText setString:@"Second, select one of the three genres, Action, Comedy or Drama\n\n You'll be asked 10 questions in each round. The more questions"];
}

-(void) levelChecks {
        
	SettingsManager *settingsManagerSlot = [SettingsManager sharedSettingsManager];
	[settingsManagerSlot loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    isLevel2Locked = [settingsManagerSlot getBool:@"Level2Lock"];
    isLevel3Locked = [settingsManagerSlot getBool:@"Level3Lock"];
}


-(void) back: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];

    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"LevelSelectSpriteSheet.plist"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
}

-(void) LaunchLevel: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

	UIButton *button = (UIButton*) sender;

	if (button.tag == 1) {
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryMenu scene:save lvl:1]]];
	}
	if (button.tag == 2) {

		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryLevel2 scene:save lvl:2]]];
	}
	if (button.tag == 3) {
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryLevel3 scene:save lvl:3]]];
	}
}

- (void) dealloc {
    
    [TutorialLayer release];
    [GameLayer release];
    [super dealloc];
}
@end
