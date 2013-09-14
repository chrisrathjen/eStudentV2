//
//  ManuelleVeranstaltungViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 04.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ManuelleVeranstaltungViewController.h"
#import "CoreDataDataManager.h"
#import "Studiengang.h"
#import "Semester.h"
#import "ArtViewController.h"
#import "SemesterAuswahlViewController.h"
#import "Course.h"

@interface ManuelleVeranstaltungViewController ()
{
    NSMutableArray *_dozenten;
    NSMutableArray *_dateBlocks;
    NSArray *_studiengaenge;
    BOOL _mehrereStudiengaenge;
    BOOL _imStudiumsplaner;
    int _numberOfSectionsInTableView;
    UISwitch *_zumStundenplanHinzufuegenSwitch;
    UISwitch *_zumStudiumsplanerHinzufuegenSwitch;
    Studiengang *_selectedStudiengang;
    NSString *_veranstaltungsTitel;
    NSString *_veranstaltungsVAK;
    NSString *_veranstaltungsCP;
    UIBarButtonItem *_createButton;
    BOOL _shouldInsertNewDozent;
}

- (void)cancel:(id)sender;
- (void)createLecture:(id)sender;

@end

@implementation ManuelleVeranstaltungViewController

@synthesize veranstaltung =_veranstaltung;
@synthesize eintragsArtString = _eintragsArtString;
@synthesize semester = _semester;

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Anlegen", @"Anlegen") style:UIBarButtonItemStyleBordered target:self action:@selector(createLecture:)];
    self.navigationItem.rightBarButtonItem = _createButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //    }
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    
    _studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge].copy;
    /*if (_studiengaenge) //Muss kontrolliert werden, wenn das Semester festgelegt wurde
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
    }*/
    _mehrereStudiengaenge = _studiengaenge.count > 1 ? YES : NO;
    _numberOfSectionsInTableView = 3;
    if (_veranstaltung)
    {
        _eintragsArtString = _veranstaltung.type;
        _semester = [[CoreDataDataManager sharedInstance] getSemesterForTerm:_veranstaltung.course.semester];
        _veranstaltungsTitel = _veranstaltung.title;
        _veranstaltungsVAK = _veranstaltung.vak;
        _veranstaltungsCP = [_veranstaltung.cp stringValue];
        _createButton.enabled = YES;
        _dozenten = [NSMutableArray array];
        NSArray *dozenten = [[CoreDataDataManager sharedInstance] getLecturersForLecture:_veranstaltung];
        for (Lecturer *dozent in dozenten)
        {
            [_dozenten addObject:dozent.title];
        }
    }
    else
    {
        _eintragsArtString = [[[NSUserDefaults standardUserDefaults] arrayForKey:kDEFAULTS_ENTRY_TYPES] objectAtIndex:0];
        _semester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
        _createButton.enabled = NO;
        _dozenten = [NSMutableArray array];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIBarButtonItems

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createLecture:(id)sender
{
    NSLog(@"Veranstaltung anlegen");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _numberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) //Details
    {
        return 5;
    }
    else if (section == 1) //Dozenten
    {
        return _shouldInsertNewDozent ? _dozenten.count + 2 : _dozenten.count + 1;
    }
    else if (section == 2) //Termine
    {
        return _dateBlocks.count + 1;
    }
    else //Eintragen
    {
        if (_studiengaenge.count > 0)
        {
            int count = 0;
            if (_mehrereStudiengaenge && _imStudiumsplaner)
            {
                count = _studiengaenge.count;
            }
            return 2 + count;
        }
        return 1;
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
    static NSString *CellIdentifier3 = @"CellStyleDefault";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    else if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
    }
    
    if (cell == nil)
    {
        if (indexPath.section == 0)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        }
        else if (indexPath.section == 2)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
        }
    }
    
    [[cell.contentView.subviews lastObject] removeFromSuperview];
    UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
    if (indexPath.section == 1 && indexPath.row == _dozenten.count)
    {
        CGRect frame = txtField.frame;
        frame.origin.x = 20.0;
        frame.size.width = 270.0;
        txtField.frame = frame;
    }
    txtField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    txtField.textColor = [UIColor blackColor];
    txtField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    txtField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:txtField];
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) //Veranstaltungsdaten
    {
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Titel", @"Titel");
                txtField.keyboardType = UIKeyboardTypeDefault;
                txtField.returnKeyType = UIReturnKeyDone;
                txtField.placeholder = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Z.B.", @"Z.B."), NSLocalizedString(@"Veranstaltungstitel", @"Veranstaltungstitel")];
                txtField.text = _veranstaltungsTitel;
                [cell.contentView addSubview:txtField];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"VAK", @"VAK");
                txtField.keyboardType = UIKeyboardTypeDefault;
                txtField.returnKeyType = UIReturnKeyDone;
                txtField.placeholder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Optional", @"Optional")];
                txtField.text = _veranstaltungsVAK;
                [cell.contentView addSubview:txtField];
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Semester", @"Semester");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = _semester.name;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Art", @"Art");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = _eintragsArtString;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"CP", @"CP");
                txtField.keyboardType = UIKeyboardTypeNumberPad;
                txtField.placeholder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Optional", @"Optional")]; //hier aus den UserDefaults die zuletzt eingetragenen CPs eintragen o.ä.
                txtField.text = _veranstaltungsCP;
                [cell.contentView addSubview:txtField];
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
        if (_shouldInsertNewDozent)
        {
            if (indexPath.row < _dozenten.count)
            {
                cell.textLabel.text = [_dozenten objectAtIndex:indexPath.row];
            }
            else if (indexPath.row == _dozenten.count)//Das Feld um einen neuen Dozenten anzulegen
            {
                txtField.placeholder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Name", @"Name")];
                txtField.returnKeyType = UIReturnKeyDone;
                [cell.contentView addSubview:txtField];
                //[txtField becomeFirstResponder];
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"DozentIn hinzufügen (optional)", @"DozentIn hinzufügen (optional)");
            }
        }
        else
        {
            if (indexPath.row < _dozenten.count)
            {
                cell.textLabel.text = [_dozenten objectAtIndex:indexPath.row];
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"DozentIn hinzufügen (optional)", @"DozentIn hinzufügen (optional)");
            }
        }
    }
    else if (indexPath.section == 2) //DateBlocks
    {
        if (indexPath.row == _dateBlocks.count)
        {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
            cell.textLabel.text = NSLocalizedString(@"Terminblock hinzufügen", @"Terminblock hinzufügen");
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
            NSString *dateRange = [db.repeatModifier intValue] == 0 ? [NSString stringWithFormat:@"am %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]] : [NSString stringWithFormat:@"vom %@ bis zum %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle], [NSDateFormatter localizedStringFromDate:db.stopDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
            NSMutableString *wochentag = [[CoreDataDataManager sharedInstance] getLocalizedWeekDayForDate:db.startDate].mutableCopy;
            if ([db.repeatModifier intValue] > 0)
            {
                [wochentag appendString:@"s"];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ %@,\n%@", wochentag, db.startTime, db.stopTime, NSLocalizedString(@"Uhr", @"Uhr"), dateRange];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Raum", @"Raum"), db.room];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 3) //Veranstaltung eintragen
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
            _zumStudiumsplanerHinzufuegenSwitch.on = _imStudiumsplaner;
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
            cell.textLabel.text = NSLocalizedString(@"In den Studiumsplaner", @"In den Studiumsplaner");
        }
        else if (_imStudiumsplaner && _dateBlocks.count > 0 && indexPath.row >= 2) //Bei mehreren Studiengaengen, diese hier auflisten
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
    if (indexPath.section == 1) //Dozenten
    {
        if (indexPath.row >= _dozenten.count)
        {
            return 44.0;
        }
        return [[_dozenten objectAtIndex:indexPath.row] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] constrainedToSize:CGSizeMake(300.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == _dateBlocks.count)
        {
            return 44.0;
        }
        DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
        return [[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Raum", @"Raum"), db.room] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0] constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 50.0;
    }
    else if (indexPath.section == 3 && _imStudiumsplaner && _mehrereStudiengaenge)
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4)
        {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [[[[cell contentView] subviews] lastObject] becomeFirstResponder];
        }
        else if (indexPath.row == 2) //Semester
        {
            SemesterAuswahlViewController *savc = [[SemesterAuswahlViewController alloc] initWithNibName:@"SemesterAuswahlViewController" bundle:nil];
            savc.chosenSemester = _semester;
            [self presentViewController:savc animated:YES completion:nil];
        }
        else if (indexPath.row == 3) //Semester auswaehlen
        {
            NSArray *strings = [_eintragsArtString componentsSeparatedByString:@" + "];
            
            ArtViewController *avc = [[ArtViewController alloc] initWithNibName:@"ArtViewController" bundle:nil];
            avc.selectedCells = strings.mutableCopy;
            [self presentViewController:avc animated:YES completion:nil];
        }
    }
    else if (indexPath.section == 1)
    {
        if (!_shouldInsertNewDozent && indexPath.row == _dozenten.count)
        {
            _shouldInsertNewDozent = YES;
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dozenten.count inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textfield = [cell.contentView.subviews lastObject];
        [textfield becomeFirstResponder];
        return;
    }
    
    [self.view endEditing:YES]; //resignsFirstResponder wenn eins der Textfelder firstResponder war
}

#pragma mark - UISwitch switched

- (void)stundenplanSwitched:(UISwitch *)sender
{
    if (sender.on)
    {
        [[CoreDataDataManager sharedInstance] addDateBlocksToSchedule:_dateBlocks];
    }
    else
    {
        [[CoreDataDataManager sharedInstance] removeLectureFromSchedule:_veranstaltung];
    }
}

- (void)studiumsplanerSwitched:(UISwitch *)sender
{
    if (sender.on)
    {
        _imStudiumsplaner = YES;
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
        
        if (!_mehrereStudiengaenge)
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
        _imStudiumsplaner = NO;
        _selectedStudiengang = nil;
        [[CoreDataDataManager sharedInstance] deleteEintragForLecture:_veranstaltung];
        if (_mehrereStudiengaenge)
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
}

#pragma mark - nextSemesterStringFromSemesterString

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 1 && indexPath.row == _dozenten.count)
    {
        if (textField.text.length > 0)
        {
            [_dozenten addObject:textField.text];
            _shouldInsertNewDozent = NO;
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dozenten.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else
        {
            _shouldInsertNewDozent = NO;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dozenten.count inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ((indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4)) || (indexPath.section == 1 && indexPath.row == _dozenten.count))
    {
        NSLog(@"indexPath.row: %i", indexPath.row);
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

#pragma mark - NotificationCenter

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    UITableViewCell *cell = (UITableViewCell *)textfield.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            _veranstaltungsTitel = textfield.text;
        }
        else if (indexPath.row == 1)
        {
            _veranstaltungsVAK = textfield.text;
        }
        else if (indexPath.row == 4)
        {
            _veranstaltungsCP = textfield.text;
        }
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dozenten.count inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *textfield = [cell.contentView.subviews lastObject];
    if ([textfield isFirstResponder])
    {
        [self.tableView beginUpdates];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        [self.tableView endUpdates];
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textfield = [cell.contentView.subviews lastObject];
        if ([textfield isFirstResponder])
        {
            [self.tableView beginUpdates];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            [self.tableView endUpdates];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

@end
