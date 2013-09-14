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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    navigationBar.topItem.title = NSLocalizedString(@"Wähle Semester", @"Wähle Semester");
    fertigButton.title = NSLocalizedString(@"Fertig", @"Fertig");
    _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    if (!semesters) //holt sich die gespeicherten Semester und sortiert diese
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
    if (!tmpSemesters)
    {
        tmpSemesters = [NSMutableArray array];
    }
    [tmpSemesters addObject:[self nextSemesterStringFromSemesterString:((Semester *)[semesters lastObject]).name]];
    
    
    if (semesters.count >= 8)
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtonItems pressed

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
    
    if ([cell.textLabel.text isEqualToString:chosenSemester.name])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTitle = cell.textLabel.text;
    
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
    
    [[CoreDataDataManager sharedInstance] saveDatabase];
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]])
    {
        ((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).semester = chosenSemester;
    }
    else
    {
        ((NeuerEintragViewController *)self.presentingViewController).semester = chosenSemester;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Liefert von einem übergebenen Semester (als String) das folgende Semester als String

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
