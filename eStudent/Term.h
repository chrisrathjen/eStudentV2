//
//  Term.h
//  estudent
//
//  Created by Christian Rathjen on 6/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Term : NSManagedObject

@property (nonatomic, retain) NSDate * lectureEnd;
@property (nonatomic, retain) NSDate * lectureStart;
@property (nonatomic, retain) NSDate * termEnd;
@property (nonatomic, retain) NSDate * termStart;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *courses;
@end

@interface Term (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course *)value;
- (void)removeCoursesObject:(Course *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
