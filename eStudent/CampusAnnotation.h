//
//  CampusAnnotation.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "POI.h"

@interface CampusAnnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) POI *poi;
@end
