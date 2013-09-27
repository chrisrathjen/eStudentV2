//
//  Eintrag.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Kriterium, Lecture, Semester, Studiengang;

@interface Eintrag : NSManagedObject

@property (nonatomic, retain) NSString * art;
@property (nonatomic, retain) NSNumber * benotet;
@property (nonatomic, retain) NSNumber * bestanden;
@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSNumber * note;
@property (nonatomic, retain) NSString * titel;
@property (nonatomic, retain) NSSet *kriterien;
@property (nonatomic, retain) Lecture *lecture;
@property (nonatomic, retain) Semester *semester;
@property (nonatomic, retain) Studiengang *studiengang;
@end

@interface Eintrag (CoreDataGeneratedAccessors)

- (void)addKriterienObject:(Kriterium *)value;
- (void)removeKriterienObject:(Kriterium *)value;
- (void)addKriterien:(NSSet *)values;
- (void)removeKriterien:(NSSet *)values;

@end
