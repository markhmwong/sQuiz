//
//  GKLeaderboardViewController-LandscapeOnly.m
//  sQuiz Reel Trivia
//
//  Created by mark wong on 6/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GKLeaderboardViewController-LandscapeOnly.h"

@implementation GKLeaderboardViewController(LandscapeOnly)

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UIInterfaceOrientationIsLandscape (toInterfaceOrientation) );
}

@end
