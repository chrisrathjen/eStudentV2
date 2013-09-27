//
//  TMPDateBlock.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "TMPDateBlock.h"

@implementation TMPDateBlock

@synthesize repeatModifier = _repeatModifier;
@synthesize room = _room;
@synthesize startDate = _startDate;
@synthesize startTime = _startTime;
@synthesize stopDate = _stopDate;
@synthesize stopTime = _stopTime;
@synthesize dates = _dates;

- (id)initWithRepeatModifier:(NSNumber *)repeatModifier
                        Room:(NSString *)room
                   StartDate:(NSDate *)startDate
                   StartTime:(NSString *)startTime
                    StopDate:(NSDate *)stopDate
                    StopTime:(NSString *)stopTime
{
    self = [super init];
    if (self)
    {
        _repeatModifier = repeatModifier;
        _room = room;
        _startDate = startDate;
        _startTime = startTime;
        _stopDate = stopDate;
        _stopTime = stopTime;
    }
    return self;
}

- (id)initWithRepeatModifier:(NSNumber *)repeatModifier
                        Room:(NSString *)room
                   StartDate:(NSDate *)startDate
                   StartTime:(NSString *)startTime
                    StopDate:(NSDate *)stopDate
                    StopTime:(NSString *)stopTime
                       Dates:(NSArray *)dates
{
    self = [super init];
    if (self)
    {
        _repeatModifier = repeatModifier;
        _room = room;
        _startDate = startDate;
        _startTime = startTime;
        _stopDate = stopDate;
        _stopTime = stopTime;
        _dates = dates.mutableCopy;
    }
    return self;
}

- (void)addDate:(id)date
{
    [_dates addObject:date];
}

@end
