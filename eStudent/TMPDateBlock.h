//
//  TMPDateBlock.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMPDateBlock : NSObject

@property (nonatomic, retain) NSNumber *repeatModifier;
@property (nonatomic, retain) NSString *room;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSDate *stopDate;
@property (nonatomic, retain) NSString *stopTime;
@property (nonatomic, retain) NSMutableArray *dates;

- (id)initWithRepeatModifier:(NSNumber *)repeatModifier
                        Room:(NSString *)room
                   StartDate:(NSDate *)startDate
                   StartTime:(NSString *)startTime
                    StopDate:(NSDate *)stopDate
                    StopTime:(NSString *)stopTime;

- (id)initWithRepeatModifier:(NSNumber *)repeatModifier
                        Room:(NSString *)room
                   StartDate:(NSDate *)startDate
                   StartTime:(NSString *)startTime
                    StopDate:(NSDate *)stopDate
                    StopTime:(NSString *)stopTime
                       Dates:(NSArray *)dates;

- (void)addDate:(id)date;

@end
