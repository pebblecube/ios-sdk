//
//  PCEvent.h
//  PebbleCubeSDK
//
//  Created by Richard Adem on 19/01/11.
//  Copyright 2011 PebbleCube. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PCEvent : NSObject 
{
	NSMutableDictionary* info;
}

@property (nonatomic, retain) NSMutableDictionary* info;

@end