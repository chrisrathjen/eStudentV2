//
//  DateBlockViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 07.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "DateBlockViewController.h"
#import "TMPDate.h"
#import "TMPDateBlock.h"
#import "ManuelleVeranstaltungViewController.h"

@interface DateBlockViewController ()
{
    NSMutableArray *_dates;
    NSMutableArray *_chosenDates;
    int _numberOfDates;
    int _indexOfSegmentedControl;
    NSDate *_date;
    NSDate *_semesterStart;
    NSDate *_semesterEnd;
    NSString *_startTime;
    NSString *_endTime;
    NSString *_room;
    UIActionSheet *_actionSheet;
    UIDatePicker *_datePicker;
    UIButton *_deleteEintragButton;
    CAGradientLayer *_gradient;
    UIActionSheet *actionSheet;
}

- (void)cancel:(id)sender;
- (void)saveDateBlock:(id)sender;
- (NSString *)formattedDateFromDate:(NSDate *)date;
- (NSString *)startTimeForDate:(NSDate *)date;
- (NSString *)stopTimeForDate:(NSDate *)date;
- (void)segmentedControlTapped:(UISegmentedControl *)sender;
- (void)stepperValueChanged:(UIStepper *)sender;
- (void)callStartTimePicker:(id)sender;
- (void)callEndTimePicker:(id)sender;
- (void)highlightButton:(id)sender;
- (void)removeHighlight:(id)sender;
- (void)deleteTermine:(id)sender;

@end

@implementation DateBlockViewController

@synthesize semester = _semester;

//Erzeugt die Termine in Abhängigkeit zum übergebenen Semester und dem aktuellen Datum.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    _dates = [NSMutableArray array];
    _chosenDates = [NSMutableArray array];
    
    if (_dateBlock)
    {
        self.navigationItem.title = NSLocalizedString(@"Termine Bearbeiten", @"Termine Bearbeiten");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Speichern", @"Speichern") style:UIBarButtonItemStyleBordered target:self action:@selector(saveDateBlock:)];
        _room = _dateBlock.room;
        
        TMPDate *date = [_dateBlock.dates objectAtIndex:0];
        _date = date.date;
        for (int i = 1; i < _dateBlock.dates.count; i++)
        {
            date = [_dateBlock.dates objectAtIndex:i];
            [_dates addObject:date.date];
            if ([date.active boolValue])
            {
                [_chosenDates addObject:date.date];
            }
        }
        _numberOfDates = _dateBlock.dates.count;
        _indexOfSegmentedControl = [_dateBlock.repeatModifier intValue];
        

        
        _deleteEintragButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        _deleteEintragButton.backgroundColor = [UIColor redColor];
        _deleteEintragButton.layer.cornerRadius = 10.0;
        _deleteEintragButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_deleteEintragButton setTitle:NSLocalizedString(@"Termine löschen", @"Termine löschen") forState:UIControlStateNormal];
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
        [_deleteEintragButton addTarget:self action:@selector(deleteTermine:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 54.0)];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:_deleteEintragButton];
        self.tableView.tableFooterView = view;
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Termine Anlegen", @"Termine Anlegen");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Anlegen", @"Anlegen") style:UIBarButtonItemStyleBordered target:self action:@selector(saveDateBlock:)];
        
        _date = [NSDate date];
        [_dates addObject:[self dateFromDate:_date ForDays:1]];
        [_dates addObject:[self dateFromDate:_date ForDays:2]];
        [_chosenDates addObject:[self dateFromDate:_date ForDays:1]];
        [_chosenDates addObject:[self dateFromDate:_date ForDays:2]];
        _numberOfDates = 3;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSArray *substring = [_semester componentsSeparatedByString:@" "];
    if ([[substring objectAtIndex:0] isEqualToString:@"WiSe"]) //Der Termin ist innerhalb eines Wintersemesters
    {
        NSArray *sub = [[substring lastObject] componentsSeparatedByString:@"/"];
        NSString *dateString = [dateFormatter stringFromDate:_date];
        NSDate *date = [dateFormatter dateFromString:dateString];
        _semesterStart = [dateFormatter dateFromString:[NSString stringWithFormat:@"01.10.%@", [sub objectAtIndex:0]]];
        _semesterEnd = [dateFormatter dateFromString:[NSString stringWithFormat:@"31.03.%i", [(NSString *)[sub objectAtIndex:0] intValue]+1]];
        if (!_dateBlock && !(([_semesterStart compare:date] == NSOrderedAscending || [_semesterStart compare:date] == NSOrderedSame) && ([_semesterEnd compare:date] == NSOrderedDescending || [_semesterEnd compare:date] == NSOrderedSame)))
        {
            _date = _semesterStart;
        }
    }
    else //Sommersemester
    {   
        NSArray *sub = [[substring lastObject] componentsSeparatedByString:@"/"];
        NSString *dateString = [dateFormatter stringFromDate:_date];
        NSDate *date = [dateFormatter dateFromString:dateString];
        _semesterStart = [dateFormatter dateFromString:[NSString stringWithFormat:@"01.04.%@", [sub objectAtIndex:0]]];
        _semesterEnd = [dateFormatter dateFromString:[NSString stringWithFormat:@"30.09.%@", [sub objectAtIndex:0]]];
        if (!_dateBlock && !(([_semesterStart compare:date] == NSOrderedAscending || [_semesterStart compare:date] == NSOrderedSame) && ([_semesterEnd compare:date] == NSOrderedDescending || [_semesterEnd compare:date] == NSOrderedSame)))
        {
            _date = _semesterStart;
        }
    }
    
    _startTime = [self startTimeForDate:_date];
    _endTime = [self stopTimeForDate:_date];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIBarButtonItems

//Bricht das Anlegen der Termine ab.
- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Speichert die Termine für eine manuelle Veranstaltung.
- (void)saveDateBlock:(id)sender
{
    if (_indexOfSegmentedControl == 0)
    {
        if (_dateBlock)
        {
            _dateBlock.startDate = _date;
            _dateBlock.stopDate = nil;
            _dateBlock.room = _room;
            _dateBlock.repeatModifier = [NSNumber numberWithInt:_indexOfSegmentedControl];
            _dateBlock.startTime = _startTime;
            _dateBlock.stopTime = _endTime;
            
            TMPDate *date = [[TMPDate alloc] init];
            date.date = _date;
            date.startTime = _startTime;
            date.stopTime = _endTime;
            date.active = [_chosenDates containsObject:_date] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDates:[NSArray arrayWithObject:date] ToDateBlock:_dateBlock];
            for (NSDate *d in _dates)
            {
                TMPDate *date = [[TMPDate alloc] init];
                date.date = d;
                date.startTime = _startTime;
                date.stopTime = _endTime;
                date.active = [_chosenDates containsObject:d] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
                
                [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDates:[NSArray arrayWithObject:date] ToDateBlock:_dateBlock];
            }
        }
        else
        {
            TMPDateBlock *dateBlock = [[TMPDateBlock alloc]initWithRepeatModifier:[NSNumber numberWithInt:_indexOfSegmentedControl] Room:_room StartDate:_date StartTime:_startTime StopDate:nil StopTime:_endTime];
            TMPDate *date = [[TMPDate alloc] init];
            date.date = _date;
            date.startTime = _startTime;
            date.stopTime = _endTime;
            date.active = [_chosenDates containsObject:_date] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            dateBlock.dates = [NSArray arrayWithObject:date].mutableCopy;
            [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDateBlock:dateBlock];
            
            for (NSDate *d in _dates)
            {
                TMPDateBlock *dateBlock = [[TMPDateBlock alloc]initWithRepeatModifier:[NSNumber numberWithInt:_indexOfSegmentedControl] Room:_room StartDate:d StartTime:_startTime StopDate:nil StopTime:_endTime];
                TMPDate *date = [[TMPDate alloc] init];
                date.date = d;
                date.startTime = _startTime;
                date.stopTime = _endTime;
                date.active = [_chosenDates containsObject:d] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
                dateBlock.dates = [NSArray arrayWithObject:date].mutableCopy;
                [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDateBlock:dateBlock];
            }
            
        }
    }
    else
    {
        if (_dateBlock)
        {
            _dateBlock.startDate = _date;
            _dateBlock.stopDate = [_dates lastObject];
            _dateBlock.room = _room;
            _dateBlock.repeatModifier = [NSNumber numberWithInt:_indexOfSegmentedControl];
            _dateBlock.startTime = _startTime;
            _dateBlock.stopTime = _endTime;
            
            TMPDate *date = [[TMPDate alloc] init];
            date.date = _date;
            date.startTime = _startTime;
            date.stopTime = _endTime;
            date.active = [_chosenDates containsObject:_date] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            NSMutableArray *dates = [NSMutableArray arrayWithCapacity:_dates.count+1];
            [dates addObject:date];
            for (NSDate *d in _dates)
            {
                TMPDate *date = [[TMPDate alloc] init];
                date.date = d;
                date.startTime = _startTime;
                date.stopTime = _endTime;
                date.active = [_chosenDates containsObject:d] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
                [dates addObject:date];
            }
            
            [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDates:dates ToDateBlock:_dateBlock];
        }
        else
        {
            TMPDateBlock *dateBlock = [[TMPDateBlock alloc]initWithRepeatModifier:[NSNumber numberWithInt:_indexOfSegmentedControl] Room:_room StartDate:_date StartTime:_startTime StopDate:(_dates.count > 0 ? [_dates lastObject] : nil) StopTime:_endTime];
            TMPDate *date = [[TMPDate alloc] init];
            date.date = _date;
            date.startTime = _startTime;
            date.stopTime = _endTime;
            date.active = [_chosenDates containsObject:_date] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            NSMutableArray *dates = [NSMutableArray arrayWithCapacity:_dates.count+1];
            [dates addObject:date];
            for (NSDate *d in _dates)
            {
                TMPDate *date = [[TMPDate alloc] init];
                date.date = d;
                date.startTime = _startTime;
                date.stopTime = _endTime;
                date.active = [_chosenDates containsObject:d] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
                [dates addObject:date];
            }
            
            dateBlock.dates = dates;
            
            [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) addDateBlock:dateBlock];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2 && _dates.count > 0)
    {
        return NSLocalizedString(@"Die Termine sind abängig vom gewählten Starttermin.", @"Die Termine sind abängig vom gewählten Starttermin.");
    }
    else if (section == 3)
    {
        return NSLocalizedString(@"Uhrzeit und Raum werden für sämtliche Termine gespeichert.", @"Uhrzeit und Raum werden für sämtliche Termine gespeichert.");
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return _dates.count;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TerminCellStyleValue2";
    static NSString *CellIdentifier2 = @"TerminCellStyleValue1";
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell == nil)
    {
        if (indexPath.section == 0 && indexPath.row == 1)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        }
    }
    [[cell.contentView.subviews lastObject] removeFromSuperview];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:.0 green:.16 blue:.47 alpha:1.0];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) //Auswahl ob es ein Einzeltermin, ein woechentlicher oder ein zweiwoechentlicher ist
        {
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Einzeltermine", @"Einzeltermine"), NSLocalizedString(@"Wöchentlich", @"Wöchentlich"), NSLocalizedString(@"Zweiwöchentlich", @"Zweiwöchentlich"), nil]];
            segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
            segmentedControl.selectedSegmentIndex = _indexOfSegmentedControl;
            segmentedControl.tintColor = kCUSTOM_BLUE_COLOR;
            CGRect frame = segmentedControl.frame;
            frame.size.width = 300.0;
            segmentedControl.frame = frame;
            [segmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:segmentedControl];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            // Hier muss der Counter hin, der hochzaehlt, wie viele Wochen angezeigt werden
            NSString *termine = _numberOfDates > 1 ? NSLocalizedString(@"Termine", @"Termine") : NSLocalizedString(@"Termin", @"Termin");
            cell.textLabel.text = [NSString stringWithFormat:@"%i %@", _numberOfDates, termine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
            stepper.value = _numberOfDates;
            stepper.minimumValue = 1;
            CGRect frame = stepper.frame;
            frame.origin.x = cell.frame.size.width - (frame.size.width + 30.0);
            frame.origin.y = 8.5;
            stepper.frame = frame;
            [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:stepper];
        }
    }
    else if (indexPath.section == 1) //Hier kommt der erste Termin bei einem Terminblock, bzw. das Datum bei einem Einzeltermin hin
    {
        cell.textLabel.text = NSLocalizedString(@"Starttermin", @"Starttermin");
        cell.detailTextLabel.text = [self formattedDateFromDate:_date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2)
    {
        int index = indexPath.row+2;
        NSDate *date = [_dates objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%i. %@", index, NSLocalizedString(@"Termin", @"Termin")];
        cell.detailTextLabel.text = [self formattedDateFromDate:date];
        if ([_chosenDates containsObject:date])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else //Beginn, Ende und Raum
    {
        if (indexPath.row == 0) //Beginn
        {
            cell.textLabel.text = NSLocalizedString(@"Beginn", @"Beginn");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", _startTime, NSLocalizedString(@"Uhr", @"Uhr")];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 1) //Ende
        {
            cell.textLabel.text = NSLocalizedString(@"Ende", @"Ende");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", _endTime, NSLocalizedString(@"Uhr", @"Uhr")];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else //Raum
        {
            cell.textLabel.text = NSLocalizedString(@"Raum", @"Raum");
            UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
            txtField.font = [UIFont boldSystemFontOfSize:15.0];
            txtField.textColor = [UIColor blackColor];
            txtField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            txtField.delegate = self;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textFieldChanged:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:txtField];
            txtField.text = _room;
            txtField.placeholder = NSLocalizedString(@"Gebäude und Raum", @"Gebäude und Raum");
            txtField.returnKeyType = UIReturnKeyDone;
            [cell.contentView addSubview:txtField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return 30.0;
    }
    return 44.0;
}

//Tippt der Nutzer auf das Start-Datum fährt ein DatePicker aus, über den der Nutzer das Start-Datum verändern kann.
//Tippt er auf 'Beginn' oder 'Ende' fährt ein Picker für die Uhrzeit aus, über den der Nutzer diese auswählen kann.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) //Das Start-Datum soll verändert werden.
    {
        [self callDatePicker:_datePicker];
    }
    else if (indexPath.section == 2) //Der Nutzer will einen Termin hinzufügen.
    {
        NSDate *date = [_dates objectAtIndex:indexPath.row];
        if ([_chosenDates containsObject:date])
        {
            [_chosenDates removeObject:date];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            [_chosenDates addObject:date];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if (indexPath.section == 3) //Eines der Felder, um die Uhrzeit zu ändern.
    {
        if (indexPath.row == 0)
        {
            [self callStartTimePicker:_datePicker];
        }
        else if (indexPath.row == 1)
        {
            [self callEndTimePicker:_datePicker];
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UITextField *textfield = [cell.contentView.subviews lastObject];
            if ([textfield isFirstResponder])
            {
                [textfield resignFirstResponder];
            }
            else
            {
                [textfield becomeFirstResponder];
            }
        }
    }
}

#pragma mark - Date and Time Formatting

//Formatiert ein übergebenes Datum zu einem brauchbaren Format.
- (NSString *)formattedDateFromDate:(NSDate *)date
{
    NSArray *weekdays = [NSArray arrayWithObjects:NSLocalizedString(@"Sonntag", @"Sonntag"), NSLocalizedString(@"Montag", @"Montag"), NSLocalizedString(@"Dienstag", @"Dienstag"), NSLocalizedString(@"Mittwoch", @"Mittwoch"), NSLocalizedString(@"Donnerstag", @"Donnerstag"), NSLocalizedString(@"Freitag", @"Freitag"), NSLocalizedString(@"Samstag", @"Samstag"), nil];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    NSString *weekday = [weekdays objectAtIndex:[components weekday]-1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]]; //hier auch noch die Identifier für andere Sprachen verfügbar machen
    return [NSString stringWithFormat:@"%@, %@", weekday, [dateFormatter stringFromDate:date]];
}

//Formatiert eine Uhrzeit aus einem übergebenen Datum - für das 'Beginn' Feld.
- (NSString *)startTimeForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:date];
    int hour = [components hour];
    if (hour <= 8)
    {
        return [NSString stringWithFormat:@"08:00"];
    }
    else if (hour == 9)
    {
        return [NSString stringWithFormat:@"09:00"];
    }
    else if (hour > 18)
    {
        return [NSString stringWithFormat:@"18:00"];
    }
    return [NSString stringWithFormat:@"%i:00", hour];
}

//Formatiert eine Uhrzeit aus einem übergebenen Datum - für das 'Ende' Feld.
- (NSString *)stopTimeForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:date];
    int hour = [components hour];
    if (hour <= 8)
    {
        return [NSString stringWithFormat:@"10:00"];
    }
    else if (hour == 9)
    {
        return [NSString stringWithFormat:@"11:00"];
    }
    else if (hour > 18)
    {
        return [NSString stringWithFormat:@"20:00"];
    }
    return [NSString stringWithFormat:@"%i:00", hour+2];
}

#pragma mark - UITextFieldDelegate

//Lässt die Tastatur wieder verschwinden.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NotificationCenter

//Der Nutzer hat einen Raum eingegeben oder diesen gelöscht. Der Text wird in der _room-Variablen gespeichert.
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    _room = textfield.text;
}

#pragma mark - UISegmentedControl

//Der Nutzer hat über den DatePicker entweder das Start-Datum oder eine der Uhrzeiten ausgewählt.
//Das neue Datum/Uhrzeit wird in die entsprechende Zelle eingetragen. Im Falle dass wöchentlich oder zweiwöchentlich
//ausgewählt ist, werden nachfolgende Termine bis zum Ende des gewählten Semesters berechnet und an die Liste angehängt.
- (void)segmentedControlTapped:(UISegmentedControl *)sender
{
    _indexOfSegmentedControl = sender.selectedSegmentIndex;
    
    if (sender.selectedSegmentIndex == 0)//Einzeltermin ist gewählt
    {
        for (int i = 0; i < _dates.count; i++)
        {
            NSDate *date = [_dates objectAtIndex:i];
            [_dates removeObjectAtIndex:i];
            NSDate *newDate = [self dateFromDate:_date ForDays:i+1];
            [_dates insertObject:newDate atIndex:i];
            if ([_chosenDates containsObject:date])
            {
                int index = [_chosenDates indexOfObject:date];
                [_chosenDates removeObjectAtIndex:index];
                [_chosenDates insertObject:newDate atIndex:index];
            }
        }
    }
    else if (sender.selectedSegmentIndex == 1)//Wöchentlich ist gewählt
    {
        for (int i = 0; i < _dates.count; i++)
        {
            NSDate *date = [_dates objectAtIndex:i];
            [_dates removeObjectAtIndex:i];
            NSDate *newDate = [self dateFromDate:_date ForDays:(i+1)*7];
            [_dates insertObject:newDate atIndex:i];
            if ([_chosenDates containsObject:date])
            {
                int index = [_chosenDates indexOfObject:date];
                [_chosenDates removeObjectAtIndex:index];
                [_chosenDates insertObject:newDate atIndex:index];
            }
        }
    }
    else //Zweiwöchentlich ist gewählt
    {
        
        for (int i = 0; i < _dates.count; i++)
        {
            NSDate *date = [_dates objectAtIndex:i];
            [_dates removeObjectAtIndex:i];
            NSDate *newDate = [self dateFromDate:_date ForDays:(i+1)*14];
            [_dates insertObject:newDate atIndex:i];
            if ([_chosenDates containsObject:date])
            {
                int index = [_chosenDates indexOfObject:date];
                [_chosenDates removeObjectAtIndex:index];
                [_chosenDates insertObject:newDate atIndex:index];
            }
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - UIStepper Value Changed

//Der Nutzer betätigt den Stepper und fügt somit einen weiteren Termin an das Ende der Liste an, bzw. löscht einen Termin vom Ende der Liste.
- (void)stepperValueChanged:(UIStepper *)sender
{
    if (_numberOfDates > (int)sender.value) //Ein Termin wird geloescht
    {
        _numberOfDates--;
        NSDate *date = [_dates lastObject];
        if ([_chosenDates containsObject:date])
        {
            [_chosenDates removeObject:date];
        }
        [_dates removeObject:date];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dates.count inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else //Ein Termin wird hinzugefuegt
    {
        _numberOfDates++;
        NSDate *date = [_dates lastObject];
        if (!date)
        {
            date = _date;
        }
        NSDate *newDate;
        if (_indexOfSegmentedControl == 0)
        {
            newDate = [self dateFromDate:date ForDays:1];
        }
        else if (_indexOfSegmentedControl == 1)
        {
            newDate = [self dateFromDate:date ForDays:7];
        }
        else
        {
            newDate = [self dateFromDate:date ForDays:14];
        }
        [_dates addObject:newDate];
        [_chosenDates addObject:newDate];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dates.count-1 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
    
    }
    _numberOfDates = (int)sender.value;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIActionSheet

//Der DatePicker zum wechseln des Start-Datums wird ausgefahren.
- (void)callDatePicker:(id)sender
{
    if (!_actionSheet)
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    
    [_datePicker removeFromSuperview];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    _datePicker = nil;
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [_actionSheet addSubview:_datePicker];
    
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.tag = 2;
    _datePicker.date = _date;
    _datePicker.minimumDate = _semesterStart;
    _datePicker.maximumDate = _semesterEnd;
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Fertig", @"Fertig")]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blueColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [_actionSheet addSubview:closeButton];
    
    [_actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [_actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

//Der DatePicker zum wechseln der Beginn-Uhrzeit wird ausgefahren.
- (void)callStartTimePicker:(id)sender
{
    if (!_actionSheet)
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    
    [_datePicker removeFromSuperview];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    _datePicker = nil;
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [_actionSheet addSubview:_datePicker];
    
    _datePicker.datePickerMode = UIDatePickerModeTime;
    _datePicker.minuteInterval = 5;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setDateFormat:@"HH:mm"];
    NSArray *array = [_startTime componentsSeparatedByString:@" "];
    _datePicker.date = [df dateFromString:[array objectAtIndex:0]];
    NSLog(@"DatePicker.date: %@", _datePicker.date);
    _datePicker.tag = 3;
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Fertig", @"Fertig")]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blueColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [_actionSheet addSubview:closeButton];
    
    [_actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [_actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

//Der DatePicker zum wechseln der Ende-Uhrzeit wird ausgefahren.
- (void)callEndTimePicker:(id)sender
{
    if (!_actionSheet)
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    
    [_datePicker removeFromSuperview];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    _datePicker = nil;
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [_actionSheet addSubview:_datePicker];
    
    _datePicker.datePickerMode = UIDatePickerModeTime;
    _datePicker.minuteInterval = 5;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setDateFormat:@"HH:mm"];
    NSArray *array = [_endTime componentsSeparatedByString:@" "];
    _datePicker.date = [df dateFromString:[array objectAtIndex:0]];
    _datePicker.tag = 4;
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Fertig", @"Fertig")]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blueColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [_actionSheet addSubview:closeButton];
    
    [_actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [_actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

//Der DatePicker wird wieder eingefahren. Nach dem gewählten Datum/Uhrzeit werden die restlichen Daten wieder befüllt.
- (void)dismissActionSheet:(id)sender
{
    [_actionSheet dismissWithClickedButtonIndex:nil animated:YES];
    NSIndexPath *selectedIndexPath =  [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    
    if (_datePicker.tag == 2) //Das Start-Datum wurde verändert. Die darauffolgenden Termine müssen neu berechnet werden.
    {
        _date = _datePicker.date;
        
        if (_indexOfSegmentedControl == 0)//Einzeltermin ist gewählt
        {
            for (int i = 0; i < _dates.count; i++)
            {
                NSDate *date = [_dates objectAtIndex:i];
                [_dates removeObjectAtIndex:i];
                NSDate *newDate = [self dateFromDate:_date ForDays:i+1];
                [_dates insertObject:newDate atIndex:i];
                if ([_chosenDates containsObject:date])
                {
                    int index = [_chosenDates indexOfObject:date];
                    [_chosenDates removeObjectAtIndex:index];
                    [_chosenDates insertObject:newDate atIndex:index];
                }
            }
        }
        else if (_indexOfSegmentedControl == 1)//Wöchentlich ist gewählt
        {
            for (int i = 0; i < _dates.count; i++)
            {
                NSDate *date = [_dates objectAtIndex:i];
                [_dates removeObjectAtIndex:i];
                NSDate *newDate = [self dateFromDate:_date ForDays:(i+1)*7];
                [_dates insertObject:newDate atIndex:i];
                if ([_chosenDates containsObject:date])
                {
                    int index = [_chosenDates indexOfObject:date];
                    [_chosenDates removeObjectAtIndex:index];
                    [_chosenDates insertObject:newDate atIndex:index];
                }
            }
        }
        else //Zweiwöchentlich ist gewählt
        {
            
            for (int i = 0; i < _dates.count; i++)
            {
                NSDate *date = [_dates objectAtIndex:i];
                [_dates removeObjectAtIndex:i];
                NSDate *newDate = [self dateFromDate:_date ForDays:(i+1)*14];
                [_dates insertObject:newDate atIndex:i];
                if ([_chosenDates containsObject:date])
                {
                    int index = [_chosenDates indexOfObject:date];
                    [_chosenDates removeObjectAtIndex:index];
                    [_chosenDates insertObject:newDate atIndex:index];
                }
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if (_datePicker.tag == 3) //Die Startzeit des Termins wurde geändert, die Endzeit wird neu berechnet.
    {
        NSDate *date = _datePicker.date;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterNoStyle];
        [df setDateFormat:@"HH:mm"];
        NSString *startTime = [df stringFromDate:date];
        _startTime = [NSString stringWithFormat:@"%@ %@", startTime, NSLocalizedString(@"Uhr", @"Uhr")];
        _endTime = [NSString stringWithFormat:@"%@ %@", [df stringFromDate:[[df dateFromString:startTime] dateByAddingTimeInterval:7200]], NSLocalizedString(@"Uhr", @"Uhr")];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else //Die Endzeit des Termins wurde geändert, die Startzeit wird angepasst.
    {
        NSDate *date = _datePicker.date;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterNoStyle];
        [df setDateFormat:@"HH:mm"];
        NSString *endTime = [df stringFromDate:date];
        _endTime = [NSString stringWithFormat:@"%@ %@", endTime, NSLocalizedString(@"Uhr", @"Uhr")];
        
        NSString *startTime = [[_startTime componentsSeparatedByString:@" "] objectAtIndex:0];
        if ([[df dateFromString:startTime] compare:[df dateFromString:endTime]] == NSOrderedDescending || [[df dateFromString:startTime] compare:[df dateFromString:endTime]] == NSOrderedSame)
        {
            _startTime = [NSString stringWithFormat:@"%@ %@", [df stringFromDate:[[df dateFromString:endTime] dateByAddingTimeInterval:-3600]], NSLocalizedString(@"Uhr", @"Uhr")];
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

//Ein Datum wird um eine bestimmte Anzahl von Tagen weiter-/zurückgesetzt.
- (NSDate *)dateFromDate:(NSDate *)date ForDays:(int)days
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
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

//Der Nutzer tippt auf den 'Termin löschen' Button, dies muss erst vom Nutzer bestätigt werden.
- (void)deleteTermine:(id)sender
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Termine löschen?", @"Termine löschen?")
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                destructiveButtonTitle:NSLocalizedString(@"Löschen", @"Löschen")
                                     otherButtonTitles:nil];
    [actionSheet showInView:self.view];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //Loescht den Terminblock.
    {
        [((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]) deleteDateBlock:_dateBlock];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (buttonIndex == 1) //Bricht den Loeschvorgang ab.
    {
        [self removeHighlight:_deleteEintragButton];
    }
}

@end
