//
//  Credits.h
//  TriviaMenu
//
//  Created by mark wong on 3/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "mainMenu.h"
@interface Credits : CCLayer {
    CCLabelTTF *title;
    CCLabelTTF *name;
    int count;
    NSArray *CreditsArray;
}

+(id) scene;
- (void) nameStart;
@end
