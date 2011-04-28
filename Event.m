//
//  Event.m
//  PebbleCubeSDK
//
//  Created by Richard Adem on 19/01/11.
//  Copyright 2011 PebbleCube. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize info;

- (void)dealloc 
{
	[info release];
	[super dealloc];
}

@end