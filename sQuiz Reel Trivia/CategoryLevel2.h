//
//  CategoryMenu.h
//  TriviaMenu
//
//  Created by mark wong on 14/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "questionScene.h"
#import "FMDatabase.h"
#import "SimpleAudioEngine.h"
#import "FMDatabaseAdditions.h"
#import "LevelSelect.h"
#import "CCLabelBMFontMultiline.h"

@interface CategoryLevel2 : CCLayer {
    SimpleAudioEngine *sae;
    
    CCTexture2D *Level1NoTextSpriteSheet;
    CCTexture2D *CategoryMenuSpriteSheet;
    
    CCLayer *pageOne;
    CCLayer *pageTwo;
	CCLayer *pageThree;
    CCLayer *statLayer;
    CCLayer *pauseLayer;
    
    /*
     CCLabelTTF *actionCompleteLabel;
     CCLabelTTF *actionSkipLabel;
     CCLabelTTF *actionScoreLabel;
     CCLabelTTF *comedyCompleteLabel;
     CCLabelTTF *comedySkipLabel;
     CCLabelTTF *comedyScoreLabel;
     CCLabelTTF *dramaCompleteLabel;
     CCLabelTTF *dramaSkipLabel;
     CCLabelTTF *dramaScoreLabel;
     */
    
    CCLabelTTF *scoreTitle;
    CCLabelTTF *rankTitle;
    CCLabelTTF *progressTitle;
    CCLabelTTF *scoreResult;
    CCLabelTTF *rankResult;
    CCLabelTTF *progressResult;
    CCLabelTTF *warning;
    CCLabelTTF *categoryTitle;
    
    FMDatabase* slotDb;
    
    BOOL databaseOpenedSlot;
    BOOL showReview;
    BOOL changeMusic;
    BOOL didRoundEnd;
    BOOL SFX;
    BOOL BGM;
    
	CCScrollLayer *categoryScroller;
    
	id target;
    
	CCMenuItemSprite *ActionButton;
	CCMenuItemSprite *ComedyButton;
	CCMenuItemSprite *DramaButton;
    CCMenuItemSprite *statButton;
    
    CCSprite *leftCurtain;
    CCSprite *rightCurtain;
    CCSprite *glow;
    CCSprite *categoryReviewBackground;
    
	int categoriesSelected;
    int changedCategoryMusic;
    
    NSString *CurrentCategory;
    
    CGSize windowSize;
    
}
+(id) scene:(int) saveSlot lvl:(int)levelNumber;
-(void) SoundSettings;
- (NSString *) setRank:(int) progress totalProgressSoFar:(int) totalProgress;
- (void) lockPlayerIntoCategory;
- (void) openSlotDatabase;
-(void) categoryMenu;
-(void) getStatsFromSettingsManager:(NSString *) category;
-(int) countMaximumRowsForSkippedQuestions:(NSString *) categoryFromCategoryDb;
-(int) countMaximumRowsForCategory:(NSString *) categoryFromCategoryDb;
@end
