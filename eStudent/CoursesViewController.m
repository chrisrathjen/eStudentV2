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

@interface CoursesViewController ()
{
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_tableView;
    NSMutableDictionary *_veranstaltungen;
    NSMutableDictionary *_veranstaltungenToDisplay;
    NSMutableArray *_sectionHeader;
    NSMutableArray *_sectionHeaderToDisplay;
    MBProgressHUD *_progressHUD;
    NSArray *_belegteVeranstaltungen;
}

//- (void)doneButtonPressed:(id)sender;

@end

@implementation CoursesViewController

@synthesize studiengang = _studiengang;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    //self.navigationItem.title = [NSString stringWithFormat:@"%@, %@", self.navigationItem.title, _studiengang.semester.title];
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.detailsLabelText = NSLocalizedString(@"Lade Veranstaltungen", @"Lade Veranstaltungen");
    _progressHUD.mode = MBProgressHUDModeIndeterminate;
    _progressHUD.delegate = self;
    [self.view addSubview:_progressHUD];
    [_progressHUD show:YES];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Fertig", @"Fertig") style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
    _searchBar.tintColor = kCUSTOM_BLUE_COLOR;
    _searchBar.placeholder = NSLocalizedString(@"Veranstaltung suchen (Titel,VAK,Dozent)", @"Veranstaltung suchen (Titel,VAK,Dozent)");
    
    [[CoreDataDataManager sharedInstance] getLecturesForCourse:_studiengang withCallback:^(BOOL wasSuccessful, NSArray *lectures) {
        if (lectures.count > 0)
        {
            [_progressHUD hide:YES];
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
            [_progressHUD hide:YES];
#warning Hier muss die GUI noch den Zustand repraesentieren, wenn keine Daten vorhanden sind.
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

#pragma mark - UIBarButtonItem Pressed

/*- (void)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

#pragma mark - MBProgressHUDDelegate

/*- (void)hudWasHidden:(MBProgressHUD *)hud{}*/

@end
