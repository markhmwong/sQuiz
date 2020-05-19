//
//  EndOfRoundScene.m
//  TriviaMenu
//
//  Created by mark wong on 19/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EndOfRoundScene.h"

#define STATSFONT @"OpenSans-Bold.ttf"
#define CATEGORYTEXT90 @"CategoryText90.fnt"

@implementation EndOfRoundQuickplay
static int save;
static int numberOfQuestions;
static NSString * level;

+(id) scene:(int) setTimer difficultyLevel:(NSString *)difficulty questions:(int)questionsPerRound {

	CCScene *scene = [CCScene node];
    
	save = setTimer;
    level = difficulty;
    numberOfQuestions = questionsPerRound;
    
	// 'layer' is an autorelease object.
	EndOfRoundQuickplay *layer = [EndOfRoundQuickplay node];

	[scene addChild: layer];

	return scene;
}

-(id) init
{
	if( ( self = [super init] )) {
        /*
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"CategoryMenuBG.png"];
        background.position = ccp(240, 25);
        [self addChild:background];*/
        /*
        CCSprite *leftCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        leftCurtain.position = ccp(0,184);
        leftCurtain.flipX = TRUE;
        [self addChild:leftCurtain z:2];

        CCSprite *rightCurtain = [CCSprite spriteWithSpriteFrameName:@"CurtainLeft.png"];
        rightCurtain.position = ccp(480, 184);
        [self addChild:rightCurtain z:2];*/
        
        CCSprite *nextRoundButtonSelected = [CCSprite spriteWithSpriteFrameName:@"ReplayButton.png"];
        nextRoundButtonSelected.color = ccc3(130, 130, 130);
        CCMenuItemSprite *nextRoundButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ReplayButton.png"] selectedSprite:nextRoundButtonSelected target:self selector:@selector(nextRound:)];
        nextRoundButton.position = ccp(445, 35);
    
        
        CCSprite *exitRoundButtonSelected = [CCSprite spriteWithSpriteFrameName:@"HomeButton.png"];
        exitRoundButtonSelected.color = ccc3(130, 130, 130);
        CCMenuItemSprite *exitRoundButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HomeButton.png"] selectedSprite:exitRoundButtonSelected target:self selector:@selector(exitButton:)];
        exitRoundButton.position = ccp(35, 35);
        CCMenu *scoreMenuButtons = [CCMenu menuWithItems:nextRoundButton, exitRoundButton, nil];
        scoreMenuButtons.position = ccp(0,0);
        [self addChild:scoreMenuButtons z:3];
        
        reviewBackground = [CCSprite spriteWithSpriteFrameName:@"CountdownBG.png"];
        reviewBackground.position = ccp(240, 160);

        [self addChild:reviewBackground];
        
        [reviewBackground runAction:[CCSequence actions:[CCFadeIn actionWithDuration:2.0f], [CCCallFuncN actionWithTarget:self selector:@selector(backgroundRepeat:)], nil]];

        
        CCLabelBMFont *EasyTextFlyBy = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
        EasyTextFlyBy.position = ccp(600, 60);
        EasyTextFlyBy.color = ccc3(200, 200, 200);
        [self addChild:EasyTextFlyBy];
        
        [EasyTextFlyBy runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCMoveBy actionWithDuration:25.0f position:ccp(-700, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(700, 0)], nil]]];
        
        CCLabelBMFont *EasyTextFlyBy2 = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
        EasyTextFlyBy2.position = ccp(550, 270);                    
        EasyTextFlyBy2.scale = 0.6;
        EasyTextFlyBy2.color = ccc3(200, 200, 200);
        [self addChild:EasyTextFlyBy2];
        
        [EasyTextFlyBy2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:20.0f position:ccp(-670, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(670, 0)], nil]]];
        
        CCLabelBMFont *EasyTextFlyBy3 = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", level] fntFile:CATEGORYTEXT90];
        EasyTextFlyBy3.position = ccp(-80, 113);                    
        EasyTextFlyBy3.scale = 0.3;
        EasyTextFlyBy3.color = ccc3(150, 150, 150);
        [self addChild:EasyTextFlyBy3];
        
        [EasyTextFlyBy3 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCMoveBy actionWithDuration:15.0f position:ccp(670, 0)], [CCMoveBy actionWithDuration:0.0f position:ccp(-80, 0)], nil]]];
        
        [self loadScoreFromSettingsManager:save];
	}
	return self;
}

-(void) backgroundRepeat: (id) sender {
    [reviewBackground runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.3f scale:0.97], [CCScaleTo actionWithDuration:0.3f scale:0.95], [CCScaleTo actionWithDuration:0.3f scale:0.92], [CCScaleTo actionWithDuration:0.4f scale:0.95], nil]]];   
}

- (void) backButton: (id) sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
}

- (void) exitButton: (id) sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[mainMenu scene]]];
    
}

- (void) nextRound: (id) sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[Quickplay scene:save difficultyLevel:level questions:20]]];

}

-(void) loadScoreFromSettingsManager:(int)saveSlot {
    SettingsManager *slotSettingsManager = [SettingsManager sharedSettingsManager];
	[slotSettingsManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    
    CCLabelTTF *categoryTitleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", level] fontName:STATSFONT fontSize:20];
    categoryTitleLabel.color = ccc3(255, 255, 0);
    categoryTitleLabel.position = ccp(240, 250);

    [self addChild:categoryTitleLabel];
    
    CCLabelTTF *scoreSceneScoreTitleLabel = [CCLabelTTF labelWithString:@"Answered Correct" fontName:STATSFONT fontSize:20];
    scoreSceneScoreTitleLabel.position = ccp(185, 215);
    scoreSceneScoreTitleLabel.color = ccc3(0, 0, 0);
    [self addChild:scoreSceneScoreTitleLabel];
    
    int answered = [self loadCorrectlyAnsweredFromSettingsManager];
    CCLabelTTF *scoreSceneScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", answered] fontName:STATSFONT fontSize:19];
    scoreSceneScoreLabel.opacity = 0;
    
    scoreSceneScoreLabel.scale = 5.0f;
    scoreSceneScoreLabel.position = ccp(350, 215);
    scoreSceneScoreLabel.color = ccc3(0, 0, 0);
    [self addChild:scoreSceneScoreLabel];
    
    [scoreSceneScoreLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6f], [CCScaleTo actionWithDuration:0.3f scale:1.0f], nil]];
    
    [[GCHelper sharedInstance] reportScore:answered forLeaderboard:@"com.whizbang.sQuizReelTrivia.quickplay"];

    
    [self performSelector:@selector(starsEffects) withObject:nil afterDelay:0.10f];
    
    int combo = [slotSettingsManager getInt:@"Combo"];
    CCLabelTTF *scoreSceneComboTitleLabel = [CCLabelTTF labelWithString:@"Round Combo" fontName:STATSFONT fontSize:20];
    scoreSceneComboTitleLabel.position = ccp(165, 175);
    scoreSceneComboTitleLabel.color = ccc3(0, 0, 0);
    
    CCLabelTTF *scoreSceneComboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", combo] fontName:STATSFONT fontSize:19];
    scoreSceneComboLabel.scale = 5.0f;
    scoreSceneComboLabel.position = ccp(350, 175);
    scoreSceneComboLabel.color = ccc3(0, 0, 0);
    scoreSceneComboLabel.opacity = 0;
    
    [self addChild:scoreSceneComboTitleLabel];
    [self addChild:scoreSceneComboLabel];
    
    [scoreSceneComboLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.65f], [CCScaleTo actionWithDuration:0.3f scale:1.0f], nil]];
    
    [self performSelector:@selector(starsEffects2) withObject:nil afterDelay:0.30f];
    

    [self performSelector:@selector(starsEffects3) withObject:nil afterDelay:0.50f];
    
    [scoreSceneComboLabel runAction:[CCFadeIn actionWithDuration:1.8f]];
    [scoreSceneComboTitleLabel runAction:[CCFadeIn actionWithDuration:1.8f]];
    
    [scoreSceneScoreLabel runAction:[CCFadeIn actionWithDuration:1.8f]];
    [scoreSceneScoreTitleLabel runAction:[CCFadeIn actionWithDuration:1.8f]];
    
    [self wipeScore];
}

-(void) wipeScore {
    SettingsManager *wipeScoreManager = [SettingsManager sharedSettingsManager];
    [wipeScoreManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    [wipeScoreManager setInteger:0 keyString:[NSString stringWithFormat:@"%@ Answered", level]];
    [wipeScoreManager saveToFileInLibraryDirectory:@"QuickplaySlot.plist"];
}

-(void) starsEffects3 {
    ccBezierConfig bezier;
    bezier.controlPoint_2 = ccp(30, 10);
    bezier.controlPoint_1 = ccp(0, 0);
    bezier.endPosition = ccp(25, -100);
    
    CCSprite *starEffect1 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect1.scale = 0.5;
    starEffect1.opacity = 0.0;
    starEffect1.position = ccp(360, 145);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 145);
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
    starEffect3.position = ccp(350, 125);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 125);
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
    starEffect5.position = ccp(330, 125);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 125);
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
    starEffect7.position = ccp(335, 145);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 145);
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
    starEffect1.position = ccp(360, 185);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 185);
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
    starEffect3.position = ccp(350, 165);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 165);
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
    starEffect5.position = ccp(330, 165);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 165);
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
    starEffect7.position = ccp(335, 185);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 185);
    [self addChild:starEffect8];
    
    [starEffect8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
}

-(void) starsEffects {
    
    ccBezierConfig bezier;
    bezier.controlPoint_2 = ccp(30, 10);
    bezier.controlPoint_1 = ccp(0, 0);
    bezier.endPosition = ccp(25, -100);
    
    CCSprite *starEffect1 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect1.scale = 0.5;
    starEffect1.opacity = 0.0;
    starEffect1.position = ccp(360, 224);
    starEffect1.color = ccc3(255, 250, 0);
    [self addChild:starEffect1]; 
    
    [starEffect1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5], [CCBezierBy actionWithDuration:1.0f bezier:bezier], [CCRotateBy actionWithDuration:2.0f angle:180], [CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect2 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect2.scale = 0.8;
    starEffect2.opacity = 0.0;
    starEffect2.color = ccc3(255, 250, 0);
    starEffect2.position = ccp(370, 222);
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
    starEffect3.position = ccp(350, 200);
    [self addChild:starEffect3];
    
    [starEffect3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier2], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect4 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect4.scale = 0.5;
    starEffect4.opacity = 0.0;
    starEffect4.color = ccc3(250, 250, 0);
    starEffect4.position = ccp(350, 195);
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
    starEffect5.position = ccp(330, 212);
    [self addChild:starEffect5];
    
    [starEffect5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier3], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect6 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect6.scale = 0.5;
    starEffect6.opacity = 0.0;
    starEffect6.color = ccc3(250, 250, 0);
    starEffect6.position = ccp(335, 205);
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
    starEffect7.position = ccp(335, 225);
    [self addChild:starEffect7];
    
    [starEffect7 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.9f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
    
    CCSprite *starEffect8 = [CCSprite spriteWithSpriteFrameName:@"Combo.png"];
    starEffect8.scale = 0.5;
    starEffect8.opacity = 0.0;
    starEffect8.color = ccc3(250, 250, 0);
    starEffect8.position = ccp(330, 220);
    [self addChild:starEffect8];
    
    [starEffect8 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCSpawn actions:[CCFadeOut actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.5],[CCBezierBy actionWithDuration:1.0f bezier:bezier4], [CCRotateBy actionWithDuration:2.0f angle:180],[CCFadeOut actionWithDuration:0.5f], nil], nil]];
}


-(int) loadStarTypeFromSettingsManager:(int)saveSlot starTypeNumber:(int)number {
    SettingsManager *starTypeManager = [SettingsManager sharedSettingsManager];
    [starTypeManager loadFromFileInLibraryDirectory:[NSString stringWithFormat:@"SaveSlot%d.plist", saveSlot]];
    
    starType = [starTypeManager getInt:[NSString stringWithFormat:@"QuestionStars%d", number]];
    
    return starType;
}

-(int) loadCorrectlyAnsweredFromSettingsManager {
    SettingsManager *correctlyAnsweredManager = [SettingsManager sharedSettingsManager];
    [correctlyAnsweredManager loadFromFileInLibraryDirectory:@"QuickplaySlot.plist"];
    return [correctlyAnsweredManager getInt:[NSString stringWithFormat:@"%@ Answered", level]];
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