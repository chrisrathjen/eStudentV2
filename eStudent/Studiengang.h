//
//  Studiengang.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eintrag, Semester;

@interface Studiengang : NSManagedObject

@property (nonatomic, retain) NSString * abschluss;
@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *eintraege;
@property (nonatomic, retain) Semester *erstesFachsemester;
@property (nonatomic, retain) Semester *letztesFachsemester;
@end

@interface Studiengang (CoreDataGeneratedAccessors)

- (void)addEintraegeObject:(Eintrag *)value;
- (void)removeEintraegeObject:(Eintrag *)value;
- (void)addEintraege:(NSSet *)values;
- (void)removeEintraege:(NSSet *)values;

@end
