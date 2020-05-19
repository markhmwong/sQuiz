//
//  AppDelegate.m
//  sQuiz Reel Trivia
//
//  Created by mark wong on 21/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "AppDelegate.h"
#import "DeviceFile.h"

@implementation AppDelegate

//@synthesize window;
//@synthesize viewController;
@synthesize window=window_, navController=navController_, director=director_;
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

//- (void) applicationDidFinishLaunching:(UIApplication*)application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions

{
//    // Init the window
//    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//
//    //Game Center
//    [[GCHelper sharedInstance] authenticateLocalUser];
//
//    // Try to use CADisplayLink director
//    // if it fails (SDK < 3.1) use the default director
//
//    if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
//        [CCDirector setDirectorType:kCCDirectorTypeDefault];
//
//
//    CCDirector *director = [CCDirector sharedDirector];
//
//    // Init the View Controller
//    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
//    viewController.wantsFullScreenLayout = YES;
//
//    //
//    // Create the EAGLView manually
//    //  1. Create a RGB565 format. Alternative: RGBA8
//    //    2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
//    //
//    //
//    EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
//                                   pixelFormat:kEAGLColorFormatRGB565    // kEAGLColorFormatRGBA8
//                                   depthFormat:0                        // GL_DEPTH_COMPONENT16_OES
//                        ];
//
//    // attach the openglView to the director
//    //[director setOpenGLView:glView];
//    [director setOpenGLView:glView];
//
////    // Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//    if( ! [director enableRetinaDisplay:YES] )
////        CCLOG(@"Retina Display Not supported");
//
//    //
//    // VERY IMPORTANT:
//    // If the rotation is going to be controlled by a UIViewController
//    // then the device orientation should be "Portrait".
//    //
//    // IMPORTANT:
//    // By default, this template only supports Landscape orientations.
//    // Edit the RootViewController.m file to edit the supported orientations.
//    //
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
//    [director setDeviceOrientation:kCCDeviceOrientationPortrait];
//#else
//    [director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
//#endif
//
//    [director setAnimationInterval:1.0/60];
//    [director setDisplayFPS:NO];
//
//
//    // make the OpenGLView a child of the view controller
//    [viewController setView:glView];
//
//    // make the View Controller a child of the main window
//    [window addSubview: viewController.view];
//
//    [window makeKeyAndVisible];
//
//    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
//    // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
//    // You can change anytime.
//    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
//    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
//
//    SimpleAudioEngine *music= [SimpleAudioEngine sharedEngine];
//    if (music != nil) {
//        //[music preloadBackgroundMusic:@"MainMenuMusic.m4a"];
//        //[music preloadBackgroundMusic:@"CreditsMusic.m4a"];
//        if (music.willPlayBackgroundMusic) {
//            music.backgroundMusicVolume = 1.0f;//You'd get this from your config
//        }
//    }
//    [music preloadBackgroundMusic:@"GameplayBGM1.aif"];
//
//    // Removes the startup flicker
//    [self removeStartupFlicker];
//    //SD_HD_PLIST(@"mySpritesheet.plist")]
//
//    CCTexture2D *levelSelectSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"LevelSelectSpriteSheet.pvr"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelSelectSpriteSheet.plist" texture:levelSelectSpriteSheet];
//
//    CCTexture2D *CategoryMenuSpriteSheet = [[CCTextureCache sharedTextureCache] addImage:@"CategoryMenuSS.pvr"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CategoryMenuSS.plist" texture:CategoryMenuSpriteSheet];
//
//    CCTexture2D *buttonsEffects = [[CCTextureCache sharedTextureCache] addImage:@"ButtonsEffects.pvr"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ButtonsEffects.plist" texture:buttonsEffects];
//
//    CCTexture2D *grainBGSS = [[CCTextureCache sharedTextureCache] addImage:@"grainsBGSpriteSheet.pvr.ccz"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsBGSpriteSheet.plist" texture:grainBGSS];
//    CCTexture2D *grainsSS = [[CCTextureCache sharedTextureCache] addImage:@"grainsSpriteSheet.pvr"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"grainsSpriteSheet.plist" texture:grainsSS];
//
//    // Run the intro Scene
//    [[CCDirector sharedDirector] runWithScene: [SplashScreen scene]];
    
    // Create the main window
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
    CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
                                   pixelFormat:kEAGLColorFormatRGB565    //kEAGLColorFormatRGBA8
                                   depthFormat:0    //GL_DEPTH_COMPONENT24_OES
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    
    // Enable multiple touches
    [glView setMultipleTouchEnabled:YES];
    
    director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
    
    director_.wantsFullScreenLayout = YES;
    
    // Display FSP and SPF
    [director_ setDisplayStats:NO];
    
    // set FPS at 60
    [director_ setAnimationInterval:1.0/60];
    
    // attach the openglView to the director
    [director_ setView:glView];
    
    // for rotation and other messages
    [director_ setDelegate:self];
    
    // 2D projection
    [director_ setProjection:kCCDirectorProjection2D];
    //    [director setProjection:kCCDirectorProjection3D];
    
    // Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if( ! [director_ enableRetinaDisplay:YES] )
        CCLOG(@"Retina Display Not supported");
    
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
    // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
    // You can change anytime.
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    // If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
    // On iPad HD  : "-ipadhd", "-ipad",  "-hd"
    // On iPad     : "-ipad", "-hd"
    // On iPhone HD: "-hd"
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:NO];                // Default: NO. No fallback suffixes are going to be used
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];        // Default on iPhone RetinaDisplay is "-hd"
    [sharedFileUtils setiPadSuffix:@"-ipad"];                    // Default on iPad is "ipad"
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];    // Default on iPad RetinaDisplay is "-ipadhd"
    
    // Assume that PVR images have premultiplied alpha
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // Create a Navigation Controller with the Director
    navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
    navController_.navigationBarHidden = YES;
    
    // set the Navigation Controller as the root view controller
    [window_ setRootViewController:navController_];
    
    // make main window visible
    [window_ makeKeyAndVisible];
    [director_ runWithScene:[SplashScreen scene]];
//    [SDCloudUserDefaults registerForNotifications];
    
    return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    if( [navController_ visibleViewController] == director_ )
        [director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    if( [navController_ visibleViewController] == director_ )
        [director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    if( [navController_ visibleViewController] == director_ )
        [director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    if( [navController_ visibleViewController] == director_ )
        [director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    
    CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


//- (void)applicationWillResignActive:(UIApplication *)application {
//    [[CCDirector sharedDirector] pause];
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [[CCDirector sharedDirector] resume];
//}
//
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
//    [[CCDirector sharedDirector] purgeCachedData];
//}
//
//-(void) applicationDidEnterBackground:(UIApplication*)application {
//    [[CCDirector sharedDirector] stopAnimation];
//}
//
//-(void) applicationWillEnterForeground:(UIApplication*)application {
//    [[CCDirector sharedDirector] startAnimation];
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    CCDirector *director = [CCDirector sharedDirector];
//
//    [[director openGLView] removeFromSuperview];
//
//    [viewController release];
//
//    [window_ release];
//
//    [director end];
//}
//
//- (void)applicationSignificantTimeChange:(UIApplication *)application {
//    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
//}
//
//- (void)dealloc {
//    [[CCDirector sharedDirector] end];
//    [window_ release];
//    [super dealloc];
//}

@end
