//
//  Date.h
//  estudent
//
//  Created by Christian Rathjen on 1/10/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DateBlock, Lecture;

@interface Date : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * stopTime;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) DateBlock *dateBlock;
@property (nonatomic, retain) Lecture *lecture;

@end
