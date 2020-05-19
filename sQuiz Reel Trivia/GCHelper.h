//
//  GCHelper.h
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate 
//- (void)matchStarted;
//- (void)matchEnded;
//- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
//- (void)inviteReceived;
@end

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    //UIViewController *presentingViewController;
    //GKMatch *match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    NSMutableDictionary *playersDict;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
    //GKInvite *pendingInvite;
    //NSArray *pendingPlayersToInvite;
    
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign) id <GCHelperDelegate> delegate;
@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;



+ (GCHelper *)sharedInstance;
//- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport achievementsToReport:(NSMutableArray *)achievementsToRpoert;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
-(void)sendAchievement:(GKAchievement *) achievement;
-(void) reportAchievement:(NSString *) identifier percentComplete:(double)percentComplete;
- (void) reportScore:(int)score forLeaderboard: (NSString*) leaderboard;
-(void) resendData;
@end
