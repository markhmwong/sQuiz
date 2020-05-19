//
//  FacebookHelper.m
//  FacebookTutorial
//
//  Created by Toni Sala Echaurren on 22/08/11.
//  Copyright 2011 indiedevstories.com. All rights reserved.
//

#import "FacebookHelper.h"

static NSString* kAppId = @"000000000000000";

@implementation FacebookHelper

@synthesize facebook = _facebook;

#pragma mark -
#pragma mark Singleton Variables
static FacebookHelper *singletonDelegate = nil;

#pragma mark -
#pragma mark Singleton Methods
- (id)init {
    if (!kAppId) {
        NSLog(@"missing app id!");
        exit(1);
        return nil;
    }
    
    if ((self = [super init])) {
        _permissions =  [[NSArray arrayWithObjects: @"read_stream", @"publish_stream", @"offline_access",nil] retain];
        //_permissions =  [[NSArray arrayWithObjects: @"read_stream", @"publish_stream", nil] retain];
    }
    
    return self;
}

+ (FacebookHelper *)sharedInstance {
	@synchronized(self) {
		if (singletonDelegate == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return singletonDelegate;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (singletonDelegate == nil) {
			singletonDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return singletonDelegate;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

#pragma mark - Private Methods

-(NSMutableDictionary*) buildPostParamsWithHighscore:(int)highscore {
    NSString *customMessage = [NSString stringWithFormat:kCustomMessage, highscore, kAppName]; 
    NSString *postName = kAppName; 
    NSString *serverLink = [NSString stringWithFormat:kServerLink];
    NSString *imageSrc = kImageSrc;
    
    // Final params build.
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   //@"message", @"message",
                                   imageSrc, @"picture",
                                   serverLink, @"link",
                                   postName, @"name",
                                   @" ", @"caption",
                                   customMessage, @"description",
                                   nil];
    
    return params;
}

#pragma mark - Public Methods
-(void) login {
    // Check if there is a valid session.
    _facebook = [[Facebook alloc] initWithAppId:kAppId];
    _facebook.accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    _facebook.expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    if (![_facebook isSessionValid]) {
        [_facebook authorize:_permissions delegate:self];
    }
    else {
        [_facebook requestWithGraphPath:@"me" andDelegate:self];
    }
}

-(void) logout {
    [_facebook logout:self];
}

-(void) postToWallWithDialogNewHighscore:(int)highscore {
    NSMutableDictionary* params = [self buildPostParamsWithHighscore:highscore];
    
    // Post on Facebook.
    [_facebook dialog:@"feed" andParams:params andDelegate:self];
}

#pragma mark - FBDelegate Methods

- (void)fbDidLogin {
    NSLog(@"FB login OK");
    
    // Store session info.
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"FB did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    NSLog(@"FB logout OK");
    
    // Release stored session.
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"FB request OK");
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"FB error: %@", [error localizedDescription]);
}

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"published successfully on FB");
}

@end