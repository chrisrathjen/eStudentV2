//
//  POIListViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 05.01.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESNetworkManager.h"

//Flaches Array. Gebaeude haben coords. Institudes haben ein parent

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

- (void)getCampusInformation;
- (void)showMapView:(id)sender;
- (void)fillSectionHeadersAndPOI;

@end
