//
//  Course.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lecture, Term;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *lectures;
@property (nonatomic, retain) Term *semester;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addLecturesObject:(Lecture *)value;
- (void)removeLecturesObject:(Lecture *)value;
- (void)addLectures:(NSSet *)values;
- (void)removeLectures:(NSSet *)values;

@end
