//
//  FacebookHelper.h
//  FacebookTutorial
//
//  Created by Toni Sala Echaurren on 22/08/11.
//  Copyright 2011 indiedevstories.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"

#define kAppName        @"Your App's name"
#define kCustomMessage  @"I just got a score of %d in %@, an iPhone/iPod Touch game by me!"
#define kServerLink     @"http://indiedevstories.com"
#define kImageSrc       @"http://indiedevstories.files.wordpress.com/2011/08/newsokoban_icon.png"

@interface FacebookHelper : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
    Facebook* _facebook;
    NSArray* _permissions;
}

@property(readonly) Facebook *facebook;

+ (FacebookHelper *) sharedInstance;

#pragma mark - Public Methods
// Public methods here.
-(void) login;
-(void) logout;
-(void) postToWallWithDialogNewHighscore:(int)highscore;

@end