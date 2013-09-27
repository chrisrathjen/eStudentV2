//
//  Semester.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eintrag, Studiengang;

@interface Semester : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *ersteFachSemester;
@property (nonatomic, retain) NSSet *kurse;
@property (nonatomic, retain) NSSet *letzteFachSemester;
@end

@interface Semester (CoreDataGeneratedAccessors)

- (void)addErsteFachSemesterObject:(Studiengang *)value;
- (void)removeErsteFachSemesterObject:(Studiengang *)value;
- (void)addErsteFachSemester:(NSSet *)values;
- (void)removeErsteFachSemester:(NSSet *)values;

- (void)addKurseObject:(Eintrag *)value;
- (void)removeKurseObject:(Eintrag *)value;
- (void)addKurse:(NSSet *)values;
- (void)removeKurse:(NSSet *)values;

- (void)addLetzteFachSemesterObject:(Studiengang *)value;
- (void)removeLetzteFachSemesterObject:(Studiengang *)value;
- (void)addLetzteFachSemester:(NSSet *)values;
- (void)removeLetzteFachSemester:(NSSet *)values;

@end
