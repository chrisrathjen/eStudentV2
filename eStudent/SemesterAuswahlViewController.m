//
//  SemesterAuswahlViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 13.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "SemesterAuswahlViewController.h"
#import "CoreDataDataManager.h"
#import "Semester.h"
#import "NeuerEintragViewController.h"
#import "ManuelleVeranstaltungViewController.h"

@interface SemesterAuswahlViewController ()
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIBarButtonItem *fertigButton;
    __weak IBOutlet UINavigationBar *navigationBar;
    
    NSMutableArray *semesters;
    NSMutableArray *tmpSemesters;
    BOOL scrollViewShouldScroll;
}

- (IBAction)fertigButtonPressed:(id)sender;
- (NSString *)nextSemesterStringFromSemesterString:(NSString *)semesterstring;

@end

@implementation SemesterAuswahlViewController

@synthesize chosenSemester;
@synthesize studiengang;
@synthesize semesterString = _semesterString;

//Lädt die bereits gespeicherten Semester über den Datenmanager und bereite das UI vor.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    navigationBar.topItem.title = NSLocalizedString(@"Wähle Semester", @"Wähle Semester");
    fertigButton.title = NSLocalizedString(@"Fertig", @"Fertig");
    _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    if (!semesters) //Die gespeicherten Semester werden geladen und sortiert.
    {
        semesters = [[CoreDataDataManager sharedInstance] getAllSemesters].mutableCopy;
        if (studiengang)
        {
            NSMutableArray *tmpSem = semesters.copy;
            Semester *erstesSemester = studiengang.erstesFachsemester;
            for (Semester *s in tmpSem)
            {
                if ([[CoreDataDataManager sharedInstance] compareSemester:erstesSemester withSemester:s] == NSOrderedDescending)
                {
                    [semesters removeObject:s];
                }
                else
                {
                    break;
                }
            }
        }
    }
    if (!tmpSemesters) //In tmpSemesters werden temporäre, zukünftige Semester gespeichert, die noch nicht in die Datenbank gespeichert werden sollen. Sie sollen dem Nutzer lediglich als Auswahl dienen.
    {
        tmpSemesters = [NSMutableArray array];
    }
    [tmpSemesters addObject:[self nextSemesterStringFromSemesterString:((Semester *)[semesters lastObject]).name]];
    
    
    if (semesters.count >= 8) //Mindestens 11 Semester sollen dem Nutzer am Anfang zur Auswahl stehen.
    {
        for (int i = 0; i < 3; i++)
        {
            [tmpSemesters addObject:[self nextSemesterStringFromSemesterString:[tmpSemesters lastObject]]];
        }
    }
    else
    {
        for (int i = 0; i < (11 - semesters.count); i++)
        {
            [tmpSemesters addObject:[self nextSemesterStringFromSemesterString:[tmpSemesters lastObject]]];
        }
    }
}

#pragma mark - UIBarButtonItems pressed

//Wird der 'Fertig' Button betätigt, wird die Auswahl beendet.
- (IBAction)fertigButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return semesters.count + tmpSemesters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    if (indexPath.row < semesters.count)
    {
        NSString *cellTitle = ((Semester *)[semesters objectAtIndex:indexPath.row]).name;
        cell.textLabel.text = cellTitle;
    }
    else
    {
        cell.textLabel.text = [tmpSemesters objectAtIndex:(indexPath.row - semesters.count)];
    }
    
    if (chosenSemester)
    {
        if ([cell.textLabel.text isEqualToString:chosenSemester.name])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        if ([cell.textLabel.text isEqualToString:_semesterString])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    if ([cell.textLabel.text isEqualToString:[[CoreDataDataManager sharedInstance] getCurrentSemester].name])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %i. Fachsemester", NSLocalizedString(@"Aktuelles Semester", @"Aktuelles Semester"), indexPath.row+1, NSLocalizedString(@"Fachsemester", @"Fachsemester")];
        cell.detailTextLabel.textColor = kCUSTOM_BLUE_COLOR;
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i. Fachsemester", indexPath.row+1, NSLocalizedString(@"Fachsemester", @"Fachsemester")];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

//Tippt der Nutzer auf eine Zelle, wird das korrespondierende Semester für den Eintrag ausgewählt.
//Im Falle das ein tmpSemester gewählt wurde, werden vom jüngsten Semester bis hin zum gewählten Semester alle
//Semester in die Datenbank gespeichert.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTitle = cell.textLabel.text;
    
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]])
    {
        ((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).semester = cellTitle;
    }
    else
    {
        if (indexPath.row >= semesters.count) //es wurde auf eine Zelle getippt, für die die Semester noch nicht in der Datenbank existieren
        {
            int index = [tmpSemesters indexOfObject:cellTitle];
            for (int i = 0; i <= index; i++)
            {
                chosenSemester = [[CoreDataDataManager sharedInstance] createSemesterWithName:[tmpSemesters objectAtIndex:i]];
                [semesters addObject:chosenSemester];
            }
        }
        else
        {
            [[CoreDataDataManager sharedInstance] deleteAllEmptyFutureSemestersAfterIndex:indexPath.row];
            for (Semester *s in semesters)
            {
                if ([s.name isEqualToString:cellTitle])
                {
                    chosenSemester = s;
                }
            }
        }
        
        ((NeuerEintragViewController *)self.presentingViewController).semester = chosenSemester;
        [[CoreDataDataManager sharedInstance] saveDatabase];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Liefert von einem übergebenen Semester (als String) das folgende Semester als String

//Liefert zu einem Semesternamen das darauffolgende Semester als String.
- (NSString *)nextSemesterStringFromSemesterString:(NSString *)semesterstring
{
    NSMutableString *nextSemester = [NSMutableString string];
    
    NSArray *firstSplit = [semesterstring componentsSeparatedByString:@" "];
    if ([[firstSplit objectAtIndex:0] isEqualToString:@"WiSe"])
    {
        [nextSemester appendString:@"SoSe "];
    }
    else
    {
        [nextSemester appendString:@"WiSe "];
    }
    
    NSArray *secondSplit = [[firstSplit objectAtIndex:1] componentsSeparatedByString:@"/"];
    int i = [[secondSplit objectAtIndex:0] intValue];
    
    if (secondSplit.count == 1)
    {
        [nextSemester appendFormat:@"%i", i];
        int j = [[secondSplit objectAtIndex:0] intValue];
        [nextSemester appendFormat:@"/%i", (j%100)+1];
    }
    else
    {
        [nextSemester appendFormat:@"%i", i+1];
    }
    
    return [NSString stringWithString:nextSemester];
}

#pragma mark - UIScrollViewDelegate

//Jedes mal, wenn der Nutzer an den unteren Rand der Liste scrollt, werden 6 weitere temporäre Semester an die Liste angehängt.
//Somit kann der Nutzer unendlich weit nach unten scrollen.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_tableView.contentOffset.y >= (_tableView.contentSize.height - _tableView.bounds.size.height - 25.0) && scrollViewShouldScroll)
    {
        scrollViewShouldScroll = NO;
        NSMutableArray *nextSemesters = [NSMutableArray array];
        
        for (int i = 0; i < 6; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(semesters.count + tmpSemesters.count) inSection:0];
            [nextSemesters addObject:indexPath];
            [tmpSemesters addObject:[self nextSemesterStringFromSemesterString:[tmpSemesters lastObject]]];
        }
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:nextSemesters withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewShouldScroll = YES;
}

@end
