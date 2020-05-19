//
//  EndOfRoundScene.m
//  TriviaMenu
//
//  Created by mark wong on 19/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EndOfRoundScene.h"
#import "DeviceFile.h"

#define FACT_FNT @"OpenSans-Regular13.fnt"
#define STATSFONT @"OpenSans-Bold.ttf"
#define FADETIME 0.4f
#define STARSDELAY 0.3f

@implementation EndOfRoundScene
static int save;
static NSString * categoryFromCategoryMenu;
static int level;

+(id) scene:(int) saveSlot category:(NSString*) categoryName lvl:(int)levelNumber {

	CCScene *scene = [CCScene node];
	save = saveSlot;
    categoryFromCategoryMenu = categoryName;
    level = levelNumber;

	EndOfRoundScene *layer = [EndOfRoundScene node];

	[scene addChild: layer];

	return scene;
}

-(id) init
{

	if( ( self = [super init] )) {

        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"CategoryMenuBG.png"];
        background.position = ccp(240, 25);
        [self addChild:background];
        
        CCSprite *CategoryBackground = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@NoText.png", categoryFromCategoryMenu]];
        CategoryBackground.scale = 0.8;
        CategoryBackground.color = ccc3(150, 150, 150);
        CategoryBackground.position = ccp(240, 190);
        [self addChild:CategoryBackground];
        
        CCSprite *leftCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        leftCurtain.position = ccp(0,184);
        leftCurtain.flipX = TRUE;
        [self addChild:leftCurtain z:2];

        CCSprite *rightCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        rightCurtain.position = ccp(480, 184);
        [self addChild:rightCurtain z:2];

        CCSprite *nextRoundButtonSelected = [CCSprite spriteWithSpriteFrameName:@"NextRoundButton.png"];
        nextRoundButtonSelected.color = ccc3(130, 130, 130);
        CCMenuItemSprite *nextRoundButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"NextRoundButton.png"] selectedSprite:nextRoundButtonSelected target:self selector:@selector(nextRound:)];
        nextRoundButton.position = ccp(445, 35);
        
        CCSprite *backButtonSelected = [CCSprite spriteWithSpriteFrameName:@"BackButton.png"];
        backButtonSelected.color = ccc3(130, 130, 130);
        CCMenuItemSprite *backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BackButton.png"] selectedSprite:backButtonSelected target:self selector:@selector(backButton:)];
        backButton.position = ccp(35, 35);
        
        CCSprite *exitRoundButtonSelected = [CCSprite spriteWithSpriteFrameName:@"HomeButton.png"];
        exitRoundButtonSelected.color = ccc3(130, 130, 130);
        CCMenuItemSprite *exitRoundButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HomeButton.png"] selectedSprite:exitRoundButtonSelected target:self selector:@selector(exitButton:)];
        exitRoundButton.position = ccp(35, 290);
        CCMenu *scoreMenuButtons = [CCMenu menuWithItems:nextRoundButton, backButton, exitRoundButton, nil];
        scoreMenuButtons.position = ccp(0,0);
        [self addChild:scoreMenuButtons z:3];
        
        touchToContinue = [CCLabelTTF labelWithString:@"Touch to Continue" fontName:STATSFONT fontSize:18];
        touchToContinue.position = ccp(240, 80);
        touchToContinue.color = ccc3(255, 255, 255);
        [self addChild:touchToContinue];
        
        [touchToContinue runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0f], [CCFadeIn actionWithDuration:1.0f], nil]]];
        
        SettingsManager *completeManager = [SettingsManager sharedSettingsManager];
        [completeManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
        categoryComplete = [completeManager getBool:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]];
        
        factBG = [CCSprite spriteWithSpriteFrameName:@"ReelFactsBG.png"];
        factBG.position = ccp(240, 30);
        factBG.opacity = 0;
        [self addChild:factBG];
        
        factTitle = [CCLabelBMFont labelWithString:@"Reel Fact" fntFile:SD_HD_FONT(FACT_FNT)];
        factTitle.position = ccp(240, 45);
        factTitle.opacity = 0;
        factTitle.color = ccc3(0, 0, 0);
        [self addChild:factTitle];
        
        fact = [CCLabelBMFontMultiline labelWithString:@"" fntFile:FACT_FNT width:ADJUST_X(400) alignment:UITextAlignmentCenter];        
        fact.position = ccp(240, 23);
        fact.scale = 0.8;
        fact.opacity = 0;
        fact.color = ccc3(0, 0, 0);
        [self addChild:fact];
        
        [self openReelFactsDatabase];
        
        if (!categoryComplete) {
        //if (1) {
            [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
            page = 1;
            [self loadScoreFromSettingsManager];
        }
        else {
            [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
            page = 0;
            [self congratulations];
        }
	}
	return self;
}

-(void) fadeInReelFacts {
    
    NSString *factString = @"";
    int randomFact = arc4random() % 10 + 1;
    NSString *cat = @"";
    if ([categoryFromCategoryMenu isEqualToString:@"SciFi"]) {
        cat = @"Science Fiction";
        categoryFromCategoryMenu = cat;
    }
    else if([categoryFromCategoryMenu isEqualToString:@"RomanticComedy"]) {
        cat = @"Romantic Comedy";
        categoryFromCategoryMenu = cat;
    }
    
    FMResultSet *factQuery = [reelFactsDb executeQuery:@"SELECT Fact FROM RoundScreenFacts WHERE rowid = ? AND Category = ?", [NSNumber numberWithInt:randomFact], categoryFromCategoryMenu];
    if ([factQuery next]) {
        factString = [factQuery stringForColumn:@"fact"];
    }

    [fact setString:factString];
    [factTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
    [fact runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
    [factBG runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCFadeTo actionWithDuration:0.7f opacity:250], nil]];
}

-(void) congratulations {
    grats = [CCLabelTTF labelWithString:@"" fontName:STATSFONT fontSize:25.0 dimensions:CGSizeMake(400,200) hAlignment:kCCTextAlignmentLeft];
    
    grats.position = ccp(240, 140);
    grats.color = ccc3(255, 255, 255);
    [self addChild:grats];
    
    if ([categoryFromCategoryMenu isEqualToString:@"RomanticComedy"]) {
        [grats setString:@"Congratulations\nYou Have Completed\nRomantic Comedy"];
    }
    else if ([categoryFromCategoryMenu isEqualToString:@"SciFi"]) {
        [grats setString:@"Congratulations\nYou Have Completed\nScience Fiction"];
    }
    else {
        [grats setString:[NSString stringWithFormat:@"Congratulations\nYou Have Completed\n%@", categoryFromCategoryMenu]];
    }
}

- (void) backButton: (id) sender {
    switch (level) {
        case 1:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryMenu scene:save lvl:level]]];
            break;
        case 2:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryLevel2 scene:save lvl:level]]];
            break;
        case 3:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CategoryLevel3 scene:save lvl:level]]];
            break;
        default:
            break;
    }
}

- (void) exitButton: (id) sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];

}

- (void) nextRound: (id) sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[questionScene scene:save category:categoryFromCategoryMenu lvl:level]]];

}

-(void) resetStats {
    SettingsManager *answeredRight = [SettingsManager sharedSettingsManager];
    [answeredRight loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [answeredRight setInteger:0 keyString:@"answeredRightForRound"];
    [answeredRight setInteger:0 keyString:@"Combo"];
    [answeredRight setInteger:0 keyString:@"Round Score"];
    [answeredRight saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(int) loadAnsweredRightForRound {
    SettingsManager *answeredRight = [SettingsManager sharedSettingsManager];
    [answeredRight loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];

    int tempAnsweredRight = [answeredRight getInt:@"answeredRightForRound"];
    return tempAnsweredRight;
}

- (void) openReelFactsDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:@"RoundScreenFacts.sqlite"];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"RoundScreenFacts.sqlite"];
	
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

-(void) loadScoreFromSettingsManager {
    
    SettingsManager *slotSettingsManager = [SettingsManager sharedSettingsManager];
	[slotSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    
    if([categoryFromCategoryMenu isEqualToString:@"RomanticComedy"]) {
        categoryTitleLabel = [CCLabelTTF labelWithString:@"Romantic Comedy" fontName:STATSFONT fontSize:20];
    }
    else if ([categoryFromCategoryMenu isEqualToString:@"SciFi"]) {
        categoryTitleLabel = [CCLabelTTF labelWithString:@"Science Fiction" fontName:STATSFONT fontSize:20];
    }
    else {
        categoryTitleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", categoryFromCategoryMenu] fontName:STATSFONT fontSize:20];
    }
    categoryTitleLabel.color = ccc3(255, 255, 0);
    categoryTitleLabel.position = ccp(240, 270);
    [self addChild:categoryTitleLabel];
    
    endOfRoundTitle = [CCLabelTTF labelWithString:@"Round Review" fontName:STATSFONT fontSize:20];
    endOfRoundTitle.position = ccp(240, 300);
    [self addChild:endOfRoundTitle];
    
    scoreSceneScoreTitleLabel = [CCLabelTTF labelWithString:@"Round Score" fontName:STATSFONT fontSize:20];
    scoreSceneScoreTitleLabel.position = ccp(157, 155);
    scoreSceneScoreTitleLabel.color = ccc3(255, 255, 255);
    [self addChild:scoreSceneScoreTitleLabel];
    
    int SaveScore = [slotSettingsManager getInt:@"Round Score"];
    
    scoreSceneScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", SaveScore] fontName:STATSFONT fontSize:19];
    scoreSceneScoreLabel.opacity = 0;

    scoreSceneScoreLabel.scale = 5.0f;
    scoreSceneScoreLabel.position = ccp(350, 155);
    scoreSceneScoreLabel.color = ccc3(255, 255, 255);
    [self addChild:scoreSceneScoreLabel];
    
    [[GCHelper sharedInstance] reportScore:SaveScore forLeaderboard:@"SP1"];
    
    int combo = [slotSettingsManager getInt:@"Combo"];
    
    scoreSceneComboTitleLabel = [CCLabelTTF labelWithString:@"Round Combo" fontName:STATSFONT fontSize:20];
    scoreSceneComboTitleLabel.position = ccp(165, 195);
    scoreSceneComboTitleLabel.color = ccc3(255, 255, 255);

    scoreSceneComboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", combo] fontName:STATSFONT fontSize:19];
    scoreSceneComboLabel.scale = 5.0f;
    scoreSceneComboLabel.position = ccp(350, 195);
    scoreSceneComboLabel.color = ccc3(255, 255, 255);
    scoreSceneComboLabel.opacity = 0;
    
    [self addChild:scoreSceneComboTitleLabel];
    [self addChild:scoreSceneComboLabel];
    
    questionsCorrectTitle = [CCLabelTTF labelWithString:@"Questions Correct" fontName:STATSFONT fontSize:20];
    questionsCorrectTitle.position = ccp(185, 235);
    questionsCorrectTitle.color = ccc3(255, 255, 255);
    [self addChild:questionsCorrectTitle];
    
    int answeredRight = [self loadAnsweredRightForRound];

    questionsCorrect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / 10", answeredRight] fontName:STATSFONT fontSize:20];
    questionsCorrect.scale = 5.0f;
    questionsCorrect.opacity = 0;
    questionsCorrect.position = ccp(350, 235);
    questionsCorrect.color = ccc3(255, 255, 255);
    [self addChild:questionsCorrect];
    
    [questionsCorrect runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.50f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.6f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    [self performSelector:@selector(starsEffects3) withObject:nil afterDelay:0.40f];

    [scoreSceneComboLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.60f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.65f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    
    [self performSelector:@selector(starsEffects2) withObject:nil afterDelay:0.30f];
    
    [scoreSceneScoreLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.70f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.7f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    
    [self performSelector:@selector(starsEffects) withObject:nil afterDelay:0.20f];
    
    [scoreSceneComboLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [scoreSceneComboTitleLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    
    [scoreSceneScoreLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [scoreSceneScoreTitleLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    
    [questionsCorrect runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [questionsCorrectTitle runAction:[CCFadeIn actionWithDuration:FADETIME]];
    //[self wipeScore];
    [self resetStats];
    
    [self fadeInReelFacts];
    
    //[factTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
    //[fact runAction:[CCFadeIn actionWithDuration:1.0f]];
    //[factBG runAction:[CCFadeIn actionWithDuration:1.0f]];
    
}

-(void) loadScoreFromSettingsManager2 {

    SettingsManager *slotSettingsManager = [SettingsManager sharedSettingsManager];
	[slotSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    
    categoryTitleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", categoryFromCategoryMenu] fontName:STATSFONT fontSize:20];
    categoryTitleLabel.color = ccc3(255, 255, 0);
    categoryTitleLabel.position = ccp(240, 270);
    [self addChild:categoryTitleLabel];
    
    endOfRoundTitle = [CCLabelTTF labelWithString:@"Round Review" fontName:STATSFONT fontSize:20];
    endOfRoundTitle.position = ccp(240, 300);
    [self addChild:endOfRoundTitle];
    
    scoreSceneScoreTitleLabel = [CCLabelTTF labelWithString:@"Round Score" fontName:STATSFONT fontSize:20];
    scoreSceneScoreTitleLabel.position = ccp(157, 155);
    scoreSceneScoreTitleLabel.color = ccc3(255, 255, 255);
    [self addChild:scoreSceneScoreTitleLabel];
    
    int SaveScore = [slotSettingsManager getInt:@"Round Score"];
    
    scoreSceneScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", SaveScore] fontName:STATSFONT fontSize:19];
    scoreSceneScoreLabel.opacity = 0;
    
    scoreSceneScoreLabel.scale = 5.0f;
    scoreSceneScoreLabel.position = ccp(350, 155);
    scoreSceneScoreLabel.color = ccc3(255, 255, 255);
    [self addChild:scoreSceneScoreLabel];
    
    [[GCHelper sharedInstance] reportScore:SaveScore forLeaderboard:@"SP1"];
    
    int combo = [slotSettingsManager getInt:@"Combo"];
    
    scoreSceneComboTitleLabel = [CCLabelTTF labelWithString:@"Round Combo" fontName:STATSFONT fontSize:20];
    scoreSceneComboTitleLabel.position = ccp(165, 195);
    scoreSceneComboTitleLabel.color = ccc3(255, 255, 255);
    
    
    scoreSceneComboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", combo] fontName:STATSFONT fontSize:19];
    scoreSceneComboLabel.scale = 5.0f;
    scoreSceneComboLabel.position = ccp(350, 195);
    scoreSceneComboLabel.color = ccc3(255, 255, 255);
    scoreSceneComboLabel.opacity = 0;
    
    [self addChild:scoreSceneComboTitleLabel];
    [self addChild:scoreSceneComboLabel];
    
    questionsCorrectTitle = [CCLabelTTF labelWithString:@"Questions Correct" fontName:STATSFONT fontSize:20];
    questionsCorrectTitle.position = ccp(184, 235);
    questionsCorrectTitle.color = ccc3(255, 255, 255);
    [self addChild:questionsCorrectTitle];
    
    int answeredRight = [self loadAnsweredRightForRound];
    
    questionsCorrect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / 10", answeredRight] fontName:STATSFONT fontSize:20];
    questionsCorrect.scale = 5.0f;
    questionsCorrect.opacity = 0;
    questionsCorrect.position = ccp(350, 235);
    questionsCorrect.color = ccc3(255, 255, 255);
    [self addChild:questionsCorrect];
    
    [questionsCorrect runAction:[CCSequence actions:[CCSpawn actions:[CCFadeIn actionWithDuration:0.5f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    [self performSelector:@selector(starsEffects3) withObject:nil afterDelay:0.5f];
    
    [scoreSceneComboLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    [self performSelector:@selector(starsEffects2) withObject:nil afterDelay:0.13f];
    
    [scoreSceneScoreLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.15f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f],[CCScaleTo actionWithDuration:0.3f scale:1.0f], nil], nil]];
    [self performSelector:@selector(starsEffects) withObject:nil afterDelay:0.18f];
        
    [scoreSceneComboLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [scoreSceneComboTitleLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    
    [scoreSceneScoreLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [scoreSceneScoreTitleLabel runAction:[CCFadeIn actionWithDuration:FADETIME]];
    
    [questionsCorrect runAction:[CCFadeIn actionWithDuration:FADETIME]];
    [questionsCorrectTitle runAction:[CCFadeIn actionWithDuration:FADETIME]];
    //[self wipeScore];

    
    [self resetStats];
    
    [self fadeInReelFacts];
    
    /*
    [factTitle runAction:[CCFadeIn actionWithDuration:1.0f]];
    [fact runAction:[CCFadeIn actionWithDuration:1.0f]];
    [factBG runAction:[CCFadeIn actionWithDuration:1.0f]];
     */
}


- (void) categoryReview {
    if (categoryComplete) {
        [questionsCorrect setString:[NSString stringWithFormat:@"%d / 100",[self getQuestionsCorrect]]];
    }
    else {
        [questionsCorrect setString:[NSString stringWithFormat:@"%d / %d",[self getQuestionsCorrect], [self countMaxRowsForCategory]]];
    }
    
    overallScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [self getOverallScore]] fontName:STATSFONT fontSize:20];
    overallScore.opacity = 0;
    overallScore.position = ccp(350, 115);
    [self addChild:overallScore];
    
    overallScoreTitle = [CCLabelTTF labelWithString:@"Overall Score" fontName:STATSFONT fontSize:20];
    overallScoreTitle.opacity = 0;
    overallScoreTitle.position = ccp(162, 115);
    [self addChild:overallScoreTitle];
    
    categoryScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [self getCategoryScore]] fontName:STATSFONT fontSize:20];
    categoryScore.opacity = 0;
    categoryScore.position = ccp(350, 195);
    [self addChild:categoryScore];
    
    categoryScoreTitle = [CCLabelTTF labelWithString:@"Category Score" fontName:STATSFONT fontSize:20];
    categoryScoreTitle.opacity = 0;
    categoryScoreTitle.position = ccp(169, 195);
    [self addChild:categoryScoreTitle];
    
    finalRank = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [self getRank]] fontName:STATSFONT fontSize:20];
    finalRank.opacity = 0;
    finalRank.position = ccp(350, 155);
    [self addChild:finalRank];
    
    finalRankTitle = [CCLabelTTF labelWithString:@"Category Rank" fontName:STATSFONT fontSize:20];
    finalRankTitle.position = ccp(169, 155);
    finalRankTitle.opacity = 0;
    [self addChild:finalRankTitle];
    
    [overallScore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [overallScoreTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [categoryScoreTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [categoryScore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [finalRank runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [finalRankTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [questionsCorrectTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
    [questionsCorrect runAction:[CCSequence actions:[CCDelayTime actionWithDuration:FADETIME],[CCFadeIn actionWithDuration:FADETIME], nil]];
}

-(int) getOverallScore {
    SettingsManager *overallScoreManager = [SettingsManager sharedSettingsManager];
    [overallScoreManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    return [overallScoreManager getInt:@"Overall Score"];
}

-(int) getCategoryScore {
    SettingsManager *categoryScoreManager = [SettingsManager sharedSettingsManager];
    [categoryScoreManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    return [categoryScoreManager getInt:[NSString stringWithFormat:@"%@ Score", categoryFromCategoryMenu]];
}

-(int) getQuestionsCorrect {
    SettingsManager *questionCorrectManager = [SettingsManager sharedSettingsManager];
    [questionCorrectManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    return [questionCorrectManager getInt:[NSString stringWithFormat:@"%@ Progress", categoryFromCategoryMenu]];
}

-(int) countMaxRowsForCategory {
    [self openSlotDatabase];
	FMResultSet *countQuery = [slotDb executeQuery:@"SELECT COUNT (category_id) FROM usedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];
	}
    [countQuery close];
	return totalCount;
}

-(NSString *) getRank {
    SettingsManager *rankManager = [SettingsManager sharedSettingsManager];
    int tempProgress = [rankManager getInt:[NSString stringWithFormat:@"%@ Progress", categoryFromCategoryMenu]];
    return [self setRank:tempProgress];
}

-(NSString *) setRank:(int)progress {
    NSString *rankLetter = @"";
    if (progress >= 10 && progress <= 29) {
        rankLetter = @"D";
    }
    else if (progress >= 30 && progress <= 49) {
        rankLetter = @"C";
        
    }
    else if (progress >= 50 && progress <= 69) {
        rankLetter = @"B";
        
    }
    else if (progress >= 70 && progress <= 89) {
        rankLetter = @"A";
        
    }
    else if (progress >= 90 && progress <= 100) {
        rankLetter = @"S";
    }
    else {
        rankLetter = @"E";
    }
    return rankLetter;
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
    page++;
    switch (page) {
        case 1:
            [grats runAction:[CCFadeOut actionWithDuration:FADETIME]];
            [self performSelector:@selector(loadScoreFromSettingsManager2) withObject:nil afterDelay:FADETIME];

            break;
        case 2:
            [scoreSceneComboLabel runAction:[CCFadeOut actionWithDuration:FADETIME]];
            [scoreSceneComboTitleLabel runAction:[CCFadeOut actionWithDuration:FADETIME]];
            
            [scoreSceneScoreLabel runAction:[CCFadeOut actionWithDuration:FADETIME]];
            [scoreSceneScoreTitleLabel runAction:[CCFadeOut actionWithDuration:FADETIME]];
            
            [questionsCorrect runAction:[CCFadeOut actionWithDuration:FADETIME]];
            [questionsCorrectTitle runAction:[CCFadeOut actionWithDuration:FADETIME]];
            [self performSelector:@selector(categoryReview) withObject:nil afterDelay:FADETIME];
            [touchToContinue stopAllActions];
            [touchToContinue runAction:[CCFadeOut actionWithDuration:0.5f]];
            [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
            break;
        default:
            break;
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    return TRUE;    
}

-(void) starsEffects3 {
    ccBezierConfig bezier;
    bezier.controlPoint_2 = ccp(30, 10);
    bezier.controlPoint_1 = ccp(0, 0);
    bezier.endPosition = ccp(25, -100);
    
    //stars
    CCSprite *starEffect1 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect1.scale = 0.5;
    starEffect1.opacity = 0.0;
    starEffect1.position = ccp(360, 165);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 165);
    [self addChild:starEffect2];
    [starEffect2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier2;
    bezier2.controlPoint_2 = ccp(30, -20);
    bezier2.controlPoint_1 = ccp(0, 0);
    bezier2.endPosition = ccp(25, -120);
    
    CCSprite *starEffect3 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect3.scale = 0.8;
    starEffect3.opacity = 0.0;
    starEffect3.color = ccc3(250, 250, 0);
    starEffect3.position = ccp(350, 145);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 145);
    [self addChild:starEffect4];
    
    [starEffect4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier3;
    bezier3.controlPoint_2 = ccp(-30, -20);
    bezier3.controlPoint_1 = ccp(0, 0);
    bezier3.endPosition = ccp(-25, -100);
    
    CCSprite *starEffect5 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect5.scale = 0.8;
    starEffect5.opacity = 0.0;
    starEffect5.color = ccc3(250, 250, 0);
    starEffect5.position = ccp(330, 145);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 145);
    [self addChild:starEffect6];
    
    [starEffect6 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier4;
    bezier4.controlPoint_2 = ccp(-30, 20);
    bezier4.controlPoint_1 = ccp(0, 0);
    bezier4.endPosition = ccp(-25, -100);
    
    CCSprite *starEffect7 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect7.scale = 0.8;
    starEffect7.opacity = 0.0;
    starEffect7.color = ccc3(250, 250, 0);
    starEffect7.position = ccp(335, 125);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 125);
    [self addChild:starEffect8];
    
    [starEffect8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
}

-(void) starsEffects2 {
    ccBezierConfig bezier;
    bezier.controlPoint_2 = ccp(30, 10);
    bezier.controlPoint_1 = ccp(0, 0);
    bezier.endPosition = ccp(25, -100);
    
    CCSprite *starEffect1 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect1.scale = 0.5;
    starEffect1.opacity = 0.0;
    starEffect1.position = ccp(360, 165);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 165);
    [self addChild:starEffect2];
    [starEffect2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier2;
    bezier2.controlPoint_2 = ccp(30, -20);
    bezier2.controlPoint_1 = ccp(0, 0);
    bezier2.endPosition = ccp(25, -120);
    
    CCSprite *starEffect3 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect3.scale = 0.8;
    starEffect3.opacity = 0.0;
    starEffect3.color = ccc3(250, 250, 0);
    starEffect3.position = ccp(350, 185);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 185);
    [self addChild:starEffect4];
    
    [starEffect4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier3;
    bezier3.controlPoint_2 = ccp(-30, -20);
    bezier3.controlPoint_1 = ccp(0, 0);
    bezier3.endPosition = ccp(-25, -100);
    
    CCSprite *starEffect5 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect5.scale = 0.8;
    starEffect5.opacity = 0.0;
    starEffect5.color = ccc3(250, 250, 0);
    starEffect5.position = ccp(330, 185);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 185);
    [self addChild:starEffect6];
    
    [starEffect6 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier4;
    bezier4.controlPoint_2 = ccp(-30, 20);
    bezier4.controlPoint_1 = ccp(0, 0);
    bezier4.endPosition = ccp(-25, -100);
    
    CCSprite *starEffect7 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect7.scale = 0.8;
    starEffect7.opacity = 0.0;
    starEffect7.color = ccc3(250, 250, 0);
    starEffect7.position = ccp(335, 205);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 205);
    [self addChild:starEffect8];
    
    [starEffect8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
}

-(void) starsEffects {

    ccBezierConfig bezier;
    bezier.controlPoint_2 = ccp(30, 10);
    bezier.controlPoint_1 = ccp(0, 0);
    bezier.endPosition = ccp(25, -100);
    
    //stars
    CCSprite *starEffect1 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect1.scale = 0.5;
    starEffect1.opacity = 0.0;
    starEffect1.position = ccp(360, 244);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 242);
    [self addChild:starEffect2];
    [starEffect2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier2;
    bezier2.controlPoint_2 = ccp(30, -20);
    bezier2.controlPoint_1 = ccp(0, 0);
    bezier2.endPosition = ccp(25, -120);
    
    CCSprite *starEffect3 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect3.scale = 0.8;
    starEffect3.opacity = 0.0;
    starEffect3.color = ccc3(250, 250, 0);
    starEffect3.position = ccp(350, 220);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 215);
    [self addChild:starEffect4];
    
    [starEffect4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier3;
    bezier3.controlPoint_2 = ccp(-30, -20);
    bezier3.controlPoint_1 = ccp(0, 0);
    bezier3.endPosition = ccp(-25, -120);
    
    CCSprite *starEffect5 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect5.scale = 0.8;
    starEffect5.opacity = 0.0;
    starEffect5.color = ccc3(250, 250, 0);
    starEffect5.position = ccp(330, 232);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 225);
    [self addChild:starEffect6];
    
    [starEffect6 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    ccBezierConfig bezier4;
    bezier4.controlPoint_2 = ccp(-30, 20);
    bezier4.controlPoint_1 = ccp(0, 0);
    bezier4.endPosition = ccp(-25, -100);
    
    CCSprite *starEffect7 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect7.scale = 0.8;
    starEffect7.opacity = 0.0;
    starEffect7.color = ccc3(250, 250, 0);
    starEffect7.position = ccp(335, 245);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 240);
    [self addChild:starEffect8];
    
    [starEffect8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
}


-(int) loadStarTypeFromSettingsManager:(int)saveSlot starTypeNumber:(int)number {
    SettingsManager *starTypeManager = [SettingsManager sharedSettingsManager];
    [starTypeManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveSlot]];
    
    starType = [starTypeManager getInt:[NSString stringWithFormat:@"QuestionStars%d", number]];
    
    return starType;
}

-(void) loadRankFromSettingsManager:(int)saveSlot {
    
}

-(void) loadTimePlayedFromSettingsManager:(int)saveSlot {
    
}

-(int) loadCorrectlyAnsweredFromSettingsManager {
    SettingsManager *answeredManager = [SettingsManager sharedSettingsManager];
    int tempAnswered;
    int answered = 0;
    for (int i = 1; i <= 10; i++) {
        tempAnswered = [answeredManager getInt:[NSString stringWithFormat:@"QuestionStars%d", tempAnswered]];
        if (tempAnswered) {
            answered++;
        }
    }
    
    return answered;
}

-(void) loadStarCombo:(int)saveSlot {
    SettingsManager *slotSettingsManager = [SettingsManager sharedSettingsManager];
	[slotSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveSlot]];
        
    CCSprite *Star1 = [CCSprite spriteWithSpriteFrameName:@"Combo1.png"];
    Star1.position = ccp(105, 130);
    Star1.scale = 10;
    Star1.opacity = 0;
    
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:1]) {
        Star1.color = ccc3(250, 0, 0);
    }
    
    [Star1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(105, 130)], nil], nil]];
    [self addChild:Star1 z:2];
}

- (void) starTwo:(id) sender {
    CCSprite *Star2 = [CCSprite spriteWithSpriteFrameName:@"Combo2.png"];
    Star2.position = ccp(135, 130);
    Star2.scale = 10;
    Star2.opacity = 0;

    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:2]) {
        Star2.color = ccc3(250, 0, 0);
    }

    [Star2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(135, 130)], nil], nil]];
    [self addChild:Star2 z:2];
    [self performSelector:@selector(starThree:) withObject:nil afterDelay:0.5f];
}

- (void) starThree:(id) sender {
    CCSprite *Star3 = [CCSprite spriteWithSpriteFrameName:@"Combo3.png"];
    Star3.position = ccp(165, 130);
    Star3.scale = 10;
    Star3.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:3]) {
        Star3.color = ccc3(250, 0, 0);
    }
    
    [Star3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(165, 130)], nil], nil]];
    [self addChild:Star3 z:2];
    [self performSelector:@selector(starFour:) withObject:nil afterDelay:0.5f];
}

- (void) starFour:(id) sender {
    CCSprite *Star4 = [CCSprite spriteWithSpriteFrameName:@"Combo4.png"];
    Star4.position = ccp(195, 130);
    Star4.scale = 10;
    Star4.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:4]) {
        Star4.color = ccc3(250, 0, 0);
    }
    
    [Star4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(195, 130)], nil], nil]];
    [self addChild:Star4 z:2];
    [self performSelector:@selector(starFive:) withObject:nil afterDelay:0.5f];
}

- (void) starFive:(id) sender {
    CCSprite *Star5 = [CCSprite spriteWithSpriteFrameName:@"Combo5.png"];
    Star5.position = ccp(225, 130);
    Star5.scale = 10;
    Star5.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:5]) {
        Star5.color = ccc3(250, 0, 0);
    }
    
    [Star5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(225, 130)], nil], nil]];
    [self addChild:Star5 z:2];
    [self performSelector:@selector(starSix:) withObject:nil afterDelay:0.5f];
}

- (void) starSix:(id) sender {
    CCSprite *Star6 = [CCSprite spriteWithSpriteFrameName:@"Combo6.png"];
    Star6.position = ccp(255, 130);
    Star6.scale = 10;
    Star6.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:6]) {
        Star6.color = ccc3(250, 0, 0);
    }
    
    [Star6 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(255, 130)], nil], nil]];
    [self addChild:Star6 z:2];
    [self performSelector:@selector(starSeven:) withObject:nil afterDelay:0.5f];
}

- (void) starSeven:(id) sender {
    CCSprite *Star7 = [CCSprite spriteWithSpriteFrameName:@"Combo7.png"];
    Star7.position = ccp(285, 130);
    Star7.scale = 10;
    Star7.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:7]) {
        Star7.color = ccc3(250, 0, 0);
    }
    
    [Star7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(285, 130)], nil], nil]];
    [self addChild:Star7 z:2];
    [self performSelector:@selector(starEight:) withObject:nil afterDelay:0.5f];
}

- (void) starEight:(id) sender {
    CCSprite *Star8 = [CCSprite spriteWithSpriteFrameName:@"Combo8.png"];
    Star8.position = ccp(315, 130);
    Star8.scale = 10;
    Star8.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:8]) {
        Star8.color = ccc3(250, 0, 0);
    }
    
    [Star8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(315, 130)], nil], nil]];
    [self addChild:Star8 z:2];
    [self performSelector:@selector(starNine:) withObject:nil afterDelay:0.5f];
}

- (void) starNine:(id) sender {
    CCSprite *Star9 = [CCSprite spriteWithSpriteFrameName:@"Combo9.png"];
    Star9.position = ccp(345, 130);
    Star9.scale = 10;
    Star9.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:9]) {
        Star9.color = ccc3(250, 0, 0);
    }
    
    [Star9 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(345, 130)], nil], nil]];
    [self addChild:Star9 z:2];
    [self performSelector:@selector(starTen:) withObject:nil afterDelay:0.5f];
}

- (void) starTen:(id) sender {
    CCSprite *Star10 = [CCSprite spriteWithSpriteFrameName:@"Combo10.png"];
    Star10.position = ccp(375, 130);
    Star10.scale = 10;
    Star10.opacity = 0;
    
    if (![self loadStarTypeFromSettingsManager:save starTypeNumber:10]) {
        Star10.color = ccc3(250, 0, 0);
    }
    
    [Star10 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCRotateBy actionWithDuration:0.5f angle:360], [CCScaleTo actionWithDuration:0.5f scale:1.5],[CCMoveTo actionWithDuration:0.5f position:ccp(375, 130)], nil], nil]];
    [self addChild:Star10 z:2];
}
    

-(void) clearStarsInPLIST:(int) saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    for (int i = 1; i <= 10; i++) {
        [saveSettingsManager setBool:FALSE keyString:[NSString stringWithFormat:@"QuestionStars%d", i]];
    }
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    
}

- (void) runComboEffect:(id) sender {
    CCSprite *sprite = (CCSprite *) sender;
    
    [self createStars:ccp(sprite.position.x, sprite.position.y) starNumber:sprite.tag];
}

- (void) createStars:(CGPoint)position starNumber:(int)number {
    CCSprite *star = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Combo%d.png", number]];
    star.position = position;
    star.color = ccc3(130, 0, 0);
    star.scale = 1.5;
    [self addChild:star z:3];
}

- (void) dealloc {
    
    [super dealloc];
}

@end
