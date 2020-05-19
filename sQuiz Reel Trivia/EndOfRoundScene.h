//
//  EndOfRoundScene.h
//  TriviaMenu
//
//  Created by mark wong on 19/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SettingsManager.h"
#import "questionScene.h"
#import <GameKit/GameKit.h>
#import "CategoryLevel2.h"
#import "CategoryLevel3.h"
#import "GCHelper.h"

@interface EndOfRoundScene : CCLayer {
    
    int starType;
    int page;
    CCLabelTTF *touchToContinue;
    CCLabelTTF *questionsCorrect;
    CCLabelTTF *questionsCorrectTitle;
    CCLabelTTF *scoreSceneComboLabel;
    CCLabelTTF *scoreSceneComboTitleLabel;
    CCLabelTTF *scoreSceneScoreLabel;
    CCLabelTTF *scoreSceneScoreTitleLabel;
    CCLabelTTF *categoryTitleLabel;
    CCLabelTTF *endOfRoundTitle;

    CCLabelTTF *overallScoreTitle;
    CCLabelTTF *overallScore;
    CCLabelTTF *categoryScoreTitle;
    CCLabelTTF *categoryScore;
    CCLabelTTF *finalRankTitle;
    CCLabelTTF *finalRank;
    CCLabelTTF *grats;

    CCLabelBMFont *factTitle;
    CCLabelBMFontMultiline *fact;
    CCSprite *factBG;
    
    FMDatabase* slotDb;
    BOOL databaseOpenedSlot;
    BOOL categoryComplete;
    FMDatabase* reelFactsDb;
    BOOL databaseOpened;
}

+(id) scene:(int) saveSlot category:(NSString*) categoryName lvl:(int)levelNumber;

-(void) congratulations;
-(void) starsEffects;
-(void) starsEffects2;
-(void) starsEffects3;
-(void) loadScoreFromSettingsManager;
-(void) loadScoreFromSettingsManager2;

-(int) loadStarTypeFromSettingsManager:(int)saveSlot starTypeNumber:(int)number;
-(void) loadRankFromSettingsManager:(int)saveSlot;
-(void) loadTimePlayedFromSettingsManager:(int)saveSlot;
-(int) loadCorrectlyAnsweredFromSettingsManager;
-(void) loadStarCombo:(int)saveSlot;
-(void) createStars:(CGPoint)position starNumber:(int)number;
-(int) loadAnsweredRightForRound;
-(int) getCategoryScore;
-(int) getOverallScore;
-(int) getQuestionsCorrect;
-(NSString *) getRank;
-(int) countMaxRowsForCategory;
-(void) resetStats;
-(void) openSlotDatabase;
-(NSString *) setRank:(int) progress;
-(void) fadeInReelFacts;
-(void) openReelFactsDatabase;
//-(void) wipeScore;
@end
