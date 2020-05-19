//
//  SettingsManager.m
//

/*
 * 
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SettingsManager.h"
#import "cocos2d.h"

@implementation SettingsManager

static SettingsManager* _sharedSettingsManager = nil;

-(NSString *) getString:(NSString*)keyString
{	
	return [settings objectForKey:keyString];
}

-(int) getInt:(NSString*)keyString {
	return [[settings objectForKey:keyString] intValue];
}

-(float) getFloat:(NSString*)keyString {
	return [[settings objectForKey:keyString] floatValue];
}

-(double) getDouble:(NSString*)keyString {
	return [[settings objectForKey:keyString] doubleValue];
}

-(bool) getBool:(NSString*)keyString {
	return [[settings objectForKey:keyString] boolValue];
}

-(CGPoint) getCGPoint:(NSString*)keyString {
	return CGPointFromString([settings objectForKey:keyString]);
}

-(CGSize) getCGSize:(NSString*)keyString
{
	return CGSizeFromString([settings objectForKey:keyString]);
}

-(CGRect) getCGRect:(NSString*)keyString
{
	return CGRectFromString([settings objectForKey:keyString]);
}

-(void) setString:(NSString*)value keyString:(NSString *)keyString {	
	[settings setObject:value forKey:keyString];
}

-(void) setInteger:(int)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%d",value] forKey:keyString];
}

-(void) setFloat:(float)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%f",value] forKey:keyString];
}

-(void) setDouble:(double)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%f",value] forKey:keyString];
}


-(void) setCGPoint:(CGPoint)value keyString:(NSString*)keyString {
	//     [settings setObject:[NSValue valueWithCGPoint:value] forKey:keyString];
	[settings setObject:NSStringFromCGPoint(value) forKey:keyString];
}

-(void) setCGSize:(CGSize)value keyString:(NSString*)keyString
{
	[settings setObject:NSStringFromCGSize(value) forKey:keyString];
}

-(void) setCGRect:(CGRect)value keyString:(NSString*)keyString
{
	[settings setObject:NSStringFromCGRect(value) forKey:keyString];
}

-(void) setBool:(bool)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%d",value] forKey:keyString];
}

-(void) saveToNSUserDefaults:(NSString*)appName
{
	[[NSUserDefaults standardUserDefaults] setObject:settings forKey:appName];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) loadFromNSUserDefaults:(NSString*)appName;
{
	[self purgeSettings];
	[settings addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:appName]];
}


-(void) saveToFile:(NSString*) fileName
{
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *plistDirectory = [paths objectAtIndex:0];
	 NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];

	bool writeSuccess = [settings writeToFile:fullPath atomically:YES];
	

	if(!writeSuccess)
	{
		CCLOG(@"Couldn't write settings file, possible bad data sent in, make sure your setting proper data type");
	}
	else 
	{
		//CCLOG(@"Write success to settings file");
	}
}

-(void) loadFromFile:(NSString*) fileName
{
	// Clear first
	[self purgeSettings];
	[settings release];
	
	// read it back in with different dictionary variable
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *plistDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];
	
	settings = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
	
	if (settings != nil)
	{
		//CCLOG(@"Settings read success");
	}
	else 
	{
		//CCLOG(@"Settings read failure, file may not exist if so will be created when you save");
		settings = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	}
	
	[settings retain];
}

-(void) saveToFileInLibraryDirectory:(NSString*) fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *plistDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];
	
	bool writeSuccess = [settings writeToFile:fullPath atomically:YES];
	
	if(!writeSuccess)
	{
		//CCLOG(@"Couldn't write settings file");
	}
	else 
	{
		//CCLOG(@"Write success to settings file");
	}
}

-(void) loadFromFileInLibraryDirectory:(NSString*) fileName
{
	// Clear first
	[self purgeSettings];
	[settings release];
	
	// read it back in with different dictionary variable
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *plistDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];
	
	settings = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
	
	if (settings != nil)
	{
		//CCLOG(@"settings read success");
	}
	else 
	{
		//CCLOG(@"settings read failure");
		settings = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	}
	
	[settings retain];
}

-(void) purgeSettings
{
	[settings removeAllObjects];
}

-(void) logSettings
{
//    for(NSString* item in [settings allKeys])
//    {
//        //CCLOG(@"[SettingsManager KEY:%@ - VALUE:%@]", item, [settings valueForKey:item]);
//    }
}


+(SettingsManager*)sharedSettingsManager
{
	@synchronized([SettingsManager class])
	{
		if (!_sharedSettingsManager)
			[[self alloc] init];
		
		return _sharedSettingsManager;
	}
	
	return nil;
}

+(id) alloc
{
	@synchronized([SettingsManager class])
	{
		NSAssert(_sharedSettingsManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSettingsManager = [super alloc];
		return _sharedSettingsManager;
	}
	
	return nil;
}

-(id) init {
	
	if (settings == nil) 
	{
		settings = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	
	return self;
}

-(id) autorelease {
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

@end
