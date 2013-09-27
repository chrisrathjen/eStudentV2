//
//  ErstesFachsemesterAuswahlViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 29.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ErstesFachsemesterAuswahlViewController.h"
#import "Semester.h"
#import "CoreDataDataManager.h"
#import "Studiengang.h"

@interface ErstesFachsemesterAuswahlViewController ()
{
    NSMutableArray *semesters;
    NSIndexPath *chosenIndexPath;
    NSIndexPath *_erstesFachsemester;
    Semester *currentSemester;
    BOOL scrollViewShouldScroll;
}

- (NSString *)previousSemesterStringFromSemesterString:(NSString *)semesterstring;
- (void)anlegen:(id)sender;
- (NSComparisonResult)compareSemesterString:(NSString *)term withSemesterString:(NSString *)semester;

@end

@implementation ErstesFachsemesterAuswahlViewController

@synthesize studiengangName;
@synthesize abschlussArt;
@synthesize cp;
@synthesize studiengang = _studiengang;

//Bereitet das UI vor. Lädt das aktuelle Semester als ersten Listeneintrag. Danach werden noch 10 weitere temporäre in der Vergangenheit liegende Semester der Liste hinzugefügt.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = NSLocalizedString(@"Erstes Fachsemester", @"Erstes Fachsemester");//[NSString stringWithFormat:@"%@, %@", studiengangName, abschlussArt];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Anlegen", @"Anlegen") style:UIBarButtonItemStylePlain target:self action:@selector(anlegen:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    semesters = [NSMutableArray array];
    currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
    
    if (_studiengang)
    {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Speichern", @"Speichern");
        self.navigationItem.rightBarButtonItem.enabled = YES;
        int semestercount = 1;
        NSString *semester = currentSemester.name;
        [semesters addObject:semester];
        while ([self compareSemesterString:semester withSemesterString:_studiengang.erstesFachsemester.name] != NSOrderedSame)
        {
            semester = [self previousSemesterStringFromSemesterString:semester];
            [semesters addObject:semester];
            semestercount++;
        }
        for (int i = semestercount; i < 10; i++)
        {
            [semesters addObject:[self previousSemesterStringFromSemesterString:[semesters lastObject]]];
        }
        
        chosenIndexPath = [NSIndexPath indexPathForRow:semestercount-1 inSection:0];
        _erstesFachsemester = chosenIndexPath;
        
        [self.tableView reloadData];
    }
    else
    {
        [semesters addObject:currentSemester.name];
        for (int i = 0; i < 10; i++)
        {
            [semesters addObject:[self previousSemesterStringFromSemesterString:[semesters lastObject]]];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"Wähle das erste Fachsemester deines Studiengangs:", @"Wähle das erste Fachsemester des Studiengangs:"), studiengangName, abschlussArt];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return semesters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *cellTitle = [semesters objectAtIndex:indexPath.row];
    cell.textLabel.text = cellTitle;
    if ([indexPath isEqual:chosenIndexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.row == 0)
    {
        cell.detailTextLabel.text = NSLocalizedString(@"Aktuelles Semester", @"Aktuelles Semester");
        cell.detailTextLabel.textColor = kCUSTOM_BLUE_COLOR;
    }
    else
    {
        cell.detailTextLabel.text = nil;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

//Tippt der Nutzer auf eine Zelle, wird das ausgewählte Semester als dsa erste Fachsemester seines Studiengangs eingetragen.
//Eventuelle davorliegende Semester werden ebenfalls angelegt, falls diese noch nicht existieren.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:chosenIndexPath])
    {
        return;
    }
    else
    {
        if (!chosenIndexPath)
        {
            chosenIndexPath = indexPath;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            NSIndexPath *tmpPath = chosenIndexPath;
            chosenIndexPath = indexPath;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpPath, indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

#pragma mark - Liefert von einem übergebenen Semester (als String) das davor liegende Semester als String

//Liefert von einem übergebenen Semester (als String) das davor liegende Semester als String
- (NSString *)previousSemesterStringFromSemesterString:(NSString *)semesterstring
{
    NSMutableString *previousSemester = [NSMutableString string];
    
    NSArray *firstSplit = [semesterstring componentsSeparatedByString:@" "];
    if ([[firstSplit objectAtIndex:0] isEqualToString:@"WiSe"])
    {
        [previousSemester appendString:@"SoSe "];
    }
    else
    {
        [previousSemester appendString:@"WiSe "];
    }
    
    NSArray *secondSplit = [[firstSplit objectAtIndex:1] componentsSeparatedByString:@"/"];
    int i = [[secondSplit objectAtIndex:0] intValue];
    
    if (secondSplit.count == 1)
    {
        [previousSemester appendFormat:@"%i", i-1];
        int j = [[secondSplit objectAtIndex:0] intValue];
        j %= 100;
        if (j < 10)
        {
            [previousSemester appendFormat:@"/0%i", j];
        }
        else
        {
            [previousSemester appendFormat:@"/%i", j];
        }
    }
    else
    {
        [previousSemester appendFormat:@"%i", i];
    }
    
    return [NSString stringWithString:previousSemester];
}

#pragma mark - Anlegen Button 

//Betätigt der Nutzer den 'Anlegen' Button, muss er dieses bestätigen.
- (void)anlegen:(id)sender
{
    if (_studiengang)
    {
        _studiengang.name = studiengangName;
        _studiengang.abschluss = abschlussArt;
        _studiengang.cp = [NSNumber numberWithInt:cp];
        
        Semester *semester = [[CoreDataDataManager sharedInstance] createSemesterWithName:[semesters objectAtIndex:chosenIndexPath.row]];
        for (int i = chosenIndexPath.row-1; i >= 1; i--)
        {
            [[CoreDataDataManager sharedInstance] createSemesterWithName:[semesters objectAtIndex:i]];
        }
        
        [[CoreDataDataManager sharedInstance] setNewFirstSemester:semester forStudiengang:_studiengang];
        
        [[CoreDataDataManager sharedInstance] saveDatabase];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSString *message = NSLocalizedString(([NSString stringWithFormat:@"Möchtest du den Studiengang: \"%@, %@\", mit \"%i CP\" und dem \"%@\" als erstem Fachsemester, wirklich anlegen?", studiengangName, abschlussArt, cp, [semesters objectAtIndex:chosenIndexPath.row]]), @"Studiengang wirklich anlegen?");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Studiengang anlegen", @"Studiengang anlegen") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") otherButtonTitles:NSLocalizedString(@"Anlegen", @"Anlegen"), nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

//Bestätigt der Nutzer das Anlegen, wird der Studiengang mit Titel, CP, Abschlussart und erstem Fachsemester in die Datenbank eingetragen.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) //Anlegen Button wurde gedrückt
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        Studiengang *studiengang;
        if (chosenIndexPath.row == 0)
        {
            studiengang = [[CoreDataDataManager sharedInstance] createStudiengangWithName:studiengangName abschluss:abschlussArt cp:[NSNumber numberWithInt:cp] erstesFachsemester:currentSemester];
        }
        else
        {
            Semester *s = [[CoreDataDataManager sharedInstance] createSemesterWithName:[semesters objectAtIndex:chosenIndexPath.row]];
            for (int i = chosenIndexPath.row-1; i >= 1; i--)
            {
                [[CoreDataDataManager sharedInstance] createSemesterWithName:[semesters objectAtIndex:i]];
            }
            studiengang = [[CoreDataDataManager sharedInstance] createStudiengangWithName:studiengangName abschluss:abschlussArt cp:[NSNumber numberWithInt:cp] erstesFachsemester:s];
        }
        
        NSArray *objects = [NSArray arrayWithObjects:studiengang.name, studiengang.abschluss, studiengang.erstesFachsemester.name, studiengang.cp, nil];
        NSArray *keys = [NSArray arrayWithObjects:kDEFAULTS_COURSE_OF_STUDY_NAME, kDEFAULTS_COURSE_OF_STUDY_DEGREE, kDEFAULTS_COURSE_OF_STUDY_FIST_SEMESTER, kDEFAULTS_COURSE_OF_STUDY_CP, nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [defaults setObject:dict forKey:kDEFAULTS_COURSE_OF_STUDY];
        [defaults synchronize];
        
        [[CoreDataDataManager sharedInstance] saveDatabase];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

//Jedes Mal wenn der Nutzer an den unteren Rand der Liste scrollt, werden 6 weitere temporäre Semester an die Liste angehängt.
//Dadurch ist unendliches Scrollen nach unten möglich.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height - 25.0) && scrollViewShouldScroll)
    {
        scrollViewShouldScroll = NO;
        NSMutableArray *nextSemesters = [NSMutableArray array];
        
        for (int i = 0; i < 6; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(semesters.count) inSection:0];
            [nextSemesters addObject:indexPath];
            [semesters addObject:[self previousSemesterStringFromSemesterString:[semesters lastObject]]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:nextSemesters withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewShouldScroll = YES;
}

#pragma mark - Compare Semesterstring with semester

- (NSComparisonResult)compareSemesterString:(NSString *)term withSemesterString:(NSString *)semester
{
    NSArray *splitA = [term componentsSeparatedByString:@" "];
    NSString *_a = [splitA objectAtIndex:1];
    NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
    
    NSArray *splitB = [semester componentsSeparatedByString:@" "];
    NSString *_b = [splitB objectAtIndex:1];
    NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
    
    if (splitA2.count == 2)
    {
        if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:1] intValue] < [[splitB2 objectAtIndex:1] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:1] intValue] == [[splitB2 objectAtIndex:1] intValue])
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
