//
//  GCHelper.m
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize delegate;
@synthesize scoresToReport;
@synthesize achievementsToReport;
//@synthesize presentingViewController;
//@synthesize match;
//@synthesize playersDict;
//@synthesize pendingInvite;
//@synthesize pendingPlayersToInvite;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    //[[self alloc] [initWithScoresToReport:[NSMutableArray array] achievementsToReport:[NSMutableArray array]];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}

#pragma mark authenticationChanged

- (void)authenticationChanged {    

    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
      // NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        [self resendData];
        //[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            //NSLog(@"Received invite");
            //self.pendingInvite = acceptedInvite;
            //self.pendingPlayersToInvite = playersToInvite;
            //[delegate inviteReceived];
            
        //};
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
       //NSLog(@"Authentication changed: player not authenticated");
       userAuthenticated = FALSE;
    }
                   
}

#pragma mark User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    
    //NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];        
    } else {
        //NSLog(@"Already authenticated!");
    }
}

- (void) sendScore:(GKScore *) score {
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (error == NULL) {
                //NSLog(@"Successfully sent score");
                [scoresToReport removeObject:score];
            } else {
                //NSLog(@"Score failed to send... will try again later");
            }
        });
    }];
}

- (void) reportScore:(int)score forLeaderboard: (NSString*) leaderboard
{
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboard] autorelease];	
	scoreReporter.value = score;
    [scoresToReport addObject:scoreReporter];
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
         [self sendScore:scoreReporter];
		 //[self callDelegateOnMainThread: @selector(sendScore:scoreReporter) withArg: NULL error: error];
	 }];
}

-(void)sendAchievement:(GKAchievement *) achievement {
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)   {
            if (error == NULL) {
                NSLog(@"Successfully sent achievement!");
                [achievementsToReport removeObject:achievement];
            }
            else {
                NSLog(@"Achievement failed to send... will try again later. Reason:%@", error.localizedDescription);
            }
        });
    }];
}

-(void) reportAchievement:(NSString *) identifier percentComplete:(double)percentComplete {
    GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    achievement.percentComplete = percentComplete;
    [achievementsToReport addObject:achievement];
    //[self save];
    
    if (!gameCenterAvailable || !userAuthenticated) {
        return;
    }
    
    [self sendAchievement:achievement];
}

-(void)resendData {
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
}


@end
