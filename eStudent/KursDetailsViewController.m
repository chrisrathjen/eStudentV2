//
//  KursDetailsViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 16.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "KursDetailsViewController.h"
#import "CoreDataDataManager.h"
#import "Lecturer.h"
#import "Term.h"
#import "DateBlock.h"
#import "Studiengang.h"
#import "Eintrag.h"

@interface KursDetailsViewController ()
{
    NSArray *_dozenten;
    NSArray *_dateBlocks;
    NSMutableArray *_dateBlocksZumEintragen;
    NSArray *_studiengaenge;
    UISwitch *_zumStundenplanHinzufuegenSwitch;
    UISwitch *_zumStudiumsplanerHinzufuegenSwitch;
    BOOL imStudiumsplaner;
    BOOL mehrereStudiengaenge;
    Studiengang *_selectedStudiengang;
}

- (void)stundenplanSwitched:(UISwitch *)sender;
- (void)studiumsplanerSwitched:(UISwitch *)sender;

@end

@implementation KursDetailsViewController

@synthesize veranstaltung = _veranstaltung;

//Lädt über den Datenmanager die entsprechenden Details einer Veranstaltung.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dozenten = [[CoreDataDataManager sharedInstance] getLecturersForLecture:_veranstaltung];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    self.navigationItem.title = NSLocalizedString(@"Details", @"Details");
    
    _dateBlocks = [[CoreDataDataManager sharedInstance] getDateBlocksForLecture:_veranstaltung].copy;
    _dateBlocksZumEintragen = _dateBlocks.mutableCopy;
    if ([_veranstaltung.activeInSchedule boolValue])
    {
        NSMutableArray *toDelete = [NSMutableArray array];
        for (DateBlock *d in _dateBlocksZumEintragen)
        {
            if (![[CoreDataDataManager sharedInstance] DateBlockInSchedule:d])
            {
                [toDelete addObject:d];
            }
        }   
        [_dateBlocksZumEintragen removeObjectsInArray:toDelete];
    }
    Eintrag *eintrag = [[CoreDataDataManager sharedInstance] getEintragForLecture:_veranstaltung];
    if (eintrag)
    {
        imStudiumsplaner = YES;
        _selectedStudiengang = eintrag.studiengang;
    }
    else
    {
        imStudiumsplaner = NO;
    }
    
    _studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge].copy;
    if (_studiengaenge)
    {
        NSMutableArray *studiengaengeToShow = [NSMutableArray array];
        for (int i = 0; i < _studiengaenge.count; i++)
        {
            Studiengang *studiengang = [_studiengaenge objectAtIndex:i];
            NSComparisonResult comparisonResult = [[CoreDataDataManager sharedInstance] compareTerm:_veranstaltung.course.semester withSemester:studiengang.erstesFachsemester];
            if (comparisonResult == NSOrderedSame || comparisonResult == NSOrderedDescending)
            {
                [studiengaengeToShow addObject:studiengang];
            }
        }
        _studiengaenge = nil;
        _studiengaenge = studiengaengeToShow.copy;
    }
    mehrereStudiengaenge = _studiengaenge.count > 1 ? YES : NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = 3;
    if (_dateBlocks.count > 0)
    {
        count++;
    }
    if (count == 3 && _studiengaenge.count > 0)
    {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) //Details
    {
        return 5;
    }
    else if (section == 1) //Dozenten
    {
        return _dozenten.count;
    }
    else if (section == 2) //Termine
    {
        return _dateBlocks.count > 0 ? _dateBlocks.count : 1;
    }
    else //Eintragen
    {
        if (_dateBlocks.count > 0)
        {
            if (_studiengaenge.count > 0)
            {
                int count = 0;
                if (mehrereStudiengaenge && imStudiumsplaner)
                {
                    count = _studiengaenge.count;
                }
                return 2 + count;
            }
            return 1;
        }
        else
        {
            if (_studiengaenge.count > 0)
            {
                int count = 0;
                if (mehrereStudiengaenge && imStudiumsplaner)
                {
                    count = _studiengaenge.count;
                }
                return 1 + count;
            }
            return 0;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"Veranstaltungsdaten", @"Veranstaltungsdaten");
            break;
        case 1:
            return _dozenten.count > 1 ? NSLocalizedString(@"DozentInnen", @"DozentInnen") : NSLocalizedString(@"DozentIn", @"DozentIn");
            break;
        case 2:
            return NSLocalizedString(@"Termine", @"Termine");
            break;
        case 3:
            return NSLocalizedString(@"Veranstaltung eintragen", @"Veranstaltung eintragen");
            break;
        default:
            break;
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellStyleValue2";
    static NSString *CellIdentifier2 = @"CellStyleSubtitle";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    }
    
    if (cell == nil)
    {
        if (indexPath.section == 0)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2];
        }
    }
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.opaque = YES;
    
    if (indexPath.section != 3 && [cell.contentView.subviews containsObject:_zumStundenplanHinzufuegenSwitch])
    {
        [_zumStundenplanHinzufuegenSwitch removeFromSuperview];
    }
    else if (indexPath.section != 3 && [cell.contentView.subviews containsObject:_zumStudiumsplanerHinzufuegenSwitch])
    {
        [_zumStudiumsplanerHinzufuegenSwitch removeFromSuperview];
    }
    
    if (indexPath.section == 0) //Veranstaltungsdaten
    {
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Titel", @"Titel");
                cell.detailTextLabel.text = _veranstaltung.title;
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"VAK", @"VAK");
                cell.detailTextLabel.text = _veranstaltung.vak;
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Semester", @"Semester");
                cell.detailTextLabel.text = _veranstaltung.course.semester.title;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Art", @"Art");
                cell.detailTextLabel.text = _veranstaltung.type;
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"CP", @"CP");
                cell.detailTextLabel.text = [_veranstaltung.cp intValue] > 0 ? [_veranstaltung.cp stringValue] : @"--";
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1) //Dozenten
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = ((Lecturer *)[_dozenten objectAtIndex:indexPath.row]).title;
    }
    else if (indexPath.section == 2) //DateBlocks
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        if (_dateBlocks.count > 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
            if ([_dateBlocksZumEintragen containsObject:db])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            NSString *dateRange = [db.repeatModifier intValue] == 0 ? [NSString stringWithFormat:@"am %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]] : [NSString stringWithFormat:@"vom %@ bis zum %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle], [NSDateFormatter localizedStringFromDate:db.stopDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
            NSMutableString *wochentag = [[CoreDataDataManager sharedInstance] getLocalizedWeekDayForDate:db.startDate].mutableCopy;
            if ([db.repeatModifier intValue] > 0)
            {
                [wochentag appendString:@"s"];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ %@,\n%@", wochentag, db.startTime, db.stopTime, NSLocalizedString(@"Uhr", @"Uhr"), dateRange];
            if (db.room)
            {
                if (db.type)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@: %@", db.type, NSLocalizedString(@"Raum", @"Raum"), db.room];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Raum", @"Raum"), db.room];
                }
            }
            
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"Keine Termine vorhanden", @"Keine Termine vorhanden");
            cell.detailTextLabel.text = @"";
        }
    }
    else if (indexPath.section == 3)
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        if (indexPath.row == 0 && _dateBlocks.count > 0)//In den Stundenplan eintragen
        {
            if (!_zumStundenplanHinzufuegenSwitch)
            {
                _zumStundenplanHinzufuegenSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                if ([_zumStundenplanHinzufuegenSwitch respondsToSelector:@selector(setOnImage:)])
                {
                    _zumStundenplanHinzufuegenSwitch.onImage = [UIImage imageNamed:@"checkmark_switch"];
                }
            }
            [_zumStundenplanHinzufuegenSwitch addTarget:self action:@selector(stundenplanSwitched:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:_zumStundenplanHinzufuegenSwitch];
            CGRect frame = _zumStundenplanHinzufuegenSwitch.frame;
            frame.origin.y = 8.0;
            frame.origin.x = cell.frame.size.width - (frame.size.width + 25.0);
            _zumStundenplanHinzufuegenSwitch.frame = frame;
            _zumStundenplanHinzufuegenSwitch.on = [_veranstaltung.activeInSchedule boolValue];
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
            cell.textLabel.text = NSLocalizedString(@"In den Stundenplan", @"In den Stundenplan");
        }
        else if ((indexPath.row == 0 && _dateBlocks.count == 0) || (indexPath.row == 1 && _dateBlocks.count > 0)) //In den Studiumsplaner eintragen
        {
            if (!_zumStudiumsplanerHinzufuegenSwitch)
            {
                _zumStudiumsplanerHinzufuegenSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                if ([_zumStudiumsplanerHinzufuegenSwitch respondsToSelector:@selector(setOnImage:)])
                {
                    _zumStudiumsplanerHinzufuegenSwitch.onImage = [UIImage imageNamed:@"checkmark_switch"];
                }
            }
            [_zumStudiumsplanerHinzufuegenSwitch addTarget:self action:@selector(studiumsplanerSwitched:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:_zumStudiumsplanerHinzufuegenSwitch];
            CGRect frame = _zumStudiumsplanerHinzufuegenSwitch.frame;
            frame.origin.y = 8.0;
            frame.origin.x = cell.frame.size.width - (frame.size.width + 25.0);
            _zumStudiumsplanerHinzufuegenSwitch.frame = frame;
            _zumStudiumsplanerHinzufuegenSwitch.on = imStudiumsplaner;
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];            
            cell.textLabel.text = NSLocalizedString(@"In den Studiumsplaner", @"In den Studiumsplaner");
        }
        else if (imStudiumsplaner && _dateBlocks.count > 0 && indexPath.row >= 2) //Bei mehreren Studiengaengen, diese hier auflisten
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = [UIColor colorWithRed:.0 green:.16 blue:.47 alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:.98 green:.98 blue:.98 alpha:1.0];
            
            Studiengang *studiengang = [_studiengaenge objectAtIndex:indexPath.row-2];
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss];
            cell.detailTextLabel.text = @"";
            if ([studiengang isEqual:_selectedStudiengang])
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
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = [UIColor colorWithRed:.0 green:.16 blue:.47 alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:.98 green:.98 blue:.98 alpha:1.0];
            
            Studiengang *studiengang = [_studiengaenge objectAtIndex:indexPath.row-1];
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss];
            cell.detailTextLabel.text = @"";
            if ([studiengang isEqual:_selectedStudiengang])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return [_veranstaltung.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] constrainedToSize:CGSizeMake(200.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
        }
    }
    else if (indexPath.section == 1)
    {
        return [((Lecturer *)[_dozenten objectAtIndex:indexPath.row]).title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] constrainedToSize:CGSizeMake(300.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
    }
    else if (indexPath.section == 2) //DateBlocks
    {
        if (_dateBlocks.count > 0)
        {
            DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
            return [[NSString stringWithFormat:@"%@: %@, %@", db.type, NSLocalizedString(@"Raum", @"Raum"), db.room] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0] constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 50.0;
        }
        return 44.0;
    }
    else if (indexPath.section == 3 && imStudiumsplaner && mehrereStudiengaenge)
    {
        if (_dateBlocks.count > 0)
        {
            if (indexPath.row >= 2)
            {
                Studiengang *studiengang = [_studiengaenge objectAtIndex:indexPath.row-2];
                return [[NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] constrainedToSize:CGSizeMake(300.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
            }
        }
        else
        {
            if (indexPath.row >= 1)
            {
                Studiengang *studiengang = [_studiengaenge objectAtIndex:indexPath.row-1];
                return [[NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] constrainedToSize:CGSizeMake(300.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
            }
        }
    }
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && _dateBlocks.count > 0) //Termine wurden an- oder abgewaehlt
    {
        DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
        if ([_dateBlocksZumEintragen containsObject:db] && _dateBlocksZumEintragen.count > 1)
        {
            [_dateBlocksZumEintragen removeObject:db];
            if ([_veranstaltung.activeInSchedule boolValue])
            {
                [[CoreDataDataManager sharedInstance] removeDateBlocksFromSchedule:[NSArray arrayWithObject:db]];
            }
        }
        else
        {
            if (![_dateBlocksZumEintragen containsObject:db])
            {
                [_dateBlocksZumEintragen addObject:db];
            }
            if ([_veranstaltung.activeInSchedule boolValue])
            {
                [[CoreDataDataManager sharedInstance] addDateBlocksToSchedule:[NSArray arrayWithObject:db]];
            }
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (indexPath.section == 3 && mehrereStudiengaenge) //Der Studiengang, in den die Veranstaltung eingetragen wird, wird gewechselt
    {
        if (_dateBlocks.count > 0)
        {
            if (indexPath.row > 1)
            {
                Studiengang *selectedStudiengang = ((Studiengang *)[_studiengaenge objectAtIndex:indexPath.row-2]);
                if ([selectedStudiengang isEqual:_selectedStudiengang])
                {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    return;
                }
                else
                {
                    BOOL success = [[CoreDataDataManager sharedInstance] deleteEintragForLecture:_veranstaltung];
                    if (success)
                    {
                        Semester *semester = [[CoreDataDataManager sharedInstance] createSemesterWithName:_veranstaltung.course.semester.title];
                        [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:selectedStudiengang inSemester:semester];
                        int index = [_studiengaenge indexOfObject:_selectedStudiengang];
                        _selectedStudiengang = selectedStudiengang;
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForRow:(index+2) inSection:3], nil] withRowAnimation:UITableViewRowAnimationNone];
                        [[CoreDataDataManager sharedInstance] saveDatabase];
                    }
                }
            }
        }
        else
        {
            if (indexPath.row > 0)
            {
                Studiengang *selectedStudiengang = ((Studiengang *)[_studiengaenge objectAtIndex:indexPath.row-1]);
                if ([selectedStudiengang isEqual:_selectedStudiengang])
                {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    return;
                }
                else
                {
                    BOOL success = [[CoreDataDataManager sharedInstance] deleteEintragForLecture:_veranstaltung];
                    if (success)
                    {
                        Semester *semester = [[CoreDataDataManager sharedInstance] createSemesterWithName:_veranstaltung.course.semester.title];
                        [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:selectedStudiengang inSemester:semester];
                        int index = [_studiengaenge indexOfObject:_selectedStudiengang];
                        _selectedStudiengang = selectedStudiengang;
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForRow:(index+1) inSection:3], nil] withRowAnimation:UITableViewRowAnimationNone];
                        [[CoreDataDataManager sharedInstance] saveDatabase];
                    }
                }
            }
        }
    }
}

#pragma mark - UISwitch switched

//Trägt die Veranstaltug in den Stundenplan ein, bzw. wieder aus.
- (void)stundenplanSwitched:(UISwitch *)sender
{
    if (sender.on)
    {
        [[CoreDataDataManager sharedInstance] addDateBlocksToSchedule:_dateBlocksZumEintragen];
    }
    else
    {
        NSString *message  = NSLocalizedString(@"Bist du sicher?", @"Bist du sicher?");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Aus dem Stundenplan austragen?", @"Aus dem Stundenplan austragen?") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") otherButtonTitles:NSLocalizedString(@"Austragen", @"Austragen"), nil];
        
        alertView.tag = 2;
        [alertView show];
    }
}

//Die Veranstaltung soll in den Studiumsplaner eingetragen, bzw. wieder ausgetragen werden.
//Bei mehreren Studiengängen wird intelligent, automatisch einer vorausgewählt, den der Nutzer selbst aber noch bestimmen kann.
- (void)studiumsplanerSwitched:(UISwitch *)sender
{
    if (sender.on)
    {
        imStudiumsplaner = YES;
        Semester *semester;
        NSString *semesterTitleToCheck = _veranstaltung.course.semester.title;
        NSArray *semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
        for (Semester *s in semesters)
        {
            if ([s.name isEqualToString:semesterTitleToCheck])
            {
                semester = s;
                break;
            }
        }
        if (!semester)
        {
            NSString *newSemsterString = [self nextSemesterStringFromSemesterString:((Semester *)[semesters lastObject]).name];
            while (![semesterTitleToCheck isEqualToString:newSemsterString])
            {
                [[CoreDataDataManager sharedInstance] createSemesterWithName:newSemsterString];
                newSemsterString = [self nextSemesterStringFromSemesterString:newSemsterString];
            }
            semester = [[CoreDataDataManager sharedInstance] createSemesterWithName:newSemsterString];
        }
        
        if (!mehrereStudiengaenge)
        {
            [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:[_studiengaenge lastObject] inSemester:semester];
        }
        else //Mehrere Studiengaenge existieren
        {
            Studiengang *selectedStudiengang = [_studiengaenge lastObject];
            for (Studiengang *studiengang in _studiengaenge)
            {
                NSRange textRange = [[_veranstaltung.course.title lowercaseString] rangeOfString:[studiengang.name lowercaseString]];
                if(textRange.location != NSNotFound)
                {
                    selectedStudiengang = studiengang;
                }
                    
            }
            [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:selectedStudiengang inSemester:semester];
            _selectedStudiengang = selectedStudiengang;
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0; i < _studiengaenge.count; i++)
            {
                if (_dateBlocks.count > 0)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i+2 inSection:3]];
                }
                else
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:3]];
                }
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    else
    {
        NSString *message  = NSLocalizedString(@"Bist du sicher?", @"Bist du sicher?");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Aus dem Studiumsplaner austragen?", @"Aus dem Studiumsplaner austragen?") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") otherButtonTitles:NSLocalizedString(@"Austragen", @"Austragen"), nil];
        
        alertView.tag = 1;
        [alertView show];
    }
}

#pragma mark - nextSemesterStringFromSemesterString

//Berechnet zu einem Semesternamen das darauffolgende Semester und liefert den Namen als String zurück.
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 1) //Aus dem Studiumsplaner austragen
    {
        imStudiumsplaner = NO;
        _selectedStudiengang = nil;
        [[CoreDataDataManager sharedInstance] deleteEintragForLecture:_veranstaltung];
        if (mehrereStudiengaenge)
        {
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0; i < _studiengaenge.count; i++)
            {
                if (_dateBlocks.count > 0)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i+2 inSection:3]];
                }
                else
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:3]];
                }
            }
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    else if (buttonIndex == 0 && alertView.tag == 1) //Aus dem Studiumsplaner austragen abbrechen
    {
        [_zumStudiumsplanerHinzufuegenSwitch setOn:YES animated:YES];
    }
    else if (buttonIndex == 1 && alertView.tag == 2) //Aus dem Stundenplan austragen
    {
        [[CoreDataDataManager sharedInstance] removeLectureFromSchedule:_veranstaltung];
    }
    else //Aus dem Stundenplan austragen abbrechen
    {
        [_zumStundenplanHinzufuegenSwitch setOn:YES animated:YES];
    }
}

@end
