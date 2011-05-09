//
//  PebbleCubeSDK.h
//  PebbleCubeSDK
//
//  Created by Richard Adem on 7/11/10.
//  Copyright 2010 PebbleCube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCEvent.h"

@interface PebbleCubeSDK : NSObject
{
	NSXMLParser *xmlParser;
	NSString* apiSignature;
	NSString* apiKey;
	NSString* sessionKey;
	NSMutableData* response;
	NSMutableArray* _eventArray;
	BOOL eventSendInProgress;
	BOOL saveEventsToStorage;
}

- (id)initWithSaveToStorage: (BOOL) save;

- (void) MakeConnection: (NSString*) api_sig 
				withKey: (NSString*) api_key 
			 andVersion: (NSString*) version
				andTime: (NSString*) time;

- (void) CloseConnection: (NSString*) api_sig 
				 withKey: (NSString*) api_key 
				 andTime: (NSString*) time;

- (void) SendEvent: (NSString*) code
			 value: (NSObject*) value
		   andTime: (NSString*) time;
@end
