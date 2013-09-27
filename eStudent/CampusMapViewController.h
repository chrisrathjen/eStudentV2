//
//  CampusMapViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//Präsentiert dem Nutzer die Kartenansicht des Uni-Campus. POI werden als Pins auf der Karte repräsentiert.
@interface CampusMapViewController : UIViewController

@property (nonatomic,strong)NSArray *pointsOfInterest; //Die POI die auf der Karte angezeigt werden.
@property (nonatomic,copy)NSMutableArray *haltestellen; //Die Haltestellen werden hier extra aufgeführt, weil sie anders gefärbt sind.

@end
