//
//  DateBlock.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Date, Lecture;

@interface DateBlock : NSManagedObject

@property (nonatomic, retain) NSNumber * repeatModifier;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSDate * stopDate;
@property (nonatomic, retain) NSString * stopTime;
@property (nonatomic, retain) NSSet *dates;
@property (nonatomic, retain) Lecture *lecture;
@end

@interface DateBlock (CoreDataGeneratedAccessors)

- (void)addDatesObject:(Date *)value;
- (void)removeDatesObject:(Date *)value;
- (void)addDates:(NSSet *)values;
- (void)removeDates:(NSSet *)values;

@end
