//
//  Semester.h
//  estudent
//
//  Created by Christian Rathjen on 6/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eintrag, Studiengang;

@interface Semester : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Studiengang *ersteFachSemester;
@property (nonatomic, retain) NSSet *kurse;
@property (nonatomic, retain) Studiengang *letzteFachSemester;
@end

@interface Semester (CoreDataGeneratedAccessors)

- (void)addKurseObject:(Eintrag *)value;
- (void)removeKurseObject:(Eintrag *)value;
- (void)addKurse:(NSSet *)values;
- (void)removeKurse:(NSSet *)values;

@end
