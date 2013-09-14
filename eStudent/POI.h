//
//  POI.h
//  eStudent
//
//  Created by Nicolas Autzen on 22.01.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POI : NSObject

- (id)initWithInfoDictionary:(NSDictionary *)aDict;

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSNumber *type;
@property (nonatomic,strong)NSString *keywords;
@property (nonatomic,strong)NSString *desc;
@property (nonatomic,strong)NSString *web;
@property (nonatomic,strong)NSString *hours;
@property (nonatomic,strong)NSNumber *latitude;
@property (nonatomic,strong)NSNumber *longitude;
@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *address;
@property (nonatomic,strong)NSArray *institutions;
@property (nonatomic,strong)POI *parentPoi;


@end
