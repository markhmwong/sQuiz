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
#import "Quickplay.h"
#import <GameKit/GameKit.h>
//#import "CategoryLevel2.h"
//#import "CategoryLevel3.h"
#import "EndOfRoundQuickplay.h"
@interface EndOfRoundQuickplay : CCNode {
    CCSprite *reviewBackground;
    int starType;
}

+(id) scene:(int) setTimer difficultyLevel:(NSString *) difficulty questions:(int)questionsPerRound;

-(void) starsEffects;
-(void) starsEffects2;
-(void) starsEffects3;
-(void) loadScoreFromSettingsManager:(int)saveSlot;
-(int) loadStarTypeFromSettingsManager:(int)saveSlot starTypeNumber:(int)number;
-(int) loadCorrectlyAnsweredFromSettingsManager;
-(void) createStars:(CGPoint)position starNumber:(int)number;
-(void) wipeScore;
@end
