//
//  Lecture.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course, Date, DateBlock, Eintrag, Lecturer;

@interface Lecture : NSManagedObject

@property (nonatomic, retain) NSNumber * activeInSchedule;
@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSNumber * createdByUser;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * vak;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *dateBlocks;
@property (nonatomic, retain) NSSet *dates;
@property (nonatomic, retain) Eintrag *eintrag;
@property (nonatomic, retain) NSOrderedSet *lecturers;
@end

@interface Lecture (CoreDataGeneratedAccessors)

- (void)addDateBlocksObject:(DateBlock *)value;
- (void)removeDateBlocksObject:(DateBlock *)value;
- (void)addDateBlocks:(NSSet *)values;
- (void)removeDateBlocks:(NSSet *)values;

- (void)addDatesObject:(Date *)value;
- (void)removeDatesObject:(Date *)value;
- (void)addDates:(NSSet *)values;
- (void)removeDates:(NSSet *)values;

- (void)insertObject:(Lecturer *)value inLecturersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLecturersAtIndex:(NSUInteger)idx;
- (void)insertLecturers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLecturersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLecturersAtIndex:(NSUInteger)idx withObject:(Lecturer *)value;
- (void)replaceLecturersAtIndexes:(NSIndexSet *)indexes withLecturers:(NSArray *)values;
- (void)addLecturersObject:(Lecturer *)value;
- (void)removeLecturersObject:(Lecturer *)value;
- (void)addLecturers:(NSOrderedSet *)values;
- (void)removeLecturers:(NSOrderedSet *)values;
@end
