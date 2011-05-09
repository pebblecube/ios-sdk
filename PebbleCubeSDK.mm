//
//  PebbleCubeSDK.mm
//  PebbleCubeSDK
//
//  Created by Richard Adem on 7/11/10.
//  Copyright 2010 PebbleCube. All rights reserved.
//

#define IGNORE_CERT_AUTHENTICATION

#import "PebbleCubeSDK.h"
#import "PCFileHelper.h"
#import "JSON.h"
#import "PCConsts.h"

@interface PebbleCubeSDK()

@property(nonatomic, retain) NSXMLParser *xmlParser;
@property(nonatomic, retain) NSString* apiSignature;
@property(nonatomic, retain) NSString* apiKey;
@property(nonatomic, retain) NSString* sessionKey;
@property(nonatomic, retain) NSMutableArray* eventArray;

- (void) SendEvent: (NSMutableDictionary*) info;
- (void) FireEvent;

@end

// ------------------------------------------------------

@implementation PebbleCubeSDK

@synthesize xmlParser;
@synthesize sessionKey;
@synthesize apiSignature;
@synthesize apiKey;
@synthesize eventArray = _eventArray;

- (id)initWithSaveToStorage: (BOOL) save
{
    self = [super init];
    if (self) {
        /* class-specific initialization goes here */
		saveEventsToStorage = NO;
		saveEventsToStorage = save;
		
		eventSendInProgress = NO;
		_eventArray = [[NSMutableArray alloc] init];
		if (saveEventsToStorage)
		{
			[PCFileHelper Load:_eventArray];
		}
		
		[NSTimer scheduledTimerWithTimeInterval:4 
										 target:self 
									   selector:@selector(FireEvent) 
									   userInfo:nil 
										repeats:YES];
		
		[self setApiSignature:@""];
		[self setApiKey:@""];
    }
    return self;
}

- (id) init
{
	return [self initWithSaveToStorage: NO];
}

- (void) MakeConnection: (NSString*) api_sig 
				withKey: (NSString*) api_key 
			 andVersion: (NSString*) version
				andTime: (NSString*) time;
{
	Log(@"+MakeConnection");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([sessionKey length] <= 0)
	{
		[self setApiSignature:api_sig];
		[self setApiKey:api_key];
		
		NSString* urlString = [NSString stringWithFormat:@"https://api.pebblecube.com/sessions/start?api_sig=%@&api_key=%@&version=%@&time=%@"
							   , api_sig
							   , api_key
							   , version
							   , time
							   ];

		@synchronized(response)
		{
			response = [[NSMutableData data] retain];
		}
		NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		Log(@"urlString: %@", urlString);
	}
	else 
	{
		Log(@"sessionKey length > 0, session started already, cannot start again yet");
	}


	
	[pool drain];
	Log(@"-MakeConnection");
}

- (void) CloseConnection: (NSString*) api_sig 
				 withKey: (NSString*) api_key 
				 andTime: (NSString*) time
{
	Log(@"+CloseConnection");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([sessionKey length] > 0)
	{
		NSString* urlString = [NSString stringWithFormat:@"https://api.pebblecube.com/sessions/stop?api_sig=%@&api_key=%@&session_key=%@&time=%@"
							   , api_sig
							   , api_key
							   , sessionKey
							   , time
							   ];
		
		
		// Prepare URL request to download statuses from Twitter
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		
		// Perform request and get JSON back as a NSData object
		NSData *r = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		NSString *rString = [[NSString alloc] initWithData:r encoding:NSUTF8StringEncoding];
		
		Log(@"urlString: %@", urlString);
		Log(@"rString: %@", rString);
		[rString release];
		
		[self setSessionKey: @""];
		[self setApiSignature:@""];
		[self setApiKey:@""];
	}
	else
	{
		Log(@"sessionkey length <= 0, session not started, cannot stop");
	}
	
	
	[pool drain];
	Log(@"-CloseConnection");
}

#define IGNORE_CERT_AUTHENTICATION
#if defined(IGNORE_CERT_AUTHENTICATION)
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		//if ([trustedHosts containsObject:challenge.protectionSpace.host])
		{
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
#endif

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)resp
{
	@synchronized(response)
	{
		[response setLength: 0];
	}
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	@synchronized(response)
	{
		[response appendData:data];
	}
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	Log(@"ERROR with theConenction: \n%@", [error localizedDescription]);
	[connection release];
	@synchronized(response)
	{
		[response release];
	}
	eventSendInProgress = NO;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(response)
	{
		Log(@"DONE. Received Bytes: %d", [response length]);
	}
	
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	Log(@"responce json_string: \n%@", json_string);
	
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	
	NSError *error = nil;
    
	NSDictionary *object = [parser objectWithString:json_string error:&error];
	
	Log(@"%@", [error description]);
	
	NSString *key = [object objectForKey:@"k"];
	
	if (key != nil)
	{
		[self setSessionKey:key];
		Log(@"key: %@", key);
	}
	else
	{
		Log(@"key not found");
	}

	[json_string release];
	[connection release];
	[parser release];
	
	@synchronized(response)
	{
		[response release];
	}
	
	if (eventSendInProgress)
	{
		@synchronized(_eventArray)
		{
			[_eventArray removeObjectAtIndex:0];
			if (saveEventsToStorage)
			{
				[PCFileHelper Save:_eventArray];
			}
		}
		eventSendInProgress = NO;
	}
}

- (void) SendEvent: (NSMutableDictionary*) info
{
	Log(@"+SendEvent");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PCEvent *event = [[[PCEvent alloc] init] autorelease];

	[event setInfo: info];

	@synchronized(_eventArray)
	{
		[_eventArray addObject: event];
		if (saveEventsToStorage)
		{
			[PCFileHelper Save:_eventArray];
		}
	}
	
	[pool drain];
	Log(@"-SendEvent");
}

- (void) SendEvent: (NSString*) code
			 value: (NSObject*) value
		   andTime: (NSString*) time
{
	NSMutableDictionary* info = [[[NSMutableDictionary alloc] init] autorelease];
	
	[info setObject:code forKey:@"code"];
	[info setObject:value forKey:@"value"];
	[info setObject:time forKey:@"time"];
	
	[self SendEvent:info];
}

- (void) FireEvent
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (!eventSendInProgress && [_eventArray count] > 0 && [sessionKey length] > 0)
	{
		eventSendInProgress = YES;
		
		Log(@"fire event, event count: %d", [_eventArray count]);
		
		PCEvent* event;
		NSMutableDictionary* eventInfo;
		NSString* api_sig;
		NSString* api_key;
		@synchronized(_eventArray)
		{
			event = [[_eventArray objectAtIndex:0] retain];
			
			eventInfo = [event info];
			api_sig = [self apiSignature];
			api_key = [self apiKey];
			
		}
		
		SBJsonWriter *writer = [[SBJsonWriter alloc] init];
		NSError* error = nil;
		
		NSMutableArray* dictArray;

		dictArray = [[NSMutableArray alloc] init];
		[dictArray addObject: eventInfo];
		
		NSString* jsonOut = [writer stringWithObject:dictArray error:&error];
		
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"{" withString:@"%7B"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"[" withString:@"%5B"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"]" withString:@"%5D"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
		jsonOut = [jsonOut stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
		
		NSString* sKey = [self sessionKey];
		Log(@"sKey: %@", sKey);
		
		NSString* urlString;

		urlString = [NSString stringWithFormat:@"https://api.pebblecube.com/events/send?api_sig=%@&api_key=%@&session_key=%@&events=%@"
							   , api_sig
							   , api_key
							   , sKey
							   , jsonOut
							   ];
		
		@synchronized(response)
		{
			response = [[NSMutableData data] retain];
		}
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlString]
															   cachePolicy: NSURLRequestReloadIgnoringLocalCacheData 
														   timeoutInterval: 60.0]; 
		[request setHTTPMethod:@"POST"]; 
		
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		[event release];
		[writer release];
		[dictArray release];
	}
	[pool drain];
}


- (void)dealloc 
{
	@synchronized(response)
	{
		[response release];
	}
	[xmlParser release];
	[sessionKey release];
	[apiSignature release];
	[apiKey release];
	[_eventArray release];
	[super dealloc];
}

@end
