//
//  PCEvent.m
//  PebbleCubeSDK
//
//  Created by Richard Adem on 19/01/11.
//  Copyright 2011 PebbleCube. All rights reserved.
//

#import "PCEvent.h"


@implementation PCEvent

@synthesize info;

- (void)dealloc 
{
	[info release];
	[super dealloc];
}

@end