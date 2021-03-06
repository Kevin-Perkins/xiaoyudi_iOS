//
//  HAMUser.m
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMUser.h"

@implementation HAMUser

@synthesize UUID;
@synthesize name;
@synthesize rootID;

@synthesize layoutx;
@synthesize layouty;

-(id)initWithName:(NSString *)_name
{
    if (self =[super init])
    {
        name=[[NSString alloc] initWithString:_name];
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        UUID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
        
		uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        rootID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
        
        layoutx = USER_DEFAULT_LAYOUTX;
        layouty = USER_DEFAULT_LAYOUTY;
    }
    return self;
}

@end
