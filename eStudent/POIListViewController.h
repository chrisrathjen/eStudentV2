//
//  POIListViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 05.01.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESNetworkManager.h"

//Präsentiert dem Nutzer eine Liste mit Points Of Interest (POI), die der Nutzer wählen kann um sich weitere Informationen anzuzeigen.
@interface POIListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ESNetworkManagerDelegate, UISearchBarDelegate>
{
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITableView *tableView;
    
    ESNetworkManager *networkManager;
    NSMutableArray *sectionHeaders;
    NSMutableDictionary *pointsOfInterest;
    NSArray *pois;
    
    NSMutableArray *sectionHeadersToDisplay;
    NSMutableDictionary *pointsOfInterestToDisplay;
    
    NSIndexPath *tappedIndexPath;
}

//Lädt die POI-Daten über dem Datenmanager.
- (void)getCampusInformation;
//Lädt die Kartenansicht.
- (void)showMapView:(id)sender;
//Füllt die Liste mit den POI-Daten.
- (void)fillSectionHeadersAndPOI;

@end
