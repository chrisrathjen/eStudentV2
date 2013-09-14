//
//  POIListViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 05.01.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "POIListViewController.h"
#import "POI.h"
#import "MBProgressHUD.h"
#import "InformationenViewController.h"
#import "CampusMapViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation POIListViewController
{
    CGRect lastFrameForCellHeight;
    NSMutableArray *_haltestellen;
}

#pragma mark - ViewController Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // Unselect the selected row if any
	NSIndexPath *indexPath = tableView.indexPathForSelectedRow;
	if (indexPath)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    
    self.title = NSLocalizedString(@"Campus", @"Campus");
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"POI" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIImage *mapImage = [UIImage imageNamed:@"map"];
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:mapImage landscapeImagePhone:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(showMapView:)];
    self.navigationItem.rightBarButtonItem = mapButton;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES]; //self.tableView??
    [self getCampusInformation];
    
    searchBar.tintColor = [UIColor colorWithRed:.25 green:.51 blue:.77 alpha:1.0]; //uni-blau
    searchBar.placeholder = NSLocalizedString(@"Suchen", @"Suchen");
}

- (void)showMapView:(id)sender
{
    NSMutableArray *_pois = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [pointsOfInterestToDisplay keyEnumerator];
    id key;
    while (key = [enumerator nextObject])
    {
        NSMutableArray *array = [pointsOfInterestToDisplay objectForKey:key];
        for (POI *poi in array)
        {
            [_pois addObject:poi];
        }
    }
    
    CampusMapViewController *campusMapVC = [[CampusMapViewController alloc] initWithNibName:@"CampusMapViewController" bundle:nil];
    campusMapVC.pointsOfInterest = _pois;
    campusMapVC.haltestellen = _haltestellen;
    [self.navigationController pushViewController:campusMapVC animated:YES];
}

#pragma mark - UITableViewDataSource

//Erstellt die 'ABC' Index Navigation auf der rechten Seite
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionHeaders;
    //return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

//Reagiert auf einen Tap auf der 'ABC' Index Navigation
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [sectionHeadersToDisplay indexOfObject:title];

    /*NSArray *alphabet = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    int minIndex = [alphabet indexOfObject:[sectionHeadersToDisplay objectAtIndex:0]];

    if (index <= minIndex)
    {
        return 0;
    }
    while (![sectionHeadersToDisplay containsObject:[alphabet objectAtIndex:index]])
    {
        --index;
    }
    return index;*/
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionHeadersToDisplay.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionHeadersToDisplay objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [sectionHeadersToDisplay objectAtIndex:section];
    return ((NSMutableArray *)[pointsOfInterestToDisplay objectForKey:sectionTitle]).count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"POICell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *sectionTitle = [sectionHeadersToDisplay objectAtIndex:indexPath.section];
    NSArray *array = (NSArray *)[pointsOfInterestToDisplay objectForKey:sectionTitle];
    POI *poi = (POI *)[array objectAtIndex:indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    cell.textLabel.text = poi.name;
    
    if (poi.parentPoi)
    {
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Gebäude", @"Gebäude"), poi.parentPoi.name];
    }
    else
    {
        cell.detailTextLabel.text = nil;
    }
    
    if ([poi.type intValue] == 0) //POI ist ein  Gebaeude
    {
        cell.imageView.image = [UIImage imageNamed:@"gebaeude-b"];
    }
    else if ([poi.type intValue] == 2) //POI ist eine Essenseinrichtung
    {
        cell.imageView.image = [UIImage imageNamed:@"besteck-b"];
    }
    else if ([poi.type intValue] == 4) //POI ist eine Haltestelle
    {
        cell.imageView.image = [UIImage imageNamed:@"haltestelle-b"];
    }
    else
    {
        cell.imageView.image = nil;
    }
    
    
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell addGestureRecognizer:swipeGesture];
    
    cell.opaque = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)swipedScreen:(UIGestureRecognizer*)gestureRecognizer
{
    UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    NSString *section = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSArray *_pois = [pointsOfInterestToDisplay objectForKey:section];
    POI *poi = [_pois objectAtIndex:indexPath.row];
    InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
    [ivc setPointOfInterest:poi];
    ivc.haltestellen = _haltestellen;
    ivc.title = NSLocalizedString(@"Informationen", @"Informationen");
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)showOnMapButtonPressed:(UIButton *)sender
{
    NSString *section = [self tableView:tableView titleForHeaderInSection:tappedIndexPath.section];
    NSArray *_pois = [pointsOfInterestToDisplay objectForKey:section];
    POI *poi = [_pois objectAtIndex:tappedIndexPath.row];
    CampusMapViewController *campusMapVC = [[CampusMapViewController alloc] initWithNibName:@"CampusMapViewController" bundle:nil];
    campusMapVC.pointsOfInterest = [NSArray arrayWithObject:poi];
    campusMapVC.haltestellen = _haltestellen;
    [self.navigationController pushViewController:campusMapVC animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGSize constraintSize = CGSizeMake(250.0, MAXFLOAT);
    if (cell.imageView.image) //wenn das imageView gesetzt ist muss die constraintSize kleiner sein
    {
        constraintSize.width = 220.0;
    }
    
    CGSize textLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize detailTextLabelSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    float height = textLabelSize.height;
    if (cell.detailTextLabel.text)
    {
        height += detailTextLabelSize.height;
    }
    
    
    
    return height + 15.0;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSArray *_pois = [pointsOfInterestToDisplay objectForKey:section];
    POI *poi = [_pois objectAtIndex:indexPath.row];
    InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
    ivc.haltestellen = _haltestellen;
    [ivc setPointOfInterest:poi];
    ivc.title = NSLocalizedString(@"Informationen", @"Informationen");
    [self.navigationController pushViewController:ivc animated:YES];
}

#pragma mark - InformationModel

- (void)getCampusInformation
{
    //Wenn die gespeicherte Version der Campus Informationen aelter als 7 Tage ist werden die Daten neu aus dem Netz kopiert. Ansonsten wird eine Kopie aus dem Dateisystem geladen
    NSDate *lastRequestDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastCampusPOIRefresh];
    if ([lastRequestDate timeIntervalSinceNow] < kTimeIntervalOneWeek || lastRequestDate == nil || kDEBUG) {
        //neue Daten laden
        networkManager = [[ESNetworkManager alloc] init];
        [networkManager setDelegate:self];
        [networkManager getDataFromNetwork:[NSURL URLWithString:kGenerellCampusInformationURL]];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedPoiDataFileName] stringByExpandingTildeInPath]; //Get Path to Cached File in the Library Folder
            pois = [NSArray arrayWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fillSectionHeadersAndPOI];
                [tableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        });
    }
}

#pragma mark - ESNetworkManagerDelegate

- (void)dataFromRemoteURL:(NSData *)remoteData
{
    //Hier werden die aus dem Netz geladenen Daten wie gewohnt bearbeitet um dann angezeigt zu werden
    pois = [NSJSONSerialization JSONObjectWithData:remoteData options:kNilOptions error:nil];
    [self fillSectionHeadersAndPOI];
    
    [tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //Nachdem die Daten angezeigt sind werden sie im Hintergrunf gespeichert.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedPoiDataFileName] stringByExpandingTildeInPath]; //Get Path to Cached File in the Library Folder
        BOOL success = [pois writeToFile:filePath atomically:YES];
        if (success)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastCampusPOIRefresh];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

- (void)fillSectionHeadersAndPOI
{
    if (!sectionHeaders)
    {
        sectionHeaders = [[NSMutableArray alloc] init];
    }
    if (!pointsOfInterest)
    {
        pointsOfInterest = [[NSMutableDictionary alloc] init];
    }
    if (!_haltestellen)
    {
        _haltestellen = [NSMutableArray array];
    }
    
    for (NSDictionary *dictionary in pois)
    {
        POI *poi = [[POI alloc] initWithInfoDictionary:dictionary];
        
        if ([poi.type intValue] == 4) //Ist eine Haltestelle
        {
            [_haltestellen addObject:poi];
        }
        
        if (poi.institutions) {
            for (POI *anInstitutions in poi.institutions) {
                NSString *firstLetter = [[anInstitutions.name substringToIndex:1] capitalizedString];
                if (![sectionHeaders containsObject:firstLetter])
                {
                    [sectionHeaders addObject:firstLetter];
                    
                    NSMutableArray *ma = [[NSMutableArray alloc] init];
                    [pointsOfInterest setObject:ma forKey:firstLetter];
                }
                NSMutableArray *array = [pointsOfInterest objectForKey:firstLetter];
                if (![array containsObject:anInstitutions])
                {
                    [array addObject:anInstitutions];
                }
            }
        }
        
        NSString *firstLetter = [[poi.name substringToIndex:1] capitalizedString];
        if (![sectionHeaders containsObject:firstLetter])
        {
            [sectionHeaders addObject:firstLetter];
            
            NSMutableArray *ma = [[NSMutableArray alloc] init];
            [pointsOfInterest setObject:ma forKey:firstLetter];
        }
        NSMutableArray *array = [pointsOfInterest objectForKey:firstLetter];
        if (![array containsObject:poi])
        {
            [array addObject:poi];
        }
    }
    
    [sectionHeaders sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2){
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    sectionHeadersToDisplay = [sectionHeaders copy];
    
    //sort Pois inpointsOfInterest
    for (NSString * aKey in pointsOfInterest) {
        NSMutableArray *anArray = [pointsOfInterest objectForKey:aKey];
        [anArray sortUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(POI *)a name];
            NSString *second = [(POI *)b name];
            return [first localizedCaseInsensitiveCompare:second];
        }];
        
    }
    
    pointsOfInterestToDisplay = [pointsOfInterest copy];
}

-(void)requestFailedWithError:(NSString *)localizedErrorString
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedPoiDataFileName] stringByExpandingTildeInPath]; //Get Path to Cached File in the Library Folder
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            pois = [NSArray arrayWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fillSectionHeadersAndPOI];
                [tableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [tableView setHidden:YES];
                [searchBar setHidden:YES];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                
                UIImageView *emptyStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-network-empty-state"]];
                CGRect frame = emptyStateImage.frame;
                frame.origin.x = self.view.frame.size.width/2.0 - frame.size.width/2.0;
                frame.origin.y = self.view.frame.size.height/2.0 - frame.size.height/1.5 - 20.0;
                emptyStateImage.frame = frame;
                [self.view addSubview:emptyStateImage];
                
                frame = emptyStateImage.frame;
                UITextView *emptyStateText = [[UITextView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 200.0)];
                emptyStateText.text = NSLocalizedString(@"Verbindungsprobleme. Bitte versuche es später noch mal.", @"Verbindungsprobleme. Bitte versuche es später noch mal.");
                emptyStateText.scrollEnabled = NO;
                emptyStateText.editable = NO;
                emptyStateText.textAlignment = NSTextAlignmentCenter;
                emptyStateText.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
                emptyStateText.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
                emptyStateText.backgroundColor = [UIColor clearColor];
                [self.view addSubview:emptyStateText];
            });
        }
        
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length < 1)
    {
        [self clearSearch];
        return;
    }
    [self filterContentForSearchText:searchText];
    [tableView reloadData];
}

-(void)filterContentForSearchText:(NSString*)searchText
{
    sectionHeadersToDisplay = nil;
    sectionHeadersToDisplay = [[NSMutableArray alloc] init];
    pointsOfInterestToDisplay = nil;
    pointsOfInterestToDisplay = [[NSMutableDictionary alloc] init];
    
    NSEnumerator *enumerator = [pointsOfInterest keyEnumerator];
    id key;
    while (key = [enumerator nextObject])
    {
        NSMutableArray *tmpArray = [pointsOfInterest objectForKey:key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.keywords contains[c] %@) OR (SELF.name contains[c] %@)", searchText, searchText];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[tmpArray filteredArrayUsingPredicate:predicate]];
        if (array.count > 0)
        {
            [sectionHeadersToDisplay addObject:key];
            [pointsOfInterestToDisplay setObject:array forKey:key];
        }
    }
    [sectionHeadersToDisplay sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2){
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
}

- (void)clearSearch
{
    sectionHeadersToDisplay = nil;
    sectionHeadersToDisplay = [sectionHeaders copy];
    pointsOfInterestToDisplay = nil;
    pointsOfInterestToDisplay = [pointsOfInterest copy];
    [tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [self clearSearch];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

@end
