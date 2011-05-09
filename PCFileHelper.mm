//
//  PCFileHelper.m
//  PebbleCubeSDK
//
//  Created by Richard Adem on 6/01/11.
//  Copyright 2011 PebbleCube. All rights reserved.

#import "PCFileHelper.h"
#import "JSON.h"
#import "PCEvent.h"
#import "PCConsts.h"

@implementation PCFileHelper

+ (void) Save:(NSMutableArray*) records
{
	Log(@"Loading events in json");
	SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	NSError* error = nil;
	NSMutableArray* dictArray = [[NSMutableArray alloc] init];
	
	for (PCEvent *event in records)
	{
		[dictArray addObject: [event info]];
	}
	
	NSString* jsonOut = [writer stringWithObject:dictArray error:&error];

	if (error != nil)
	{
		Log(@"Save Events fail: %@", [error localizedDescription]);
	}
	
	NSString *fileName = EVENTS_JSON;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	[jsonOut writeToFile:path
			  atomically:YES 
				encoding:NSUTF8StringEncoding
				   error:NULL];

	[writer release];
}

+ (void) Load:(NSMutableArray*) records
{
	Log(@"Saving events in json");
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSError* error = nil;
	
	NSString *fileName = EVENTS_JSON;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSString *jsonIn = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	Log(@"jsonIn:\n%@", jsonIn);
	if (error != nil)
	{
		Log(@"Parsing events fail: %@", [error localizedDescription]);
		error = nil;
	}
	
	NSDictionary *eventObjs = [parser objectWithString:jsonIn error:&error];	
	if (error != nil)
	{
		Log(@"Parsing events fail: %@", [error localizedDescription]);
	}
	
	for (NSDictionary *eventObj in eventObjs)
	{
		NSMutableDictionary* info = [[[NSMutableDictionary alloc] init] autorelease];
		
		[info setObject:[eventObj objectForKey:@"code"] forKey:@"code"];
		[info setObject:[eventObj objectForKey:@"value"] forKey:@"value"];
		[info setObject:[eventObj objectForKey:@"time"] forKey:@"time"];
		
		PCEvent *event = [[[PCEvent alloc] init] autorelease];
		
		[event setInfo: info];
		
		@synchronized(records)
		{
			[records addObject: event];
		}
	}
}

@end
