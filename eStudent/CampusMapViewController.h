//
//  CampusMapViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CampusMapViewController : UIViewController

@property (nonatomic,strong)NSArray *pointsOfInterest;
@property (nonatomic,copy)NSMutableArray *haltestellen;

@end
