//
//  questionScene.m
//  TriviaMenu
//
//  Created by mark wong on 1/08/11.
//  Copyright 2011 Whizbang. All rights reserved.
//
//Combo colour 0 Red (wrong) 1 Yellow (right) 2 Green (skipped)
#import "Quickplay.h"
#import <sqlite3.h>
#import <math.h>
#import "mainMenu.h"

#define FONT_SIZE 13
#define EMPTY_STAR_POSITION_X 60
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

#define TIME_LIMIT 15
#define COMBO_STAR_Y 304

@implementation Quickplay
static int save;
static int numberOfQuestions;
static NSString * categoryFromCategoryMenu;
static NSString * level;
//+(id) scene:(int) setTimer difficultyLevel:(NSString *) difficulty;

+(id) scene:(int) setTimer difficultyLevel:(NSString *)difficulty questions:(int)questionsPerRound {
	CCScene *scene = [CCScene node];
	save = setTimer;

    level = difficulty;
    categoryFromCategoryMenu = difficulty;
    numberOfQuestions = questionsPerRound;
    
	Quickplay *layer = [Quickplay node];
    
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

        correctlyAnswered = 0;
        consecutiveAnswers = 0;
		questionLabel.tag = 15;
        Lives = 3;
        countdownSkipped = FALSE;
        TICKTOCK = TRUE;
        Time = TIME_LIMIT;
        
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
        
        countdownNumber = [CCLabelTTF labelWithString:@"3" fontName:questionFont fontSize:170];
        countdownNumber.opacity = 0;
        countdownNumber.color = ccc3(0, 0, 0);
        countdownNumber.position = ccp(240, 170);
        countdownNumber.tag = 21;
        [screenLayer addChild:countdownNumber z:10];
        
		menuLayer.position = ccp(0, 0);
		[self addChild:menuLayer z:2];
        
        [self checkIfCategoryHasBeenCompleted];
        
        NSString *levelName = @"Quickplay.sqlite";//[NSString stringWithFormat:@"Quickplay.sqlite", level];
        
        [self openDatabase:levelName];
        [self openSlotDatabase:[NSString stringWithFormat:@"QuickplaySlot.sqlite"]];
        [self openScoringDatabase];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsBGSpriteSheet.plist"];
        BGSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"grainsBGSpriteSheet.pvr.ccz"];
        [screenLayer addChild:BGSpriteSheet z:2];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsSpriteSheet.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"grainsSpriteSheet.pvr"];
        [screenLayer addChild:spriteSheet z:2];
        
        lineGrain = [CCSprite spriteWithSpriteFrameName:@"Line.png"];
        lineGrain.position = ccp(100, 140);
        
        [spriteSheet addChild:lineGrain];
        lineGrain.tag = 22;
        
        categoryText = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
        
        categoryText.opacity = 0;
        categoryText.position = ccp(400, 100);
        categoryText.tag = 23;
        [screenLayer addChild:categoryText z:2];
        
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

-(void) checkIfCategoryHasBeenCompleted {
    SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
    [categoryCompleteManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    categoryComplete = [categoryCompleteManager getBool:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]];
    
}

-(void) checkIfOneHundredQuestionsInUsedQuestions {
    FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (difficulty_id) FROM usedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];
	}
    [countQuery close];
    

    if ((!(totalCount % 100)) && (totalCount != 0)) {

        SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
        [categoryCompleteManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
        [categoryCompleteManager setBool:TRUE keyString:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]]; 
        [categoryCompleteManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
        

        [SlotDb beginTransaction];
        [SlotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
        [SlotDb executeUpdate:@"DELETE FROM usedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
        [SlotDb commit];
        


    }
    else {
        SettingsManager *categoryCompleteManager = [SettingsManager sharedSettingsManager];
        [categoryCompleteManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
        [categoryCompleteManager setBool:FALSE keyString:[NSString stringWithFormat:@"%@ Complete", categoryFromCategoryMenu]]; 
        [categoryCompleteManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
    }
    //NSLog(@"totalCount %d", totalCount); 
}



-(void) loadStarsAfterQuitting {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    int coordX = EMPTY_STAR_POSITION_X;
    
    int comboNumber = [saveSettingsManager getInt:@"Combo"];

    for (int i = 1; i <= comboNumber; i++) { //use to be tempCombo
        [self createStarCombo:ccp(coordX, COMBO_STAR_Y) starTag:i comboNumber:i colour:1];
        coordX = coordX + 18;
    }
}

-(void) saveStarsAfterQuitting:(int)saveNumber starNumber:(int)number answerType:(int)answered {
    
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];

    [saveSettingsManager setInteger:answered keyString:@"QuickplaySlot.plist"];
    [saveSettingsManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
}

-(int) checkComboIfHigherThanCurrentCombo:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    return [saveSettingsManager getInt:@"Combo"];
}

-(int) loadComboFromSettingsManager {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    SaveCombo = [saveSettingsManager getInt:@"Combo"];

    return SaveCombo;
}

-(void) saveComboToSettingsManager:(int)comboNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];

    [saveSettingsManager setInteger:comboNumber keyString:@"Combo"];
    [saveSettingsManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
}

- (void) loadCurrentQuestionFromSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    theRoundQuestionNumber = [saveSettingsManager getInt:@"CurrentQuestion"];
}

- (void) saveCurrentQuestionToSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    [saveSettingsManager setInteger:theRoundQuestionNumber keyString:@"CurrentQuestion"];
    [saveSettingsManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
}

- (void) loadScoreFromSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    //totalScore 
    totalScore = [saveSettingsManager getInt:[NSString stringWithFormat:@"%@ Score", level]];
}

- (void) saveScoreToSettingsManager:(int)saveNumber {
    SettingsManager *saveSettingsManager = [SettingsManager sharedSettingsManager];
    [saveSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    [saveSettingsManager setInteger:SaveScore keyString:[NSString stringWithFormat:@"%@ Score", level]];

    [saveSettingsManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
}

- (void) startCountdown {
    
    countdownBackground = [CCSprite spriteWithSpriteFrameName:@"CountdownBG.png"];
    countdownBackground.position = ccp(240, 160);
    countdownBackground.opacity = 0;
    if ([level isEqualToString:@"Easy"]) {
        countdownBackground.color = ccc3(210, 250, 210);
    }
    else if ([level isEqualToString:@"Medium"]) {
        countdownBackground.color = ccc3(210, 160, 100);
    }
    else if ([level isEqualToString:@"Hard"]) {
        countdownBackground.color = ccc3(255, 150, 150);
    }
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
    
    [countdownBackground runAction:[CCSequence actions:[CCFadeIn actionWithDuration:2.0f], [CCCallFuncN actionWithTarget:self selector:@selector(backgroundRepeat:)], nil]];
    
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

-(void) backgroundRepeat: (id) sender {
    [countdownBackground runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.3f scale:0.97], [CCScaleTo actionWithDuration:0.3f scale:0.95], [CCScaleTo actionWithDuration:0.3f scale:0.92], [CCScaleTo actionWithDuration:0.4f scale:0.95], nil]]];   
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
        /*TICKTOCK = !TICKTOCK;
        if (TICKTOCK) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
        }
        else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"tock.caf"];
        }*/
        [[SimpleAudioEngine sharedEngine] playEffect:@"Heartbeat.caf"];
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

- (void) finishCountdown {
    
    CCLabelBMFont *EasyTextFlyBy = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
    EasyTextFlyBy.position = ccp(660, 60);
    EasyTextFlyBy.color = ccc3(200, 200, 200);
    //EasyTextFlyBy.opacity = 0.9;
    [screenLayer addChild:EasyTextFlyBy z:5];
    
    [EasyTextFlyBy runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCMoveBy actionWithDuration:25.0f position:ccp(-700, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(700, 0)], nil]]];
    
    CCLabelBMFont *EasyTextFlyBy2 = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
    EasyTextFlyBy2.position = ccp(550, 270);                    
    EasyTextFlyBy2.scale = 0.6;
    EasyTextFlyBy2.color = ccc3(200, 200, 200);
    [screenLayer addChild:EasyTextFlyBy2 z:5];
    
    [EasyTextFlyBy2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:20.0f position:ccp(-670, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(670, 0)], nil]]];
    
    CCLabelBMFont *EasyTextFlyBy3 = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
    EasyTextFlyBy3.position = ccp(-80, 113);                    
    EasyTextFlyBy3.scale = 0.3;
    EasyTextFlyBy3.color = ccc3(150, 150, 150);
    [screenLayer addChild:EasyTextFlyBy3 z:5];
    
    [EasyTextFlyBy3 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:15.0f position:ccp(670, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(-80, 0)], nil]]];
    
    
    if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GameplayBGM1.aif" loop:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3f];
    }
    else {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GameplayBGM1.aif" loop:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3f];
    }
    
    [self SoundSettings];
    
    if (BGM) {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.1f;
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
    
    self.isTouchEnabled = YES;
    
    ShuffledQuestionList = [[NSMutableArray alloc] init];
    
    [SlotDb beginTransaction];
    [SlotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
    [SlotDb executeUpdate:@"DELETE FROM usedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
    [SlotDb commit];
    
    [self shuffleQuestions:categoryFromCategoryMenu];
    [self saveShuffledQuestions:categoryFromCategoryMenu];    
    
    maxRowsForCategory = [self countMaximumRowsForCategory];

    [crosshairBg runAction:[CCCallFuncN actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)]];
    
    livesLabel = [CCLabelBMFont labelWithString:@"Lives:" fntFile:@"broadway.fnt"];
    livesLabel.position = ccp(40, 300);
    [screenLayer addChild:livesLabel z:2];
    int x = 155;
    int y = 302;
    for (int i = 2; i >= 0; i--) {        
        [self createLives:ccp(x, y) lifetag:i];
        x = x - 30;
    }
    
    pauseButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"PauseButton.png"] selectedSprite:nil target:self selector:@selector(pauseButton:)];
    pauseButton.position = ccp(460, 300);
    
    skipButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"SkipButton.png"] selectedSprite:nil target:self selector:@selector(confirmSkip:)];
    skipButton.position = ccp(20, 300); 

    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
    menu.position = ccp(0, 0);
    [screenLayer addChild:menu z:5];
    
    questionNumberLabel = [CCLabelTTF labelWithString:@"" fontName:@"Broadway BT" fontSize:60];
    questionNumberLabel.position = ccp(240, 245);
    questionNumberLabel.opacity = 150;
    questionNumberLabel.color = ccc3(170, 170, 170);
    [buttonLayer addChild:questionNumberLabel z:3];
    

    correctlyAnsweredLabel = [CCLabelBMFont labelWithString:@"Correct: 0" fntFile:@"broadway.fnt"];
    correctlyAnsweredLabel.position = ccp(373, 300);
    [screenLayer addChild:correctlyAnsweredLabel z:5];
    
    timerLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", TIME_LIMIT] fntFile:@"timer.fnt"];
    timerLabel.position = ccp(240, 300);
    [screenLayer addChild:timerLabel z:5];

    questionLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:420 alignment:UITextAlignmentCenter];
    
    questionLabel.position = ccp(240 , 247);
    questionLabel.color = ccc3(0, 0, 0);
    [buttonLayer addChild:questionLabel z:3];
    
    questionBox = [CCSprite spriteWithSpriteFrameName:@"QuestionBox.png"];
    questionBox.position = ccp(240, 245);
    
    [buttonLayer addChild:questionBox z:2];
    
    aButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"AButton.png"] selectedSprite:nil target:self selector:@selector(buttonACheck:)];
    
    ALabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:362 alignment:UITextAlignmentCenter];
    
    ALabel.color = ccc3(0, 0, 0);
    ALabel.position = ccp(180, 30);
    ALabel.tag = 11;
    [aButton addChild:ALabel z:1];
    
    bButton =   [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"BButton.png"] selectedSprite:nil target:self selector:@selector(buttonBCheck:)];
    BLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:362 alignment:UITextAlignmentCenter];
    
    BLabel.color = ccc3(0, 0, 0);
    BLabel.position = ccp(180, 30);
    
    BLabel.tag = 12;
    [bButton addChild:BLabel];
    
    cButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"CButton.png"] selectedSprite:nil target:self selector:@selector(buttonCCheck:)];
    CLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:362 alignment:UITextAlignmentCenter];
    
    CLabel.color = ccc3(0, 0, 0);
    CLabel.position = ccp(180, 30);
    
    CLabel.tag = 13;
    [cButton addChild:CLabel];
    
    dButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"DButton.png"] selectedSprite:nil target:self selector:@selector(buttonDCheck:)];
    DLabel = [CCLabelBMFontMultiline labelWithString:@"" fntFile:BMFONTREGULAR13 width:362 alignment:UITextAlignmentCenter];
    
    DLabel.color = ccc3(0, 0, 0);
    DLabel.position = ccp(180, 30);
    
    DLabel.tag = 14;
    [dButton addChild:DLabel];
    
    CCMenu *buttonsMenu = [CCMenu menuWithItems:aButton, bButton, cButton, dButton, nil];
    buttonsMenu.position = ccp(240, 110);
    [buttonsMenu alignItemsVerticallyWithPadding:1.0f];
    [buttonLayer addChild:buttonsMenu];
    
    [self prepareQuestionList];
    [self getNextQuestion];
}

- (void) createLives:(CGPoint)position lifetag:(int)tag {
    CCSprite *life = [CCSprite spriteWithSpriteFrameName:@"Lives.png"];
    life.position = position;
    life.scale = 0.6;
    life.tag = tag;
    [screenLayer addChild:life z:2];
}

- (void) removeLives:(int) tag {
    CCSprite *life = (CCSprite *)[screenLayer getChildByTag:tag];
    [life runAction:[CCFadeTo actionWithDuration:0.8f opacity:60]];

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
    [backGroundLayer runAction:[CCScaleTo actionWithDuration:2.2f scale:1.0f]];
}

- (void) zoomInBG {
    [backGroundLayer runAction:[CCScaleTo actionWithDuration:1.7f scale:1.4f]];
    [curtainLayer runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];

}

- (void) zoomAfterResume {
    [screenLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:1.0f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, -30)], nil]];
    [buttonLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:2.0f scale:1.0f], [CCMoveBy actionWithDuration:2.0f position:ccp(0, -30)], nil]];
    
    [backGroundLayer runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:1.7f scale:1.5f], nil]];
    [curtainLayer runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];
}

- (void) openCurtains {
    id scaleAndMoveLeft = [CCSpawn actions:[CCMoveTo actionWithDuration:6.0f position:ccp(-90, 184)], [CCTintTo actionWithDuration:4.0f red:100 green:10 blue:10], nil];
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
    [leftCurtain runAction:[CCTintTo actionWithDuration:3.0f red:210 green:210 blue:210]];
    [rightCurtain runAction:[CCTintTo actionWithDuration:3.0f red:210 green:210 blue:210]];
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
    

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    
    
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;

    [self checkAnswer:@"A"];
}

- (void) buttonBCheck: (id) sender {
    
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;

	[self checkAnswer:@"B"];
}

- (void) buttonCCheck: (id) sender {
    
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;

	[self checkAnswer:@"C"];
    
}

- (void) buttonDCheck: (id) sender {
    
    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    if (!enteredSkippedPhase) {
        [self addUsedQuestion:[[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue] category:categoryFromCategoryMenu];
    }
	questionNumberArrayIndex++;
    theRoundQuestionNumber++;

	[self checkAnswer:@"D"];
}

- (void) fadeLabelsOutAndInBetweenQuestions {
    [ALabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [BLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [CLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [DLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
    [questionLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:LABEL_FADING_DELAY], [CCFadeOut actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeIn actionWithDuration:0.5f], nil]];
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
    //[star runAction:[CCSpawn actions:[CCFadeIn actionWithDuration:0.5f], [CCMoveBy actionWithDuration:0.5f position:ccp(0,4)], nil]];
}

- (void) removeStarCombo:(int) spriteTag {
    CCSprite *removeSprite = (CCSprite*)[screenLayer getChildByTag:spriteTag];
    [removeSprite runAction:[CCSpawn actions:[CCMoveBy actionWithDuration:0.5f position:ccp(0, -15)], [CCFadeOut actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(spriteRemoveScreenLayer:)], nil]];
}

-(BOOL) checkCategory:(NSString *)difficulty_id {
	FMResultSet *categoryidQuery = [SlotDb executeQuery:@"SELECT difficulty_id FROM shuffledQuestions WHERE difficulty_id = ?", difficulty_id];
	if ([categoryidQuery next]) {


		return FALSE;
	}
	else {
		return TRUE;
	}

    
    [categoryidQuery close];
}

-(int) countMaximumRowsForCategory {
	FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (difficulty_id) FROM shuffledQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
	int totalCount = 0;
	if ([countQuery next]) {
		totalCount = [countQuery intForColumnIndex:0];

	}

    
    [countQuery close];
	return totalCount;
}

-(void) prepareQuestionList {
	[ShuffledQuestionList removeAllObjects];
	FMResultSet * slotQuestionQuery = [SlotDb executeQuery:@"SELECT question_id FROM shuffledQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu]; 
	while ([slotQuestionQuery next]) {

		[ShuffledQuestionList addObject:[NSNumber numberWithInt:[slotQuestionQuery intForColumn:@"question_id"]]];
	}


    
    [slotQuestionQuery close];
}

-(void) saveShuffledQuestions: (NSString*) category_id {
    
	int questionID = 0;
	[SlotDb beginTransaction];
	for (questionID = 0; questionID < [ShuffledQuestionList count]; questionID++) {
		[SlotDb executeUpdate:@"insert into shuffledQuestions (difficulty_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:[[ShuffledQuestionList objectAtIndex:questionID] intValue]]];
	}
	[SlotDb commit];	
}

-(void) shuffleQuestions:(NSString *) category_id {
	FMResultSet *actionQuestionQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT rowid FROM %@ WHERE difficulty_id = ?", level], category_id];
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
    //NSLog(@"%@", ShuffledQuestionList);
}

-(int) countRowPlayerIsUpTo {
	FMResultSet *countQuery = [SlotDb executeQuery:@"SELECT COUNT (difficulty_id) FROM usedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
	int rowCount = 0;
	if ([countQuery next]) {
		rowCount = [countQuery intForColumnIndex:0];
        
	}
    [countQuery close];
    //int skippedQuestions = [self countNumberOfSkippedQuestions];
    //int countTotal = rowCount + skippedQuestions;
    /*newly added*/
    
	return rowCount;
}

- (int) countNumberOfSkippedQuestions {
    FMResultSet *skipQuery = [SlotDb executeQuery:@"SELECT COUNT (difficulty_id) FROM skippedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
    int skipCount = 0;
    if ([skipQuery next]) {
        skipCount = [skipQuery intForColumnIndex:0];
    }
    /*newly added*/
    [skipQuery close];
    return skipCount;
}

-(void) addUsedQuestion:(int)questionID category:(NSString *) category_id {
	[SlotDb beginTransaction];
	[SlotDb executeUpdate:@"insert into usedQuestions (difficulty_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:questionID]];
	[SlotDb commit];
}

-(void) timeOver {
    //play boo sound
    //Time = TIME_LIMIT;
    [[SimpleAudioEngine sharedEngine] playEffect:@"OutOfTime.caf"];
    //************END OF GAME**************//
    //show correct answer
    consecutiveAnswers = 0;
    answeredRightWrong = FALSE;
    
    //only if there are lives remaining
    if (Lives) {
        Lives--;
        [self removeLives:Lives];
        //animate lives text and icon
        //[livesNumber runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.25f scale:1.3], [CCScaleTo actionWithDuration:0.25f scale:1.0f], nil]];
        [livesIcon runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.25f scale:1.3], [CCScaleTo actionWithDuration:0.25f scale:1.0f], nil]];
        //[livesNumber setString:[NSString stringWithFormat:@"%d", Lives]];
        
        questionNumberArrayIndex++;
        theRoundQuestionNumber++;
        [self showCorrectAnswerAnimation:Answer];
        [self greyOutInsignificantAnswersAfterTimer:Answer];
        NSLog(@"test");
    }
    else {
        /**** END GAME ****/
        //[self wipeScore];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EndOfRoundQuickplay scene:save difficultyLevel:level questions:numberOfQuestions]]];

    }

    //[Answer release];
    
}

-(void) getNextQuestion {
    [aButton setIsEnabled:TRUE];
    [bButton setIsEnabled:TRUE];
    [cButton setIsEnabled:TRUE];
    [dButton setIsEnabled:TRUE];
    [pauseButton setIsEnabled:TRUE];
    
    
    Time = save;
    [timerLabel setString:[NSString stringWithFormat:@"%d", Time]];

    [self schedule:@selector(scheduleUpdate:) interval:1.0f];
    
    if (Lives > 0) {
        if (questionNumberArrayIndex <= maxRowsForCategory-1) {
            
            [self saveCurrentQuestionToSettingsManager:save];
            
            [questionNumberLabel setString:[NSString stringWithFormat:@"%d", theRoundQuestionNumber+1]];
            tempQuestionID = [[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue];
            if (questionNumberArrayIndex < maxRowsForCategory) {
                [self getQuestionID:tempQuestionID category:categoryFromCategoryMenu skippedOn:FALSE];
            }
        }
        else {

            questionNumberArrayIndex = 0;
            [SlotDb beginTransaction];
            [SlotDb executeUpdate:@"DELETE FROM shuffledQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
            [SlotDb executeUpdate:@"DELETE FROM usedQuestions WHERE difficulty_id = ?", categoryFromCategoryMenu];
            [SlotDb commit];
            
            [self shuffleQuestions:categoryFromCategoryMenu];
            [self saveShuffledQuestions:categoryFromCategoryMenu];
            
            [questionNumberLabel setString:[NSString stringWithFormat:@"%d", theRoundQuestionNumber+1]];
            tempQuestionID = [[ShuffledQuestionList objectAtIndex:questionNumberArrayIndex] intValue];
            if (questionNumberArrayIndex < maxRowsForCategory) {
                [self getQuestionID:tempQuestionID category:categoryFromCategoryMenu skippedOn:FALSE];
            }
        }

    }
    else {
        [ALabel stopAllActions];
        [BLabel stopAllActions];
        [CLabel stopAllActions];
        [DLabel stopAllActions];
        [questionLabel stopAllActions];
        //[self wipeScore];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EndOfRoundQuickplay scene:save difficultyLevel:level questions:numberOfQuestions]]];

    }
}

-(void) getQuestionID:(int)questionID category:(NSString *) category_id skippedOn:(BOOL)skippedSet {
    FMResultSet *questionQuery;
    FMResultSet *aQuery;
    FMResultSet *bQuery;
    FMResultSet *cQuery;
    FMResultSet *dQuery;
    
    enteredSkippedPhase = skippedSet;
    
    if (skippedSet) {
        questionQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT question FROM %@ WHERE question_id = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID],category_id];
        
    }
    else {
        questionQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT question FROM %@ WHERE question_id = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID],category_id];
        
    }
    
	while ([questionQuery next]) {
		NSString *question = [questionQuery stringForColumn:@"question"];
        [questionLabel setString:question];
	}
	[questionQuery close];
	
    aQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT A FROM %@ WHERE rowid = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID], category_id];
    bQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT B FROM %@ WHERE rowid = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID], category_id];
    cQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT C FROM %@ WHERE rowid = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID], category_id];
    dQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT D FROM %@ WHERE rowid = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID], category_id];
    
    
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
    
    FMResultSet *answerQuery = [db executeQuery:[NSString stringWithFormat:@"SELECT Answer FROM %@ WHERE rowid = ? AND difficulty_id = ?", level], [NSNumber numberWithInt:questionID], category_id]; 
	
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
    [self openDatabase:@"Quickplay.sqlite"];
}

- (int) getSkippedQuestion:(int) questionID category:(NSString *)category_id {
    int skippedQuestionID;
    
    FMResultSet *skipQuery = [SlotDb executeQuery:@"SELECT question_id from skippedQuestions WHERE rowid = ? AND difficulty_id = ?", [NSNumber numberWithInt:questionID], category_id];
    while ([skipQuery next]) {
		skippedQuestionID = [skipQuery intForColumn:@"question_id"];
	}
    
    return skippedQuestionID;
}

- (void) skippedQuestion:(int)questionID category:(NSString *) category_id {
    [SlotDb beginTransaction];
	[SlotDb executeUpdate:@"insert into skippedQuestions (difficulty_id, question_id) values (?, ?)", category_id, [NSNumber numberWithInt:questionID]];
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
    
    consecutiveAnswers = 0;
    
    questionNumberArrayIndex++;
    theRoundQuestionNumber++;
    [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:2];

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
    [self pauseSchedulerAndActions];

    [aButton setIsEnabled:FALSE];
    [bButton setIsEnabled:FALSE];
    [cButton setIsEnabled:FALSE];
    [dButton setIsEnabled:FALSE];
    [pauseButton setIsEnabled:FALSE];

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
    pauseBG.scale = 0.9;
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
    
    
    CCMenu *pauseMenu = [CCMenu menuWithItems:resume, quit, BGMButton, SFXButton, nil];
    pauseMenu.position = ccp(0, 0);
    
    CCLabelTTF *areYouSure = [CCLabelTTF labelWithString:@"Do you want to quit?" fontName:PAUSE_FONT fontSize:13];
    areYouSure.position = ccp(240, 250);
    [pauseLayer addChild:areYouSure z:2];
    
    [pauseLayer addChild:pauseMenu z:2];
    pauseLayer.scale = 0.9;
    
    [resume runAction:[CCFadeIn actionWithDuration:1.0f]];
    [quit runAction:[CCFadeIn actionWithDuration:1.0f]];
    [areYouSure runAction:[CCFadeIn actionWithDuration:1.0f]];
    [pauseBG runAction:[CCFadeIn actionWithDuration:1.0f]];
    [BGMButton runAction:[CCFadeIn actionWithDuration:1.0f]];
    [SFXButton runAction:[CCFadeIn actionWithDuration:1.0f]];

}

-(void) BGM:(id) sender {
    BGM = !BGM;
    SettingsManager *BGMSettings = [SettingsManager sharedSettingsManager];
    
    if (BGM) {
        [BGMSettings setBool:TRUE keyString:@"Music"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.5;
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOn.png"]];
    }
    else {
        [BGMSettings setBool:FALSE keyString:@"Music"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
        [BGMButton setNormalImage:[CCSprite spriteWithSpriteFrameName:@"BGMOff.png"]];
    }
    [BGMSettings saveToFileInLibraryDirectory:@"SoundSettings.plist"];
}

-(void) SFX:(id) sender {
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
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
    
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

-(void) checkAnswer:(NSString *) yourAnswer {

    [pauseButton setIsEnabled:FALSE];
    
    [self unschedule:@selector(scheduleUpdate:)];

	if ([yourAnswer isEqualToString:Answer]) {
        if (consecutiveAnswers < 11) {
            consecutiveAnswers++;
        }
        correctlyAnswered++;
        [self saveCorrectlyAnswered];
        [self saveComboToSettingsManager:consecutiveAnswers];

        
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
            [[SimpleAudioEngine sharedEngine] playEffect:@"Woohoo3.caf"];
        }
        
        [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:1];
        if (theRoundQuestionNumber <= 10) {
            answeredRightWrong = TRUE;
        }

        [self correctAnswerAnimation:yourAnswer];
        [correctlyAnsweredLabel setString:[NSString stringWithFormat:@"Correct: %d", correctlyAnswered]];

	}
	else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"aaww1.caf"];
        
        consecutiveAnswers = 0;
        answeredRightWrong = FALSE;
        Lives--;
        
        [self removeLives:Lives];
        [self saveStarsAfterQuitting:save starNumber:theRoundQuestionNumber answerType:0];
        [self wrongAnswerAnimation:yourAnswer]; 
        [self showCorrectAnswerAnimation:Answer];
        [self greyOutInsignificantAnswers:Answer userAnswer:yourAnswer];
	}
    
	[Answer release];
}

- (void) updateScore:(id) sender {

}

-(void) saveCorrectlyAnswered {
    SettingsManager *correctlyAnsweredManager = [SettingsManager sharedSettingsManager];
    [correctlyAnsweredManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    [correctlyAnsweredManager setInteger:correctlyAnswered keyString:[NSString stringWithFormat:@"%@ Answered", level]];
    [correctlyAnsweredManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
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
    ShuffledQuestionList = nil; //added 29/9/11 16:27
    
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
