//
//  AppDelegate.h
//  sQuiz Reel Trivia
//
//  Created by mark wong on 21/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "RootViewController.h"
#import "SplashScreen.h"
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "GCHelper.h"
#import "GLES-Render.h"
//#import "GameCenterManager.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
    UIWindow *window_;
	RootViewController	*viewController;
    CCDirectorIOS    *__weak director_;                            // weak ref
    UINavigationController *navController_;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;
@property (readonly) UINavigationController *navController;
@property (weak, readonly) CCDirectorIOS *director;

@end
