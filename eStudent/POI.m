//
//  POI.m
//  eStudent
//
//  Created by Nicolas Autzen on 22.01.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "POI.h"

@implementation POI

@synthesize name;
@synthesize keywords;
@synthesize desc;
@synthesize web;
@synthesize hours;
@synthesize phone; //neu -> string
@synthesize address; //neu -> string
@synthesize type; //neu -> number
@synthesize institutions; //neu -> array
@synthesize latitude;
@synthesize longitude;
@synthesize parentPoi;

//Der Initializer eines POI-Objekts.
- (id)initWithInfoDictionary:(NSDictionary *)aDict
{
    self = [super init];
    if (self) {
        self.name = [aDict objectForKey:@"name"];
        self.keywords = [aDict objectForKey:@"keywords"];
        self.desc = [aDict objectForKey:@"desc"];
        self.latitude = [aDict objectForKey:@"latitude"];
        self.longitude = [aDict objectForKey:@"longitude"];
        self.type = [aDict objectForKey:@"type"];
        self.web = [aDict objectForKey:@"web"];
        self.hours = [aDict objectForKey:@"hours"];
        self.phone = [aDict objectForKey:@"phone"];
        self.address = [aDict objectForKey:@"address"];
        
        NSArray *institutionArray  = [aDict objectForKey:@"institutions"];
        if (institutionArray) {
            NSMutableArray *poiArray = [[NSMutableArray alloc] init];
            for (NSDictionary *aPoiDict in institutionArray) {
                POI *aPOI = [[POI alloc] initWithInfoDictionary:aPoiDict];
                aPOI.parentPoi = self;
                [poiArray addObject:aPOI];
            }
            self.institutions = [poiArray copy];
        }
        
    }
    
    return self;
}

@end
