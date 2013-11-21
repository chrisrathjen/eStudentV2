//
//  StudiengaengeViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 12.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "StudiengaengeViewController.h"
#import "CoreDataDataManager.h"
#import "Course.h"
#import "Studiengang.h"
#import "FPPopoverController.h"
#import "ChangeSemesterViewController.h"
#import "CoursesViewController.h"
#import "SVProgressHUD.h"

@interface StudiengaengeViewController ()
{
    __weak IBOutlet UISearchBar *_searchbar;
    __weak IBOutlet UITableView *_tableView;
    
    NSArray *_studiengaenge;
    NSMutableArray *_sectionHeader;
    NSMutableArray *_sectionHeaderToDisplay;
    NSMutableDictionary *_sortedCourses;
    NSMutableDictionary *_sortedCoursesToDisplay;
    FPPopoverController *_popoverController;
    ChangeSemesterViewController *_csvc;
    UIView *_emptyState;
}

- (void)changeSemester:(id)sender;

@end

@implementation StudiengaengeViewController

@synthesize chosenSemester = _chosenSemester;

//Setzt die Button und den Titel der Navigationbar.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_chosenSemester.title style:UIBarButtonItemStyleBordered target:self action:@selector(changeSemester:)];
    self.tabBarController.title = NSLocalizedString(@"Studiengänge", @"Studiengänge");
    self.tabBarController.navigationItem.title = NSLocalizedString(@"Studiengänge", @"Studiengänge");
    
    NSIndexPath *selection = [_tableView indexPathForSelectedRow];
    if (selection)
    {
        [_tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_chosenSemester)
    {
        Term *currentTerm = [[CoreDataDataManager sharedInstance] currentTerm];
        if (currentTerm)
        {
            if (_searchbar.hidden)
            {
                _searchbar.hidden = NO;
            }
            if ([self.view.subviews containsObject:_emptyState])
            {
                [_emptyState removeFromSuperview];
            }
            _chosenSemester = currentTerm;
            [self loadCoursesforTerm:currentTerm];
            
            self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:currentTerm.title style:UIBarButtonItemStyleBordered target:self action:@selector(changeSemester:)];
            if ([[CoreDataDataManager sharedInstance] getAllTermsFromCoreData].count > 1)
            {
                self.tabBarController.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else
            {
                self.tabBarController.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
        else
        {
            _searchbar.hidden = YES;
            self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
            _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
            _tableView.backgroundView = nil;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _sectionHeaderToDisplay = nil;
            _sortedCoursesToDisplay = nil;
            [_tableView reloadData];
            
            if (!_emptyState)
            {
                CGRect frame = self.view.frame;
                _emptyState = [[UIView alloc] initWithFrame:frame];
                UIImageView *emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty"]];
                frame = emptySemester.frame;
                frame.origin.x = (_emptyState.frame.size.width / 2.0) - (frame.size.width / 2.0);
                frame.origin.y = (_emptyState.frame.size.height / 2.0) - (frame.size.height);
                emptySemester.frame = frame;
                [_emptyState addSubview:emptySemester];
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, frame.origin.y + frame.size.height + 10.0, 260.0, 150.0)];
                textView.text = NSLocalizedString(@"Die Studiengänge konnten nicht geladen werden. Versuche es später noch einmal.", @"Die Studiengänge konnten nicht geladen werden. Versuche es später noch einmal.");
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    self.tabBarController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Studiengänge", @"Studiengänge") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _searchbar.tintColor = kCUSTOM_BLUE_COLOR;
    _searchbar.placeholder = NSLocalizedString(@"Studiengang suchen", @"Studiengang suchen");
}


//Lädt alle Studiengänge für ein Semester.
- (void)loadCoursesforTerm:(Term *)term
{
    [_popoverController dismissPopoverAnimated:YES];
    self.tabBarController.navigationItem.rightBarButtonItem.title = term.title;
    
    _sectionHeader = nil;
    _sectionHeader = [NSMutableArray array];
    _sortedCourses = nil;
    _sortedCourses = [NSMutableDictionary dictionary];
    
    [self searchBarCancelButtonClicked:_searchbar];
    
    _studiengaenge = nil;
    _studiengaenge = [[CoreDataDataManager sharedInstance] getCoursesForTerm:term];
    NSArray *userStudiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge];
    if (userStudiengaenge.count > 0)
    {
        [_sortedCourses setObject:[NSMutableArray array] forKey:@"userStudiengaenge"];
        [_sectionHeader addObject:@"#"];
    }
    for (Course *c in _studiengaenge)
    {
        if (userStudiengaenge.count > 0)
        {
            for (Studiengang *s in userStudiengaenge)
            {
                NSRange range = [[c.title lowercaseString] rangeOfString:[NSString stringWithFormat:@".*%@.*", [s.name lowercaseString]] options:NSRegularExpressionSearch];
                if (range.location != NSNotFound)
                {
                    NSMutableArray *array = [_sortedCourses objectForKey:@"userStudiengaenge"];
                    if (![array containsObject:c])
                    {
                        [array addObject:c];
                    }
                }
            }
        }
        
        NSString *firstLetter = [[c.title substringToIndex:1] capitalizedString];
        if (![_sectionHeader containsObject:firstLetter])
        {
            [_sectionHeader addObject:firstLetter];
            [_sortedCourses setObject:[NSMutableArray array] forKey:firstLetter];
        }
        NSMutableArray *array = [_sortedCourses objectForKey:firstLetter];
        if (![array containsObject:c])
        {
            [array addObject:c];
        }
    }
    if (((NSMutableArray *)[_sortedCourses objectForKey:@"userStudiengaenge"]).count == 0)
    {
        [_sortedCourses removeObjectForKey:@"userStudiengaenge"];
        [_sectionHeader removeObject:@"#"];
    }
    
    _sectionHeaderToDisplay = _sectionHeader.copy;
    _sortedCoursesToDisplay = _sortedCourses.copy;
    
    [_tableView reloadData];
}

#pragma mark - Table view data source

//Erstellt die 'ABC' Index Navigation auf der rechten Seite
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sectionHeader;
}

//Reagiert auf einen Tap auf der 'ABC' Index Navigation
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"])
    {
        return 0;
    }
    return [_sectionHeaderToDisplay indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionHeaderToDisplay.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:section];
    if ([sectionTitle isEqualToString:@"#"])
    {
        return ((NSMutableArray *)[_sortedCoursesToDisplay objectForKey:@"userStudiengaenge"]).count;
    }
    return ((NSMutableArray *)[_sortedCoursesToDisplay objectForKey:sectionTitle]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:section];
    if ([sectionTitle isEqualToString:@"#"])
    {
        return NSLocalizedString(@"Treffer nach Studiengangstitel", @"Treffer nach Studiengangstitel");
    }
    return [_sectionHeaderToDisplay objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StudiengangsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *array;
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    if ([sectionTitle isEqualToString:@"#"])
    {
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:@"userStudiengaenge"];
        cell.textLabel.textColor = [UIColor colorWithRed:.0 green:.16 blue:.47 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    }
    else
    {
        NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:sectionTitle];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    }
    
    Course *course = (Course *)[array objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = course.title;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSArray *array;
    if ([sectionTitle isEqualToString:@"#"])
    {
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:@"userStudiengaenge"];
    }
    else
    {
        
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:sectionTitle];
    }
    
    Course *course = (Course *)[array objectAtIndex:indexPath.row];
    
    return [course.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
}

//Reagiert auf die Auswahl eines Studiengangs und leitet den Nutzer zum Controller mit den Veranstaltungen für diesen Studiengang in diesem Semester.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSArray *array;
    if ([sectionTitle isEqualToString:@"#"])
    {
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:@"userStudiengaenge"];
    }
    else
    {
        
        array = (NSArray *)[_sortedCoursesToDisplay objectForKey:sectionTitle];
    }
    
    Course *course = (Course *)[array objectAtIndex:indexPath.row];
    CoursesViewController *cvc = [[CoursesViewController alloc] initWithNibName:@"CoursesViewController" bundle:nil];
    cvc.studiengang = course;
    cvc.title = NSLocalizedString(@"Veranstaltungen", @"Veranstaltungen");
    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark - UIBarButtonItem Actions

//Wechselt das Semester, wodurch die Studiengänge zu dem neu gewählten Semester geladen werden. Anschliessend wird das UI neu geladen.
- (void)changeSemester:(id)sender
{
    if (!_popoverController)
    {
        _csvc = [[ChangeSemesterViewController alloc] initWithNibName:nil bundle:nil];
        _csvc.pViewController = self;
        _popoverController = [[FPPopoverController alloc] initWithViewController:_csvc];
        _popoverController.tint = FPPopoverLightGrayTint;
        _popoverController.contentSize = CGSizeMake(200.0, 195.0);
    }
    
    _csvc.chosenTerm = _chosenSemester;
    [_csvc updateData];
    
    UIView* btnView = [sender valueForKey:@"view"];
    [_popoverController presentPopoverFromView:btnView];
}

#pragma mark - UISearchBarDelegate

//Reagiert direkt auf eine Eingabe in die Suchleiste.
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

//Durchsucht die Studiengänge nach dem eingegebenen Text aus der Suchleiste und lädt die Treffer neu.
-(void)filterContentForSearchText:(NSString*)searchText
{
    _sectionHeaderToDisplay = nil;
    _sectionHeaderToDisplay = [[NSMutableArray alloc] init];
    _sortedCoursesToDisplay = nil;
    _sortedCoursesToDisplay = [[NSMutableDictionary alloc] init];
    
    NSEnumerator *enumerator = [_sortedCourses keyEnumerator];
    id key;
    while (key = [enumerator nextObject])
    {
        NSMutableArray *tmpArray = [_sortedCourses objectForKey:key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@", searchText];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[tmpArray filteredArrayUsingPredicate:predicate]];
        if (array.count > 0)
        {
            if ([key isEqualToString:@"userStudiengaenge"])
            {
                [_sectionHeaderToDisplay addObject:@"#"];
                [_sortedCoursesToDisplay setObject:array forKey:@"userStudiengaenge"];
            }
            else
            {
                [_sectionHeaderToDisplay addObject:key];
                [_sortedCoursesToDisplay setObject:array forKey:key];
            }
        }
    }
    [_sectionHeaderToDisplay sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2){
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
}

//Setzt das Suchergebnis zurück und lädt alle ursprünglichen Daten.
- (void)clearSearch
{
    _sectionHeaderToDisplay = nil;
    _sectionHeaderToDisplay = [_sectionHeader copy];
    _sortedCoursesToDisplay = nil;
    _sortedCoursesToDisplay = [_sortedCourses copy];
    [_tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchbar setShowsCancelButton:YES animated:YES];
}

//Beendet die Suche.
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self clearSearch];
    [_searchbar setShowsCancelButton:NO animated:YES];
    _searchbar.text = @"";
    [_searchbar resignFirstResponder];
}

//Lässt die Tastatur verschwinden, wenn der Nutzer auf das 'Suchen'Feld getippt hat.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar setShowsCancelButton:NO animated:YES];
    [_searchbar resignFirstResponder];
}

@end
