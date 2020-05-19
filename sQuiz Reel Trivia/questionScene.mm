//
//  questionScene.m
//  TriviaMenu
//
//  Created by mark wong on 1/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//Combo colour 0 Red (wrong) 1 Yellow (right) 2 Green (skipped)
#import "questionScene.h"

#define FONT_SIZE 13
#define EMPTY_STAR_POSITION_X 20
#define EMPTY_STAR_POSITION_Y 305

#define MENU_SELECT_FORWARD @"MenuSelectForward.caf"
#define MENU_SELECT_BACK @"MenuSelectBack.caf"

#define QUESTION_FONT @"OpenSans-Bold.ttf"
#define ANSWER_FONT @"OpenSans-Regular.ttf"
#define PAUSE_FONT @"OpenSans-Bold.ttf"
#define BMFONTREGULAR13 @"OpenSans-Regular13.fnt"
#define BMFONTBOLD12 @"OpenSans-Bold12.fnt"
#define CATEGORYTEXT90 @"CategoryText90.fnt"

#define BUTTON_TINT_DELAY 2.5f
#define PAUSE_BETWEEN_QUESTIONS 3.5f
#define LABEL_FADING_DELAY 2.5f

#define TIME_LIMIT 60
#define COMBO_STAR_Y 304

#define GameClick @"gameplayClick.caf"

@implementation questionScene
static int save;
static NSString * categoryFromCategoryMenu;
static int level;

+(id) scene:(int) saveSlot category:(NSString *) categoryName lvl:(int)levelNumber {
	CCScene *scene = [CCScene node];
	save = saveSlot;
	categoryFromCategoryMenu = categoryName;
    level = levelNumber;
    
	questionScene *layer = [questionScene node];

	[scene addChild: layer];

	return scene;
}

-(void) SoundSettings {
    
    SettingsManager *soundSettings = [SettingsManager sharedSettingsManager];
    [soundSettings loadFromFileInLibraryDirectory:@"SoundSettings.plist"];
    BOOL fileCreated = [soundSettings getBool:@"FileCreated"];
    
    if (fileCreated) {
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

-(id) init
{
	if( ( self = [super init] )) {
        questionFont = [NSString stringWithFormat:@"OpenSans-Bold.ttf"];
		questionNumberArrayIndex = 0;
        skippedNumberIndex = 0;
		score = 0;
        answeredRight = 0;
        consecutiveAnswers = 0;
		questionLabel.tag = 15;
        countdownSkipped = FALSE;
        TICKTOCK = TRUE;
        categoryComplete = FALSE;
        Time = TIME_LIMIT;
        TimeTaken = 0;
        
        pauseLayer = [[CCLayer alloc] init];
        backGroundLayer = [[CCLayer alloc] init];
        curtainLayer = [[CCLayer alloc] init];
        screenLayer = [[CCLayer alloc] init];
        buttonLayer = [[CCLayer alloc] init];
        menuLayer = [[CCLayer alloc] init];

        [self addChild:screenLayer z:2];
        [self addChild:curtainLayer z:3];
        [self addChild:backGroundLayer z:1];
        [self addChild:buttonLayer z:5];

        leftCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        leftCurtain.position = ccp(-30, 184);
        leftCurtain.flipX = TRUE;
        [curtainLayer addChild:leftCurtain z:6];
        
        rightCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        rightCurtain.position = ccp(510, 184);
        [curtainLayer addChild:rightCurtain z:6];
        
        BG = [CCSprite spriteWithSpriteFrameName:@"CategoryMenuBG.png"];
        BG.position = ccp(240, 25);
        [backGroundLayer addChild:BG z:1];
        
        countdownNumber = [CCLabelTTF labelWithString:@"599" fontName:questionFont fontSize:170];
        countdownNumber.opacity = 0;
        countdownNumber.color = ccc3(0, 0, 0);
        countdownNumber.position = ccp(240, 170);
        countdownNumber.tag = 21;
        [screenLayer addChild:countdownNumber z:10];
        
		menuLayer.position = ccp(0, 0);
		[self addChild:menuLayer z:2];
        
        categoryComplete = [self checkIfCategoryHasBeenCompleted];
            
        NSString *levelName = [NSString stringWithFormat:@"Level%d.sqlite", level];
        
        [self openDatabase:levelName];
        [self openSlotDatabase:[NSString stringWithFormat:@"Slot%d.sqlite", save]];
        [self openScoringDatabase];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsBGSpriteSheet.plist"];
        BGSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"grainsBGSpriteSheet.pvr.ccz"];
        [screenLayer addChild:BGSpriteSheet z:2];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsSpriteSheet.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"grainsSpriteSheet.pvr"];
        [screenLayer addChild:spriteSheet z:2];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CategoryText.plist"];
        
        //CategoryText = [CCSpriteBatchNode batchNodeWithFile:@"CategoryText.pvr.ccz"];
        //[screenLayer addChild:CategoryText];
        
        lineGrain = [CCSprite spriteWithSpriteFrameName:@"Line.png"];
        lineGrain.position = ccp(100, 140);
        
        [spriteSheet addChild:lineGrain];
        lineGrain.tag = 22;
        
        if ([categoryFromCategoryMenu isEqualToString:@"RomanticComedy"]) {
            categoryText = [CCLabelBMFont labelWithString:@"Romantic Comedy" fntFile:CATEGORYTEXT90];
        }
        else if ([categoryFromCategoryMenu isEqualToString:@"SciFi"]) {
            categoryText = [CCLabelBMFont labelWithString:@"Science Fiction" fntFile:CATEGORYTEXT90];
        }
        else {
            categoryText = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", categoryFromCategoryMenu] fntFile:CATEGORYTEXT90];
        }
        
        categoryText.opacity = 0;
        categoryText.position = ccp(400, 100);
        categoryText.tag = 23;
        [screenLayer addChild:categoryText z:2];
        
        SettingsManager *S1 = [SettingsManager sharedSettingsManager];
        [S1 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
        [S1 setBool:FALSE keyString:@"didRoundEnd"];
        [S1 setString:categoryFromCategoryMenu keyString:@"CurrentCategory"];
        [S1 saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];

        
        [self startCountdown];
        [self startAnimationQuestionScene];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        [self performSelector:@selector(checkIfCountdownSkipped) withObject:self afterDelay:2.5f];
    }
	return self;
} 

-(void) checkIfCountdownSkipped {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

    if (!countdownSkipped) {
        [self performSelector:@selector(finishCountdown) withObject:self afterDelay:0.0f];
    }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    countdownSkipped = TRUE;
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

    [[CCActionManager sharedManager] removeAllActionsFromTarget:countdownNumber];
    [screenLayer removeChildByTag:21 cleanup:YES];
    [[CCActionManager sharedManager] removeAllActionsFromTarget:lineGrain];
    [spriteSheet removeChildByTag:22 cleanup:YES];
    
    [spriteSheet removeAllChildrenWithCleanup:YES];
    [[CCActionManager sharedManager] removeAllActionsFromTarget:categoryText];
    [screenLayer removeChildByTag:23 cleanup:YES];
    [self performSelector:@selector(finishCountdown) withObject:self afterDelay:0.0f];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
	
    return TRUE;    
}

-(void) clearStarsInPLIST:(int) saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    for (int i = 1; i <= 10; i++) {
        [saveSettingsManager setBool:FALSE keyString:[NSString stringWithFormat:@"QuestionStars%d", i]];
    }
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    
}

-(BOOL) checkIfCategoryHasBeenCompleted {
    SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
    [categoryCompleteManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];

    return [categoryCompleteManager getBool:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]];
}

-(void) checkIfOneHundredQuestionsInUsedQuestions {
    FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (category_id) FROM usedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];
	}
    [countQuery close];
    

    if ((!(totalCount % 100)) && (totalCount != 0)) {

        SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
        [categoryCompleteManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
        [categoryCompleteManager setBool:TRUE keyString:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]]; 
        [categoryCompleteManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
        

        [SlotDb beginTransaction];
        [SlotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", categoryFromCategoryMenu];
        [SlotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
        [SlotDb commit];
        
    }
    else {
        SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
        [categoryCompleteManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
        [categoryCompleteManager setBool:FALSE keyString:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]]; 
        [categoryCompleteManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    }

}

-(void) loadStarsAfterQuitting:(int) saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    int coordX = EMPTY_STAR_POSITION_X;
    
    for (int i = 1; i <= theRoundQuestionNumber; i++) {

        [self createStarCombo:ccp(coordX, COMBO_STAR_Y+1) starTag:i comboNumber:i colour:[saveSettingsManager getInt:[NSString stringWithFormat:@"QuestionStars%d", i]]];
        coordX = coordX + 18;
    }
}

-(void) saveStarsAfterQuitting:(int)saveNumber starNumber:(int)number answerType:(int)answered {
    
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];

    [saveSettingsManager setInteger:answered keyString:[NSString stringWithFormat:@"QuestionStars%d", number]];
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
}

-(int) checkComboIfHigherThanCurrentCombo:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    return [saveSettingsManager getInt:@"Combo"];
}

-(int) loadComboFromSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    SaveCombo = [saveSettingsManager getInt:@"Combo"];

    return SaveCombo;
}

-(void) saveComboToSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];

    [saveSettingsManager setInteger:consecutiveAnswers keyString:@"Combo"];//consecutiveAnswers
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
}

- (void) loadCurrentQuestionFromSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    theRoundQuestionNumber = [saveSettingsManager getInt:@"CurrentQuestion"];
}

- (void) saveCurrentQuestionToSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    [saveSettingsManager setInteger:theRoundQuestionNumber keyString:@"CurrentQuestion"];
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
}

- (void) loadScoreFromSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    //totalScore 
    CategoryScore = [saveSettingsManager getInt:[NSString stringWithFormat:@"%@ Score", categoryFromCategoryMenu]];
    RoundScore = [saveSettingsManager getInt:@"Round Score"];
}

- (void) saveScoreToSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
    [saveSettingsManager setInteger:RoundScore keyString:@"Round Score"];
    
    [saveSettingsManager setInteger:CategoryScore keyString:[NSString stringWithFormat:@"%@ Score", categoryFromCategoryMenu]];
    if (!categoryComplete) {
        int tempTotalScore = 0;
        tempTotalScore = [saveSettingsManager getInt:[NSString stringWithFormat:@"Overall Score"]];
        tempTotalScore = tempTotalScore + score;
        [saveSettingsManager setInteger:tempTotalScore keyString:@"Overall Score"];
    }
    
    [saveSettingsManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveNumber]];
}


- (void) startCountdown {
    countdownBackground = [CCSprite spriteWithSpriteFrameName:@"CountdownBG.png"];
    countdownBackground.position = ccp(240, 160);
    countdownBackground.opacity = 0;
    [BGSpriteSheet addChild:countdownBackground z:1];
    
    crosshairBg = [CCSprite spriteWithSpriteFrameName:@"Crosshair.png"];
    crosshairBg.position = ccp(240, 160);
    [screenLayer addChild:crosshairBg z:2];
    [crosshairBg runAction:[CCFadeIn actionWithDuration:1.0f]];
    
    NSMutableArray *grainAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 5; ++i) {
        [grainAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grain%d.png", i]]];
    }
    
    [lineGrain runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.0f], [CCRepeat actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.5 position:ccp(-20,0)], [CCMoveBy actionWithDuration:0.3 position:ccp(40,0)], [CCMoveBy actionWithDuration:0.1 position:ccp(-20,0)],  nil] times:3], [CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveSpriteSheet:)], nil]];

    CCAnimation *grainAnim = [CCAnimation animationWithFrames:grainAnimFrames delay:0.1f];
    grain1 = [CCSprite spriteWithSpriteFrameName:@"grain1.png"];
    grain1.scale = 0.5;
    grain1.position = ccp(460, 190);
    grain1.tag = 23;
    grain2 = [CCSprite spriteWithSpriteFrameName:@"grain2.png"];
    grain2.scale = 0.5;
    grain2.position = ccp(160, 90);
    grain1.tag = 24;
    grain3 = [CCSprite spriteWithSpriteFrameName:@"grain3.png"];
    grain3.scale = 0.5;
    grain3.position = ccp(420, 240);
    grain1.tag = 25;
    grain4 = [CCSprite spriteWithSpriteFrameName:@"grain4.png"];
    grain4.scale = 0.5;
    grain4.position = ccp(100, 290);
    grain1.tag = 26;
    [grain1 runAction:[CCSequence actions:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:grainAnim restoreOriginalFrame:NO] times:6], nil]];
    [grain2 runAction:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:grainAnim restoreOriginalFrame:NO] times:6]];
    [grain3 runAction:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:grainAnim restoreOriginalFrame:NO] times:6]];
    [grain4 runAction:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:grainAnim restoreOriginalFrame:NO] times:6]];
    
    [spriteSheet addChild:grain1];
    [spriteSheet addChild:grain2];
    [spriteSheet addChild:grain3];
    [spriteSheet addChild:grain4];
        
    [countdownBackground runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.0f], [CCFadeIn actionWithDuration:0.7f], [CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05f scale:1.0], [CCScaleTo actionWithDuration:0.15f scale:0.95], [CCScaleTo actionWithDuration:0.2f scale:0.92], [CCScaleTo actionWithDuration:0.3f scale:0.95], nil] times:3], nil]];
    
    [categoryText runAction:[CCSequence actions:[CCSpawn actions:[CCFadeIn actionWithDuration:0.2f],[CCMoveBy actionWithDuration:2.5f position:ccp(-100,0)], nil], [CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];
        
    CCSprite *threeReverse = [CCSprite spriteWithFile:@"Three_reverse.png"];
    threeReverse.position = ccp(90, 205);
    threeReverse.scale = 0.35;
    threeReverse.opacity = 0;
    [screenLayer addChild:threeReverse z:2];
    
    [countdownNumber setString:@"3"];
    [countdownNumber runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(CDTwo:)], nil]];
    
    [threeReverse runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.1f], [CCMoveBy actionWithDuration:0.08f position:ccp(0, -35)], [CCMoveBy actionWithDuration:0.0f position:ccp(0, 35)], [CCDelayTime actionWithDuration:0.2f], [CCFadeOut actionWithDuration:0.0f], [CCMoveBy actionWithDuration:0.12f position:ccp(0, -55)], [CCFadeIn actionWithDuration:0.0f], [CCDelayTime actionWithDuration:0.4], [CCFadeOut actionWithDuration:0.0f], [CCDelayTime actionWithDuration:0.1f], [CCFadeIn actionWithDuration:0.0f], [CCDelayTime actionWithDuration:0.2f], [CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];    
    
}

- (void) CDTwo: (id) sender {

    CCSprite *twoReverse = [CCSprite spriteWithFile:@"Two_reverse.png"];
    twoReverse.position = ccp(80, 205);
    twoReverse.scale = 0.35;
    twoReverse.opacity = 0;
    [screenLayer addChild:twoReverse z:2];

    [countdownNumber setString:@"2"];
    [countdownNumber runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];

    [twoReverse runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.0f], [CCMoveBy actionWithDuration:0.08f position:ccp(0, -35)], [CCMoveBy actionWithDuration:0.0f position:ccp(0, 35)], [CCDelayTime actionWithDuration:0.5f], [CCMoveBy actionWithDuration:0.12f position:ccp(0, -35)], [CCMoveBy actionWithDuration:0.0f position:ccp(0, 35)], [CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];
}

-(void) scheduleUpdate: (ccTime) dt {

    Time = Time - 1;
    if (Time <= 10) {
        TICKTOCK = !TICKTOCK;
        if (TICKTOCK) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
        }
        else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"tock.caf"];
        }
        [timerLabel setString:[NSString stringWithFormat:@"%d", Time]];
        [timerLabel runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0 scale:1.2], [CCScaleTo actionWithDuration:0.3 scale:1.0], nil]];
    }
    else {
        [timerLabel setString:[NSString stringWithFormat:@"%d", Time]];
    }
    
    if (Time == 0) {
        [self unschedule:@selector(scheduleUpdate:)];
        [self timeOver];
    }
}

-(void) selectMusic {
    int randomMusic = arc4random() % 6 + 1;

    switch (randomMusic) {
        case 1:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GameplayBGM1.aif" loop:YES];
            break;
        case 2:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"In Game loop2.aif" loop:YES];
            break;
        case 3:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"My Life.aif" loop:YES];
            break;
        case 4:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Calm Beach Walk.aif" loop:YES];
            break;
        case 5:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Free.aif" loop:YES];
            break;
        case 6:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Dark Uncertainty.aif" loop:YES];
            break;
        default:
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"In Game loop2.aif" loop:YES];
            break;
    }
}


- (void) finishCountdown {
    
    if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [self selectMusic];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];
    }
    else {
        [self selectMusic];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];
    }
    
    [self SoundSettings];
    
    if (BGM) {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.5f;
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
    
    levelBgSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"GameBgLevel%dSS.pvr", level]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"GameBgLevel%dSS.plist", level] texture:levelBgSpriteSheet];
    
    [countdownBackground runAction:[CCFadeOut actionWithDuration:0.5f]];

    self.isTouchEnabled = YES;

    ShuffledQuestionList = [[NSMutableArray alloc] init];
    
    if ([self checkCategory:categoryFromCategoryMenu]) {
        [self shuffleQuestions:categoryFromCategoryMenu];
        [self saveShuffledQuestions:categoryFromCategoryMenu];
    }

    [self loadNumberOfAnsweredRight:save];
    
    maxRowsForCategory = [self countMaximumRowsForCategory];
    NSLog(@"%d maxrows", maxRowsForCategory);
    resumeFromRow = [self countRowPlayerIsUpTo];
    NSLog(@"resumefrom %d", resumeFromRow);
    if (resumeFromRow >= 1) {
        questionNumberArrayIndex = resumeFromRow;
    }
    //questionNumberArrayIndex = 89;

    if (!endOfRound) {
        [self loadCurrentQuestionFromSettingsManager:save];  
        
        if (theRoundQuestionNumber != 0) {

            [self loadStarsAfterQuitting:save];
        }
    }

    [crosshairBg runAction:[CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)]];
    
    int emptyStarPositionX = EMPTY_STAR_POSITION_X;
    int emptyStarPositionY = EMPTY_STAR_POSITION_Y;
    for (int i = 0; i < 10; i++) {
        [self createEmptyStar:ccp(emptyStarPositionX, emptyStarPositionY)];
        emptyStarPositionX = emptyStarPositionX + 18;
    }
    
    pauseButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"PauseButton.png"] selectedSprite:nil target:self selector:@selector(pauseButton:)];
    pauseButton.position = ccp(460, 305);
    
    //skipButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SkipButton.png"] selectedSprite:nil target:self selector:@selector(confirmSkip:)];
    //skipButton.position = ccp(400, 305); 
    //[skipButton setIsEnabled:FALSE];
    
    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
    menu.position = ccp(0, 0);
    [screenLayer addChild:menu z:5];
    
    CategoryBackground = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@NoText.png", categoryFromCategoryMenu]];
    CategoryBackground.position = ccp(240, 160);
    [screenLayer addChild:CategoryBackground z:1];

    questionNumberLabel = [CCLabelTTF labelWithString:@"" fontName:@"Broadway BT" fontSize:60];
    questionNumberLabel.position = ccp(240, 245);
    questionNumberLabel.opacity = 150;
    questionNumberLabel.color = ccc3(170, 170, 170);
    [buttonLayer addChild:questionNumberLabel z:3];
    
    scoreLabel = [CCLabelBMFont labelWithString:@"000000" fntFile:@"broadway.fnt"];
    scoreLabel.position = ccp(376, 305);
    [screenLayer addChild:scoreLabel z:5];
    [self loadScoreFromSettingsManager:save];
    [scoreLabel setString:[NSString stringWithFormat:@"%06d", CategoryScore]];

    scoreAddLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"broadway.fnt"];
    scoreAddLabel.position = ccp(396, 287);
    [screenLayer addChild:scoreAddLabel z:5];
    
    timerLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", TIME_LIMIT] fntFile:@"timer.fnt"];
    timerLabel.position = ccp(240, 305);
    [screenLayer addChild:timerLabel z:5];
    
    questionLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:410 alignment:UITextAlignmentCenter];

    questionLabel.position = ccp(240 , 247);
    questionLabel.color = ccc3(0, 0, 0);
    [buttonLayer addChild:questionLabel z:3];

    questionBox = [CCSprite spriteWithSpriteFrameName:@"QuestionBox.png"];
    questionBox.position = ccp(240, 245);

    [buttonLayer addChild:questionBox z:2];

    aButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"AButton.png"] selectedSprite:nil target:self selector:@selector(buttonACheck:)];
    
    ALabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:352 alignment:UITextAlignmentCenter];
    ALabel.color = ccc3(0, 0, 0);
    ALabel.position = ccp(180, 30);
    ALabel.tag = 11;
    [aButton addChild:ALabel z:1];
    
    bButton =   [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BButton.png"] selectedSprite:nil target:self selector:@selector(buttonBCheck:)];

    BLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:352 alignment:UITextAlignmentCenter];

    BLabel.color = ccc3(0, 0, 0);
    BLabel.position = ccp(180, 30);

    BLabel.tag = 12;
    [bButton addChild:BLabel];
    
    cButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"CButton.png"] selectedSprite:nil target:self selector:@selector(buttonCCheck:)];
    CLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:352 alignment:UITextAlignmentCenter];
    CLabel.color = ccc3(0, 0, 0);
    CLabel.position = ccp(180, 30);
    CLabel.tag = 13;
    [cButton addChild:CLabel];
    
    dButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"DButton.png"] selectedSprite:nil target:self selector:@selector(buttonDCheck:)];

    DLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:352 alignment:UITextAlignmentCenter];

    DLabel.color = ccc3(0, 0, 0);
    DLabel.position = ccp(180, 30);

    DLabel.tag = 14;
    [dButton addChild:DLabel];
    
    CCMenu *buttonsMenu = [CCMenu menuWithItems:aButton, bButton, cButton, dButton, nil];
    buttonsMenu.position = ccp(240, 110);
    [buttonsMenu alignItemsVerticallyWithPadding:1.0f];
    [buttonLayer addChild:buttonsMenu];

    eliminate = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"Eliminate.png"] selectedSprite:nil target:self selector:@selector(eliminate:)];

    fiftyFifty = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"5050.png"] selectedSprite:nil target:self selector:@selector(fiftyFifty:)];

    if ([self checkIfEliminateUsed]) {
        eliminate.color = ccc3(150, 150, 150);
        [eliminate setIsEnabled:FALSE];
    }
    
    if ([self checkIfFiftyFiftyUsed]) {
        fiftyFifty.color = ccc3(150, 150, 150);
        [fiftyFifty setIsEnabled:FALSE];
    }
    
    CCMenu *lifeLines = [CCMenu menuWithItems:eliminate, fiftyFifty, nil];
    lifeLines.position = ccp(460, 40);
    [lifeLines alignItemsVerticallyWithPadding:20.0];
    
    [buttonLayer addChild:lifeLines];

    [self loadComboFromSettingsManager:save];
    [self prepareQuestionList];
    [self getNextQuestion];
}

-(BOOL) checkIfEliminateUsed {
    SettingsManager *eliminateManager = [SettingsManager sharedSettingsManager];
    [eliminateManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    return [eliminateManager getBool:@"usedEliminate"];
}

-(BOOL) checkIfFiftyFiftyUsed {
    SettingsManager *fiftFiftyManager = [SettingsManager sharedSettingsManager];
    [fiftFiftyManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    return [fiftFiftyManager getBool:@"usedFiftyFifty"];
}

- (void) eliminate:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];

    int letterNumber;
    
    if ([Answer isEqualToString:@"A"]) {
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 1);
        
        if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }
    }
    else if ([Answer isEqualToString:@"B"]) {
        
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 2);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }
    }
    else if ([Answer isEqualToString:@"C"]) {

        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 3);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }
        
    }
    else if ([Answer isEqualToString:@"D"]) {

        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 4);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
    }

    [eliminate setIsEnabled:FALSE];
    [eliminate runAction:[CCTintTo actionWithDuration:0.5f red:150 green:150 blue:150]];
    [fiftyFifty setIsEnabled:FALSE];
    [fiftyFifty runAction:[CCTintTo actionWithDuration:0.5f red:150 green:150 blue:150]];
    [self setEliminateUsedToTrue];
}

- (void) fiftyFifty:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];

    int letterNumber = 0;
    int letterNumber2 = 0;
    
    if ([Answer isEqualToString:@"A"]) {
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 1);
        
        if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }
        do {
            letterNumber2 = arc4random() % 4 + 1;
        } while ((letterNumber2 == letterNumber) || (letterNumber2 == 1));
        
        if (letterNumber2 == 2) {
            [self greyOutB];
        }
        else if (letterNumber2 == 3) {
            [self greyOutC];
        }
        else if (letterNumber2 == 4) {
            [self greyOutD];
        }
    }
    else if ([Answer isEqualToString:@"B"]) {
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 2);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }

        do {
            letterNumber2 = arc4random() % 4 + 1;

        } while ((letterNumber2 == letterNumber) || (letterNumber2 == 2));

        
        if (letterNumber2 == 1) {
            [self greyOutA];
        }
        else if (letterNumber2 == 3) {
            [self greyOutC];
        }
        else if (letterNumber2 == 4) {
            [self greyOutD];
        }
    }
    else if ([Answer isEqualToString:@"C"]) {
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 3);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 4) {
            [self greyOutD];
        }
        
        do {
            letterNumber2 = arc4random() % 4 + 1;
        } while ((letterNumber2 == 3) || (letterNumber2 == letterNumber));
        
        if (letterNumber2 == 1) {
            [self greyOutA];
        }
        else if (letterNumber2 == 2) {
            [self greyOutB];
        }
        else if (letterNumber2 == 4) {
            [self greyOutD];
        }
    }
    else if ([Answer isEqualToString:@"D"]) {
        do {
            letterNumber = arc4random() % 4 + 1;
        } while (letterNumber == 4);
        
        if (letterNumber == 1) {
            [self greyOutA];
        }
        else if (letterNumber == 2) {
            [self greyOutB];
        }
        else if (letterNumber == 3) {
            [self greyOutC];
        }
        do {
            letterNumber2 = arc4random() % 4 + 1;
        } while ((letterNumber2) == 4 || (letterNumber2 == letterNumber));
        
        if (letterNumber2 == 1) {
            [self greyOutA];
        }
        else if (letterNumber2 == 2) {
            [self greyOutB];
        }
        else if (letterNumber2 == 3) {
            [self greyOutC];
        }
    }

    [fiftyFifty setIsEnabled:FALSE];
    [fiftyFifty runAction:[CCTintTo actionWithDuration:0.5f red:150 green:150 blue:150]];
    [eliminate setIsEnabled:FALSE];
    [eliminate runAction:[CCTintTo actionWithDuration:0.5f red:150 green:150 blue:150]];
    [self setFiftyFiftyToTrue];
}

-(void) setEliminateUsedToTrue {
    
    SettingsManager *lifeLineManager = [SettingsManager sharedSettingsManager];
    [lifeLineManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [lifeLineManager setBool:TRUE keyString:@"usedEliminate"];
    [lifeLineManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) setEliminateUsedToFalse {
    SettingsManager *lifeLineManager = [SettingsManager sharedSettingsManager];
    [lifeLineManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [lifeLineManager setBool:FALSE keyString:@"usedEliminate"];
    [lifeLineManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) setFiftyFiftyToTrue {
    SettingsManager *lifeLineManager = [SettingsManager sharedSettingsManager];
    [lifeLineManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [lifeLineManager setBool:TRUE keyString:@"usedFiftyFifty"];
    [lifeLineManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) setFiftyFiftyToFalse {
    SettingsManager *lifeLineManager = [SettingsManager sharedSettingsManager];
    [lifeLineManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [lifeLineManager setBool:FALSE keyString:@"usedFiftyFifty"];
    [lifeLineManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

- (void) greyOutA {
    [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:1.0f red:250 green:250 blue:0], [CCTintTo actionWithDuration:0.3f red:150 green:150 blue:150], nil]];
    [aButton setIsEnabled:FALSE];
}

- (void) greyOutB {
    [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:1.0f red:250 green:250 blue:0], [CCTintTo actionWithDuration:0.3f red:150 green:150 blue:150], nil]];
    [bButton setIsEnabled:FALSE];

}
    
- (void) greyOutC {
    [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:1.0f red:250 green:250 blue:0], [CCTintTo actionWithDuration:0.3f red:150 green:150 blue:150], nil]];
    [cButton setIsEnabled:FALSE];

}

- (void) greyOutD {
    [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:1.0f red:250 green:250 blue:0], [CCTintTo actionWithDuration:0.3f red:150 green:150 blue:150], nil]];
    [dButton setIsEnabled:FALSE];

}

- (void) startAnimationQuestionScene {
    [self zoomInBG];
    [self openCurtains];
    [self fadeLightsOut];
}

- (void) zoomOutBG {
    [curtainLayer runAction:[CCScaleTo actionWithDuration:2.0f scale:1.0f]];
    [buttonLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:0.76f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, 30)], nil]];
    [screenLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:0.76f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, 30)], nil]];
    [CategoryBackground runAction:[CCFadeTo actionWithDuration:2.0f opacity:150]];
    [backGroundLayer runAction:[CCScaleTo actionWithDuration:1.7f scale:1.0f]];
}

- (void) zoomInBG {
    [backGroundLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:1.7f scale:1.5f], nil]];
    [curtainLayer runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];
}

- (void) zoomAfterResume {
    [screenLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:1.0f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, -30)], nil]];
    [buttonLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:1.0f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, -30)], nil]];
    [CategoryBackground runAction:[CCFadeTo actionWithDuration:2.0f opacity:255]];

    [backGroundLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:1.7f scale:1.5f], nil]];
    [curtainLayer runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];
}

- (void) openCurtains {
    id scaleAndMoveLeft = [CCSpawn actions:[CCMoveTo actionWithDuration:6.0f position:ccp(-92, 184)], [CCTintTo actionWithDuration:4.0f red:100 green:10 blue:10], nil];
    id scaleAndMoveRight = [CCSpawn actions:[CCMoveTo actionWithDuration:6.0f position:ccp(572, 184)], [CCTintTo actionWithDuration:4.0f red:100 green:10 blue:10], nil];

    [leftCurtain runAction:scaleAndMoveLeft];
    [rightCurtain runAction:scaleAndMoveRight];
}

- (void) closeCurtains {
    id scaleAndMoveLeft = [CCSpawn actions:[CCMoveTo actionWithDuration:6.0f position:ccp(-30, 184)], [CCTintTo actionWithDuration:4.0f red:255 green:255 blue:255], nil];
    id scaleAndMoveRight = [CCSpawn actions:[CCMoveTo actionWithDuration:6.0f position:ccp(510, 184)], [CCTintTo actionWithDuration:4.0f red:255 green:255 blue:255], nil];
    
    [leftCurtain runAction:scaleAndMoveLeft];
    [rightCurtain runAction:scaleAndMoveRight];
}

- (void) fadeLightsIn {
    [leftCurtain runAction:[CCTintTo actionWithDuration:3.0f red:190 green:190 blue:190]];
    [rightCurtain runAction:[CCTintTo actionWithDuration:3.0f red:190 green:190 blue:190]];
}

- (void) fadeLightsOut {
    [leftCurtain runAction:[CCTintTo actionWithDuration:3.0f red:100 green:100 blue:100]];
    [rightCurtain runAction:[CCTintTo actionWithDuration:3.0f red:100 green:100 blue:100]];
}

- (void) openScoringDatabase {
    BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:@"Scoring.sqlite"];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Scoring.sqlite"];
	
	BOOL forceRefresh = FALSE;
	
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	if (!success || forceRefresh) {
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];

	}
	
	scoringDb = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([scoringDb open]) {
		
		[scoringDb setTraceExecution: FALSE];
		[scoringDb setLogsErrors: TRUE];
		
		databaseOpened = TRUE;
		
		[scoringDb setShouldCacheStatements:FALSE];
		
	} else {

        databaseOpened = FALSE;
    }
}

- (void) openSlotDatabase:(NSString *)dbName {
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:dbName];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
	
	BOOL forceRefresh = FALSE;
	
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	if (!success || forceRefresh) {
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];

	}
	
	SlotDb = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([SlotDb open]) {		
		[SlotDb setTraceExecution: FALSE];
		[SlotDb setLogsErrors: TRUE];
		
		databaseOpened = TRUE;
		
		[SlotDb setShouldCacheStatements:FALSE];
		
	} else {

        databaseOpened = FALSE;
    }
}

- (void) openDatabase:(NSString*) dbName {
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, TRUE);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:dbName];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];

    [fileManager removeItemAtPath:writableDBPath error:&error];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];	
	db = [[FMDatabase databaseWithPath:writableDBPath] retain];
	
	if ([db open]) {
		
		[db setTraceExecution: FALSE];
		[db setLogsErrors: TRUE];
		
		databaseOpened = TRUE;
		
		[db setShouldCacheStatements:FALSE];
	} else {
        databaseOpened = FALSE;
    }	
}

- (void) buttonACheck:(id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    
    
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveCurrentQuestionToSettingsManager:save];
    [self checkAnswer:@"A"];
}

- (void) buttonBCheck: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveCurrentQuestionToSettingsManager:save];
	[self checkAnswer:@"B"];
}

- (void) buttonCCheck: (id) sender {

    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveCurrentQuestionToSettingsManager:save];
	[self checkAnswer:@"C"];
    
}

- (void) buttonDCheck: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:GameClick];

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveCurrentQuestionToSettingsManager:save];
	[self checkAnswer:@"D"];
    
}

- (void) fadeLabelsOutAndInBetweenQuestions {
    [ALabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [BLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [CLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [DLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [questionLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
}

- (void) createEmptyStar:(CGPoint)position {
    CCSprite *emptyStar = [CCSprite spriteWithSpriteFrameName:@"EmptyCombo.png"];
    emptyStar.position = position;
    [screenLayer addChild:emptyStar z:2];
}

- (void) createStarCombo:(CGPoint) position starTag:(int) spriteTag comboNumber:(int)number colour:(int)correct {
    CCSprite *star = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Combo%d.png", number]];
    star.tag = spriteTag;
    star.position = position;
    star.scale = 1.0;
    if (correct == 0) {
        star.color = ccc3(250, 0, 0);
    }
    if (correct == 2) {
        star.color = ccc3(0, 250, 0);
    }
    
    [screenLayer addChild:star z:5];
    [star runAction:[CCSequence actions:[CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCScaleTo actionWithDuration:0.2f scale:1.4f], nil], [CCScaleTo actionWithDuration:0.2f scale:1.0], nil]];

}

- (void) removeStarCombo:(int) spriteTag {
    CCSprite *removeSprite = (CCSprite*)[screenLayer getChildByTag:spriteTag];
    [removeSprite runAction:[CCSpawn actions:[CCMoveBy actionWithDuration:0.5f position:ccp(0, -10)], [CCFadeOut actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];
}

-(BOOL) checkCategory:(NSString *)category_id {
	FMResultSet *categoryidQuery = [SlotDb executeQuery:@"SELECT category_id FROM shuffledQuestions WHERE category_id = ?", category_id];
	if ([categoryidQuery next]) {
		return FALSE;
	}
	else {
		return TRUE;
	}

    [categoryidQuery close];
}

-(int) countMaximumRowsForCategory {
	FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (category_id) FROM shuffledQuestions WHERE category_id = ?", categoryFromCategoryMenu];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];

	}
    
    [countQuery close];
	return totalCount;
}

-(void) prepareQuestionList {
	[ShuffledQuestionList removeAllObjects];
	FMResultSet * slotQuestionQuery = [SlotDb executeQuery:@"SELECT question_id FROM shuffledQuestions WHERE category_id = ?", categoryFromCategoryMenu]; 
	while ([slotQuestionQuery next]) {

		[ShuffledQuestionList addObject:[NSNumber numberWithInt:[slotQuestionQuery intForColumn:@"question_id"]]];
	}

    [slotQuestionQuery close];
}

-(void) saveShuffledQuestions: (NSString*) category_id {

	int questionID = 0;
	[SlotDb beginTransaction];
	for (questionID = 0; questionID < [ShuffledQuestionList count]; questionID++) {
		[SlotDb executeUpdate:@"insert into shuffledQuestions (category_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:[[ShuffledQuestionList objectAtIndex:questionID] intValue]]];
	}
	[SlotDb commit];	
}

-(void) shuffleQuestions:(NSString *) category_id {
	FMResultSet *actionQuestionQuery = [db executeQuery:@"SELECT rowid FROM LevelOneQuestions WHERE category_id = ?", category_id];
	while ([actionQuestionQuery next]) {
		NSString *rowid = [actionQuestionQuery stringForColumn:@"rowid"];
		[ShuffledQuestionList addObject:rowid];
	}
	for (int i = 0; i < [ShuffledQuestionList count]; i++) {
		int maxNumberOfQuestions = [ShuffledQuestionList count] - i;
		int randomNumber = (arc4random() % maxNumberOfQuestions) + i;
		[ShuffledQuestionList exchangeObjectAtIndex:i withObjectAtIndex:randomNumber];
	}
    [actionQuestionQuery close];

}

-(int) countRowPlayerIsUpTo {
	FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (category_id) FROM usedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
	int rowCount = 0;
	if ([countQuery next]) {
		rowCount = [countQuery intForColumnIndex:0];

	}
    [countQuery close];

	return rowCount;
}

- (int) countNumberOfSkippedQuestions {
    FMResultSet *skipQuery = [SlotDb executeQuery:@"SELECT COUNT (category_id) FROM skippedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
    int skipCount = 0;
    if ([skipQuery next]) {
        skipCount = [skipQuery intForColumnIndex:0];
    }

    [skipQuery close];
    return skipCount;
}

-(void) addUsedQuestion:(int)questionID category:(NSString *) category_id {
	[SlotDb beginTransaction];
	[SlotDb executeUpdate:@"insert into usedQuestions (category_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:questionID]];
	[SlotDb commit];
}

-(void) timeOver {

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    [fiftyFifty setIsEnabled:FALSE];
    [eliminate setIsEnabled:FALSE];
    [pauseButton setIsEnabled:FALSE];
    
    Time = TIME_LIMIT;
    [[SimpleAudioEngine sharedEngine] playEffect:@"OutOfTime.caf"];


    consecutiveAnswers = 0;
    answeredRightWrong = FALSE;
    [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];

    questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    
    if (theRoundQuestionNumber == 1) {
        [self createStarCombo:ccp(20, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 2) {
        [self createStarCombo:ccp(38, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 3) {
        [self createStarCombo:ccp(56, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 4) {
        [self createStarCombo:ccp(74, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 5) {
        [self createStarCombo:ccp(92, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 6) {
        [self createStarCombo:ccp(110, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 7) {
        [self createStarCombo:ccp(128, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 8) {
        [self createStarCombo:ccp(146, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 9) {
        [self createStarCombo:ccp(164, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }
    if (theRoundQuestionNumber == 10) {
        
        [self createStarCombo:ccp(182, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        
    }

    [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:0];
    

    [self showCorrectAnswerAnimation:Answer];
    [self greyOutInsignificantAnswersAfterTimer:Answer];
    [Answer release];
}

-(void) getNextQuestion {
    [aButton setIsEnabled:TRUE];
    [bButton setIsEnabled:TRUE];
    [cButton setIsEnabled:TRUE];
    [dButton setIsEnabled:TRUE];
    [pauseButton setIsEnabled:TRUE];
    [eliminate setIsEnabled:TRUE];
    [fiftyFifty setIsEnabled:TRUE];
    NSLog(@"getNextQuestion");
    /*Check Lifelines*/
    if (![self checkIfEliminateUsed]) {
        [eliminate runAction:[CCTintTo actionWithDuration:0.8f red:255 green:255 blue:255]];
    }
    if (![self checkIfFiftyFiftyUsed]) {
        [fiftyFifty runAction:[CCTintTo actionWithDuration:0.8f red:255 green:255 blue:255]];
    }
    
    Time = TIME_LIMIT;
    [timerLabel setString:[NSString stringWithFormat:@"%d", Time]];

    [self schedule:@selector(scheduleUpdate:) interval:1.0f];
    
    if ([self checkIfEliminateUsed]) {
        eliminate.color = ccc3(150, 150, 150);
        [eliminate setIsEnabled:FALSE];
        [fiftyFifty setIsEnabled:TRUE];
    }
    
    if ([self checkIfFiftyFiftyUsed]) {
        fiftyFifty.color = ccc3(150, 150, 150);
        [fiftyFifty setIsEnabled:FALSE];
        [eliminate setIsEnabled:TRUE];
    }
    
    if ([self checkIfEliminateUsed] && [self checkIfFiftyFiftyUsed]) {
        fiftyFifty.color = ccc3(150, 150, 150);
        [fiftyFifty setIsEnabled:FALSE];
        eliminate.color = ccc3(150, 150, 150);
        [eliminate setIsEnabled:FALSE];
    }


    if (questionNumberArrayIndex <= 99) {

        if (theRoundQuestionNumber > 9) {

            [ALabel stopAllActions];
            [BLabel stopAllActions];
            [CLabel stopAllActions];
            [DLabel stopAllActions];
            [questionLabel stopAllActions];
            
            SettingsManager *S1 = [SettingsManager sharedSettingsManager];
            [S1 loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
            [S1 setBool:TRUE keyString:@"didRoundEnd"];
            [S1 setString:@"None" keyString:@"CurrentCategory"];

            [S1 saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
            
            endOfRound = TRUE;
            theRoundQuestionNumber = 0;
            consecutiveAnswers = 0;
            
            [self setEliminateUsedToFalse];
            [self setFiftyFiftyToFalse];
            [self clearStarsInPLIST:save];

            [self saveCurrentQuestionToSettingsManager:save];
            [self checkIfOneHundredQuestionsInUsedQuestions];
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EndOfRoundScene scene:save category:categoryFromCategoryMenu lvl:level]]];
        }
        else {
            [self saveCurrentQuestionToSettingsManager:save];

            [questionNumberLabel setString:[NSString stringWithFormat:@"%d", theRoundQuestionNumber+1]];
            tempQuestionID = [[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue];
            if (questionNumberArrayIndex < maxRowsForCategory) {
                [self getQuestionID:tempQuestionID category:categoryFromCategoryMenu skippedOn:FALSE];
            }
        }
    }
    else {
        
        /**STOP SCORING**/
        [SlotDb beginTransaction];
        [SlotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE category_id = ?", categoryFromCategoryMenu];
        [SlotDb executeUpdate:@"DELETE FROM usedQuestions WHERE category_id = ?", categoryFromCategoryMenu];
        [SlotDb commit];
        
        [self markCategoryComplete];
        endOfRound = TRUE;

        theRoundQuestionNumber = 0;

        [self shuffleQuestions:categoryFromCategoryMenu];
        [self saveShuffledQuestions:categoryFromCategoryMenu];
        [self saveCurrentQuestionToSettingsManager:save];

        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EndOfRoundScene scene:save category:categoryFromCategoryMenu lvl:level]]];
    }
}

-(void) markCategoryComplete {
    SettingsManager *completeManager = [SettingsManager sharedSettingsManager];
    [completeManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [completeManager setBool:TRUE keyString:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]];
    [completeManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) getQuestionID:(int)questionID category:(NSString *) category_id skippedOn:(BOOL)skippedSet {
    FMResultSet *questionQuery;
    FMResultSet *aQuery;
    FMResultSet *bQuery;
    FMResultSet *cQuery;
    FMResultSet *dQuery;
    
    enteredSkippedPhase = skippedSet;
    
    if (skippedSet) {
        questionQuery = [db executeQuery:@"SELECT question FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID],category_id];
        
    }
    else {
        questionQuery = [db executeQuery:@"SELECT question FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID],category_id];

    }

	while ([questionQuery next]) {
		NSString *question = [questionQuery stringForColumn:@"question"];
        [questionLabel setString:question];
	}
	[questionQuery close];
	
    
    aQuery = [db executeQuery:@"SELECT A FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id];
    bQuery = [db executeQuery:@"SELECT B FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id];
    cQuery = [db executeQuery:@"SELECT C FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id];
    dQuery = [db executeQuery:@"SELECT D FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id];


	NSString *a = @"";
	NSString *b = @"";
	NSString *c = @"";
	NSString *d = @"";
	
	while ([aQuery next]) {
		a = [aQuery stringForColumn:@"A"];
	}
	while ([bQuery next]) {
		b = [bQuery stringForColumn:@"B"];
	}
	while ([cQuery next]) {
		c = [cQuery stringForColumn:@"C"];
	}
	while ([dQuery next]) {
		d = [dQuery stringForColumn:@"D"];
	}

    [aQuery close];
    [bQuery close];
    [cQuery close];
    [dQuery close];
    
    FMResultSet *answerQuery = [db executeQuery:@"SELECT answer FROM LevelOneQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id]; 
	
	while ([answerQuery next]) {
		Answer = [answerQuery stringForColumn:@"answer"];
		[Answer retain];
	}
    [answerQuery close];
    
    [ALabel setString:a];
    [BLabel setString:b];
    [CLabel setString:c];
    [DLabel setString:d];
    
    [db close];
    [self openDatabase:[NSString stringWithFormat:@"Level%d.sqlite", level]];
}

- (int) getSkippedQuestion:(int) questionID category:(NSString *)category_id {
    int skippedQuestionID;
    
    FMResultSet *skipQuery = [SlotDb executeQuery:@"SELECT question_id from skippedQuestions WHERE rowid = ? AND category_id = ?", [NSNumber numberWithInt:questionID], category_id];
    while ([skipQuery next]) {
		skippedQuestionID = [skipQuery intForColumn:@"question_id"];
	}
    
    return skippedQuestionID;
}

- (void) skippedQuestion:(int)questionID category:(NSString *) category_id {
    [SlotDb beginTransaction];
	[SlotDb executeUpdate:@"insert into skippedQuestions (category_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:questionID]];
	[SlotDb commit];
}

- (void) skipAsk: (id) sender {  
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    [pauseButton setIsEnabled:FALSE];
    [skipButton setIsEnabled:FALSE];
    pauseLayer.position = ccp(0, 0);
    [self addChild:pauseLayer z:6];

    CCMenuItemSprite *confirm = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ConfirmButton.png"] selectedSprite:nil target:self selector:@selector(confirmSkip:)];
    confirm.position = ccp(290, 140);

    
    CCMenuItemSprite *deny = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"DenyButton.png"] selectedSprite:nil target:self selector:@selector(denySkip:)];
    deny.position = ccp(190, 140);

    
    CCSprite *skipBG = [CCSprite spriteWithSpriteFrameName:@"AlertBG.png"];
    skipBG.position = ccp(240, 160);    
    [pauseLayer addChild:skipBG z:1];
    
    CCMenu *skipMenu = [CCMenu menuWithItems:confirm, deny, nil];
    skipMenu.position = ccp(0, 0);
    
    CCLabelTTF *skipCurrentQuestion = [CCLabelTTF labelWithString:@"Skip current question?" fontName:@"Broadway BT" fontSize:13];
    skipCurrentQuestion.position = ccp(240, 180);
    [pauseLayer addChild:skipCurrentQuestion z:2];
    
    [pauseLayer addChild:skipMenu z:3];
    pauseLayer.scale = 0.9;
    [pauseLayer runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05f scale:1.0], [CCScaleTo actionWithDuration:0.15f scale:0.9], [CCScaleTo actionWithDuration:0.05f scale:1.0], nil]];
}

- (void) confirmSkip: (id) sender {
    [aButton setIsEnabled:TRUE];
    [bButton setIsEnabled:TRUE];
    [cButton setIsEnabled:TRUE];
    [dButton setIsEnabled:TRUE];
    [pauseButton setIsEnabled:TRUE];
    [skipButton setIsEnabled:TRUE];
    [pauseLayer removeAllChildrenWithCleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
    
    [self skippedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];

    questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:2];

    if (theRoundQuestionNumber == 1) {
        [self createStarCombo:ccp(20, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 2) {
        [self createStarCombo:ccp(38, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 3) {
        [self createStarCombo:ccp(56, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 4) {
        [self createStarCombo:ccp(74, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 5) {
        [self createStarCombo:ccp(92, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 6) {
        [self createStarCombo:ccp(110, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 7) {
        [self createStarCombo:ccp(128, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 8) {
        [self createStarCombo:ccp(146, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 9) {
        [self createStarCombo:ccp(164, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    if (theRoundQuestionNumber == 10) {
        [self createStarCombo:ccp(182, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:2];
    }
    
    [self getNextQuestion];
    
}

- (void) denySkip: (id) sender {
    [aButton setIsEnabled:TRUE];
    [bButton setIsEnabled:TRUE];
    [cButton setIsEnabled:TRUE];
    [dButton setIsEnabled:TRUE];
    [pauseButton setIsEnabled:TRUE];
    [skipButton setIsEnabled:TRUE];
    [pauseLayer removeAllChildrenWithCleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
}

-(void) pauseButton: (id) sender {
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];

    [self pauseSchedulerAndActions];
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    [pauseButton setIsEnabled:FALSE];
    //[skipButton setIsEnabled:FALSE];
    pauseLayer.position = ccp(0, 0);
    [self addChild:pauseLayer z:6];
    [self closeCurtains];
    [self fadeLightsIn];
    [self zoomOutBG];

    [questionLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    [ALabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    [BLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    [CLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    [DLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    
    CCSprite *pauseBG = [CCSprite spriteWithSpriteFrameName:@"AlertBG.png"];
    pauseBG.position = ccp(240, 190);
    
    [pauseLayer addChild:pauseBG z:1];
     
    CCSprite *resumeButtonSelected = [CCSprite spriteWithSpriteFrameName:@"ResumeButton.png"];
    resumeButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite * resume = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ResumeButton.png"] selectedSprite:resumeButtonSelected target:self selector:@selector(resumeButton:)];
    resume.position = ccp(190, 150);
    
    CCSprite *exitButtonSelected = [CCSprite spriteWithSpriteFrameName:@"QuitButton.png"];
    exitButtonSelected.color = ccc3(150, 150, 150);
    CCMenuItemSprite * quit = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"QuitButton.png"] selectedSprite:exitButtonSelected target:self selector:@selector(quitButton:)];
    quit.position = ccp(290, 150);
    
    BGMButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BGMOn.png"] selectedSprite:nil target:self selector:@selector(BGM:)];
    BGMButton.position = ccp(290, 210);
    
    SFXButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SFXOn.png"] selectedSprite:nil target:self selector:@selector(SFX:)];
    SFXButton.position = ccp(190, 210);
    
    if (BGM) {
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOn.png"]];
    }
    else {
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOff.png"]];
    }
    if (SFX) {
        [SFXButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"SFXOn.png"]];
    }
    else {
        [SFXButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"SFXOff.png"]];
    }
    
    CCMenu *pauseMenu = [CCMenu menuWithItems:resume, quit, SFXButton, BGMButton, nil];
    pauseMenu.position = ccp(0, 0);
    
    CCLabelTTF *areYouSure = [CCLabelTTF labelWithString:@"Do you want to quit?" fontName:PAUSE_FONT fontSize:16];
    areYouSure.position = ccp(240, 245);
    [pauseLayer addChild:areYouSure z:2];
    
    [pauseLayer addChild:pauseMenu z:2];
    pauseLayer.scale = 0.9;
    
    [resume runAction:[CCFadeIn actionWithDuration:1.0f]];
    [quit runAction:[CCFadeIn actionWithDuration:1.0f]];
    [areYouSure runAction:[CCFadeIn actionWithDuration:1.0f]];
    [pauseBG runAction:[CCFadeIn actionWithDuration:1.0f]];
    [SFXButton runAction:[CCFadeIn actionWithDuration:1.0f]];
    [BGMButton runAction:[CCFadeIn actionWithDuration:1.0f]];
    
}

- (void) BGM:(id) sender {
    BGM = !BGM;
    SettingsManager *BGMSettings = [SettingsManager sharedSettingsManager];
    [BGMSettings loadFromFileInLibraryDirectory:@"SoundSettings.plist"];
    if (BGM) {
        [BGMSettings setBool:TRUE keyString:@"Music"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.5f;
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
    [SFXSettings loadFromFileInLibraryDirectory:@"SoundSettings.plist"];
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

-(void) resumeButton: (id) sender {    
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_FORWARD];
    [questionLabel runAction:[CCFadeIn actionWithDuration:1.0f]];
    [ALabel runAction:[CCFadeIn actionWithDuration:1.0f]];
    [BLabel runAction:[CCFadeIn actionWithDuration:1.0f]];
    [CLabel runAction:[CCFadeIn actionWithDuration:1.0f]];
    [DLabel runAction:[CCFadeIn actionWithDuration:1.0f]];

    [self fadeLightsOut];
    [self openCurtains];
    [self zoomAfterResume];
    [pauseLayer removeAllChildrenWithCleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
    //[skipButton setIsEnabled:TRUE];
    [self performSelector:@selector(timerDelayBeforeStarting:) withObject:nil afterDelay:1.5f];

}

-(void) timerDelayBeforeStarting: (id) sender {
    [aButton setIsEnabled:TRUE];
    [bButton setIsEnabled:TRUE];
    [cButton setIsEnabled:TRUE];
    [dButton setIsEnabled:TRUE];
    [pauseButton setIsEnabled:TRUE];

    [self resumeSchedulerAndActions];
    //[timer resumeSchedulerAndActions];
}

-(void) quitButton: (id) sender {   
    [[SimpleAudioEngine sharedEngine] playEffect:MENU_SELECT_BACK];

    [self saveCurrentQuestionToSettingsManager:save];
    [self saveComboToSettingsManager:save];
    //[self saveScoreToSettingsManager:save];
    
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

-(void) starsEffect:(NSString *) answer  {
    comboEffect = [CCSprite spriteWithSpriteFrameName:@"ComboSpriteEffect.png"];
    comboEffect.position = ccp(240, 180);
    comboEffect.color = ccc3(255, 0, 255);
    comboEffect.scale = .70;
    [buttonLayer addChild:comboEffect z:5];
    
    ccBezierConfig path1;
    path1.endPosition	 = ccp(35,-20);
    path1.controlPoint_1 = ccp(0,150);
    path1.controlPoint_2 = ccp(30,50);
    
    [comboEffect runAction:[CCSpawn actions:[CCBezierTo actionWithDuration:3.0f bezier:path1], [CCRotateBy actionWithDuration:1.5f angle:-50], [CCScaleTo actionWithDuration:0.5 scale:0.2], nil]];
    
}

-(void) saveProgressToSettingsManager:(int) save {
    SettingsManager *progressManager = [SettingsManager sharedSettingsManager];
    [progressManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    int tempProgress = [progressManager getInt:[NSString stringWithFormat:@"%@ Progress", categoryFromCategoryMenu]];
    tempProgress = tempProgress + 1;
    [progressManager setInteger:tempProgress keyString:[NSString stringWithFormat:@"%@ Progress", categoryFromCategoryMenu]];
    [progressManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) saveNumberOfAnsweredRight:(int)save {
    SettingsManager *answeredManager = [SettingsManager sharedSettingsManager];
    [answeredManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    [answeredManager setInteger:answeredRight keyString:@"answeredRightForRound"];
    [answeredManager saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(void) loadNumberOfAnsweredRight:(int)save {
    SettingsManager *answeredManager = [SettingsManager sharedSettingsManager];
    [answeredManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    answeredRight = [answeredManager getInt:@"answeredRightForRound"];
}

-(BOOL) checkAchievement:(NSString *) achievementID {
    SettingsManager *achievementManager = [SettingsManager sharedSettingsManager];
    [achievementManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    if ([achievementID isEqualToString:@"ABeautifulMind"]) {
        return [achievementManager getBool:@"ABeautifulMind"];
    }
    else if ([achievementID isEqualToString:@"FastAndFurious"]) {
        return [achievementManager getBool:@"FastAndFurious"];
    }
    else if ([achievementID isEqualToString:@"HowToLoseARoundIn10Questions"]) {
        return [achievementManager getBool:@"HowToLoseARoundIn10Questions"];
    }
    else {
        return 0;
    }
}
                 
-(void) setAchievement:(NSString *) achievementID {
    SettingsManager *achievement = [SettingsManager sharedSettingsManager];
    [achievement loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
    
    if ([achievementID isEqualToString:@"ABeautifulMind"]) {
        [achievement setBool:TRUE keyString:@"ABeautifulMind"];
        [[GCHelper sharedInstance] reportAchievement:@"com.whizbang.squizreeltrivia.abeautifulmind" percentComplete:100.00];
        [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"A Beautiful Mind" andMessage:@"Get 10 questions in a row correct!"];
    }
    else if ([achievementID isEqualToString:@"FastAndFurious"]) {
        [achievement setBool:TRUE keyString:@"FastAndFurious"];
        [[GCHelper sharedInstance] reportAchievement:@"com.whizbang.squizreeltrivia.fastandfurious" percentComplete:100.00];
        [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Fast and Furious" andMessage:@"Answer a question correct in under 60 seconds!"];
    }
    else if ([achievementID isEqualToString:@"Loser"]) {
        [achievement setBool:TRUE keyString:@"Loser"];
        [[GCHelper sharedInstance] reportAchievement:@"com.whizbang.squizreeltrivia.loser" percentComplete:100.00];
        [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Loser" andMessage:@"Answer all questions incorrect in a round"];
    }
    [achievement saveToFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", save]];
}

-(int) getCombo {
    SettingsManager *comboManager = [SettingsManager sharedSettingsManager];
    return [comboManager getInt:@"Combo"];
}

-(void) checkAnswer:(NSString *) yourAnswer {

    [fiftyFifty setIsEnabled:FALSE];
    [eliminate setIsEnabled:FALSE];
    [pauseButton setIsEnabled:FALSE];
    
    [self unschedule:@selector(scheduleUpdate:)];

	if ([yourAnswer isEqualToString:Answer]) {
        consecutiveAnswers++;
        answeredRight++;
        TimeTaken = (60 - Time) + TimeTaken;
        [self saveNumberOfAnsweredRight:save];
        
        if ([self getCombo] < consecutiveAnswers) {
            [self saveComboToSettingsManager:save];
        }
        
        if (consecutiveAnswers == 1 || consecutiveAnswers == 2 || consecutiveAnswers == 3) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"ShortClap.caf"];
        }
        if (consecutiveAnswers == 4 || consecutiveAnswers == 5) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"WellDone.caf"];
        }
        if (consecutiveAnswers == 6 || consecutiveAnswers == 7) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"Woohoo1.caf"];
        }
        if (consecutiveAnswers == 8 || consecutiveAnswers == 9) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"Woohoo2.caf"];
        }
        if (consecutiveAnswers == 10) {
            if (![self checkAchievement:@"ABeautifulMind"]) {
                [self setAchievement:@"ABeautifulMind"];
            }
            if (TimeTaken <= 60) {
                if (![self checkAchievement:@"FastAndFurious"]) {

                    [self setAchievement:@"FastAndFurious"];
                }
            }

            [[SimpleAudioEngine sharedEngine] playEffect:@"Woohoo3.caf"];
        }
        [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:1];
        if (theRoundQuestionNumber <= 10) {

            answeredRightWrong = TRUE;

            if (theRoundQuestionNumber == 1) {

                [self createStarCombo:ccp(20, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
            }
            if (theRoundQuestionNumber == 2) {

                [self createStarCombo:ccp(38, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 3) {
                [self createStarCombo:ccp(56, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 4) {
                [self createStarCombo:ccp(74, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 5) {
                [self createStarCombo:ccp(92, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 6) {
                [self createStarCombo:ccp(110, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 7) {
                [self createStarCombo:ccp(128, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 8) {

                [self createStarCombo:ccp(146, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 9) {

                [self createStarCombo:ccp(164, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];

            }
            if (theRoundQuestionNumber == 10) {

                [self createStarCombo:ccp(182, COMBO_STAR_Y) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
            }
        }
        
        FMResultSet *getScore = [scoringDb executeQuery:[NSString stringWithFormat:@"SELECT Level%d FROM ScoringTable WHERE consecutiveAnswer = ?", level], [NSNumber numberWithInt:consecutiveAnswers]];
        
        if ([getScore next]) {
            score = [getScore intForColumn:[NSString stringWithFormat:@"Level%d", level]];

            [scoreAddLabel setString:[NSString stringWithFormat:@"+%d", score]];
            [scoreAddLabel runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.3f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:0.3f], [CCCallFunc actionWithTarget:self selector:@selector(updateScore:)], nil]];
            
            CategoryScore = CategoryScore +  score;
            RoundScore = RoundScore + score;

            [self saveScoreToSettingsManager:save];
            
            [self saveProgressToSettingsManager:save];
            [self correctAnswerAnimation:yourAnswer];
        }
	}
	else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"aaww1.caf"];

        consecutiveAnswers = 0;
        answeredRightWrong = FALSE;
        
        if (theRoundQuestionNumber == 1) {
            [self createStarCombo:ccp(20, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 2) {
            [self createStarCombo:ccp(38, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 3) {
            [self createStarCombo:ccp(56, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 4) {
            [self createStarCombo:ccp(74, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 5) {
            [self createStarCombo:ccp(92, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 6) {
            [self createStarCombo:ccp(110, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 7) {
            [self createStarCombo:ccp(128, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 8) {
            [self createStarCombo:ccp(146, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 9) {
            [self createStarCombo:ccp(164, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        if (theRoundQuestionNumber == 10) {
            [self createStarCombo:ccp(182, COMBO_STAR_Y+1) starTag:theRoundQuestionNumber comboNumber:theRoundQuestionNumber colour:answeredRightWrong];
        }
        
        [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:0];

        [self wrongAnswerAnimation:yourAnswer]; 
        [self showCorrectAnswerAnimation:Answer];
        [self greyOutInsignificantAnswers:Answer userAnswer:yourAnswer];
	}
	[Answer release];
}

- (void) updateScore:(id) sender {
    [scoreLabel setString:[NSString stringWithFormat:@"%06d", CategoryScore]];
}

- (void) showCorrectAnswerAnimation:(NSString *)correctAnswer {
    if ([correctAnswer isEqualToString:@"A"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    
    if ([correctAnswer isEqualToString:@"B"]) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([correctAnswer isEqualToString:@"C"]) {
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([correctAnswer isEqualToString:@"D"]) {
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
}

- (void) greyOutInsignificantAnswers:(NSString *)correctAnswer userAnswer:(NSString *) yourAnswer {
    
    if (([yourAnswer isEqualToString:@"A"] && [correctAnswer isEqualToString:@"B"]) || ([yourAnswer isEqualToString:@"B"] && [correctAnswer isEqualToString:@"A"])) {
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    else if (([yourAnswer isEqualToString:@"A"] && [correctAnswer isEqualToString:@"C"]) || ([yourAnswer isEqualToString:@"C"] && [correctAnswer isEqualToString:@"A"])) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    else if (([yourAnswer isEqualToString:@"A"] && [correctAnswer isEqualToString:@"D"]) || ([yourAnswer isEqualToString:@"D"] && [correctAnswer isEqualToString:@"A"])) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    else if (([yourAnswer isEqualToString:@"B"] && [correctAnswer isEqualToString:@"C"]) || ([yourAnswer isEqualToString:@"C"] && [correctAnswer isEqualToString:@"B"])) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    else if (([yourAnswer isEqualToString:@"B"] && [correctAnswer isEqualToString:@"D"]) || ([yourAnswer isEqualToString:@"D"] && [correctAnswer isEqualToString:@"B"])) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    else if (([yourAnswer isEqualToString:@"C"] && [correctAnswer isEqualToString:@"D"]) || ([yourAnswer isEqualToString:@"D"] && [correctAnswer isEqualToString:@"C"])) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
}

- (void) greyOutInsignificantAnswersAfterTimer:(NSString *) correctAnswer {
    if ([correctAnswer isEqualToString:@"A"]) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([correctAnswer isEqualToString:@"B"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([correctAnswer isEqualToString:@"C"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([correctAnswer isEqualToString:@"D"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    
    [self fadeLabelsOutAndInBetweenQuestions];
    [self performSelector:@selector(getNextQuestion) withObject:nil afterDelay:PAUSE_BETWEEN_QUESTIONS];
}

- (void) correctAnswerAnimation:(NSString *) yourAnswer {
 
    if ([yourAnswer isEqualToString:@"A"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    
    if ([yourAnswer isEqualToString:@"B"]) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    
    if ([yourAnswer isEqualToString:@"C"]) {
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    
    if ([yourAnswer isEqualToString:@"D"]) {
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:40 green:255 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.2f red:150 green:150 blue:150], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    [self fadeLabelsOutAndInBetweenQuestions];

    [self performSelector:@selector(getNextQuestion) withObject:nil afterDelay:PAUSE_BETWEEN_QUESTIONS];
}

- (void) wrongAnswerAnimation:(NSString *) yourAnswer {

    if ([yourAnswer isEqualToString:@"A"]) {
        [aButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:255 green:40 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([yourAnswer isEqualToString:@"B"]) {
        [bButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:255 green:40 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([yourAnswer isEqualToString:@"C"]) {
        [cButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:255 green:40 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    if ([yourAnswer isEqualToString:@"D"]) {
        [dButton runAction:[CCSequence actions:[CCTintTo actionWithDuration:0.3f red:255 green:40 blue:10], [CCDelayTime actionWithDuration:BUTTON_TINT_DELAY], [CCTintTo actionWithDuration:0.3f red:255 green:255 blue:255], nil]];
    }
    [self fadeLabelsOutAndInBetweenQuestions];
    [self performSelector:@selector(getNextQuestion) withObject:nil afterDelay:PAUSE_BETWEEN_QUESTIONS];
}

- (void) spriteRemoveSpriteSheet: (id) sender {
    CCSprite *sprite = (CCSprite *)sender;
    [spriteSheet removeChild:sprite cleanup:YES];       
}

- (void) spriteRemoveScreenLayer: (id) sender {
    CCSprite *sprite = (CCSprite *)sender;
    [screenLayer removeChild:sprite cleanup:YES];
}

- (void) spriteMoveFinished: (id) sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
}

- (void) dealloc
{
    
	[ShuffledQuestionList release];
    ShuffledQuestionList = nil;     
    [SlotDb close];
    [db close];
    [menuLayer release];
    [screenLayer release];
    [buttonLayer release];
    [curtainLayer release];
    [backGroundLayer release];
    
	[super dealloc];
}

@end
