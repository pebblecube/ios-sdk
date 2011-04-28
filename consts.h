/*
 *  consts.h
 *  PebbleCubeSDK
 *
 *  Created by Richard Adem on 17/02/11.
 *  Copyright 2011 PebbleCube. All rights reserved.
 *
 */

#pragma once
#ifndef _CONSTS_H_
#define _CONSTS_H_

#ifndef RELEASE
#define Log(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Log(format, ...)
#endif

#define EVENTS_JSON @"events.json"

#endif // _CONSTS_H_