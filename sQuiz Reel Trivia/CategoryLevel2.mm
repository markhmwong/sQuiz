//
//  CategoryMenu.m
//  TriviaMenu
//
//  Created by mark wong on 14/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoryLevel2.h"
#import "CDXPropertyModifierAction.h"

#define ACTION_TAG 11
#define COMEDY_TAG 12
#define DRAMA_TAG 13

#define CAT1 @"Family"
#define CAT2 @"RomanticComedy"
#define CAT3 @"SciFi"

#define MENU_SELECT_FORWARD @"MenuSelectForward.caf"
#define MENU_SELECT_BACK @"MenuSelectBack.caf"

#define OPENSANSBOLD @"OpenSans-Bold.ttf"
#define OPENSANSREGULAR @"OpenSans-Regular.ttf"

@implementation CategoryLevel2
static int save;
static int level;

+(id) scene:(int) saveSlot lvl:(int)levelNumber {
    
	CCScene *scene = [CCScene node];
	save = saveSlot;
    level = levelNumber;
    
	CategoryLevel2 *layer = [CategoryLevel2 node];
	
    
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

-(void) SoundSettings {
    
    SettingsManager *soundSettings = [SettingsManager sharedSettingsManager];
    [soundSettings loadFromFileInLibraryDirectory:@"SoundSettings.plist"];
    SFX = [soundSettings getBool:@"Sound"];
    BGM = [soundSettings getBool:@"Music"];

}

-(id) init {
	if ((self = [super init])) {
        statLayer = [[CCLayer alloc] init];
        [self addChild:statLayer z:4];

        CategoryMenuSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"CategoryMenuSS.pvr"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CategoryMenuSS.plist" texture:CategoryMenuSpriteSheet];
        
        Level1NoTextSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"Level2BGText.pvr"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Level2BGText.plist" texture:Level1NoTextSpriteSheet];
        
		target = self;
		categoriesSelected = 0;
        showReview = TRUE;
        changeMusic = TRUE;
        
        sae = [SimpleAudioEngine sharedEngine];
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];        
        
        [self SoundSettings];
        if (SFX) {
            [SimpleAudioEngine sharedEngine].effectsVolume = 1;
        }
        else {
            [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        }
        
        //probably do this during start up
        //[sae preloadBackgroundMusic:@"Action.aif"];
        //[sae preloadBackgroundMusic:@"Comedy.aif"];
        //[sae preloadBackgroundMusic:@"Drama.aif"];
        
        //Get sound sources for our files, we must retain them if we want to use them 
        //outside this method.
        ///sound1 = [[sae soundSourceForFile:@"dp3.caf"] retain];
        //sound2 = [[sae soundSourceForFile:@"dp1.caf"] retain];
        //sound3 = [[sae soundSourceForFile:@"dp2.caf"] retain];
        //CDLOG(@"Sound 1 duration %0.4f",sound1.durationInSeconds);
        
        //Used in test 3
        //fadingOut = YES;
        //sound3.gain = 0.0f;
        
        //Used in test 1
        //sourceFader = [[CDSoundSourceFader alloc] init:sound1 interpolationType:kIT_SCurve startVal:1.0f endVal:0.0f];
        //[sourceFader setStopTargetWhenComplete:YES];
        //Create a property modifier action to wrap the fader 
        //faderAction = [CDXPropertyModifierAction actionWithDuration:1.0f modifier:sourceFader];
        //[faderAction retain];
        
		[self categoryMenu];
	}
	return self;
}

-(void) categoryhelp:(id) sender {
    
    
    
}


-(void) categoryMenu {
    CCLayer *animationLayer = [[CCLayer alloc] init];
	pageOne = [[CCLayer alloc] init];
    pageTwo = [[CCLayer alloc] init];
	pageThree = [[CCLayer alloc] init];
    
    [self addChild:animationLayer z:1];
    
	leftCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
	leftCurtain.position = ccp(0,184);
    leftCurtain.flipX = TRUE;
	[self addChild:leftCurtain z:2];
	[leftCurtain runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.1f  red:255 green:255 blue:255], [CCTintTo actionWithDuration:0.15f red:230 green:230 blue:230], nil]]];
	rightCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
	rightCurtain.position = ccp(480, 184);
	[self addChild:rightCurtain z:2];
	[rightCurtain runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.1f  red:255 green:255 blue:255], [CCTintTo actionWithDuration:0.15f red:230 green:230 blue:230], nil]]];
    
    [self openSlotDatabase];
    
    //int actionAnswered = [self countMaximumRowsForCategory:@"Action"];
    //int comedyAnswered = [self countMaximumRowsForCategory:@"Comedy"];
    //int dramaAnswered = [self countMaximumRowsForCategory:@"Drama"]; 
    
	CCSprite* menuBGPage1 = [CCSprite spriteWithSpriteFrameName:@"CategoryMenuBG.png"];
	menuBGPage1.position = ccp(240, 25);
	[self addChild:menuBGPage1];
    
    [menuBGPage1 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.1f  red:255 green:255 blue:255], [CCTintTo actionWithDuration:0.15f red:230 green:230 blue:230], nil]]];
    CCSprite *filmStripTop = [CCSprite spriteWithSpriteFrameName:@"FilmStrip.png"];
    filmStripTop.position = ccp(240, 310);
    [animationLayer addChild:filmStripTop z:1];
    
    CCSprite *filmStripTop2 = [CCSprite spriteWithSpriteFrameName:@"FilmStrip.png"];
    filmStripTop2.position = ccp(640, 310);
    
    [animationLayer addChild:filmStripTop2 z:1];
    
    id repeatForever1 = [CCRepeatForever actionWithAction:[CCSpawn actions:[CCSequence actions:[CCFadeTo actionWithDuration:0.2f opacity:100], [CCFadeTo actionWithDuration:0.3f opacity:250], nil], [CCSequence actions:[CCMoveBy actionWithDuration:0.6f position:ccp(-428, 0)], [CCMoveTo actionWithDuration:0.0f position:ccp(240, 310)], nil], nil]];
    
    [filmStripTop runAction:[CCSequence actions:repeatForever1, nil]];
    [filmStripTop2 runAction:[CCRepeatForever actionWithAction:[CCSpawn actions:[CCSequence actions:[CCFadeTo actionWithDuration:0.2f opacity:100], [CCFadeTo actionWithDuration:0.3f opacity:250], nil], [CCSequence actions:[CCMoveBy actionWithDuration:0.6f position:ccp(-428, 0)],  [CCMoveTo actionWithDuration:0.0f position:ccp(668, 310)], nil], nil]]];
    
    CCSprite *filmStripBottom = [CCSprite spriteWithSpriteFrameName:@"FilmStrip.png"];
    filmStripBottom.position = ccp(240, 72);
    filmStripBottom.opacity = 230;
    [animationLayer addChild:filmStripBottom z:1];
    CCSprite *filmStripBottom2 = [CCSprite spriteWithSpriteFrameName:@"FilmStrip.png"];
    filmStripBottom2.position = ccp(675, 72);
    filmStripBottom2.opacity = 230;
    [animationLayer addChild:filmStripBottom2 z:1];
    
    [filmStripBottom runAction:[CCRepeatForever actionWithAction:[CCSpawn actions:[CCSequence actions:[CCFadeTo actionWithDuration:0.2f opacity:100], [CCFadeTo actionWithDuration:0.3f opacity:250], nil], [CCSequence actions:[CCMoveBy actionWithDuration:0.6f position:ccp(-400, 0)], [CCMoveTo actionWithDuration:0.0f position:ccp(240, 72)], nil], nil]]];
    [filmStripBottom2 runAction:[CCRepeatForever actionWithAction:[CCSpawn actions:[CCSequence actions:[CCFadeTo actionWithDuration:0.2f opacity:100], [CCFadeTo actionWithDuration:0.3f opacity:250], nil], [CCSequence actions:[CCMoveBy actionWithDuration:0.6f position:ccp(-400, 0)], [CCMoveTo actionWithDuration:0.0f position:ccp(675, 72)], nil], nil]]];
    
    [animationLayer runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.1f position:ccp(0, -5)], [CCMoveBy actionWithDuration:0.1f position:ccp(0, 5)], [CCDelayTime actionWithDuration:1.25f], [CCMoveBy actionWithDuration:0.1f position:ccp(-3, 4)], [CCMoveBy actionWithDuration:0.0f position:ccp(3, -4)], [CCDelayTime actionWithDuration:0.8f], nil]]];
    
    CCLabelTTF *selectACategory = [CCLabelTTF labelWithString:@"Select A Category" fontName:@"Broadway BT" fontSize:25];
    selectACategory.position = ccp(240, 280);
    [animationLayer addChild:selectACategory z:2];
    [selectACategory runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.1f opacity:200], [CCFadeTo actionWithDuration:0.2f opacity:250], nil]]];
    
	ActionButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"FamilyText.png"] selectedSprite:nil target:target selector:@selector(LaunchLevel:)];
    ActionButton.scale = 0.90;
    ActionButton.position = ccp(240, 170);
	ActionButton.tag = 1;
    [ActionButton runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.1f opacity:200], [CCFadeTo actionWithDuration:0.2f opacity:250], nil]]];
    
    CCMenu *menuPage1 = [CCMenu menuWithItems:ActionButton, nil];
	menuPage1.position = ccp(0, 0);
	[pageOne addChild:menuPage1];
    
    [pageOne runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.1f position:ccp(0, -3)], [CCMoveBy actionWithDuration:0.1f position:ccp(0, 3)], [CCDelayTime actionWithDuration:1.25f], [CCMoveBy actionWithDuration:0.1f position:ccp(-3, 4)], [CCMoveBy actionWithDuration:0.0f position:ccp(3, -4)], [CCDelayTime actionWithDuration:0.8f], nil]]];
    
	ComedyButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"RomanticComedyText.png"] selectedSprite:nil target:target selector:@selector(LaunchLevel:)];
    ComedyButton.scale = 0.90;
	ComedyButton.position = ccp(240, 170);
	ComedyButton.tag = 2;
    
    [ComedyButton runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.1f opacity:200], [CCFadeTo actionWithDuration:0.2f opacity:250], nil]]];
    
    
	CCMenu *menuPage2 = [CCMenu menuWithItems:ComedyButton, nil];
	menuPage2.position = ccp(0,0);
	[pageTwo addChild:menuPage2];
	
    [pageTwo runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.1f position:ccp(0, -3)], [CCMoveBy actionWithDuration:0.1f position:ccp(0, 3)], [CCDelayTime actionWithDuration:1.25f], [CCMoveBy actionWithDuration:0.1f position:ccp(-3, 4)], [CCMoveBy actionWithDuration:0.0f position:ccp(3, -4)], [CCDelayTime actionWithDuration:0.8f], nil]]];
    
	DramaButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SciFiText.png"] selectedSprite:nil target:target selector:@selector(LaunchLevel:)];
    DramaButton.scale = 0.90;
	DramaButton.position = ccp(240, 170);
	DramaButton.tag = 3;
	
    [DramaButton runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.1f opacity:200], [CCFadeTo actionWithDuration:0.2f opacity:250], nil]]];
    
	CCMenu *menuPage3 = [CCMenu menuWithItems:DramaButton, nil];
	menuPage3.position = ccp(0, 0);
	[pageThree addChild:menuPage3];
	
    [pageThree runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.1f position:ccp(0, -3)], [CCMoveBy actionWithDuration:0.1f position:ccp(0, 3)], [CCDelayTime actionWithDuration:1.25f], [CCMoveBy actionWithDuration:0.1f position:ccp(-3, 4)], [CCMoveBy actionWithDuration:0.0f position:ccp(3, -4)], [CCDelayTime actionWithDuration:0.8f], nil]]];
    
	categoryScroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne, pageTwo, pageThree, nil] widthOffset:200];
	[self addChild:categoryScroller];
    
    
	pauseLayer = [[CCLayer alloc] init];
	pauseLayer.position = ccp(0, 0);
	[self addChild:pauseLayer z:2];
    
    CCSprite *backButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
    backButtonSelected.color = ccc3(130, 130, 130);
    CCMenuItemSprite *backButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:nil target:self selector:@selector(back:)];
    backButton.position = ccp(30, 30);
    backButton.scale = 0.9;
    
    CCSprite *homeButtonSelected = [CCSprite spriteWithSpriteFrameName:@"HomeButton.png"];
    homeButtonSelected.color = ccc3(130, 130, 130);
    CCMenuItemSprite *homeButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HomeButton.png"] selectedSprite:homeButtonSelected target:self selector:@selector(exit:)];
    homeButton.position = ccp(450, 30);
    homeButton.scale = 0.9;
    
    CCSprite *statButtonSelected = [CCSprite spriteWithSpriteFrameName:@"ReviewButton.png"];
    statButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ReviewButton.png"] selectedSprite:statButtonSelected target:self selector:@selector(stat:)];
    statButton.position = ccp(170, 30);
    
    CCSprite *helpButtonSelected = [CCSprite spriteWithSpriteFrameName:@"HelpButton.png"];
    helpButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite *helpButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HelpButton.png"] selectedSprite:helpButtonSelected target:target selector:@selector(categoryhelp:)];
    helpButton.position = ccp(310, 30);
    //infoAction.scale = 1.0;
    //infoAction.tag = ACTION_TAG;    
    
    CCMenu *backMenu = [CCMenu menuWithItems:backButton, homeButton, statButton, helpButton, nil];
    backMenu.position = ccp(0, 0);
    [self addChild:backMenu z:4];
    
    [backMenu runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.1f opacity:200], [CCFadeTo actionWithDuration:0.2f opacity:250], nil]]];
    
    categoryReviewBackground = [CCSprite spriteWithSpriteFrameName:@"CategoryReviewBG.png"];
    categoryReviewBackground.position = ccp(240, 160);
    categoryReviewBackground.scale = 1.3;
    categoryReviewBackground.opacity = 0;
    [statLayer addChild:categoryReviewBackground];
    
    warning = [CCLabelTTF labelWithString:@"" fontName:@"OpenSans-Bold.ttf" fontSize:15.0 dimensions:CGSizeMake(200,150) hAlignment:kCCTextAlignmentCenter];
    warning.position = ccp(240, 140);
    warning.opacity = 0;
    [statLayer addChild:warning];
    
    scoreTitle = [CCLabelTTF labelWithString:@"Score" fontName:OPENSANSBOLD fontSize:15];
    scoreTitle.position = ccp(240, 200);
    scoreTitle.opacity = 0;
    [statLayer addChild:scoreTitle];
    
    rankTitle = [CCLabelTTF labelWithString:@"Rank" fontName:OPENSANSBOLD fontSize:15];
    rankTitle.position = ccp(240, 155);
    rankTitle.opacity = 0;
    [statLayer addChild:rankTitle];
    
    progressTitle = [CCLabelTTF labelWithString:@"Progress" fontName:OPENSANSBOLD fontSize:15];
    progressTitle.position = ccp(240, 110);
    progressTitle.opacity = 0;
    [statLayer addChild:progressTitle];
    
    scoreResult = [CCLabelTTF labelWithString:@"" fontName:OPENSANSBOLD fontSize:20];
    scoreResult.position = ccp(240, 180);
    scoreResult.opacity = 0;
    [statLayer addChild:scoreResult];
    
    rankResult = [CCLabelTTF labelWithString:@"" fontName:OPENSANSBOLD fontSize:20];
    rankResult.position = ccp(240, 135);
    rankResult.opacity = 0;
    [statLayer addChild:rankResult];
    
    progressResult = [CCLabelTTF labelWithString:@"" fontName:OPENSANSBOLD fontSize:20];
    progressResult.position = ccp(240, 90);
    progressResult.opacity = 0;
    [statLayer addChild:progressResult];
    
    SettingsManager *S1 = [SettingsManager sharedSettingsManager];
    [S1 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    didRoundEnd = [S1 getBool:@"didRoundEnd"];
    
    CurrentCategory = @"";
    CurrentCategory = [S1 getString:@"CurrentCategory"];
    [CurrentCategory retain];
    
    [self lockPlayerIntoCategory];
    
    if ([CurrentCategory isEqualToString:CAT1]) {
        [categoryScroller moveToPage:0];
    }
    else if ([CurrentCategory isEqualToString:CAT2]) {
        [categoryScroller moveToPage:1];
    }
    else if ([CurrentCategory isEqualToString:CAT3]) {
        [categoryScroller moveToPage:2];
    }
    categoryTitle = [CCLabelTTF labelWithString:@"" fontName:@"OpenSans-Bold.ttf" fontSize:18];
    categoryTitle.position = ccp(240, 223);
    categoryTitle.opacity = 0;
    categoryTitle.color = ccc3(0, 0, 0);
    [statLayer addChild:categoryTitle];
    
    [pageOne release];
    [pageTwo release];
    [pageThree release];
    [categoryScroller release];
    
    [self schedule: @selector(tick:) interval:0.5f];
}

-(void) lockPlayerIntoCategory {
    //NSLog(@"CurrentCategory %@", CurrentCategory);
    if (!didRoundEnd) {
        if ([CurrentCategory isEqualToString:CAT1]) {
            ComedyButton.color = ccc3(100, 100, 100);
            DramaButton.color = ccc3(100, 100, 100);
        }
        else if ([CurrentCategory isEqualToString:CAT2]) {
            ActionButton.color = ccc3(100, 100, 100); 
            DramaButton.color = ccc3(100, 100, 100);
        }
        else if ([CurrentCategory isEqualToString:CAT3]) {
            ActionButton.color = ccc3(100, 100, 100); 
            ComedyButton.color = ccc3(100, 100, 100);
        }
        else if ([CurrentCategory isEqualToString:@"None"]) {
            ActionButton.color = ccc3(255, 255, 255);
            ComedyButton.color = ccc3(255, 255, 255);
            DramaButton.color = ccc3(255, 255, 255);
        }
        else {
            ActionButton.color = ccc3(100, 100, 100);
            ComedyButton.color = ccc3(100, 100, 100);
            DramaButton.color = ccc3(100, 100, 100);
        }
    }
}

-(void) tick: (ccTime) dt
{
    
    if (categoryScroller.currentScreen == 0 && changeMusic) {
        changeMusic = FALSE;
        changedCategoryMusic = categoryScroller.currentScreen;
        statButton.tag = categoryScroller.currentScreen;

        if (BGM) {
            [sae setBackgroundMusicVolume:1.0f];
        }
        [sae rewindBackgroundMusic];
        [sae playBackgroundMusic:[NSString stringWithFormat:@"%@.aif", CAT1]];
    }
    if (categoryScroller.currentScreen == 1 && changeMusic) {
        changeMusic = FALSE;
        changedCategoryMusic = categoryScroller.currentScreen;
        statButton.tag = categoryScroller.currentScreen;

        
        if (BGM) {
            [sae setBackgroundMusicVolume:1.0f];
        }        [sae rewindBackgroundMusic];
        [sae playBackgroundMusic:[NSString stringWithFormat:@"%@.aif", CAT2]];
    }
    if (categoryScroller.currentScreen == 2 && changeMusic) {
        changeMusic = FALSE;
        changedCategoryMusic = categoryScroller.currentScreen;
        statButton.tag = categoryScroller.currentScreen;

        
        if (BGM) {
            [sae setBackgroundMusicVolume:1.0f];
        }        [sae rewindBackgroundMusic];
        [sae playBackgroundMusic:[NSString stringWithFormat:@"%@.aif", CAT3]];
    }
    if (changedCategoryMusic != categoryScroller.currentScreen) {
        changeMusic = TRUE;
        [CDXPropertyModifierAction fadeBackgroundMusic:1.5f finalVolume:0.0f curveType:kIT_Exponential shouldStop:YES];
    }
}

- (void) openSlotDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Slot%d.sqlite", save]];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Slot%d.sqlite", save]];
	
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

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    showReview = !showReview;
    
    [ActionButton setIsEnabled:TRUE];
    [ComedyButton setIsEnabled:TRUE];
    [DramaButton setIsEnabled:TRUE];
    
    categoryScroller.isTouchEnabled = YES;
    [categoryReviewBackground runAction:[CCFadeOut actionWithDuration:1.0f]];
    [scoreTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
    [rankTitle runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
    [progressTitle runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
    [rankResult runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
    [progressResult runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
    [scoreResult runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], nil]];
    [categoryTitle runAction:[CCFadeOut actionWithDuration:1.0f]];

    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    return TRUE;    
}

-(void) getStatsFromSettingsManager:(NSString *) category {
    SettingsManager *statsManager = [SettingsManager sharedSettingsManager];
	[statsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    
    int tempScore = [statsManager getInt:[NSString stringWithFormat:@"%@ Score", category]];
    [scoreResult setString:[NSString stringWithFormat:@"%d", tempScore]];
    
    int tempAnswered = [self countMaximumRowsForCategory:category];
    
    int tempProgress = [statsManager getInt:[NSString stringWithFormat:@"%@ Progress", category]];
    [progressResult setString:[NSString stringWithFormat:@"%d / %d", tempProgress, tempAnswered]];
    
    //[self setRank:tempProgress];
    [statsManager setString:[self setRank:tempProgress totalProgressSoFar:tempAnswered] keyString:[NSString stringWithFormat:@"%@ Rank", category]];
    NSString *tempRank = [statsManager getString:[NSString stringWithFormat:@"%@ Rank", category]];
    [rankResult setString:[NSString stringWithFormat:@"%@", tempRank]];    
}

-(NSString *) setRank:(int)progress totalProgressSoFar:(int)totalProgress {
    NSString *rankLetter = @"";
    
    float rankTemp = (float)progress / (float)totalProgress;
    
    if (rankTemp >= 0.10f && rankTemp <= 0.29f) {
        rankLetter = @"D";
    }
    else if (rankTemp >= 0.30f && rankTemp <= 0.49f) {
        rankLetter = @"C";
    }
    else if (rankTemp >= 0.50f && rankTemp <= 0.69f) {
        rankLetter = @"B";
    }
    else if (rankTemp >= 0.70f && rankTemp <= 0.89f) {
        rankLetter = @"A";
    }
    else if (rankTemp >= 0.90f && rankTemp <= 1.00f) {
        rankLetter = @"S";
    }
    else {
        rankLetter = @"E";
    }
    
    return rankLetter;
}


-(void) stat:(id) sender {    
    
    if (showReview) {
        [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
        
        [ActionButton setIsEnabled:FALSE];
        [ComedyButton setIsEnabled:FALSE];
        [DramaButton setIsEnabled:FALSE];
        
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        categoryScroller.isTouchEnabled = NO;
        
        [categoryReviewBackground runAction:[CCFadeIn actionWithDuration:1.0f]];
                
        switch (categoryScroller.currentScreen) {
            case 0:
                [scoreTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressTitle runAction:[CCFadeIn actionWithDuration:1.0f]];

                [categoryTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [categoryTitle setString:CAT1];
                [self getStatsFromSettingsManager:CAT1];
                [scoreResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                break;
            case 1:
                //show stats for comedy
                [scoreTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [categoryTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [categoryTitle setString:@"Romantic Comedy"];

                [self getStatsFromSettingsManager:CAT2];
                [scoreResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                break;
            case 2:
                //show stats for drama
                [scoreTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [categoryTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
                [categoryTitle setString:@"Science Fiction"];

                [self getStatsFromSettingsManager:CAT3];
                [scoreResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [progressResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                [rankResult runAction:[CCFadeIn actionWithDuration:1.0f]];
                break;
            default:
                break;
        }
    }
    else {
        [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];
        
        [ActionButton setIsEnabled:TRUE];
        [ComedyButton setIsEnabled:TRUE];
        [DramaButton setIsEnabled:TRUE];
        
        categoryScroller.isTouchEnabled = YES;
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        [categoryReviewBackground runAction:[CCFadeOut actionWithDuration:1.0f]];
        [scoreTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
        [rankTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
        [categoryTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
        [progressTitle runAction:[CCFadeOut actionWithDuration:1.0f]];
        [progressResult runAction:[CCFadeOut actionWithDuration:1.0f]];
        [scoreResult runAction:[CCFadeOut actionWithDuration:1.0f]];
        [rankResult runAction:[CCFadeOut actionWithDuration:1.0f]];
    }
    showReview = !showReview;
    
}

-(void) removeStatLabels:(id) sender {
    
}

-(int) countMaximumRowsForCategory:(NSString *) categoryFromCategoryDb {
	FMResultSet *countQuery = [slotDb executeQuery:@"SELECT COUNT (category_id) FROM usedQuestions WHERE category_id = ?", categoryFromCategoryDb];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];
		NSLog(@"totalCount %d", totalCount); 
	}
    NSLog(@"totalCount %d", totalCount); 
	return totalCount;
}

-(int) countMaximumRowsForSkippedQuestions:(NSString *) categoryFromCategoryDb {
    FMResultSet *countQuery = [slotDb executeQuery:@"SELECT COUNT (category_id) FROM skippedQuestions WHERE category_id = ?", categoryFromCategoryDb];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];
		//NSLog(@"totalCount %d", totalCount); 
	}
    //NSLog(@"totalCount %d", totalCount); 
	return totalCount;
}

-(void) LaunchLevel: (id)sender {
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CategoryMenuSS.plist"];
    //[[CCTextureCache sharedTextureCache] removeTexture:CategoryMenuSpriteSheet];
    //[self removeAllChildrenWithCleanup:TRUE];
    
	//record which category was selected
	UIButton *button = (UIButton*) sender;
	//NSLog(@"%d", button.tag);
	
    switch (button.tag) {
        case 1:
            if (didRoundEnd || [CurrentCategory isEqualToString:CAT1] || [CurrentCategory isEqualToString:@"None"]) {
                [sae stopBackgroundMusic];
                [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT1 lvl:level]];
            }
            else {
                [warning runAction:[CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:0.5f], nil]];
                if ([CurrentCategory isEqualToString:@"RomanticComedy"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nRomantic Comedy\n before playing a new category", CurrentCategory]];
                }
                else if ([CurrentCategory isEqualToString:@"SciFi"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nScience Fiction\n before playing a new category", CurrentCategory]];

                }
                else {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\n%@\n before playing a new category", CurrentCategory]];
                }
                //finish currentCategory first!
            }
            break;
        case 2:
            //if (didRoundEnd  || [CurrentCategory isEqualToString:CAT2]) {
            /**********FIX THIS**********/
            if (didRoundEnd || [CurrentCategory isEqualToString:CAT2] || [CurrentCategory isEqualToString:@"None"]) {
                [sae stopBackgroundMusic];
                [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT2 lvl:level]];
            }
            else {
                //finish currentCategory first!
                [warning runAction:[CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:0.5f], nil]];
                if ([CurrentCategory isEqualToString:@"RomanticComedy"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nRomantic Comedy\n before playing a new category", CurrentCategory]];
                }
                else if ([CurrentCategory isEqualToString:@"SciFi"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nScience Fiction\n before playing a new category", CurrentCategory]];
                    
                }
                else {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\n%@\n before playing a new category", CurrentCategory]];
                }
            }
            break;
        case 3:
            if (didRoundEnd  || [CurrentCategory isEqualToString:CAT3] || [CurrentCategory isEqualToString:@"None"]) {
                [sae stopBackgroundMusic];
                [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT3 lvl:level]];
            }
            else {
                //finish currentCategory first!
                [warning runAction:[CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:0.5f], nil]];
                if ([CurrentCategory isEqualToString:@"RomanticComedy"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nRomantic Comedy\n before playing a new category", CurrentCategory]];
                }
                else if ([CurrentCategory isEqualToString:@"SciFi"]) {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\nScience Fiction\n before playing a new category", CurrentCategory]];
                    
                }
                else {
                    [warning setString:[NSString stringWithFormat:@"Please finish the round in\n%@\n before playing a new category", CurrentCategory]];
                }
            }
            break;
        default:
            break;
    }
    /*
     if (button.tag == 1) {
     //NSLog(@"button 1");
     if ([CurrentCategory isEqualToString:CAT1]) {
     [sae stopBackgroundMusic];
     [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT1 lvl:level]];
     }
     }
     if (button.tag == 2) {
     //NSLog(@"button 2");
     [sae stopBackgroundMusic];
     
     [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT2 lvl:level]];
     }
     if (button.tag == 3) {
     //NSLog(@"button 3");
     [sae stopBackgroundMusic];
     
     [[CCDirector sharedDirector] replaceScene:[questionScene scene:1 category:CAT3 lvl:level]];
     }*/
}

-(void) back: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];
    
	//NSLog(@"backButton");
    //[self removeAllChildrenWithCleanup:TRUE];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CategoryMenuSS.plist"];
    //[[CCTextureCache sharedTextureCache] removeTexture:CategoryMenuSpriteSheet];
    [sae stopBackgroundMusic];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelect scene:save]]];
}

-(void) exit: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];
    
    
    //[self removeAllChildrenWithCleanup:TRUE];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"CategoryMenuSS.plist"];
    [[CCTextureCache sharedTextureCache] removeTexture:CategoryMenuSpriteSheet];
    [sae stopBackgroundMusic];
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
}

-(void) dealloc {
    //[self removeAllChildrenWithCleanup:TRUE];
    //[scoreTitle release];
    //scoreTitle = nil;
    //[statLayer release];
    //[pauseLayer release];
    [CurrentCategory release];
    
    sae = nil;
	[super dealloc];
}

@end
