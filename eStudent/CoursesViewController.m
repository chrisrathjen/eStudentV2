//
//  CoursesViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 15.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "CoursesViewController.h"
#import "CoreDataDataManager.h"
#import "Lecture.h"
#import "KursDetailsViewController.h"
#import "SVProgressHUD.h"

@interface CoursesViewController ()
{
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_tableView;
    NSMutableDictionary *_veranstaltungen;
    NSMutableDictionary *_veranstaltungenToDisplay;
    NSMutableArray *_sectionHeader;
    NSMutableArray *_sectionHeaderToDisplay;
    NSArray *_belegteVeranstaltungen;
    UIView *_emptyState;
}

@end

@implementation CoursesViewController

@synthesize studiengang = _studiengang;


//Lädt die Veranstaltungen, in die der Nutzer sich eingetragen hat, um diese visuell hervorheben zu können.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _belegteVeranstaltungen = [[CoreDataDataManager sharedInstance] getAllActiveLectures].copy;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selection = [_tableView indexPathForSelectedRow];
    if (selection)
    {
        [_tableView beginUpdates];
        [_tableView deselectRowAtIndexPath:selection animated:YES];
        _belegteVeranstaltungen = [[CoreDataDataManager sharedInstance] getAllActiveLectures];
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selection] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    }
}

//Lädt die Veranstaltungen zu einem Studiengang aus einem bestimmten Semester und erzeugt das UI.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];

    //self.navigationItem.title = [NSString stringWithFormat:@"%@, %@", self.navigationItem.title, _studiengang.semester.title];
    CoreDataDataManager *cdm = [CoreDataDataManager sharedInstance];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Lade Veranstaltungen", @"Lade Veranstaltungen")];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Fertig", @"Fertig") style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
    _searchBar.tintColor = kCUSTOM_BLUE_COLOR;
    _searchBar.placeholder = NSLocalizedString(@"Veranstaltung suchen (Titel,VAK,Dozent)", @"Veranstaltung suchen (Titel,VAK,Dozent)");
    
    [cdm getLecturesForCourse:_studiengang withCallback:^(BOOL wasSuccessful, NSArray *lectures) {
        if (lectures.count > 0)
        {
            [SVProgressHUD dismiss];
            _veranstaltungen = [NSMutableDictionary dictionary];
            _sectionHeader = [NSMutableArray array];
            for (Lecture *lecture in lectures)
            {
                NSString *firstLetter = [[lecture.title substringToIndex:1] capitalizedString];
                if (![_sectionHeader containsObject:firstLetter])
                {
                    [_sectionHeader addObject:firstLetter];
                    [_veranstaltungen setObject:[NSMutableArray array] forKey:firstLetter];
                }
                NSMutableArray *array = [_veranstaltungen objectForKey:firstLetter];
                if (![array containsObject:lecture])
                {
                    [array addObject:lecture];
                }
            }
            
            _veranstaltungenToDisplay = _veranstaltungen.copy;
            _sectionHeaderToDisplay = _sectionHeader.copy;
            [_tableView reloadData];
        }
        else
        {
            [SVProgressHUD dismiss];
            _searchBar.hidden = YES;
            self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
            _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
            _tableView.backgroundView = nil;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _sectionHeaderToDisplay = nil;
            _veranstaltungenToDisplay = nil;
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
                textView.text = NSLocalizedString(@"Die Veranstaltungen konnten nicht geladen werden. Prüfe deine Internetverbindung und versuche es noch einmal.", @"Die Veranstaltungen konnten nicht geladen werden. Prüfe deine Internetverbindung und versuche es noch einmal.");
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
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [_sectionHeaderToDisplay indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionHeaderToDisplay.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:section];
    return ((NSMutableArray *)[_veranstaltungenToDisplay objectForKey:sectionTitle]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionHeaderToDisplay objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VeranstaltungenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    Lecture *lecture = [((NSMutableArray *)[_veranstaltungenToDisplay objectForKey:sectionTitle]) objectAtIndex:indexPath.row];
    if ([_belegteVeranstaltungen containsObject:lecture])
    {
        cell.imageView.image = [UIImage imageNamed:@"258-checkmark"];
    }
    else
    {
        cell.imageView.image = nil;
    }
    cell.textLabel.text = lecture.title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    cell.detailTextLabel.text = lecture.vak;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSArray *array = (NSArray *)[_veranstaltungenToDisplay objectForKey:sectionTitle];
    Lecture *lecture = (Lecture *)[array objectAtIndex:indexPath.row];
    if ([_belegteVeranstaltungen containsObject:lecture])
    {
        return [lecture.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] constrainedToSize:CGSizeMake(210.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 40.0;
    }
    return [lecture.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] constrainedToSize:CGSizeMake(245.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 40.0;
}

//Lädt den KursDetailsViewController mit den Veranstalungsdaten der Zelle, auf die der Nuter getippt hat und navigiert ihn rein.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [_sectionHeaderToDisplay objectAtIndex:indexPath.section];
    NSArray *array = (NSArray *)[_veranstaltungenToDisplay objectForKey:sectionTitle];
    Lecture *lecture = (Lecture *)[array objectAtIndex:indexPath.row];
    
    KursDetailsViewController *kdvc = [[KursDetailsViewController alloc] initWithNibName:@"KursDetailsViewController" bundle:nil];
    kdvc.veranstaltung = lecture;
    [self.navigationController pushViewController:kdvc animated:YES];
}

#pragma mark - UISearchBarDelegate

//Reagiert auf die Eingaben des Nuters in die Suchleiste und lädt das UI mit den Suchtreffern neu.
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

//Filtert die Veranstaltungen nach dem Text der Suchleiste.
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.title contains[c] %@) OR (SELF.vak contains[c] %@) OR (ANY SELF.lecturers.title contains[c] %@)", searchText, searchText, searchText];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[tmpArray filteredArrayUsingPredicate:predicate]];
        if (array.count > 0)
        {
            [_sectionHeaderToDisplay addObject:key];
            [_veranstaltungenToDisplay setObject:array forKey:key];
        }
    }
    [_sectionHeaderToDisplay sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2){
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
}

//Setzt die Suche zurück.
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

//Beendet die Suche.
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

@end
