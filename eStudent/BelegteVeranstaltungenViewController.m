//
//  BelegteVeranstaltungenViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 23.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "BelegteVeranstaltungenViewController.h"
#import "CoreDataDataManager.h"
#import "Lecture.h"
#import "Course.h"
#import "KursDetailsViewController.h"
#import "Eintrag.h"
#import "ManuelleVeranstaltungViewController.h"

@interface BelegteVeranstaltungenViewController ()
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UISearchBar *_searchBar;
    NSMutableArray *_belegteVeranstaltungen;
    NSMutableDictionary *_veranstaltungen;
    NSMutableDictionary *_veranstaltungenToDisplay;
    NSMutableArray *_sectionHeader;
    NSMutableArray *_sectionHeaderToDisplay;
    UIView *_emptyState;
}

- (void)addLectureManually:(id)sender;
- (NSComparisonResult)compareSemester:(NSString *)s1 withSemester:(NSString *)s2;

@end

@implementation BelegteVeranstaltungenViewController

//Lädt über den Datenmanger sämtliche Veranstaltungen, in die der Nutzer sich eingetragen hat.
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLectureManually:)];
    self.tabBarController.navigationItem.title = NSLocalizedString(@"Deine Veranstaltungen", @"Deine Veranstaltungen");
    //self.tabBarController.navigationItem.rightBarButtonItem = nil;
    _searchBar.text = nil;
    
    _belegteVeranstaltungen = [[CoreDataDataManager sharedInstance] getAllActiveLectures].mutableCopy;
    if (_belegteVeranstaltungen.count > 0)
    {
        if (_emptyState)
        {
            [_emptyState removeFromSuperview];
        }
        _searchBar.hidden = NO;
        _veranstaltungen = [NSMutableDictionary dictionary];
        _sectionHeader = [NSMutableArray array];
        for (Lecture *lecture in _belegteVeranstaltungen)
        {
            NSString *semester = lecture.course.semester.title;
            if (![_sectionHeader containsObject:semester])
            {
                [_sectionHeader addObject:semester];
                [_veranstaltungen setObject:[NSMutableArray array] forKey:semester];
                
                [_sectionHeader sortUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2){
                    return [self compareSemester:s2 withSemester:s1];
                }];
            }
            NSMutableArray *array = [_veranstaltungen objectForKey:semester];
            if (![array containsObject:lecture])
            {
                [array addObject:lecture];
                [array sortUsingComparator:^NSComparisonResult(Lecture *l1, Lecture *l2){
                    return [l1.title compare:l2.title];
                }];
            }
        }
        _sectionHeaderToDisplay = _sectionHeader.copy;
        _veranstaltungenToDisplay = _veranstaltungen.copy;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView reloadData];
    }
    else
    {
        _searchBar.hidden = YES;
        _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _sectionHeaderToDisplay = nil;
        _veranstaltungenToDisplay = nil;
        [_tableView reloadData];
        
        if (!_emptyState)
        {
            _emptyState = [[UIView alloc] initWithFrame:self.view.frame];
            UIImageView *emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty"]];
            CGRect frame = emptySemester.frame;
            frame.origin.x = (_emptyState.frame.size.width / 2.0) - (frame.size.width / 2.0);
            frame.origin.y = (_emptyState.frame.size.height / 2.0) - (frame.size.height);
            emptySemester.frame = frame;
            [_emptyState addSubview:emptySemester];
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, frame.origin.y + frame.size.height + 10.0, 260.0, 150.0)];
            textView.text = NSLocalizedString(@"Du hast bisher keine Veranstaltung hinzugefügt. Füge Veranstaltungen über das Veranstaltungsverzeichnis oder manuell über den '+'-Button hinzu.", @"Du hast bisher keine Veranstaltung hinzugefügt. Füge Veranstaltungen über das Veranstaltungsverzeichnis oder manuell über den '+'-Button hinzu.");
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.textAlignment = NSTextAlignmentCenter;
            textView.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
            textView.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
            textView.backgroundColor = [UIColor clearColor];
            [_emptyState addSubview:textView];
        }
        [self.view addSubview:_emptyState];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _searchBar.tintColor = kCUSTOM_BLUE_COLOR;
    _searchBar.placeholder = NSLocalizedString(@"Veranstaltung suchen", @"Veranstaltung suchen");
    self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionHeaderToDisplay.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionHeader = [_sectionHeaderToDisplay objectAtIndex:section];
    NSMutableArray *veranstaltungen = [_veranstaltungenToDisplay objectForKey:sectionHeader];
    return veranstaltungen.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionHeaderToDisplay objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BelegteVeranstaltungenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *sectionHeader = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSMutableArray *veranstaltungen = [_veranstaltungenToDisplay objectForKey:sectionHeader];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Lecture *lecture = (Lecture *)[veranstaltungen objectAtIndex:indexPath.row];
    cell.textLabel.text = lecture.title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    if ([lecture.createdByUser boolValue])
    {
        cell.textLabel.textColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    NSMutableString *subtitle = [NSMutableString string];
    if ([lecture.activeInSchedule boolValue])
    {
        [subtitle appendFormat:@"%@", NSLocalizedString(@"Stundenplan", @"Stundenplan")];
        Eintrag *eintrag = [[CoreDataDataManager sharedInstance] getEintragForLecture:lecture];
        if (eintrag)
        {
            [subtitle appendFormat:@", %@", NSLocalizedString(@"Studiumsplaner", @"Studiumsplaner")];
        }
    }
    else
    {
        Eintrag *eintrag = [[CoreDataDataManager sharedInstance] getEintragForLecture:lecture];
        if (eintrag)
        {
            [subtitle appendFormat:@"%@", NSLocalizedString(@"Studiumsplaner", @"Studiumsplaner")];
        }
    }
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionHeader = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSMutableArray *veranstaltungen = [_veranstaltungenToDisplay objectForKey:sectionHeader];
    return [((Lecture *)[veranstaltungen objectAtIndex:indexPath.row]).title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] constrainedToSize:CGSizeMake(280.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 35.0;
}

//Lädt die Detailansicht zu einer Veranstaltung, dessen korrespondierende Zelle der Nutzer angetippt hat.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionHeader = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSMutableArray *veranstaltungen = [_veranstaltungenToDisplay objectForKey:sectionHeader];
    Lecture *chosenLecture = (Lecture *)[veranstaltungen objectAtIndex:indexPath.row];
    
    if ([chosenLecture.createdByUser boolValue])
    {
        ManuelleVeranstaltungViewController *mvvc = [[ManuelleVeranstaltungViewController alloc] initWithNibName:@"ManuelleVeranstaltungViewController" bundle:nil];
        mvvc.veranstaltung = chosenLecture;
        mvvc.title = NSLocalizedString(@"Veranstaltung bearbeiten", @"Veranstaltung bearbeiten");
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvvc];
        nc.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
        [self presentViewController:nc animated:YES completion:nil];
    }
    else
    {
        KursDetailsViewController *kdvc = [[KursDetailsViewController alloc] initWithNibName:@"KursDetailsViewController" bundle:nil];
        kdvc.veranstaltung = chosenLecture;
        [self.navigationController pushViewController:kdvc animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

//Immer wenn der Nutzer etwas in das Suchfeld tippt, wird die Suche gestartet
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length < 1)
    {
        [self clearSearch];
        return;
    }
    [self filterContentForSearchText:searchText];
    [_tableView reloadData];
}

//Filtert die Veranstaltungen nach dem Text des Suchfeldes. Die Treffer werden neu im UI geladen.
-(void)filterContentForSearchText:(NSString*)searchText
{
    _sectionHeaderToDisplay = nil;
    _sectionHeaderToDisplay = [[NSMutableArray alloc] init];
    _veranstaltungenToDisplay = nil;
    _veranstaltungenToDisplay = [[NSMutableDictionary alloc] init];
    
    NSEnumerator *enumerator = [_veranstaltungen keyEnumerator];
    id key;
    while (key = [enumerator nextObject])
    {
        NSMutableArray *tmpArray = [_veranstaltungen objectForKey:key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@", searchText];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[tmpArray filteredArrayUsingPredicate:predicate]];
        if (array.count > 0)
        {
            [_sectionHeaderToDisplay addObject:key];
            [_veranstaltungenToDisplay setObject:array forKey:key];
        }
    }
}

//Das Suchfeld und die Suchergebnisse werden zurückgesetzt.
- (void)clearSearch
{
    _sectionHeaderToDisplay = nil;
    _sectionHeaderToDisplay = [_sectionHeader copy];
    _veranstaltungenToDisplay = nil;
    _veranstaltungenToDisplay = [_veranstaltungen copy];
    [_tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:YES];
}

//Die Suche wird beendet.
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self clearSearch];
    [_searchBar setShowsCancelButton:NO animated:YES];
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
}

#pragma mark - Add Lecture Manually

//Der Button um eine Veranstaltung manuell anzulegen wird angetippt. Der ManuelleVeranstaltungViewController wird geladen.
- (void)addLectureManually:(id)sender
{
    ManuelleVeranstaltungViewController *mvvc = [[ManuelleVeranstaltungViewController alloc] initWithNibName:@"ManuelleVeranstaltungViewController" bundle:nil];
    mvvc.title = NSLocalizedString(@"Neue Veranstaltung", @"Neue Veranstaltung");
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvvc];
    nc.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - compare two Semesters

//Vergleicht zwei Semester anhand ihrer Namen miteinander und liefert ein NSComparisonResult zurück, dass darüber auskunft gibt,
//ob das erste Semester früher, später oder gleich dem zweiten Semester ist.
- (NSComparisonResult)compareSemester:(NSString *)s1 withSemester:(NSString *)s2
{
    NSArray *splitA = [s1 componentsSeparatedByString:@" "];
    NSString *_a = [splitA objectAtIndex:1];
    NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
    
    NSArray *splitB = [s2 componentsSeparatedByString:@" "];
    NSString *_b = [splitB objectAtIndex:1];
    NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
    
    if (splitA2.count == 2)
    {
        if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:0] intValue] == [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
        else //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
    }
    else
    {
        if (splitB2.count == 2) //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] <= [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
        else //hier werden zwei Sommersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:0] intValue] == [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
    }
    
    return NSOrderedAscending;
}

@end
