//
//  Singleplayer.h
//  Trivia
//
//  Created by mark wong on 12/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "cocos2d.h"
#import "mainMenu.h"
#import "CCScrollLayer.h"
#import "CategoryMenu.h"
#import "CategoryLevel2.h"
#import "CategoryLevel3.h"
#import "SettingsManager.h"
#import "CCLabelBMFontMultiline.h"
#import <GameKit/GameKit.h>


@interface LevelSelect : CCLayer {
    
    CCLayer *GameLayer;
    CCLayer *TutorialLayer;
    CCTexture2D *levelSelectSpriteSheet;
    
    CCMenuItemSprite *level1Page1;
    CCMenuItemSprite *level3Page1;
    CCMenuItemSprite *level2Page1;

    CCSprite * tutorialBG;
    
    CCLabelTTF *TouchToContinue;

    
    CCLabelBMFontMultiline *tutorialText;
    
    int page;
    int slotNumber;

    CCLayerColor *gameTint;
    
    BOOL isLevel2Locked;
    BOOL isLevel3Locked;
    BOOL BGM;
    BOOL SFX;
}

-(void) tutorialPage1;
-(void) SoundSettings;
+(id)scene:(int)saveSlot;
-(void) levelChecks;
@end
