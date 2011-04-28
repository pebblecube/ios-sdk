//
//  FileHelper.h
//  PebbleCubeSDK
//
//  Created by Richard Adem on 6/01/11.
//  Copyright 2011 PebbleCube. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface FileHelper : NSObject 
{

}

+ (void) Save:(NSMutableArray*) records;
+ (void) Load:(NSMutableArray*) records;

@end
