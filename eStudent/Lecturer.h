//
//  Lecturer.h
//  estudent
//
//  Created by Christian Rathjen on 1/10/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lecture;

@interface Lecturer : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *lectures;
@end

@interface Lecturer (CoreDataGeneratedAccessors)

- (void)addLecturesObject:(Lecture *)value;
- (void)removeLecturesObject:(Lecture *)value;
- (void)addLectures:(NSSet *)values;
- (void)removeLectures:(NSSet *)values;

@end
