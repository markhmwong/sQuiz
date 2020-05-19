//
//  mainMenu.h
//  Trivia
//
//  Created by mark wong on 20/05/11.
//  Copyright 2011 . All rights reserved.
//

#import "cocos2d.h"
#import "Credits.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "SettingsManager.h"
#import "CCScrollLayer.h"
#import "SimpleAudioEngine.h"
#import "LevelSelect.h"
#import <GameKit/GameKit.h>

#import "AppDelegate.h"
#import "RootViewController.h"
#import "Quickplay.h"
#import "GCHelper.h"
#import "AppDelegate.h"

//@class AppDelegate;
//, GKLeaderboardViewControllerDelegate, GameCenterManagerDelegate
@interface mainMenu : CCLayer <UITextFieldDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {

    //UIViewController *gameCenterViewController;
    AppDelegate *delegate;
/*
	GameCenterManager *gameCenterManager;
	int64_t  currentScore;
	NSString* currentLeaderBoard;
	CCLabelTTF *currentScoreLabel;
    */
    FMDatabase* reelFactsDb;
    FMDatabase* scoringDb;
    FMDatabase* slotDb;
    
    CCTexture2D *mainMenuSpriteSheet;
    CCTexture2D *gameplayButtons;
    CCTexture2D *buttonsEffects;
    
    CCMenu *menu;
    CCMenu *confirmDeleteMenu;
    CCMenuItemSprite *SinglePlayerButton;
    CCMenuItemSprite *CreditsButton;
    CCMenuItemSprite *QuickPlayButton;
    CCMenuItemSprite *StatsButton;
    //CCMenuItemSprite *MultiPlayerButton;
	CCLayer *menuLayer;
    
    CCSprite *blankTicket;
    CCSprite *screenFlash;
    CCSprite *flash2;
    CCSprite *flash1;
    CCSprite *flash3;
    CCSprite *ReelFactBG;

    //CCLabelTTF *fact;
    CCLabelBMFont *factTitle;
    CCLabelBMFontMultiline *fact;
    //CCLabelTTF *factTitle;
    CCLabelTTF *areYouSureLabel;
    CCLabelTTF *NewGameLabelSlotOne;
    CCLabelTTF *NewGameLabelSlotTwo;
    CCLabelTTF *NewGameLabelSlotThree;
    //*************"Load game" stuff*******//
	CCLayerColor *darken;

    CCLayer *slotOneLayer;
    CCLayer *slotTwoLayer;
    CCLayer *slotThreeLayer;
    CCLayer *disableTouch;
    CCLayer *confirmLayer;
    
    CCScrollLayer *scroller;
    
    CCMenuItemSprite *slotOneMenuButton;
    CCMenuItemSprite *slotTwoMenuButton;
    CCMenuItemSprite *slotThreeMenuButton;
    CCMenuItemSprite *deny;
    CCMenuItemSprite *confirm;
    CCMenuItemSprite *deleteButton;
    CCMenuItemSprite *statsButton;
    CCMenuItemSprite *SFXButton;
    CCMenuItemSprite *BGMButton;    
    CCMenuItemSprite *SettingsButton;
    
    BOOL settingsMenuOn;
    BOOL isEmpty;
    BOOL Level2Lock;
    BOOL Level3Lock;
    BOOL Level4Lock;
    BOOL QuestionStars;
    BOOL Question;
    BOOL databaseOpened;
    BOOL databaseOpenedScores;
    BOOL databaseOpenedSlot;
    BOOL didRoundEnd;
    BOOL isTutorialFinished;
    BOOL BGM;
    BOOL SFX;
    BOOL ActionComplete;
	UITextField *nameTextField;
    
    int SaveScore;
    int SaveTotalScore;
    int SaveActionScore;
    int SaveComedyScore;
    int SaveDramaScore;
    int SaveAnimationScore;
    int SaveThrillerScore;
    int SaveAdventureScore;
    int SaveRomanticComedyScore;
    int SaveSciFiScore;
    int SaveFamilyScore;
    
    int SaveCombo;
    
    int SaveActionCombo;
    int SaveComedyCombo;
    int SaveDramaCombo;
    int SaveSciFiCombo;
    int SaveAnimationCombo;
    int SaveThrillerCombo;
    int SaveRomanticComedyCombo;
    int SaveFamilyCombo;
    int SaveAdventureCombo;
    
    int SaveActionProgress;
    int SaveComedyProgress;
    int SaveDramaProgress;
    int SaveSciFiProgress;
    int SaveAnimationProgress;
    int SaveRomanticComedyProgress;
    int SaveFamilyProgress;
    int SaveThrillerProgress;
    int SaveAdventureProgress;
    
    int SaveTotalQuestionsAnsweredCorrectly;
	int SavePercentageComplete;
    int SaveCurrentQuestion;
	int SaveAchievements;
	int SaveLevel1QuestionComplete;
    int randomNumber;
    int saveGameSelected;
    
    NSString *Rank;
    NSString *SaveCurrentCategory;
    NSString *SaveDate;
	NSString *SaveName;
}
/*
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic, retain) CCLabelTTF *currentScoreLabel;
@property (retain) UIViewController *gameCenterViewController;
*/
+(id) scene;
- (void) SoundSettings;
//- (void) GameCenter;

- (void) showLeaderBoardGameCenter:(NSString *) leaderboardKey;
- (void) createQuickplayPLIST;
- (void) getEvenOddLight;
- (void) spawnLight:(CGPoint) position spriteTag:(int) _tag;
- (void) shiningLights;

- (void) openSlotDatabase;
- (void) openReelFactsDatabase;
- (void) openScoringDatabase;
- (void) fadeInReelFacts;

- (void) createSlotOne;
- (void) createSlotTwo;
- (void) createSlotThree;

- (void) saveSlotOne;
- (void) saveSlotTwo;
- (void) saveSlotThree;

- (void) loadSlotOne;
- (void) loadSlotTwo;
- (void) loadSlotThree;

- (BOOL) checkSlotOne;
- (BOOL) checkSlotTwo;
- (BOOL) checkSlotThree;

- (void) displaySlotOne;
- (void) displaySlotTwo;
- (void) displaySlotThree;

- (void) removeLabelsSlotTwo;
- (void) removeLabelsSlotOne;
- (void) removeLabelsSlotThree;
@end
