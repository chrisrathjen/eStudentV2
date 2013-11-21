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
#import "DateBlockViewController.h"
#import "TMPDateBlock.h"
#import "TMPDate.h"
#import <QuartzCore/QuartzCore.h>

@interface ManuelleVeranstaltungViewController ()
{
    NSMutableArray *_dozenten;
    NSMutableArray *_dateBlocks;
    NSArray *_studiengaenge;
    BOOL _mehrereStudiengaenge;
    BOOL _imStudiumsplaner;
    BOOL _imStundenplan;
    int _numberOfSectionsInTableView;
    UISwitch *_zumStudiumsplanerHinzufuegenSwitch;
    Studiengang *_selectedStudiengang;
    NSString *_veranstaltungsTitel;
    NSString *_veranstaltungsVAK;
    NSString *_veranstaltungsCP;
    UIBarButtonItem *_createButton;
    BOOL _shouldInsertNewDozent;
    UIButton *_deleteEintragButton;
    CAGradientLayer *_gradient;
    NSMutableString *_dozentText;
}

- (void)cancel:(id)sender;
- (void)createLecture:(id)sender;
- (void)checkUserInput;
- (NSComparisonResult)compareSemesterString:(NSString *)term withSemesterString:(NSString *)semester;
- (NSString *)nextSemesterStringFromSemesterString:(NSString *)semesterstring;
- (void)highlightButton:(id)sender;
- (void)removeHighlight:(id)sender;
- (void)deleteVeranstaltung:(id)sender;

@end

@implementation ManuelleVeranstaltungViewController

@synthesize veranstaltung =_veranstaltung;
@synthesize eintragsArtString = _eintragsArtString;
@synthesize semester = _semester;
@synthesize zumStundenplanHinzufuegenSwitch = _zumStundenplanHinzufuegenSwitch;
@synthesize inDenStundenplan = _inDenStundenplan;

- (void)setSemester:(NSString *)semester
{
    _semester = semester;
    _studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge].copy; //Lädt die bestehenden Studiengänge aus der Datenbank.
    if (_studiengaenge) //Muss kontrolliert werden, wenn das Semester festgelegt wurde
    {
        NSMutableArray *studiengaengeToShow = [NSMutableArray array];
        for (int i = 0; i < _studiengaenge.count; i++)
        {
            Studiengang *studiengang = [_studiengaenge objectAtIndex:i];
            NSComparisonResult comparisonResult = [self compareSemesterString:_semester withSemesterString:studiengang.erstesFachsemester.name];
            if (comparisonResult == NSOrderedSame || comparisonResult == NSOrderedDescending)
            {
                [studiengaengeToShow addObject:studiengang];
            }
        }
        _studiengaenge = nil;
        _studiengaenge = studiengaengeToShow.copy;
    }
}

//Lädt die Eingabemaske neu.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self];
    _numberOfSectionsInTableView = (_studiengaenge.count > 0 || _dateBlocks.count > 0) ? 4 : 3;
    if (_inDenStundenplan)
    {
        _inDenStundenplan = NO;
        _imStundenplan = YES;
    }
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Lädt die für die Eingabemaske benötigten Daten.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    
    _studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge].copy; //Lädt die bestehenden Studiengänge aus der Datenbank.
    _mehrereStudiengaenge = _studiengaenge.count > 1 ? YES : NO;
    if (_veranstaltung)
    {
        _createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Speichern", @"Speichern") style:UIBarButtonItemStyleBordered target:self action:@selector(createLecture:)];
        _eintragsArtString = _veranstaltung.type;
        _semester = _veranstaltung.course.semester.title;
        
        if (_studiengaenge) //Muss kontrolliert werden, wenn das Semester festgelegt wurde
        {
            NSMutableArray *studiengaengeToShow = [NSMutableArray array];
            for (int i = 0; i < _studiengaenge.count; i++)
            {
                Studiengang *studiengang = [_studiengaenge objectAtIndex:i];
                NSComparisonResult comparisonResult = [self compareSemesterString:_semester withSemesterString:studiengang.erstesFachsemester.name];
                if (comparisonResult == NSOrderedSame || comparisonResult == NSOrderedDescending)
                {
                    [studiengaengeToShow addObject:studiengang];
                }
            }
            _studiengaenge = nil;
            _studiengaenge = studiengaengeToShow.copy;
        }
        
        _veranstaltungsTitel = _veranstaltung.title;
        _veranstaltungsVAK = _veranstaltung.vak;
        _veranstaltungsCP = [_veranstaltung.cp stringValue];
        _createButton.enabled = YES;
        _dozenten = [NSMutableArray array];
        _dateBlocks = [[CoreDataDataManager sharedInstance] getTMPDateBlocksForLecture:_veranstaltung].mutableCopy;
        NSArray *dozenten = [[CoreDataDataManager sharedInstance] getLecturersForLecture:_veranstaltung];
        for (Lecturer *dozent in dozenten)
        {
            [_dozenten addObject:dozent.title];
        }
        _imStundenplan = [_veranstaltung.activeInSchedule boolValue];
        _imStudiumsplaner = _veranstaltung.eintrag ? YES : NO;
        _selectedStudiengang = _veranstaltung.eintrag.studiengang;
        
        
        _deleteEintragButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        _deleteEintragButton.backgroundColor = [UIColor redColor];
        _deleteEintragButton.layer.cornerRadius = 10.0;
        _deleteEintragButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_deleteEintragButton setTitle:NSLocalizedString(@"Veranstaltung löschen", @"Veranstaltung löschen") forState:UIControlStateNormal];
        [_deleteEintragButton setBackgroundColor:[UIColor redColor]];
        [_deleteEintragButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _gradient = [CAGradientLayer layer];
        _gradient.frame = _deleteEintragButton.bounds;
        _gradient.borderWidth = 1.0;
        _gradient.borderColor = [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1.0].CGColor;
        _gradient.cornerRadius = 10.0;
        _gradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.9 green:.4 blue:.4 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            nil];
        [_deleteEintragButton.layer insertSublayer:_gradient atIndex:0];
        
        [_deleteEintragButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [_deleteEintragButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
        [_deleteEintragButton addTarget:self action:@selector(deleteVeranstaltung:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 54.0)];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:_deleteEintragButton];
        self.tableView.tableFooterView = view;
    }
    else
    {
        _createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Anlegen", @"Anlegen") style:UIBarButtonItemStyleBordered target:self action:@selector(createLecture:)];
        _eintragsArtString = [[[NSUserDefaults standardUserDefaults] arrayForKey:kDEFAULTS_ENTRY_TYPES] objectAtIndex:0];
        _semester = [[CoreDataDataManager sharedInstance] getCurrentSemester].name;
        _createButton.enabled = NO;
        _dozenten = [NSMutableArray array];
        _dateBlocks = [NSMutableArray array];
    }
    
    _numberOfSectionsInTableView = (_studiengaenge.count > 0 || _dateBlocks.count > 0) ? 4 : 3;
    
    self.navigationItem.rightBarButtonItem = _createButton;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIBarButtonItems

//Bricht das Anlegen/Bearbeiten einer manuellen Veranstaltung ab.
- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Legt die Veranstaltung anhand der Daten der Eingabemaske an.
- (void)createLecture:(id)sender
{
    if (_veranstaltung)
    {
        if (_dozentText.length > 0)
        {
            [_dozenten addObject:_dozentText];
        }
        _veranstaltung = [[CoreDataDataManager sharedInstance] updateUserCreatedLecture:_veranstaltung title:_veranstaltungsTitel type:_eintragsArtString cp:[NSNumber numberWithInt:[_veranstaltungsCP intValue]] vak:_veranstaltungsVAK isInSchedule:_imStundenplan tmpDateBlocks:_dateBlocks lecturer:_dozenten inSemester:_semester];
        if (_imStudiumsplaner)
        {
            if (!(_veranstaltung.eintrag))
            {
                NSArray *semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
                Semester *lastSemester = [semesters lastObject];
                if ([self compareSemesterString:_semester withSemesterString:lastSemester.name] != NSOrderedDescending)
                {
                    Semester *semester;
                    for (Semester *s in semesters)
                    {
                        if ([s.name isEqualToString:_semester])
                        {
                            semester = s;
                            break;
                        }
                    }
                    [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:_selectedStudiengang inSemester:semester];
                }
                else
                {
                    NSString *nextSemester = [self nextSemesterStringFromSemesterString:lastSemester.name];
                    while ([self compareSemesterString:nextSemester withSemesterString:_semester] != NSOrderedDescending)
                    {
                        
                        lastSemester = [[CoreDataDataManager sharedInstance] createSemesterWithName:nextSemester];
                        nextSemester = [self nextSemesterStringFromSemesterString:lastSemester.name];
                    }
                    [[CoreDataDataManager sharedInstance] copyLecture:_veranstaltung intoStudiengang:_selectedStudiengang inSemester:lastSemester];
                }
            }
            else
            {
                _veranstaltung.eintrag.studiengang = _selectedStudiengang;
                _veranstaltung.eintrag.titel = _veranstaltungsTitel;
                _veranstaltung.eintrag.art = _eintragsArtString;
                _veranstaltung.eintrag.cp = [NSNumber numberWithInt:[_veranstaltungsCP intValue]];
                NSArray *semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
                Semester *semester;
                for (Semester *s in semesters)
                {
                    if ([s.name isEqualToString:_semester])
                    {
                        semester = s;
                        break;
                    }
                }
                _veranstaltung.eintrag.semester = semester;
            }
        }
        else
        {
            if (_veranstaltung.eintrag)
            {
                [[CoreDataDataManager sharedInstance] deleteEintrag:_veranstaltung.eintrag];
            }
        }
        
        NSArray *allSemesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
        Semester *currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
        for (int i = allSemesters.count-1; i >= 0; i--)
        {
            Semester *s = [allSemesters objectAtIndex:i];
            if ([self compareSemesterString:currentSemester.name withSemesterString:s.name] != NSOrderedDescending)
            {
                if (s.kurse.count == 0)
                {
                    [[CoreDataDataManager sharedInstance] deleteSemester:s];
                }
            }
            else
            {
                break;
            }
        }
    }
    else
    {
        if (_dozentText.length > 0)
        {
            [_dozenten addObject:_dozentText];
        }
        Lecture *lecture = [[CoreDataDataManager sharedInstance] createUserCreatedLectureWithTitle:_veranstaltungsTitel type:_eintragsArtString cp:[NSNumber numberWithInt:[_veranstaltungsCP intValue]] vak:_veranstaltungsVAK isInSchedule:_imStundenplan tmpDateBlocks:_dateBlocks lecturer:_dozenten inSemester:_semester.copy];
        
        if (_imStudiumsplaner)
        {
            NSArray *semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
            Semester *lastSemester = [semesters lastObject];
            if ([self compareSemesterString:_semester withSemesterString:lastSemester.name] != NSOrderedDescending)
            {
                Semester *semester;
                for (Semester *s in semesters)
                {
                    if ([s.name isEqualToString:_semester])
                    {
                        semester = s;
                    }
                }
                [[CoreDataDataManager sharedInstance] copyLecture:lecture intoStudiengang:_selectedStudiengang inSemester:semester];
            }
            else
            {
                while ([self compareSemesterString:[self nextSemesterStringFromSemesterString:lastSemester.name] withSemesterString:_semester] != NSOrderedDescending)
                {
                    lastSemester = [[CoreDataDataManager sharedInstance] createSemesterWithName:[self nextSemesterStringFromSemesterString:lastSemester.name]];
                }
                [[CoreDataDataManager sharedInstance] copyLecture:lecture intoStudiengang:_selectedStudiengang inSemester:lastSemester];
            }
        }
    }
    
    [[CoreDataDataManager sharedInstance] saveDatabase];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        if (_dateBlocks.count > 0)
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
        else
        {
            if (_studiengaenge.count > 0)
            {
                int count = 0;
                if (_mehrereStudiengaenge && _imStudiumsplaner)
                {
                    count = _studiengaenge.count;
                }
                return 1 + count;
            }
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        return NSLocalizedString(@"Die anlegbaren Termine sind abängig vom gewählten Semester.", @"Die anlegbaren Termine sind abängig vom gewählten Semester.");
    }
    return nil;
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
    static NSString *CellIdentifier = @"LectureCellStyleValue2";
    static NSString *CellIdentifier2 = @"LectureCellStyleSubtitle";
    static NSString *CellIdentifier3 = @"LectureCellStyleDefault";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    //else if (indexPath.section == 2)
    //{
     //   cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    //}
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
        else if (indexPath.section == 2)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
        }
    }
    cell.accessoryView = nil;
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
    if (indexPath.section == 1 && indexPath.row == _dozenten.count)
    {
        CGRect frame = txtField.frame;
        frame.origin.x = 20.0;
        frame.size.width = 270.0;
        txtField.frame = frame;
    }
    txtField.font = [UIFont boldSystemFontOfSize:15.0];
    txtField.textColor = [UIColor blackColor];
    txtField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    txtField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:txtField];
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    //cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    cell.textLabel.textColor = [UIColor colorWithRed:.0 green:.16 blue:.47 alpha:1.0];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.opaque = YES;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) //Veranstaltungsdaten
    {
        //cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
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
                cell.detailTextLabel.text = _semester;
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
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
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
                cell.textLabel.text = NSLocalizedString(@"DozentIn hinzufügen", @"DozentIn hinzufügen");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                cell.textLabel.text = NSLocalizedString(@"DozentIn hinzufügen", @"DozentIn hinzufügen");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    else if (indexPath.section == 2) //DateBlocks
    {
        if (indexPath.row < _dateBlocks.count)
        {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            TMPDateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
            NSString *dateRange = [db.repeatModifier intValue] == 0 ? [NSString stringWithFormat:@"am %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]] : [NSString stringWithFormat:@"vom %@ bis zum %@", [NSDateFormatter localizedStringFromDate:db.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle], [NSDateFormatter localizedStringFromDate:db.stopDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
            NSMutableString *wochentag = [[CoreDataDataManager sharedInstance] getLocalizedWeekDayForDate:db.startDate].mutableCopy;
            if ([db.repeatModifier intValue] > 0)
            {
                [wochentag appendString:@"s"];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ %@,\n%@", wochentag, db.startTime, db.stopTime, NSLocalizedString(@"Uhr", @"Uhr"), dateRange];
            if (db.room.length > 0)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Raum", @"Raum"), db.room];
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = NSLocalizedString(@"Termine hinzufügen", @"Termine hinzufügen");
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 3) //Veranstaltung eintragen
    {
        //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
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
            _zumStundenplanHinzufuegenSwitch.on = _imStundenplan;
            cell.accessoryView = _zumStundenplanHinzufuegenSwitch;
            
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
            _zumStudiumsplanerHinzufuegenSwitch.on = _imStudiumsplaner;
            cell.accessoryView = _zumStudiumsplanerHinzufuegenSwitch;
            
            cell.textLabel.text = NSLocalizedString(@"In den Studiumsplaner", @"In den Studiumsplaner");
        }
        else if (_imStudiumsplaner && _dateBlocks.count > 0 && indexPath.row >= 2) //Bei mehreren Studiengaengen, diese hier auflisten
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 2 && indexPath.row < _dateBlocks.count) || (indexPath.section == 1 && indexPath.row < _dozenten.count))
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [_dozenten removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else if (indexPath.section == 2)
    {
        [_dateBlocks removeObjectAtIndex:indexPath.row];
        _imStundenplan = _dateBlocks.count == 0 ? NO : YES;
        if (_dateBlocks.count > 0)
        {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
        else
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

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
    else if (indexPath.section == 2) //DateBlocks
    {
        if (indexPath.row < _dateBlocks.count)
        {
            DateBlock *db = [_dateBlocks objectAtIndex:indexPath.row];
            if (db.room.length > 0)
            {
                return [[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Raum", @"Raum"), db.room] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0] constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 60.0;
            }
            return 60.0;
        }
        return 44.0;
        
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

//Tippt der Nutzer auf eines der Felder, wird das entsprechende Feld aktiviert und lädt entweder einen Sub-Controller oder aktiviert das dazugehörige Textfeld für eine Nutzereingabe.
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
            savc.semesterString = _semester;
            savc.studiengang = _selectedStudiengang;
            [self presentViewController:savc animated:YES completion:nil];
        }
        else if (indexPath.row == 3) //Art auswaehlen
        {
            NSArray *strings = [_eintragsArtString componentsSeparatedByString:@" + "];
            
            ArtViewController *avc = [[ArtViewController alloc] initWithNibName:@"ArtViewController" bundle:nil];
            avc.selectedCells = strings.mutableCopy;
            [self presentViewController:avc animated:YES completion:nil];
        }
    }
    else if (indexPath.section == 1) //Dozenten
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
    else if (indexPath.section == 2) //Termin anlegen/bearbeiten
    {
        DateBlockViewController *dbvc = [[DateBlockViewController alloc] initWithNibName:@"DateBlockViewController" bundle:nil];
        dbvc.semester = _semester;
        if (indexPath.row < _dateBlocks.count)
        {
            dbvc.dateBlock = [_dateBlocks objectAtIndex:indexPath.row];
        }
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:dbvc];
        nc.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
        [self presentViewController:nc animated:YES completion:nil];
    }
    else if (indexPath.section == 3) //Hinzufügen
    {
        if (_dateBlocks.count > 0) //Das zum Stundenplan hinzufügen Feld wird auch angezeigt.
        {
            if (indexPath.row > 1)
            {
                _selectedStudiengang = [_studiengaenge objectAtIndex:indexPath.row-2];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else
        {
            if (indexPath.row > 0)
            {
                _selectedStudiengang = [_studiengaenge objectAtIndex:indexPath.row-1];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    
    [self.view endEditing:YES]; //resignsFirstResponder wenn eins der Textfelder firstResponder war
}

#pragma mark - UISwitch switched

//Die Veranstaltung soll in den Stundenplan eingetragen, bzw. wieder ausgetragen werden.
- (void)stundenplanSwitched:(UISwitch *)sender
{
    _imStundenplan = sender.on;
}

//Die Veranstaltung soll in den Studiumsplaner eingetragen, bzw. wieder ausgetragen werden.
//Bei mehreren Studiengängen wird intelligent, automatisch einer vorausgewählt, den der Nutzer selbst aber noch bestimmen kann.
- (void)studiumsplanerSwitched:(UISwitch *)sender
{
    _imStudiumsplaner = sender.on;
    _imStudiumsplaner = YES;
    _zumStudiumsplanerHinzufuegenSwitch.on = sender.on;
    if (sender.on)
    {
        if (!_mehrereStudiengaenge)
        {
            _selectedStudiengang = [_studiengaenge lastObject];
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
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.tableView endUpdates];
        }
    }
    else
    {
        _imStudiumsplaner = NO;
        _selectedStudiengang = nil;
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

#pragma mark - UITextFieldDelegate

//Reagiert auf die Return-Taste der Tastatur. Wird diese vom Nutzer gedrückt, während er den Namen eines Dozenten anlegt, wird der Dozent angelegt.
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
            _dozentText = nil;
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dozenten.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else
        {
            _shouldInsertNewDozent = NO;
            _dozentText = nil;
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
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ((indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4)) || (indexPath.section == 1 && indexPath.row == _dozenten.count))
    {
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
            [self checkUserInput];
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
    else if (indexPath.section == 1)
    {
        _dozentText = textfield.text.mutableCopy;
    }
}

//Wird aufgerufen wenn die Tastatur einfährt.
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

//Wird aufgerufen wenn die Tastatur wieder ausfährt.
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Check User Input

//Prüft sämtliche benötigten Felder und schaltet Button und andere Felder frei oder wieder ab.
- (void)checkUserInput
{
    if (_veranstaltungsTitel.length > 0)
    {
        [_createButton setEnabled:YES];
    }
    else
    {
        [_createButton setEnabled:NO];
    }
}

#pragma mark - DateBlocks angelegt/bearbeitet

- (void)addDates:(NSArray *)dates ToDateBlock:(TMPDateBlock *)dateBlock
{
    dateBlock.dates = dates.mutableCopy;
}

- (void)addDateBlock:(TMPDateBlock *)dateBlock
{
    [_dateBlocks addObject:dateBlock];
}

- (void)deleteDateBlock:(TMPDateBlock *)dateBlock
{
    [_dateBlocks removeObject:dateBlock];
    _imStundenplan = _dateBlocks.count == 0 ? NO : YES;
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

#pragma mark - Termine loeschen Button

//Highligted den Button zum Löschen eines Eintrags, wenn dieser betätigt wird.
- (void)highlightButton:(UIButton *)button
{
    CAGradientLayer *hoverGradient = [CAGradientLayer layer];
    hoverGradient.frame = _deleteEintragButton.bounds;
    hoverGradient.borderWidth = 1.0;
    hoverGradient.borderColor = [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1.0].CGColor;
    hoverGradient.cornerRadius = 10.0;
    hoverGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.9 green:.4 blue:.4 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1.0] CGColor],
                            nil];
    [button.layer insertSublayer:hoverGradient atIndex:1];
}

//Löscht das Highlight wieder.
- (void)removeHighlight:(UIButton *)button
{
    [[[button.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
}

//Der Nutzer tippt auf den 'Veranstaltung löschen' Button, dies muss erst vom Nutzer bestätigt werden.
- (void)deleteVeranstaltung:(id)sender
{
    NSString *message;
    if (_veranstaltung.eintrag || _veranstaltung.dates.count > 0)
    {
        message = NSLocalizedString(@"Die Veranstaltung wird ebenfalls aus dem Stundenplan und dem Studiumsplaner gelöscht. Fortfahren?", @"Die Veranstaltung wird ebenfalls aus dem Stundenplan und dem Studiumsplaner gelöscht. Fortfahren?");
    }
    else
    {
        message = NSLocalizedString(@"Bist du sicher?", @"Bist du sicher?");
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Veranstaltung löschen?", @"Veranstaltung löschen?") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") otherButtonTitles:NSLocalizedString(@"Löschen", @"Löschen"), nil];
    
    [alertView show];
    
}

#pragma mark - UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) //Loescht die Veranstaltung.
    {
        [[CoreDataDataManager sharedInstance] deleteLecture:_veranstaltung];
        [[CoreDataDataManager sharedInstance] saveDatabase];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else //Bricht den Loeschvorgang ab.
    {
        [self removeHighlight:_deleteEintragButton];
    }
}

@end
