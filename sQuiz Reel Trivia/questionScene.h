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
#import "CategoryMenu.h"
#import "CategoryLevel3.h"
#import "CategoryLevel2.h"
#import "EndOfRoundScene.h"
#import "SettingsManager.h"
#import "CCLabelBMFontMultiline.h"
#import "GCHelper.h"
#import "GKAchievementHandler.h"
#import "GKAchievementNotification.h"
#import <sqlite3.h>
#import <math.h>

@interface questionScene : CCLayer {
	int SavePercentageComplete;
	int SaveAchievements;
	int SaveLevel1QuestionComplete;
    int answeredRight;
    
	FMDatabase * db;
	FMDatabase * SlotDb;
	FMDatabase * scoringDb;
    
	BOOL databaseOpened;
	BOOL endOfRound;
    BOOL countdownSkipped;
    BOOL enteredSkippedPhase;
    BOOL BGM;
    BOOL SFX;
    BOOL TICKTOCK;
    BOOL answeredRightWrong;
    BOOL categoryComplete;
    
    CCLabelTTF *countdownNumber;
    CCLabelBMFontMultiline *questionLabel;
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *scoreAddLabel;
    CCLabelTTF *questionNumberLabel;
    CCLabelBMFontMultiline *ALabel;
    CCLabelBMFontMultiline *BLabel;
    CCLabelBMFontMultiline *CLabel;
    CCLabelBMFontMultiline *DLabel;
    CCLabelBMFont *timerLabel;

    CCMenuItemSprite *SFXButton;
    CCMenuItemSprite *BGMButton;
    CCMenuItemSprite *aButton;
	CCMenuItemSprite *bButton;
	CCMenuItemSprite *cButton;
	CCMenuItemSprite *dButton;
    CCMenuItemSprite *pauseButton;
    CCMenuItemSprite *skipButton;
    
    CCLayer *pauseLayer;
    CCLayer *menuLayer;
    CCLayer *buttonLayer;
    CCLayer *backGroundLayer;
    CCLayer *curtainLayer;
    CCLayer *screenLayer;
        
    //CCSpriteBatchNode *CategoryText;
    CCLabelBMFont *CategoryText;
    CCSpriteBatchNode *spriteSheet;
    CCSpriteBatchNode *BGSpriteSheet;
    CCTexture2D *levelBgSpriteSheet;
    CCTexture2D *pauseBgSpriteSheet;
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
    
    CCMenuItemSprite *eliminate;
    CCMenuItemSprite *fiftyFifty;
    
    int theRoundQuestionNumber;
    int SaveCombo;
    int RoundScore;
    int tempQuestionID;
    int consecutiveAnswers;
	int questionNumberArrayIndex;
	int score;
    int CategoryScore;
	int maxRowsForCategory;
	int resumeFromRow;
	int skippedNumberIndex;
    int categoryScore;
    int questionsUsed;
    int Time;
    int TimeTaken;
    
	NSString *scoreString;
	NSString *Answer;
	NSString *questionFont;
	
    CGSize windowSize;
	
	NSMutableArray *ShuffledQuestionList;
    
    //CCProgressTimer* timer;
}

+(id) scene:(int) saveSlot category:(NSString*) categoryName lvl:(int)levelNumber;

-(void) SoundSettings;
-(void) selectMusic;
-(void) timeOver;

-(void) greyOutA;
-(void) greyOutB;
-(void) greyOutC;
-(void) greyOutD;
-(void) setEliminateUsedToTrue;
-(void) setEliminateUsedToFalse;
-(BOOL) checkIfFiftyFiftyUsed;
-(BOOL) checkIfEliminateUsed;
-(void) setFiftyFiftyToTrue;
-(void) setFiftyFiftyToFalse;

-(void) setAchievement:(NSString *) achievementID;
-(BOOL) checkAchievement:(NSString *) achievementID;

-(BOOL) checkIfCategoryHasBeenCompleted;
-(void) checkIfOneHundredQuestionsInUsedQuestions;
-(void) markCategoryComplete;
-(void) fadeLabelsOutAndInBetweenQuestions;

-(void) skippedQuestion:(int)questionID category:(NSString *) category_id;
-(int) countNumberOfSkippedQuestions;
-(int) getSkippedQuestion:(int) questionID category:(NSString *) category_id;

-(void) createEmptyStar:(CGPoint) position;
-(void) createStarCombo:(CGPoint) position starTag:(int) spriteTag comboNumber:(int) number colour:(int) correct;
-(void) removeStarCombo:(int) spriteTag;
-(void) loadStarsAfterQuitting:(int) saveNumber;
-(void) saveStarsAfterQuitting:(int) saveNumber starNumber:(int) number answerType:(int) answered;
-(void) clearStarsInPLIST:(int) saveNumber;
-(int) checkComboIfHigherThanCurrentCombo:(int)saveNumber;
-(int) loadComboFromSettingsManager:(int)saveNumber;
-(void) saveComboToSettingsManager:(int)saveNumber;
-(void) loadCurrentQuestionFromSettingsManager:(int)saveNumber;
-(void) saveCurrentQuestionToSettingsManager:(int)saveNumber;
-(void) saveScoreToSettingsManager:(int)saveNumber;
-(void) loadScoreFromSettingsManager:(int)saveNumber;
-(void) saveNumberOfAnsweredRight:(int)save;
-(void) loadNumberOfAnsweredRight:(int)save;
-(void) checkAnswer:(NSString *)yourAnswer;
-(void) saveProgressToSettingsManager:(int) save;

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
-(BOOL) checkCategory:(NSString*)category_id;
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

-(int) getCombo;
-(void) starsEffect:(NSString *) answer;
@end
