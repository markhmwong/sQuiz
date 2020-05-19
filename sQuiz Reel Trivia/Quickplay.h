//
//  questionScene.h
//  TriviaMenu
//
//  Created by mark wong on 1/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#import "EndOfRoundQuickplay.h"
#import "SettingsManager.h"
#import "CCLabelBMFontMultiline.h"
#import "mainMenu.h"

@interface Quickplay : CCLayer {
	int SavePercentageComplete;
	int SaveAchievements;
	int SaveLevel1QuestionComplete;
    NSString *SaveDate;
	NSString *SaveName;
    
	FMDatabase * db;
	FMDatabase * SlotDb;
	FMDatabase * scoringDb;
    
	BOOL databaseOpened;
	BOOL endOfRound;
    BOOL countdownSkipped;
    BOOL enteredSkippedPhase;
    BOOL categoryComplete;
    BOOL BGM;
    BOOL SFX;
    BOOL TICKTOCK;
    BOOL answeredRightWrong;

    CCLabelBMFontMultiline *questionLabel;

    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *scoreAddLabel;

    CCLabelTTF *countdownNumber;
    CCLabelTTF *questionNumberLabel;
    CCLabelBMFontMultiline *ALabel;
    CCLabelBMFontMultiline *BLabel;
    CCLabelBMFontMultiline *CLabel;
    CCLabelBMFontMultiline *DLabel;
    CCLabelBMFont *timerLabel;
    CCLabelBMFont *timerAddLabel;
    CCLabelBMFont *correctlyAnsweredLabel;
    CCLabelBMFont *livesLabel;
    
    CCMenuItemSprite *aButton;
	CCMenuItemSprite *bButton;
	CCMenuItemSprite *cButton;
	CCMenuItemSprite *dButton;
    CCMenuItemSprite *pauseButton;
    CCMenuItemSprite *skipButton;
    CCMenuItemSprite *SFXButton;
    CCMenuItemSprite *BGMButton;
    
    CCLayer *pauseLayer;
    CCLayer *menuLayer;
    CCLayer *buttonLayer;
    CCLayer *backGroundLayer;
    CCLayer *curtainLayer;
    CCLayer *screenLayer;
    
    CCLabelBMFont *CategoryText;
    
    CCSpriteBatchNode *spriteSheet;
    CCSpriteBatchNode *BGSpriteSheet;
    CCTexture2D *levelBgSpriteSheet;
    CCTexture2D *pauseBgSpriteSheet;
    CCTexture2D *categoryBGSpriteSheet;
    CCSprite *CategoryBackground;
    CCSprite *questionBox;
    CCSprite *grain1;
    CCSprite *grain2;
    CCSprite *grain3;
    CCSprite *grain4;
    CCSprite *leftCurtain;
    CCSprite *rightCurtain;
    CCSprite *countdownBackground;
    CCSprite *BG;
    CCSprite *crosshairBg;
    CCSprite *lineGrain;
    CCSprite *categoryText;
    CCSprite *comboEffect;
    CCSprite *livesIcon;
    
    int theRoundQuestionNumber;
    int SaveCombo;
    int SaveScore;
    int tempQuestionID;
    int consecutiveAnswers;
	int questionNumberArrayIndex;
	int score;
    int totalScore;
	int maxRowsForCategory;
	int resumeFromRow;
	int skippedNumberIndex;
    int categoryScore;
    int questionsUsed;
    int Time;
    int Lives;
    int correctlyAnswered;
    
	NSString *scoreString;
	NSString *Answer;
	NSString *questionFont;
	
    CGSize windowSize;
	
	NSMutableArray *ShuffledQuestionList;


}

+(id) scene:(int) setTimer difficultyLevel:(NSString *) difficulty questions:(int)questionsPerRound;

-(void) SoundSettings;

-(void) timeOver;

-(void) checkIfCategoryHasBeenCompleted;
-(void) checkIfOneHundredQuestionsInUsedQuestions;

//-(void) wipeScore;
-(void) createLives:(CGPoint)position lifetag:(int)tag;
-(void) saveCorrectlyAnswered;

-(void) fadeLabelsOutAndInBetweenQuestions;

-(void) skippedQuestion:(int)questionID category:(NSString *) category_id;
-(int) countNumberOfSkippedQuestions;
-(int) getSkippedQuestion:(int) questionID category:(NSString *) category_id;

//-(void) createEmptyStar:(CGPoint) position;
-(void) createStarCombo:(CGPoint) position starTag:(int) spriteTag comboNumber:(int) number colour:(int) correct;
-(void) removeStarCombo:(int) spriteTag;
-(void) loadStarsAfterQuitting;
-(void) saveStarsAfterQuitting:(int) saveNumber starNumber:(int) number answerType:(int) answered;

-(int) checkComboIfHigherThanCurrentCombo:(int)saveNumber;
-(int) loadComboFromSettingsManager;
-(void) saveComboToSettingsManager:(int)comboNumber;
-(void) loadCurrentQuestionFromSettingsManager:(int)saveNumber;
-(void) saveCurrentQuestionToSettingsManager:(int)saveNumber;
-(void) saveScoreToSettingsManager:(int)saveNumber;
-(void) loadScoreFromSettingsManager:(int)saveNumber;
-(void) checkAnswer:(NSString *)yourAnswer;

-(void) startCountdown;
-(void) finishCountdown;
-(void) checkIfCountdownSkipped;

-(void) openDatabase:(NSString*)dbName;
-(void) openSlotDatabase:(NSString*)dbName;
-(void) openScoringDatabase;

-(void) getQuestionID: (int)questionID category:(NSString*) category_id skippedOn:(BOOL) skippedSet;
-(void) getNextQuestion;
-(void) addUsedQuestion:(int)questionID category:(NSString*) category_id;
-(void) saveShuffledQuestions:(NSString*)category_id;
-(void) shuffleQuestions:(NSString*) category_id;
-(BOOL) checkCategory:(NSString*)difficulty_id;
-(int) countMaximumRowsForCategory;
-(int) countRowPlayerIsUpTo;
-(void) prepareQuestionList;

-(void) fadeLightsIn;
-(void) fadeLightsOut;
-(void) openCurtains;
-(void) closeCurtains;
-(void) zoomInBG;
-(void) zoomOutBG;
-(void) zoomAfterResume;
-(void) startAnimationQuestionScene;
-(void) correctAnswerAnimation:(NSString *) yourAnswer;
-(void) wrongAnswerAnimation:(NSString *) yourAnswer;
-(void) greyOutInsignificantAnswers:(NSString *) correctAnswer userAnswer:(NSString *) yourAnswer;
-(void) greyOutInsignificantAnswersAfterTimer:(NSString *) correctAnswer;
-(void) showCorrectAnswerAnimation:(NSString *) correctAnswer;

-(void) starsEffect:(NSString *) answer;
@end
