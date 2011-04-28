//
//  Connect.h
//  PebbleCubeSDK
//
//  Created by Richard Adem on 7/11/10.
//  Copyright 2010 PebbleCube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

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

@property(nonatomic, retain) NSXMLParser *xmlParser;
@property(nonatomic, retain) NSString* apiSignature;
@property(nonatomic, retain) NSString* apiKey;
@property(nonatomic, retain) NSString* sessionKey;
@property(nonatomic, retain) NSMutableArray* eventArray;

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
			
- (void) FireEvent;

@end
