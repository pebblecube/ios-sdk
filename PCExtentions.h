//
//  PCExtentions.h
//  pebbleCubeSDK
//
//  Created by Richard Adem on 29/05/11.
//  Copyright 2011 PebbleCube. All rights reserved.
//
// http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c

#import <Foundation/Foundation.h>

@interface NSString (MyExtensions)
- (NSString *) md5;
@end

@interface NSData (MyExtensions)
- (NSString*)md5;
@end