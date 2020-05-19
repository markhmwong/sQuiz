//
//  mainMenu.m
//  Trivia
//
//  Created by mark wong on 20/05/11.
//  Copyright 2011 . All rights reserved.
//
/*fb stuff*/
//App ID:	273861459315328
//App Secret:	ad67d51f29bc9e90857f6ac422498f9f

#import "mainMenu.h"
#import "DeviceFile.h"
#import "GKAchievementHandler.h"
#import "GKAchievementNotification.h"
//#import "RootViewController.h"

#define SlotOneLabelNameTag 101
#define SlotTwoLabelNameTag 102
#define SlotThreeLabelNameTag 103

#define SlotOneLabelNumberTag 111
#define SlotTwoLabelNumberTag 112
#define SlotThreeLabelNumberTag 113

#define SlotOneNewGameTag 121
#define SlotTwoNewGameTag 122
#define SlotThreeNewGameTag 123

#define QUICKPLAY_EASY 131
#define QUICKPLAY_MEDIUM 132
#define QUICKPLAY_HARD 133

#define MENU_SELECT_FORWARD @"MenuSelectForward.caf"
#define MENU_SELECT_BACK @"MenuSelectBack.caf"

#define FACT_FONT @"OpenSans-Regular.ttf"
#define FACT_FNT @"OpenSans-Regular13.fnt"


@implementation mainMenu
/*
@synthesize gameCenterManager;
@synthesize currentScore;
@synthesize currentLeaderBoard;
@synthesize currentScoreLabel;
@synthesize gameCenterViewController;
*/
+(id) scene
{
	CCScene *scene = [CCScene node];
	
	mainMenu *layer = [mainMenu node];
	
	[scene addChild: layer];
	
	return scene;
}

- (void) showLeaderBoardGameCenter:(NSString *) leaderboardKey {
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
        if ([leaderboardKey isEqualToString:@"nil"]) {
            NSLog(@"nil");
            leaderboardController.category = nil;
            leaderboardController.leaderboardDelegate = self; 
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            [delegate.viewController presentModalViewController:leaderboardController animated:YES];
        }
        else {
            leaderboardController.category = leaderboardKey;
            leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
            leaderboardController.leaderboardDelegate = self; 
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            [delegate.viewController presentModalViewController:leaderboardController animated:YES];
        }
	}
}

-(void) showAchievements {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != NULL) {
        achievements.achievementDelegate = self;
        [delegate.viewController presentModalViewController:achievements animated:YES];
    }
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.viewController dismissModalViewControllerAnimated:YES];
    [viewController release];
}


- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *) viewController
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
	[delegate.viewController dismissModalViewControllerAnimated:YES];
	[viewController release];
}

- (void) cameraFlash:(ccTime)dt {
    
    randomNumber = arc4random() % 8 + 1;

    CCSequence *flashSequenceFlashOne = [CCSequence actions:[CCDelayTime actionWithDuration:0.3], [CCScaleTo actionWithDuration:0.07 scale:1.0f], [CCScaleTo actionWithDuration:0.17 scale:0.0f], nil];
    CCSequence *flashSequenceFlashTwo = [CCSequence actions:[CCDelayTime actionWithDuration:0.4], [CCScaleTo actionWithDuration:0.07 scale:1.0f], [CCScaleTo actionWithDuration:0.17 scale:0.0f], nil];
    if (randomNumber == 1) {
        flash1.position = ADJUST_XY(40, 130);//ccp(40, 130);
        [flash1 runAction:flashSequenceFlashOne];
    }
    if (randomNumber == 2) {
        flash2.position = ADJUST_XY(48, 80);//ccp(48, 80);
        [flash2 runAction:flashSequenceFlashOne];
    }
    if (randomNumber == 3) {
        flash3.position = ADJUST_XY(240, 160);//ccp(240, 160);
        [flash3 runAction:flashSequenceFlashOne];
    }
    if (randomNumber == 4) {
        flash1.position = ADJUST_XY(440, 150);//ccp(440, 150);
        [flash1 runAction:flashSequenceFlashOne];
    }	
    if (randomNumber == 5) {
        flash2.position = ADJUST_XY(460, 100);//ccp(460, 100);
        [flash2 runAction:flashSequenceFlashOne];
    }
    if (randomNumber == 6) {
        flash2.position = ADJUST_XY(440, 130);//ccp(440, 130);
        flash1.position = ADJUST_XY(450, 170);//ccp(450, 170);
        [flash2 runAction:flashSequenceFlashOne];
        [flash1 runAction:flashSequenceFlashTwo];
    }
    if (randomNumber == 7) {
        flash2.position = ADJUST_XY(160, 130);//ccp(160, 130);
        flash3.position = ADJUST_XY(80, 150);//ccp(80, 150);
        [flash2 runAction:flashSequenceFlashOne];
        [flash3 runAction:flashSequenceFlashTwo];
    }
    if (randomNumber == 8) {
        flash1.position = ADJUST_XY(380, 120);//ccp(380, 120);
        flash3.position = ADJUST_XY(210, 140);//ccp(210, 140);
        [flash1 runAction:flashSequenceFlashOne];
        [flash3 runAction:flashSequenceFlashTwo];
    }
}

-(void) shiningLights {

    float tempCoord = 0;
    for (int i = 0; i <= 28; i++) {
        tempCoord = (16.43 * i) + 10;
        //[self spawnLight:ccp(tempCoord, 240) spriteTag:i];
        [self spawnLight:ADJUST_XY(tempCoord, 240) spriteTag:i];

    }
    /*[self spawnLight:ccp(470, 257.5) spriteTag:29];
    [self spawnLight:ccp(470, 275.22) spriteTag:30];
    [self spawnLight:ccp(470, 292.94) spriteTag:31];*/
    [self spawnLight:ADJUST_XY(470, 257.5) spriteTag:29];
    [self spawnLight:ADJUST_XY(470, 275.22) spriteTag:30];
    [self spawnLight:ADJUST_XY(470, 292.94) spriteTag:31];
    //[self spawnLight:ccp(470, 310) spriteTag:32];
    
    tempCoord = 0;
    int multiplier = 0;
    for (int i = 32; i <= 60; i++) {
        tempCoord = 470 - (16.43 * multiplier);
        //[self spawnLight:ccp(tempCoord, 310) spriteTag:i];
        [self spawnLight:ADJUST_XY(tempCoord, 310) spriteTag:i];

        multiplier++;
    }
    
    /*[self spawnLight:ccp(10, 292.94) spriteTag:61];
    [self spawnLight:ccp(10, 275.22) spriteTag:62];
    [self spawnLight:ccp(10, 257.5) spriteTag:63];
    */
    [self spawnLight:ADJUST_XY(10, 292.94) spriteTag:61];
    [self spawnLight:ADJUST_XY(10, 275.22) spriteTag:62];
    [self spawnLight:ADJUST_XY(10, 257.5) spriteTag:63];
    //get even and odd lights
    [self getEvenOddLight];
}


-(void)getEvenOddLight {

    for (int i = 0; i <= 63; i++) {
        CCSprite *sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite.tag % 2) {
            [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.4f], nil]]];
        }
        else {
            [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.4f], [CCFadeOut actionWithDuration:0.6f], nil]]];
        }
    }
}

-(void) spawnLight: (CGPoint) position spriteTag:(int)_tag {
    CCSprite *light = [CCSprite spriteWithSpriteFrameName:@"Light.png"];
    light.position = position;
    light.tag = _tag;
    [self addChild:light z:2];
}

/*
- (void) GameCenter {
	if ([GameCenterManager isGameCenterAvailable]) {
		
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
		
	} 
    else {
		
		// The current device does not support Game Center.
        
	}
}
*/

-(id) init {
	if ((self = [super init])) {
        
        [self SoundSettings];
        //[[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"A Beautiful Mind" andMessage:@"Get 10 questions in a row correct!"];

        buttonsEffects = [[CCTextureCache sharedTextureCache] addImage:SD_HD_PVR(@"ButtonsEffects.pvr")];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_HD_PLIST(@"ButtonsEffects.plist") texture:buttonsEffects];
        //gameplayButtons = [[CCTextureCache sharedTextureCache] addImage:@"GamePlayButtonsSpriteSheet.pvr"];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GamePlayButtonsSpriteSheet.plist" texture:gameplayButtons];
        
        mainMenuSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"MainMenuSS.pvr"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MainMenuSS.plist" texture:mainMenuSpriteSheet];
        
        if (SFX) {
            [SimpleAudioEngine sharedEngine].effectsVolume = 1.0f;
        }
        else {
            [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        }
        
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuMusic.aif" loop:YES];
            if (BGM) {
                [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
            }
            else {
                [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
    
            }
        }        
        
        //CCSprite *fb = [CCSprite spriteWithFile:@"f_logo.png"];
        //fb.position = ccp(450, 20);
        //[self addChild:fb z:2];
        
		menuLayer = [[CCLayer alloc] init];
		menuLayer.position = ccp(0, 0);
		[self addChild:menuLayer z:2];
        
        [self shiningLights];

        CCSprite *backGround = [CCSprite spriteWithSpriteFrameName:@"MainMenuBG.png"];
        //ADJUST_XY( kScreenWidth*0.7f , kScreenHeight*0.4f );
		backGround.position = ADJUST_XY(240, 160);//ccp(240, 160);
		[self addChild:backGround z:1];
        
        CCSprite *SinglePlayerButtonSelected = [CCSprite spriteWithSpriteFrameName:@"AdmitOne.png"];
        SinglePlayerButtonSelected.color = ccc3(130, 130, 130);
        SinglePlayerButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"AdmitOne.png"] selectedSprite:SinglePlayerButtonSelected target:self selector:@selector(Singleplayer:)];
        SinglePlayerButton.position = ADJUST_XY(144, 172);//ccp(144, 172);        

        CCSprite *QuickPlayButtonSelected = [CCSprite spriteWithSpriteFrameName:@"QuickPlay.png"];
        QuickPlayButtonSelected.color = ccc3(130, 130, 130);
        
        QuickPlayButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"QuickPlay.png"] selectedSprite:QuickPlayButtonSelected target:self selector:@selector(Quickplay:)];
        QuickPlayButton.position = ADJUST_XY(336, 172);//ccp(336, 172);
        
        /*
        MultiPlayerButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"MainMenuCredits.png"] selectedSprite:nil target:self selector:@selector(Multiplayer:)];
		MultiPlayerButton.position = ccp(336, 192);
        */
		//Options = [CCMenuItemImage itemFromNormalImage:@"Options_3G.png" selectedImage:@"Options_3G.png" target:self selector:@selector(Options:)];
		//Options.position = ccp((win.width/10) * 3, (win.height/20) * 7.5);
		
        CCSprite *CreditsButtonSelected = [CCSprite spriteWithSpriteFrameName:@"Credits.png"];
        CreditsButtonSelected.color = ccc3(130, 130, 130);
		CreditsButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Credits.png"] selectedSprite:CreditsButtonSelected target:self selector:@selector(Credits:)];
		CreditsButton.position = ADJUST_XY(336, 110);//ccp(240, 110);

        CCSprite *StatsButtonSelected = [CCSprite spriteWithSpriteFrameName:@"StatsButton2.png"];
        StatsButtonSelected.color = ccc3(130, 130, 130);
        StatsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"StatsButton2.png"] selectedSprite:StatsButtonSelected target:self selector:@selector(stats:)];
        StatsButton.position = ADJUST_XY(144, 110);
        
		menu = [CCMenu menuWithItems:SinglePlayerButton, QuickPlayButton, CreditsButton, StatsButton, nil];
		menu.position = ccp(0, 0);
		[menuLayer addChild:menu z:4];
        ReelFactBG = [CCSprite spriteWithSpriteFrameName:@"ReelFactsBG.png"];
        ReelFactBG.position = ADJUST_XY(240, 30);//ccp(240, 30);
        ReelFactBG.opacity = 0;
        [self addChild:ReelFactBG z:1];

        flash1 = [CCSprite spriteWithSpriteFrameName:@"FlashBlue.png"];
        flash1.scale = 0.0f;
        
        flash2 = [CCSprite spriteWithSpriteFrameName:@"FlashGreen.png"];
        flash2.scale = 0.0f;
        
        flash3 = [CCSprite spriteWithSpriteFrameName:@"FlashYellow.png"];
        flash3.scale = 0.0f;

        //factTitle = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(100, 14) alignment:UITextAlignmentCenter fontName:FACT_FONT fontSize:10];
        factTitle = [CCLabelBMFont labelWithString:@"" fntFile:SD_HD_FONT(FACT_FNT)];
        factTitle.opacity = 0;
        factTitle.position = ADJUST_XY(240, 45);//ccp(240, 45);
        factTitle.color = ccc3(0, 0, 0);
        [self addChild:factTitle z:4];
        
        //fact = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(324, 30) alignment:UITextAlignmentCenter fontName:FACT_FONT fontSize:10];

        //fact = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(324, 30) alignment:UITextAlignmentCenter fontName:SD_HD_FONT(FACT_FNT) fontSize:10];
//        fact = [CCLabelBMFontMultiline labelWithString:@"" fntFile:FACT_FNT width:ADJUST_X(400) alignment:kCCTextAlignmentCenter];
//        fact.opacity = 0;
//        fact.scale = 0.80;
//        fact.position = ADJUST_XY(240, 23);
//        fact.color = ccc3(0, 0, 0);

        slotOneLayer = [[CCLayer alloc] init];
        slotTwoLayer = [[CCLayer alloc] init];
        slotThreeLayer = [[CCLayer alloc] init]; 
        
        NewGameLabelSlotOne = [CCLabelTTF labelWithString:@"" fontName:@"Broadway BT" fontSize:30];
        NewGameLabelSlotOne.position = ADJUST_XY(240, 160);
        NewGameLabelSlotOne.tag = SlotOneNewGameTag;
        NewGameLabelSlotOne.color = ccc3(0, 0, 0);
        NewGameLabelSlotOne.opacity = 0;
        [slotOneLayer addChild:NewGameLabelSlotOne z:5];
        
        NewGameLabelSlotTwo = [CCLabelTTF labelWithString:@"" fontName:@"Open Sans" fontSize:30];
        NewGameLabelSlotTwo.position = ccp(240, 160);
        NewGameLabelSlotTwo.tag = SlotTwoNewGameTag;
        NewGameLabelSlotTwo.color = ccc3(0, 0, 0);
        [slotTwoLayer addChild:NewGameLabelSlotTwo z:5];
        
        NewGameLabelSlotThree = [CCLabelTTF labelWithString:@"" fontName:@"Broadway BT" fontSize:30];
        NewGameLabelSlotThree.position = ccp(240, 160);
        NewGameLabelSlotThree.tag = SlotThreeNewGameTag;
        NewGameLabelSlotThree.color = ccc3(0, 0, 0);
        [slotThreeLayer addChild:NewGameLabelSlotThree z:5];
        
        CCSprite *SettingsButtonSelected = [CCSprite spriteWithSpriteFrameName:@"SettingsButton.png"];
        SettingsButtonSelected.color = ccc3(150, 150, 150);
        SettingsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SettingsButton.png"] selectedSprite:SettingsButtonSelected target:self selector:@selector(settings:)];
        SettingsButton.position = ADJUST_XY(455, 30);//ccp(455, 30);
        
        CCMenu *settingsMenu = [CCMenu menuWithItems:SettingsButton, nil];
        settingsMenu.position = ccp(0, 0);
        [self addChild:settingsMenu z:5];
        
        BGMButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BGMOn.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"BGMOff.png"] target:self selector:@selector(BGM:)];
        BGMButton.scale = 0.8;
        
        if (!BGM) {
            [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOff.png"]];
        }
        SFXButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SFXOn.png"] selectedSprite:nil target:self selector:@selector(SFX:)];
        if (!SFX) {
            [SFXButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"SFXOff.png"]];
        }
        SFXButton.scale = 0.8;
        BGMButton.position = ADJUST_XY(520, 80);//ccp(510, 80);
        SFXButton.position = ADJUST_XY(520, 125);//ccp(510, 125);
        CCMenu *SoundMenu = [CCMenu menuWithItems:BGMButton, SFXButton, nil];
        SoundMenu.position = ccp(0, 0);
        [self addChild:SoundMenu z:6];
        
//        [self addChild:fact z:4];
        [self openReelFactsDatabase];
        [self openScoringDatabase];
        [self fadeInReelFacts];
        [self addChild:flash1 z:1];
        [self addChild:flash2 z:1];
        [self addChild:flash3 z:1];
	}
    
    [self schedule:@selector(cameraFlash:) interval:2.5];
	return self;
}

-(void)settings:(id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    settingsMenuOn = !settingsMenuOn;
    if (settingsMenuOn) {
        [BGMButton runAction:[CCMoveTo actionWithDuration:0.5f position:ADJUST_XY(455, 80)]];
        [SFXButton runAction:[CCMoveTo actionWithDuration:0.5f position:ADJUST_XY(455, 125)]];
    }
    else {
        [BGMButton runAction:[CCMoveTo actionWithDuration:0.5f position:ADJUST_XY(520, 80)]];
        [SFXButton runAction:[CCMoveTo actionWithDuration:0.5f position:ADJUST_XY(520, 125)]];
    }
}

-(void) stats:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    [QuickPlayButton runAction:[CCFadeOut actionWithDuration:1.0f]];
    [CreditsButton runAction:[CCFadeOut actionWithDuration:1.0f]];
    [SinglePlayerButton runAction:[CCFadeOut actionWithDuration:1.0f]];
    [StatsButton runAction:[CCFadeOut actionWithDuration:1.0f]];
    [fact runAction:[CCFadeOut actionWithDuration:1.0f]];
    [factTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
    [ReelFactBG runAction:[CCFadeOut actionWithDuration:1.0f]];
    
    CCMenuItemSprite *stats = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ScoresButton.png"] selectedSprite:nil target:self selector:@selector(showLeaderBoard:)];
    stats.opacity = 0;
    stats.position = ccp(144, 172);
    
    CCMenuItemSprite *achievements = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"AchievementsButton.png"] selectedSprite:nil target:self selector:@selector(showAchievements)];
    achievements.opacity = 0;
    achievements.position = ccp(336, 172);
    
    CCSprite *backButtonSelect = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
    backButtonSelect.color = ccc3(130, 130, 130);
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:nil target:self selector:@selector(back:)];
    backButton.position = ccp(30, 30);
    
    CCMenu *statsMenu = [CCMenu menuWithItems:stats, achievements, backButton, nil];
    statsMenu.position = ccp(0, 0);
    [self addChild:statsMenu z:1];
    [statsMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCFadeIn actionWithDuration:1.0f], nil]];
}

-(void) showLeaderBoard:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    [self showLeaderBoardGameCenter:@"nil"];
}

- (void) BGM:(id) sender {
    BGM = !BGM;
    SettingsManager *BGMSettings = [SettingsManager sharedSettingsManager];
    
    if (BGM) {
        [BGMSettings setBool:TRUE keyString:@"Music"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOn.png"]];
    }
    else {
        [BGMSettings setBool:FALSE keyString:@"Music"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOff.png"]];
    }
    [BGMSettings saveToFileInLibraryDirectory:@"SoundSettings.plist"];
}

- (void) SFX:(id) sender {
    SFX = !SFX;
    SettingsManager *SFXSettings = [SettingsManager sharedSettingsManager];

    if (SFX) {
        [SFXSettings setBool:TRUE keyString:@"Sound"];
        [SimpleAudioEngine sharedEngine].effectsVolume = 1.0;
        [SFXButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"SFXOn.png"]];
    }
    else {
        [SFXSettings setBool:FALSE keyString:@"Sound"];
        [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        [SFXButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"SFXOff.png"]];
    }
    [SFXSettings saveToFileInLibraryDirectory:@"SoundSettings.plist"];
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
        SFX = [soundSettings getBool:@"Sound"];
        BGM = [soundSettings getBool:@"Music"];    
    }
}


/**CREATE SLOT DATABASES**/

- (void) openSlotDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Slot%d.sqlite", scroller.currentScreen+1]];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Slot%d.sqlite", scroller.currentScreen+1]];
	
	BOOL forceRefresh = FALSE;
	
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	if (!success || forceRefresh) {
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		//NSLog(@"initial creation of writable database (%@) from resources database (%@)", writableDBPath, defaultDBPath);
	}
	
	slotDb = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([slotDb open]) {
		
		[slotDb setTraceExecution: FALSE];
		[slotDb setLogsErrors: TRUE];
		
		databaseOpenedSlot = TRUE;
		
		[slotDb setShouldCacheStatements:FALSE];
		
	} else {
        databaseOpenedSlot = FALSE;
    }
}

- (void) openScoringDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:@"Scoring.sqlite"];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Scoring.sqlite"];
	
	//BOOL forceRefresh = FALSE;
	
	//success = [fileManager fileExistsAtPath:writableDBPath];
    [fileManager removeItemAtPath:writableDBPath error:&error];

	//if (!success || forceRefresh) {
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		//NSLog(@"initial creation of writable database (%@) from resources database (%@)", writableDBPath, defaultDBPath);
	//}
	
	scoringDb = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([scoringDb open]) {
		
		[scoringDb setTraceExecution: FALSE];
		[scoringDb setLogsErrors: TRUE];
		
		databaseOpenedScores = TRUE;
		
		[scoringDb setShouldCacheStatements:FALSE];
		
	} else {
        databaseOpenedScores = FALSE;
    }
}

- (void) openReelFactsDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:@"MainScreenFacts.sqlite"];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MainScreenFacts.sqlite"];
	
	//BOOL forceRefresh = FALSE;
	
	//success = [fileManager fileExistsAtPath:writableDBPath];
    [fileManager removeItemAtPath:writableDBPath error:&error];

	//if (!success || forceRefresh) {
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		//NSLog(@"initial creation of writable database (%@) from resources database (%@)", writableDBPath, defaultDBPath);
	//}
	
	reelFactsDb = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([reelFactsDb open]) {
		
		[reelFactsDb setTraceExecution: FALSE];
		[reelFactsDb setLogsErrors: TRUE];
		
		databaseOpened = TRUE;
		
		[reelFactsDb setShouldCacheStatements:FALSE];
		
	} else {
        databaseOpened = FALSE;
    }
}

-(void) fadeInReelFacts {

    NSString *factString = @"";
    int randomFact = arc4random() % 34 + 1;
    FMResultSet *factQuery = [reelFactsDb executeQuery:@"SELECT fact FROM MainScreenFacts WHERE rowid = ?", [NSNumber numberWithInt:randomFact]];
    if ([factQuery next]) {
        factString = [factQuery stringForColumn:@"fact"];
    }
    [factTitle setString:@"Reel Fact"];
    [fact setString:factString];
    [factTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
    [fact runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
    [ReelFactBG runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
}

-(void)Credits: (id)sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[Credits scene]]];
}

-(void)back: (id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
}

-(void)Singleplayer: (id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    
    [menu runAction:[CCFadeOut actionWithDuration:0.6]];
    [fact runAction:[CCFadeOut actionWithDuration:0.4]];
    [factTitle runAction:[CCFadeOut actionWithDuration:0.4]];
    [ReelFactBG runAction:[CCFadeOut actionWithDuration:0.4]];
    
    [SinglePlayerButton setIsEnabled:NO];
    [CreditsButton setIsEnabled:NO];
    [QuickPlayButton setIsEnabled:NO];
    
    [self loadSlotOne];

    [[SettingsManager sharedSettingsManager] logSettings];
    
    [self loadSlotTwo];
    [self saveSlotTwo];
    [[SettingsManager sharedSettingsManager] logSettings];  
    
    [self loadSlotThree];
    [self saveSlotThree];
    [[SettingsManager sharedSettingsManager] logSettings];  
    
    int checkSlotOne = [self checkSlotOne];
    int checkSlotTwo = [self checkSlotTwo];
    int checkSlotThree = [self checkSlotThree];   
        
    CCMenuItemSprite *backButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:nil target:self selector:@selector(back:)];
    backButton.opacity = 0;
    backButton.position = ADJUST_XY(30, 30);//ccp(30, 30);
    backButton.scale = 0.9;
    
    CCSprite *deleteButtonSelected = [CCSprite spriteWithSpriteFrameName:@"DeleteButton.png"];
    deleteButtonSelected.color = ccc3(150, 150, 150);
    deleteButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"DeleteButton.png"] selectedSprite:deleteButtonSelected target:self selector:@selector(deleteSlotOne:)];
    deleteButton.opacity = 0;
    deleteButton.position = ADJUST_XY(240, 30);//ccp(160, 30);
    
    CCSprite *statsButtonSelected = [CCSprite spriteWithSpriteFrameName:@"StatsButton.png"];
    statsButtonSelected.color = ccc3(150, 150, 150);
    statsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"StatsButton.png"] selectedSprite:statsButtonSelected target:self selector:@selector(slotOneStats:)];
    statsButton.tag = 0;
    statsButton.opacity = 0;
    [statsButton setIsEnabled:TRUE];
    statsButton.position = ADJUST_XY(320, 30);//ccp(320, 30);
    
    CCMenu *bottomMenu = [CCMenu menuWithItems:backButton, deleteButton, nil];
    bottomMenu.position = ccp(0, 0);
    [self addChild:bottomMenu z:4];

    if (checkSlotOne) {
        CCSprite *slotOneMenuButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"];

        slotOneMenuButtonSelected.color = ccc3(150, 150, 150);

        slotOneMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:slotOneMenuButtonSelected target:self selector:@selector(SlotOne:)];

        [self displaySlotOne];

    }
    else {
        CCSprite *slotOneMenuButtonNewGameSelected = [CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"];
        slotOneMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:slotOneMenuButtonNewGameSelected target:self selector:@selector(SlotOne:)];
        
        [NewGameLabelSlotOne setString:@"New Game"];

    }
    slotOneMenuButton.opacity = 0;
    CCMenu *slotOneMenu= [CCMenu menuWithItems:slotOneMenuButton, nil];
    slotOneMenuButton.position = ADJUST_XY(240, 160);
    slotOneMenu.position = ccp(0, 0);
    
    if (checkSlotTwo) {
        CCSprite *slotTwoMenuButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"];
        slotTwoMenuButtonSelected.color = ccc3(150, 150, 150);
        slotTwoMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:slotTwoMenuButtonSelected target:self selector:@selector(SlotTwo:)];
        [self displaySlotTwo];

    }
    else {
        slotTwoMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:nil target:self selector:@selector(SlotTwo:)];
        [NewGameLabelSlotTwo setString:@"New Game"];
    }

    CCMenu *slotTwoMenu = [CCMenu menuWithItems:slotTwoMenuButton, nil];
    
    slotTwoMenuButton.position = ccp(240, 160);
    slotTwoMenu.position = ccp(0, 0);
    [slotTwoMenuButton setIsEnabled:FALSE];
    if (checkSlotThree) {
        CCSprite *slotThreeMenuButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"];
        slotThreeMenuButtonSelected.color = ccc3(150, 150, 150);
        slotThreeMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:slotThreeMenuButtonSelected target:self selector:@selector(SlotThree:)];
        [self displaySlotThree];
    }
    else {
        slotThreeMenuButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"] selectedSprite:nil target:self selector:@selector(SlotThree:)];
        [NewGameLabelSlotThree setString:@"New Game"];
    }
    
    CCMenu *slotThreeMenu = [CCMenu menuWithItems:slotThreeMenuButton, nil];
    slotThreeMenuButton.position = ccp(240, 160);
    slotThreeMenu.position = ccp(0, 0);
    [slotThreeMenuButton setIsEnabled:FALSE];

    [slotTwoLayer addChild:slotTwoMenu z:4];
    [slotOneLayer addChild:slotOneMenu z:4];
    [slotThreeLayer addChild:slotThreeMenu z:4];
    
    [deleteButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.5], nil]];
    [backButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.5], nil]];
    [NewGameLabelSlotOne runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.5], nil]];

    //[statsButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.5], nil]];
    
    [slotOneMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCFadeIn actionWithDuration:0.5], nil]];
    
    [self addChild:slotOneLayer z:1];    
}

- (void) deleteSlotOne: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    [slotOneMenuButton setIsEnabled:FALSE];
    [slotTwoMenuButton setIsEnabled:FALSE];
    [slotThreeMenuButton setIsEnabled:FALSE];
    
    scroller.isTouchEnabled = NO;

    confirmLayer = [[CCLayer alloc] init];
    [self addChild:confirmLayer z:5];
        
    blankTicket = [CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"];
    blankTicket.position = ADJUST_XY(240, 160);//ccp(240, 160);
    [confirmLayer addChild:blankTicket z:1];
    
    areYouSureLabel = [CCLabelTTF labelWithString:@"Are you sure?" fontName:@"Broadway BT" fontSize:25];
    areYouSureLabel.color = ccc3(0, 0, 0);
    areYouSureLabel.position = ADJUST_XY(240, 185);//ccp(240, 185);
    [confirmLayer addChild:areYouSureLabel z:1];
    
    CCSprite *confirmSelected = [CCSprite spriteWithSpriteFrameName:@"ConfirmButton.png"];
    confirmSelected.color = ccc3(150, 150, 150);
    confirm = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ConfirmButton.png"] selectedSprite:confirmSelected target:self selector:@selector(confirmDeleteSlotOne:)];
    confirm.position = ADJUST_XY(200, 140);//ccp(200, 140);
    //confirm.tag = 13;
    CCSprite *denySelected = [CCSprite spriteWithSpriteFrameName:@"DenyButton.png"];
    denySelected.color = ccc3(150, 150, 150);
    deny = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"DenyButton.png"] selectedSprite:denySelected target:self selector:@selector(denyDelete:)];
    deny.position = ADJUST_XY(280, 140);//ccp(280, 140);
    //deny.tag = 14;
    
    confirmDeleteMenu = [CCMenu menuWithItems:confirm, deny, nil];
    confirmDeleteMenu.position = ccp(0,0);
    [confirmLayer addChild:confirmDeleteMenu z:1];
}

- (void) confirmDeleteSlotOne: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
    [slotOneMenuButton setIsEnabled:TRUE];
    [slotTwoMenuButton setIsEnabled:TRUE];
    [slotThreeMenuButton setIsEnabled:TRUE];
    scroller.isTouchEnabled = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath:[libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SaveSlot%d.plist", scroller.currentScreen+1]] error:NULL];

    switch (scroller.currentScreen) {
        case 0:
            [self removeLabelsSlotOne];
            [self loadSlotOne];
            //[self saveSlotOne];
            [[SettingsManager sharedSettingsManager] logSettings];
            [slotOneMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
            [NewGameLabelSlotOne setString:@"New Game"];

            break;
        case 1:
            [self removeLabelsSlotTwo];
            [self loadSlotTwo];
            [self saveSlotTwo];
            [[SettingsManager sharedSettingsManager] logSettings];
            [slotTwoMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
            [NewGameLabelSlotTwo setString:@"New Game"];

            break;
        case 2:
            [self removeLabelsSlotThree];
            [self loadSlotThree];
            [self saveSlotThree];
            [[SettingsManager sharedSettingsManager] logSettings];
            [slotThreeMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
            [NewGameLabelSlotThree setString:@"New Game"];

            break;
        default:
            break;
    }
    
    
    [self openSlotDatabase];
    [slotDb beginTransaction];
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Action"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Action"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Action"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Comedy"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Comedy"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Comedy"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Drama"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Drama"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Drama"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"RomanticComedy"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"RomanticComedy"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"RomanticComedy"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"SciFi"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"SciFi"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"SciFi"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Family"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Family"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Family"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Thriller"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Thriller"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Thriller"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Animation"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Animation"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Animation"]];
    
    [slotDb executeUpdate:@"DELETE FROM skippedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Adventure"]];
    [slotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Adventure"]];
    [slotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", [NSString stringWithFormat:@"Adventure"]];
    [slotDb commit];
    
    [confirmLayer removeChild:confirmDeleteMenu cleanup:YES];
    [confirmLayer removeChild:blankTicket cleanup:YES];
    [confirmLayer removeChild:areYouSureLabel cleanup:YES];
}

- (void) denyDelete:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];

    scroller.isTouchEnabled = YES;

    [deny setIsEnabled:NO];
    [confirm setIsEnabled:NO];
    [slotOneMenuButton setIsEnabled:TRUE];
    [confirmLayer removeChild:confirmDeleteMenu cleanup:YES];
    [confirmLayer removeChild:blankTicket cleanup:YES];
    [confirmLayer removeChild:areYouSureLabel cleanup:YES];
}

-(void)Quickplay: (id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    [menu runAction:[CCFadeOut actionWithDuration:0.6]];
    [fact runAction:[CCFadeOut actionWithDuration:0.4]];
    [factTitle runAction:[CCFadeOut actionWithDuration:0.4]];
    [ReelFactBG runAction:[CCFadeOut actionWithDuration:0.4]];
    
    [SinglePlayerButton setIsEnabled:NO];
    [CreditsButton setIsEnabled:NO];
    [QuickPlayButton setIsEnabled:NO];
    
    [self createQuickplayPLIST];
    
    CCSprite *EasyButtonSelected = [CCSprite spriteWithSpriteFrameName:@"EasyButton.png"];
    EasyButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite *EasyButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"EasyButton.png"] selectedSprite:nil target:self selector:@selector(LaunchQuickplay:)];
    EasyButton.tag = QUICKPLAY_EASY;
    EasyButton.opacity = 0;
    EasyButton.position = ADJUST_XY(144, 172);//ccp(144, 172);
    
    CCSprite *MediumButtonSelected = [CCSprite spriteWithSpriteFrameName:@"MediumButton.png"];
    MediumButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite *MediumButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"MediumButton.png"] selectedSprite:MediumButtonSelected target:self selector:@selector(LaunchQuickplay:)];
    MediumButton.tag = QUICKPLAY_MEDIUM;
    MediumButton.opacity = 0;
    MediumButton.position =ADJUST_XY(336, 172); //ccp(336, 172);
    
    CCSprite *HardButtonSelected = [CCSprite spriteWithSpriteFrameName:@"HardButton.png"];
    HardButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite *HardButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HardButton.png"] selectedSprite:HardButtonSelected target:self selector:@selector(LaunchQuickplay:)];
    HardButton.tag = QUICKPLAY_HARD;
    HardButton.opacity = 0;
    HardButton.position = ADJUST_XY(240, 110);//ccp(240, 110);
    

    CCMenu *quickplayMenu = [CCMenu menuWithItems:EasyButton, MediumButton, HardButton, nil];
    quickplayMenu.position = ccp(0, 0);

    [self addChild:quickplayMenu z:2];
    /*
    CCMenuItemSprite *quickplayStatsButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"StatsButton.png"] selectedSprite:nil target:self selector:@selector(slotOneStats:)];
    quickplayStatsButton.opacity = 0;
    quickplayStatsButton.tag = 1;
    quickplayStatsButton.position = ADJUST_XY(240, 30);//ccp(240, 30);
    
    CCMenu *quickplayStatsMenu = [CCMenu menuWithItems:quickplayStatsButton, nil];
    quickplayStatsMenu.position = ccp(0,0);
    [self addChild:quickplayStatsMenu z:3];*/
    
    CCSprite *BackButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
    BackButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite *BackButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:BackButtonSelected target:self selector:@selector(back:)];
    BackButton.opacity = 0;
    BackButton.position = ADJUST_XY(30, 30);//ccp(30, 30);
    BackButton.scale = 0.8;
    
    CCMenu *backMenu = [CCMenu menuWithItems:BackButton, nil];
    backMenu.position = ccp(0, 0);
    [self addChild:backMenu z:2];
    
    [BackButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f],[CCFadeIn actionWithDuration:1.0], nil]];
    //[quickplayStatsButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f],[CCFadeIn actionWithDuration:1.0], nil]];
    [quickplayMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f],[CCFadeIn actionWithDuration:1.0], nil]];
}
/*
-(void)Multiplayer: (id)sender {
	//NSLog(@"Multiplayer");
}
*/

-(void) LaunchQuickplay: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
    CCSprite *difficulty = (CCSprite *)sender;

    
    if (difficulty.tag == 131) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[Quickplay scene:20 difficultyLevel:@"Easy" questions:20]]];
    }
    if (difficulty.tag == 132) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[Quickplay scene:25 difficultyLevel:@"Medium" questions:20]]];
    }
    if (difficulty.tag == 133) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[Quickplay scene:30 difficultyLevel:@"Hard" questions:20]]];
    }
}

-(void) createQuickplayPLIST {
    SettingsManager *quickplayManager = [SettingsManager sharedSettingsManager];
    [quickplayManager loadFromFileInLibraryDirectory:@"Quickplay.plist"];
    BOOL hasBeenCreated = [quickplayManager getBool:@"hasBeenCreated"];
    
    if (!hasBeenCreated) {
        [quickplayManager setBool:TRUE keyString:@"hasBeenCreated"];
        [quickplayManager setInteger:0 keyString:@"Easy Answered"];
        [quickplayManager setInteger:0 keyString:@"Medium Answered"];
        [quickplayManager setInteger:0 keyString:@"Hard Answered"];
        [quickplayManager setBool:FALSE keyString:@"DeleteCurrentCategory"];
        [quickplayManager setString:@"None" keyString:@"CurrentCategory"];
        [quickplayManager setInteger:0 keyString:@"Combo"];
        
    }
    
    [quickplayManager saveToFileInLibraryDirectory:@"Quickplay.plist"];

}

-(void) SlotOne: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

	[slotOneMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot1.plist"];
	
	if ([S1 getBool:@"isEmpty"]) {
        [self removeLabelsSlotOne];
		[slotOneMenuButton setIsEnabled:FALSE];
		[slotTwoMenuButton setIsEnabled:FALSE];
		[slotThreeMenuButton setIsEnabled:FALSE];
        scroller.isTouchEnabled = NO;

        [self createSlotOne];

		nameTextField = [[UITextField alloc] initWithFrame: CGRectMake(140, 110, 120, 23)];

		nameTextField.opaque = NO;
		nameTextField.returnKeyType = UIReturnKeyDone;
		nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		nameTextField.delegate = self;
		
		[[[CCDirector sharedDirector] openGLView] addSubview: nameTextField];
		
        [nameTextField becomeFirstResponder];
		nameTextField.backgroundColor = [UIColor clearColor];
		nameTextField.borderStyle = UITextBorderStyleNone;
        [nameTextField setFont:[UIFont fontWithName:@"Broadway BT" size:20]];
		isEmpty = FALSE;
		
        [S1 setBool:isEmpty keyString:@"isEmpty"];
        [S1 saveToFileInLibraryDirectory:@"SaveSlot1.plist"];
		[[SettingsManager sharedSettingsManager] logSettings];
	}
	else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LevelSelect scene:1]]];
	}
}

-(void) SlotTwo: (id) sender {

	[slotTwoMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot2.plist"];
	
	if ([S1 getBool:@"isEmpty"]) {
        [self removeLabelsSlotTwo];
		[slotOneMenuButton setIsEnabled:FALSE];
		[slotTwoMenuButton setIsEnabled:FALSE];
		[slotThreeMenuButton setIsEnabled:FALSE];
        scroller.isTouchEnabled = NO;
        
        [self createSlotTwo];
        
		nameTextField = [[UITextField alloc] initWithFrame: CGRectMake(140, 110, 120, 23)];
		
		// NOTE: UITextField won't be visible by default without setting backGroundColor & borderStyle
		nameTextField.opaque = NO;
		nameTextField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
		nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
		nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		nameTextField.delegate = self;
		
		// add the textField to the main game openGLVview
		[[[CCDirector sharedDirector] openGLView] addSubview: nameTextField];
		
		// auto show the keyboard once the view has been added (NB: seems to need to be AFTER addSubview call to work)
		[nameTextField becomeFirstResponder];
		nameTextField.backgroundColor = [UIColor clearColor];
		nameTextField.borderStyle = UITextBorderStyleNone;
        [nameTextField setFont:[UIFont fontWithName:@"Broadway BT" size:20]];
		isEmpty = FALSE;
		
        [S1 setBool:isEmpty keyString:@"isEmpty"];
		NSLog(@"isEmpty %d", [S1 getBool:@"isEmpty"]);
		[S1 saveToFileInLibraryDirectory:@"SaveSlot2.plist"];
		[[SettingsManager sharedSettingsManager] logSettings];
	}
	else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LevelSelect scene:1]]];
	}
}

-(void) SlotThree: (id) sender {
	[slotThreeMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot3.plist"];
	
	if ([S1 getBool:@"isEmpty"]) {
        [self removeLabelsSlotThree];
		[slotOneMenuButton setIsEnabled:FALSE];
		[slotTwoMenuButton setIsEnabled:FALSE];
		[slotThreeMenuButton setIsEnabled:FALSE];
        scroller.isTouchEnabled = NO;
        
        [self createSlotThree];
        
		nameTextField = [[UITextField alloc] initWithFrame: CGRectMake(140, 110, 120, 23)];
		
		// NOTE: UITextField won't be visible by default without setting backGroundColor & borderStyle
		nameTextField.opaque = NO;
		nameTextField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
		nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
		nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		nameTextField.delegate = self;
		
		// add the textField to the main game openGLVview
		[[[CCDirector sharedDirector] openGLView] addSubview: nameTextField];
		
		// auto show the keyboard once the view has been added (NB: seems to need to be AFTER addSubview call to work)
		[nameTextField becomeFirstResponder];
		nameTextField.backgroundColor = [UIColor clearColor];
		nameTextField.borderStyle = UITextBorderStyleNone;
        [nameTextField setFont:[UIFont fontWithName:@"Broadway BT" size:20]];
		isEmpty = FALSE;
		
        [S1 setBool:isEmpty keyString:@"isEmpty"];
		NSLog(@"isEmpty %d", [S1 getBool:@"isEmpty"]);
		[S1 saveToFileInLibraryDirectory:@"SaveSlot3.plist"];
		[[SettingsManager sharedSettingsManager] logSettings];
	}
	else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LevelSelect scene:1]]];
	}
}

-(void) createSlotOne {
    SettingsManager *S1 = [SettingsManager sharedSettingsManager];
    
    for (int i = 1; i <= 10; i++) {
        [S1 setInteger:QuestionStars keyString:[NSString stringWithFormat:@"QuestionStars%d", i]];
    }
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot1.plist"];
}

-(void) createSlotTwo {
    SettingsManager *S1 = [SettingsManager sharedSettingsManager];
    
    for (int i = 1; i <= 10; i++) {
        [S1 setInteger:QuestionStars keyString:[NSString stringWithFormat:@"QuestionStars%d", i]];
    }
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot2.plist"];
}

-(void) createSlotThree {
    SettingsManager *S1 = [SettingsManager sharedSettingsManager];
    
    for (int i = 1; i <= 10; i++) {
        [S1 setInteger:QuestionStars keyString:[NSString stringWithFormat:@"QuestionStars%d", i]];
    }
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot3.plist"];
}

-(void) saveSlotOne {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 setString:SaveName keyString:@"Name"];
    
	[S1 setInteger:SaveScore keyString:@"Round Score"];
    [S1 setInteger:SaveTotalScore keyString:@"Overall Score"];
    [S1 setInteger:SaveActionScore keyString:@"Action Score"];
    [S1 setInteger:SaveComedyScore keyString:@"Comedy Score"];
    [S1 setInteger:SaveDramaScore keyString:@"Drama Score"];
    
    [S1 setInteger:SaveCombo keyString:@"Combo"];
    [S1 setInteger:SaveTotalQuestionsAnsweredCorrectly keyString:@"AnsweredCorrectTotal"];
    [S1 setInteger:SaveCurrentQuestion keyString:@"CurrentQuestion"];
	[S1 setInteger:SaveAchievements keyString:@"Achievements"];
    [S1 setString:SaveCurrentCategory keyString:@"CurrentCategory"];
	[S1 setString:SaveDate keyString:@"Last Played"];
	[S1 setInteger:SaveLevel1QuestionComplete keyString:@"Level1QuestionsComplete"];
	[S1 setBool:isEmpty keyString:@"isEmpty"];
    [S1 setBool:Level2Lock keyString:@"Level2Lock"];
    [S1 setBool:Level3Lock keyString:@"Level3Lock"];
    [S1 setBool:Level4Lock keyString:@"Level4Lock"];
    
    /*NEW STUFF SINCE ORGANISING THE SLOTS*/
    [S1 setBool:didRoundEnd keyString:@"didRoundEnd"];
    [S1 setBool:isTutorialFinished keyString:@"isTutorialFinished"];
    
    [S1 setInteger:SaveFamilyScore keyString:@"Family Score"];
    [S1 setInteger:SaveSciFiScore keyString:@"SciFi Score"];
    [S1 setInteger:SaveRomanticComedyScore keyString:@"RomanticComedy Score"];
    
    [S1 setInteger:SaveAdventureScore keyString:@"Adventure Score"];
    [S1 setInteger:SaveAnimationScore keyString:@"Animation Score"];
    [S1 setInteger:SaveThrillerScore keyString:@"Thriller Score"];
    
    [S1 setInteger:SaveActionProgress keyString:@"Action Progress"];
    [S1 setInteger:SaveComedyProgress keyString:@"Comedy Progress"];
    [S1 setInteger:SaveDramaProgress keyString:@"Drama Progress"];
    
    [S1 setInteger:SaveSciFiProgress keyString:@"SciFi Progress"];
    [S1 setInteger:SaveFamilyProgress keyString:@"Family Progress"];
    [S1 setInteger:SaveRomanticComedyProgress keyString:@"RomanticComedy Progress"];

    [S1 setInteger:SaveAdventureProgress keyString:@"Adventure Progress"];
    [S1 setInteger:SaveAnimationProgress keyString:@"Animation Progress"];
    [S1 setInteger:SaveThrillerProgress keyString:@"Thriller Progress"];

    
    [S1 setInteger:SaveActionCombo keyString:@"Action Combo"];
    [S1 setInteger:SaveComedyCombo keyString:@"Comedy Combo"];
    [S1 setInteger:SaveDramaCombo keyString:@"Drama Combo"];
    
    [S1 setInteger:SaveRomanticComedyCombo keyString:@"RomanticComedy Combo"];
    [S1 setInteger:SaveSciFiCombo keyString:@"SciFi Combo"];
    [S1 setInteger:SaveFamilyCombo keyString:@"Family Combo"];
    
    [S1 setInteger:SaveThrillerCombo keyString:@"Thriller Combo"];
    [S1 setInteger:SaveAnimationCombo keyString:@"Animation Combo"];
    [S1 setInteger:SaveAdventureCombo keyString:@"Adventure Combo"];
    
    [S1 setBool:FALSE keyString:@"Action Complete"];
    [S1 setBool:FALSE keyString:@"Comedy Complete"];
    [S1 setBool:FALSE keyString:@"Drama Complete"];
    [S1 setBool:FALSE keyString:@"Family Complete"];
    [S1 setBool:FALSE keyString:@"RomanticComedy Complete"];
    [S1 setBool:FALSE keyString:@"SciFi Complete"];
    [S1 setBool:FALSE keyString:@"Adventure Complete"];
    [S1 setBool:FALSE keyString:@"Animation Complete"];
    [S1 setBool:FALSE keyString:@"Thriller Complete"];
    
    [S1 setString:@"-" keyString:@"Action Rank"];
    [S1 setString:@"-" keyString:@"Comedy Rank"];
    [S1 setString:@"-" keyString:@"Drama Rank"];
    
    [S1 setString:@"-" keyString:@"Family Rank"];
    [S1 setString:@"-" keyString:@"RomanticComedy Rank"];
    [S1 setString:@"-" keyString:@"SciFi Rank"];

    [S1 setString:@"-" keyString:@"Adventure Rank"];
    [S1 setString:@"-" keyString:@"Animation Rank"];
    [S1 setString:@"-" keyString:@"Thriller Rank"];

    [S1 setBool:FALSE keyString:@"usedEliminate"];
    [S1 setBool:FALSE keyString:@"usedFiftyFifty"];
    [S1 setBool:FALSE keyString:@"usedSkip"];

    [S1 setBool:FALSE keyString:@"ABeautifulMind"];
    [S1 setBool:FALSE keyString:@"FastAndFurious"];
    [S1 setBool:FALSE keyString:@"Loser"];
    [S1 setBool:FALSE keyString:@"FilmNovice"];
    [S1 setBool:FALSE keyString:@"FilmWatcher"];
    [S1 setBool:FALSE keyString:@"FilmBuff"];
    [S1 setBool:FALSE keyString:@"TriviaGuru"];
    [S1 setBool:FALSE keyString:@"TriviaKing"];
    [S1 setBool:FALSE keyString:@"TriviaGod"];
    
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot1.plist"];
}

-(void) saveSlotTwo {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 setString:SaveName keyString:@"Name"];
    
	[S1 setInteger:SaveScore keyString:@"Score"];
    [S1 setInteger:SaveTotalScore keyString:@"Overall Score"];
    [S1 setInteger:SaveActionScore keyString:@"Action Score"];
    [S1 setInteger:SaveComedyScore keyString:@"Comedy Score"];
    [S1 setInteger:SaveDramaScore keyString:@"Drama Score"];
    
    [S1 setInteger:SaveCombo keyString:@"Combo"];
    [S1 setInteger:SaveTotalQuestionsAnsweredCorrectly keyString:@"AnsweredCorrectTotal"];
    [S1 setInteger:SaveCurrentQuestion keyString:@"CurrentQuestion"];
	[S1 setInteger:SaveAchievements keyString:@"Achievements"];
    [S1 setString:SaveCurrentCategory keyString:@"CurrentCategory"];
	[S1 setString:SaveDate keyString:@"Last Played"];
	[S1 setInteger:SaveLevel1QuestionComplete keyString:@"Level1QuestionsComplete"];
	[S1 setBool:isEmpty keyString:@"isEmpty"];
    [S1 setBool:Level2Lock keyString:@"Level2Lock"];
    [S1 setBool:Level3Lock keyString:@"Level3Lock"];
    [S1 setBool:Level4Lock keyString:@"Level4Lock"];
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot2.plist"];
}

-(void) saveSlotThree {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 setString:SaveName keyString:@"Name"];
    
    [S1 setInteger:0 keyString:@"answeredRightForRound"];
    
	[S1 setInteger:SaveScore keyString:@"Score"];
    [S1 setInteger:SaveTotalScore keyString:@"Overall Score"];
    [S1 setInteger:SaveActionScore keyString:@"Action Score"];
    [S1 setInteger:SaveComedyScore keyString:@"Comedy Score"];
    [S1 setInteger:SaveDramaScore keyString:@"Drama Score"];
    
    [S1 setInteger:SaveCombo keyString:@"Combo"];
    [S1 setInteger:SaveTotalQuestionsAnsweredCorrectly keyString:@"AnsweredCorrectTotal"];
    [S1 setInteger:SaveCurrentQuestion keyString:@"CurrentQuestion"];
	[S1 setInteger:SaveAchievements keyString:@"Achievements"];
    [S1 setString:SaveCurrentCategory keyString:@"CurrentCategory"];
	[S1 setString:SaveDate keyString:@"Last Played"];
	[S1 setInteger:SaveLevel1QuestionComplete keyString:@"Level1QuestionsComplete"];
	[S1 setBool:isEmpty keyString:@"isEmpty"];
    [S1 setBool:Level2Lock keyString:@"Level2Lock"];
    [S1 setBool:Level3Lock keyString:@"Level3Lock"];
    [S1 setBool:Level4Lock keyString:@"Level4Lock"];
    
    [S1 saveToFileInLibraryDirectory:@"SaveSlot3.plist"];
    
}

-(void) loadSlotOne {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot1.plist"];

    //QuestionStars
    
	BOOL hasAlreadySaved = [S1 getBool:@"hasAlreadySaved"];
	if (!hasAlreadySaved) {
		SaveName = @"Empty";
        NSLog(@"test");
		SaveScore = 0;
        SaveTotalScore = 0;
        SaveActionScore = 0;
        SaveComedyScore = 0;
        SaveDramaScore = 0;
        
        SaveCombo = 0;
        SaveTotalQuestionsAnsweredCorrectly = 0;
        SaveCurrentQuestion = 0;
        SaveCurrentCategory = @"None";
		SaveAchievements = 0;
		SaveDate = @"Unknown";
		SaveLevel1QuestionComplete = 0;
        
        QuestionStars = FALSE;
		isEmpty = TRUE;
        Level2Lock = TRUE;
        Level3Lock = TRUE;
        Level4Lock = TRUE;
        didRoundEnd = TRUE;
        isTutorialFinished = FALSE;
        
        /***New STUFF AFTER ORGANISING***/
        SaveThrillerScore = 0;
        SaveAnimationScore = 0;
        SaveAdventureScore = 0;
        
        SaveSciFiScore = 0;
        SaveFamilyScore = 0;
        SaveRomanticComedyScore = 0;
        
        SaveActionProgress = 0;
        SaveComedyProgress = 0;
        SaveDramaProgress = 0;
        
        SaveSciFiProgress = 0;
        SaveFamilyProgress = 0;
        SaveRomanticComedyProgress = 0;
        
        SaveAdventureProgress = 0;
        SaveAnimationProgress = 0;
        SaveThrillerProgress = 0;
        
        SaveThrillerCombo = 0;
        SaveRomanticComedyCombo = 0;

        Rank = @"E";
        
		[S1 setBool:TRUE keyString:@"hasAlreadySaved"];
        [self saveSlotOne];
	}
    else {
        SaveName = [S1 getString:@"Name"];
        
        SaveScore = [S1 getInt:@"Score"];
        SaveTotalScore = [S1 getInt:@"Overall Score"];
        SaveActionScore = [S1 getInt:@"Action Score"];
        SaveComedyScore = [S1 getInt:@"Comedy Score"];
        SaveDramaScore = [S1 getInt:@"Drama Score"];
        
        SaveCombo = [S1 getInt:@"Combo"];
        SaveTotalQuestionsAnsweredCorrectly = [S1 getInt:@"AnsweredCorrectTotal"];
        SaveCurrentQuestion = [S1 getInt:@"CurrentQuestion"];
        SaveCurrentCategory = [S1 getString:@"CurrentCategory"];
        SaveAchievements = [S1 getInt:@"Achievements"];
        SaveDate = [S1 getString:@"Last Played"];
        SaveLevel1QuestionComplete = [S1 getInt:@"Level1QuestionsComplete"];
        isEmpty = [S1 getBool:@"isEmpty"];
        Level2Lock = [S1 getBool:@"Level2Lock"];
        Level3Lock = [S1 getBool:@"Level3Lock"];
        Level4Lock = [S1 getBool:@"Level4Lock"];
        
        [S1 setBool:didRoundEnd keyString:@"didRoundEnd"];
        [S1 setBool:isTutorialFinished keyString:@"isTutorialFinished"];
        
        didRoundEnd = [S1 getBool:@"didRoundEnd"];
        isTutorialFinished = [S1 getBool:@""];
        
        /***New stats after organising***/
        
        SaveFamilyCombo = [S1 getInt:@"Family Combo"];
        SaveSciFiCombo = [S1 getInt:@"SciFi Combo"];
        SaveRomanticComedyCombo = [S1 getInt:@"RomanticComedy Combo"];
        
        SaveAnimationCombo = [S1 getInt:@"Animation Combo"];
        SaveAdventureCombo = [S1 getInt:@"Adventure Combo"];
        SaveThrillerCombo = [S1 getInt:@"Thriller Combo"];
        
        SaveActionProgress = [S1 getInt:@"Action Progress"];
        SaveComedyProgress = [S1 getInt:@"Comedy Progress"];
        SaveDramaProgress = [S1 getInt:@"Drama Progress"];
        
        SaveFamilyProgress = [S1 getInt:@"Family Progress"];
        SaveRomanticComedyProgress = [S1 getInt:@"RomanticComedy Progress"];
        SaveSciFiProgress = [S1 getInt:@"SciFi Progress"];
        
        SaveAnimationProgress = [S1 getInt:@"Animation Progress"];
        SaveThrillerProgress = [S1 getInt:@"Thriller Progress"];
        SaveAdventureProgress = [S1 getInt:@"Adventure Progress"];
         
        
    }
	[S1 saveToFileInLibraryDirectory:@"SaveSlot1.plist"];
}

-(void) loadSlotTwo {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot2.plist"];
	SaveName = [S1 getString:@"Name"];
    
	SaveScore = [S1 getInt:@"Score"];
    SaveTotalScore = [S1 getInt:@"Overall Score"];
    SaveActionScore = [S1 getInt:@"Action Score"];
    SaveComedyScore = [S1 getInt:@"Comedy Score"];
    SaveDramaScore = [S1 getInt:@"Drama Score"];
    
    SaveCombo = [S1 getInt:@"Combo"];
    SaveTotalQuestionsAnsweredCorrectly = [S1 getInt:@"AnsweredCorrectTotal"];
    SaveCurrentQuestion = [S1 getInt:@"CurrentQuestion"];
    SaveCurrentCategory = [S1 getString:@"CurrentCategory"];
	SaveAchievements = [S1 getInt:@"Achievements"];
	SaveDate = [S1 getString:@"Last Played"];
    SaveLevel1QuestionComplete = [S1 getInt:@"Level1QuestionsComplete"];
	isEmpty = [S1 getBool:@"isEmpty"];
    Level2Lock = [S1 getBool:@"Level2Lock"];
    Level3Lock = [S1 getBool:@"Level3Lock"];
    Level4Lock = [S1 getBool:@"Level4Lock"];
    
    //QuestionStars
    
	BOOL hasAlreadySaved = [S1 getBool:@"hasAlreadySaved"];
	if (!hasAlreadySaved) {
		SaveName = @"Empty";
        NSLog(@"test");
		SaveScore = 0;
        SaveTotalScore = 0;
        SaveActionScore = 0;
        SaveComedyScore = 0;
        SaveDramaScore = 0;
        
        SaveCombo = 0;
        SaveTotalQuestionsAnsweredCorrectly = 0;
        SaveCurrentQuestion = 0;
        SaveCurrentCategory = @"None";
		SaveAchievements = 0;
		SaveDate = @"Unknown";
		SaveLevel1QuestionComplete = 0;
        
        QuestionStars = FALSE;
		isEmpty = TRUE;
        Level2Lock = TRUE;
        Level3Lock = TRUE;
        Level4Lock = TRUE;
		[S1 setBool:TRUE keyString:@"hasAlreadySaved"];
	}
	[S1 saveToFileInLibraryDirectory:@"SaveSlot2.plist"];
}

-(void) loadSlotThree {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot3.plist"];
	SaveName = [S1 getString:@"Name"];
    
	SaveScore = [S1 getInt:@"Score"];
    SaveTotalScore = [S1 getInt:@"Overall Score"];
    SaveActionScore = [S1 getInt:@"Action Score"];
    SaveComedyScore = [S1 getInt:@"Comedy Score"];
    SaveDramaScore = [S1 getInt:@"Drama Score"];
    
    SaveCombo = [S1 getInt:@"Combo"];
    SaveTotalQuestionsAnsweredCorrectly = [S1 getInt:@"AnsweredCorrectTotal"];
    SaveCurrentQuestion = [S1 getInt:@"CurrentQuestion"];
    SaveCurrentCategory = [S1 getString:@"CurrentCategory"];
	SaveAchievements = [S1 getInt:@"Achievements"];
	SaveDate = [S1 getString:@"Last Played"];
    SaveLevel1QuestionComplete = [S1 getInt:@"Level1QuestionsComplete"];
	isEmpty = [S1 getBool:@"isEmpty"];
    Level2Lock = [S1 getBool:@"Level2Lock"];
    Level3Lock = [S1 getBool:@"Level3Lock"];
    Level4Lock = [S1 getBool:@"Level4Lock"];
    
    //QuestionStars
    
	BOOL hasAlreadySaved = [S1 getBool:@"hasAlreadySaved"];
	if (!hasAlreadySaved) {
		SaveName = @"Empty";
        NSLog(@"test");
		SaveScore = 0;
        SaveTotalScore = 0;
        SaveActionScore = 0;
        SaveComedyScore = 0;
        SaveDramaScore = 0;
        
        SaveCombo = 0;
        SaveTotalQuestionsAnsweredCorrectly = 0;
        SaveCurrentQuestion = 0;
        SaveCurrentCategory = @"None";
		SaveAchievements = 0;
		SaveDate = @"Unknown";
		SaveLevel1QuestionComplete = 0;
        
        QuestionStars = FALSE;
		isEmpty = TRUE;
        Level2Lock = TRUE;
        Level3Lock = TRUE;
        Level4Lock = TRUE;
		[S1 setBool:TRUE keyString:@"hasAlreadySaved"];
	}
	[S1 saveToFileInLibraryDirectory:@"SaveSlot3.plist"];
}

- (void) SlotOneDelete: (id) sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath:[libraryDirectory stringByAppendingPathComponent:@"SaveSlot1.plist"] error:NULL];
    
	[slotOneMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    NewGameLabelSlotOne = [CCLabelTTF labelWithString:@"New Game" fontName:@"Broadway BT" fontSize:20];
    NewGameLabelSlotOne.position = ADJUST_XY(240, 160);//ccp(240, 160);
    [slotOneLayer addChild:NewGameLabelSlotOne];
    [self removeLabelsSlotOne];    
}

- (void) SlotTwoDelete: (id) sender {
    //NSLog(@"delete slot Two");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath:[libraryDirectory stringByAppendingPathComponent:@"SaveSlot2.plist"] error:NULL];
    
	[slotTwoMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    NewGameLabelSlotTwo = [CCLabelTTF labelWithString:@"New Game" fontName:@"Broadway BT" fontSize:20];
    NewGameLabelSlotTwo.position = ccp(240, 160);
    [slotTwoLayer addChild:NewGameLabelSlotTwo];
    [self removeLabelsSlotTwo];
    //[self loadSlotTwo];
    //[self saveSlotTwo];
    //[[SettingsManager sharedSettingsManager] logSettings];

}

- (void) SlotThreeDelete: (id) sender {
    //NSLog(@"delete slot Three");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath:[libraryDirectory stringByAppendingPathComponent:@"SaveSlot3.plist"] error:NULL];
    
	[slotThreeMenuButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BlankTicket.png"]];
    NewGameLabelSlotThree = [CCLabelTTF labelWithString:@"New Game" fontName:@"Broadway BT" fontSize:20];
    NewGameLabelSlotThree.position = ccp(240, 160);
    [slotThreeLayer addChild:NewGameLabelSlotThree];
    [self removeLabelsSlotThree];
    //[self loadSlotThree];
    //[self saveSlotThree];
    //[[SettingsManager sharedSettingsManager] logSettings];
}

- (BOOL) checkSlotOne {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot1.plist"]];
	BOOL slotEmpty = 0;
	if ([S1 getBool:@"isEmpty"]) {
		//NSLog(@"slotone is empty");
        slotEmpty = 0;
	}
	else {
		//NSLog(@"slotOne is not empty");
        slotEmpty = 1;
	}
	return slotEmpty;
}

- (BOOL) checkSlotTwo {
	SettingsManager *S2 = [SettingsManager sharedSettingsManager];
	[S2 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot2.plist"]];
	BOOL slotEmpty = 0;
	if ([S2 getBool:@"isEmpty"]) {
		//NSLog(@"slottwo is empty");
        slotEmpty = 0;
	}
	else {
        //NSLog(@"slotTwo is not empty");
        slotEmpty = 1;
	}
    return slotEmpty;
}

- (BOOL) checkSlotThree {
	SettingsManager *S3 = [SettingsManager sharedSettingsManager];
	[S3 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot3.plist"]];
	BOOL slotEmpty = 0;
	if ([S3 getBool:@"isEmpty"]) {
		//NSLog(@"slotThree is empty");
        slotEmpty = 0;
	}
	else {
        //NSLog(@"slotThree is not empty");
        slotEmpty = 1;
	}
    return slotEmpty;
}

-(void) displaySlotOne {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot1.plist"];
    
    CCLabelTTF *SlotOneLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [S1 getString:@"Name"]] fontName:@"Broadway BT" fontSize:20.0 dimensions:CGSizeMake(90,40) hAlignment:kCCTextAlignmentLeft];
    
    
    CCLabelTTF *SlotOneLabelNumber = [CCLabelTTF labelWithString:@"1" fontName:@"Broadway BT" fontSize:20];
    
	SlotOneLabel.color = ccc3(0,0,0);
	SlotOneLabel.position = ADJUST_XY(185, 190);//ccp(185,190);
	SlotOneLabel.tag = SlotOneLabelNameTag;
	
    SlotOneLabelNumber.color = ccc3(0, 0, 0);
    SlotOneLabelNumber.position = ADJUST_XY(120, 160);//ccp(120, 160);
    SlotOneLabelNumber.tag = SlotOneLabelNumberTag;
    SlotOneLabelNumber.rotation = 270;
	[slotOneLayer addChild:SlotOneLabel z:5];
    [slotOneLayer addChild:SlotOneLabelNumber z:5];
    
}

-(void) displaySlotTwo {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot2.plist"];
    
    CCLabelTTF *SlotTwoLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [S1 getString:@"Name"]] fontName:@"Broadway BT" fontSize:20.0 dimensions:CGSizeMake(90,40) hAlignment:kCCTextAlignmentLeft];
    
    CCLabelTTF *SlotTwoLabelNumber = [CCLabelTTF labelWithString:@"2" fontName:@"Broadway BT" fontSize:20];
    
	SlotTwoLabel.color = ccc3(0,0,0);
	SlotTwoLabel.position = ccp(185,190);
	SlotTwoLabel.tag = SlotTwoLabelNameTag;
	
    SlotTwoLabelNumber.color = ccc3(0, 0, 0);
    SlotTwoLabelNumber.position = ccp(120, 160);
    SlotTwoLabelNumber.tag = SlotTwoLabelNumberTag;
    SlotTwoLabelNumber.rotation = 270;
	[slotTwoLayer addChild:SlotTwoLabel z:5];
    [slotTwoLayer addChild:SlotTwoLabelNumber z:5];
    
}

-(void) displaySlotThree {
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 loadFromFileInLibraryDirectory:@"SaveSlot3.plist"];
    //NSLog(@"name %@", [S1 getString:@"Name"]);
    
    CCLabelTTF *SlotThreeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [S1 getString:@"Name"]] fontName:@"Broadway BT" fontSize:20.0 dimensions:CGSizeMake(90,40) hAlignment:kCCTextAlignmentLeft];
    CCLabelTTF *SlotThreeLabelNumber = [CCLabelTTF labelWithString:@"3" fontName:@"Broadway BT" fontSize:20];
    
	SlotThreeLabel.color = ccc3(0,0,0);
	SlotThreeLabel.position = ccp(185,190);
	SlotThreeLabel.tag = SlotThreeLabelNameTag;
	
    SlotThreeLabelNumber.color = ccc3(0, 0, 0);
    SlotThreeLabelNumber.position = ccp(120, 160);
    SlotThreeLabelNumber.tag = SlotThreeLabelNumberTag;
    SlotThreeLabelNumber.rotation = 270;
	[slotThreeLayer addChild:SlotThreeLabel z:5];
    [slotThreeLayer addChild:SlotThreeLabelNumber z:5];
    
}

- (void) slotOneStats: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
    CCSprite *spriteTag = (CCSprite *) sender;
    
    switch (spriteTag.tag) {
        case 0:
            [self showLeaderBoardGameCenter:@"SP1"];
            break;
        case 1:
            [self showLeaderBoardGameCenter:@"nil"];
            break;
        default:
            break;
    }
}

- (void) slotTwoStats: (id) sender {
    
}

- (void) slotThreeStats: (id) sender {
    
}

- (void) removeLabelsSlotOne {
    [NewGameLabelSlotOne setString:@""];
	[slotOneLayer removeChildByTag:SlotOneLabelNameTag cleanup:YES];
    [slotOneLayer removeChildByTag:SlotOneLabelNumberTag cleanup:YES];
}

- (void) removeLabelsSlotTwo {
    [NewGameLabelSlotTwo setString:@""];
	[slotTwoLayer removeChildByTag:SlotTwoLabelNameTag cleanup:YES];
    [slotTwoLayer removeChildByTag:SlotTwoLabelNumberTag cleanup:YES];
}

- (void) removeLabelsSlotThree {
    [NewGameLabelSlotThree setString:@""];
	[slotThreeLayer removeChildByTag:SlotThreeLabelNameTag cleanup:YES];
    [slotThreeLayer removeChildByTag:SlotThreeLabelNumberTag cleanup:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	//Re-Enable buttons/save slots only if there are not in use
	[slotOneMenuButton setIsEnabled:TRUE];
	[slotTwoMenuButton setIsEnabled:TRUE];
	[slotThreeMenuButton setIsEnabled:TRUE];
    
	NSString *name = textField.text;
	//NSLog(@"name %@", name);
	SettingsManager *S1 = [SettingsManager sharedSettingsManager];
	[S1 setString:name keyString:@"Name"];
	[S1 saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", scroller.currentScreen+1]];
	[[SettingsManager sharedSettingsManager] logSettings];  // Should now show same data as logData
    switch (scroller.currentScreen) {
        case 0:
            [self displaySlotOne];
            break;
        case 1:
            [self displaySlotTwo];
            break;
        case 2:
            [self displaySlotThree];
            break;
        default:
            break;
    }
    scroller.isTouchEnabled = YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	//check if it's empty
	if ([theTextField.text isEqual:@""]) {
		//must not be empty
		//NSLog(@"it's empty");
	}
	else {
		//remove keyboard and uitextfield from screen
		[nameTextField resignFirstResponder];
		[nameTextField removeFromSuperview];
		[nameTextField release];
	}
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 8) ? NO : YES;
}
                               
- (void) dealloc
{
    
    [slotOneLayer release];
    [slotTwoLayer release];
    [slotThreeLayer release];
    [scroller release];
    
    [self removeAllChildrenWithCleanup: YES];
    [scoringDb close];
    [reelFactsDb close];
    [menuLayer release]; //causes crash in next singleplayerscene
	[super dealloc];

}


@end
