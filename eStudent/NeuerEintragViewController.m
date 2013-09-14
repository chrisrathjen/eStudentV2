//
//  NeuerEintragViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.02.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "NeuerEintragViewController.h"
#import "Eintrag.h"
#import "Studiengang.h"
#import "Semester.h"
#import "ArtViewController.h"
#import "SemesterAuswahlViewController.h"
#import "StudiengangAuswahlViewController.h"
#import "KriteriumViewController.h"
#import "CoreDataDataManager.h"
#import "TMPKriterium.h"
#import <QuartzCore/QuartzCore.h>
#import "StudiumsplanerViewController.h"
#import "UebersichtViewController.h"

#define kFont [UIFont boldSystemFontOfSize:17.0]

@interface NeuerEintragViewController ()
{
    __weak IBOutlet UINavigationBar *navigationBar;
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UIBarButtonItem *fertigButton;
    
    UISwitch *benotetSwitch;
    UISwitch *bestandenSwitch;
    UIButton *deleteEintragButton;
    CAGradientLayer *gradient;
    UIActionSheet *actionSheet;
    int numberOfRows;
    BOOL benotet;
    BOOL bestanden;
    
    NSString *eintragsTitel;
    NSString *eintragsCP;
    NSString *eintragsNote;
    NSMutableArray *kriterien;
}

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)fertigButtonPressed:(id)sender;
- (void)saveEintragToDatabaseSaveAllKriterien:(BOOL)saveAll;
- (void)bestandenSwitched:(UISwitch *)sender;
- (void)benotetSwitched:(UISwitch *)sender;
- (void)textFieldChanged:(NSNotification *)notification;
- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;
- (NSDate *)normalizedDateWithDate:(NSDate *)date;

@end

@implementation NeuerEintragViewController

@synthesize eintrag;
@synthesize eintragsArtString;
@synthesize semester;
@synthesize studiengang;
@synthesize tmpKriterien;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationBar.topItem.title = self.title;
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise_lines"]];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_COURSE_OF_STUDY];
    studiengang = studiengang ? studiengang : eintrag ? eintrag.studiengang : [[CoreDataDataManager sharedInstance] getStudiengangForName:[dict objectForKey:kDEFAULTS_COURSE_OF_STUDY_NAME] abschluss:[dict objectForKey:kDEFAULTS_COURSE_OF_STUDY_DEGREE]];
    
    benotet = eintrag ? [eintrag.benotet boolValue] : YES;
    bestanden = eintrag ? [eintrag.bestanden boolValue] : NO;
    numberOfRows = (bestanden && benotet) ? 8 : 7;
    tmpKriterien = [NSMutableArray array];
    if (eintrag)
    {
        kriterien = [NSMutableArray arrayWithArray:[eintrag.kriterien allObjects]];
        [fertigButton setEnabled:YES];
        eintragsTitel = eintrag.titel;
        eintragsCP = [eintrag.cp stringValue];
        eintragsArtString = eintrag.art;
        semester = eintrag.semester;
        if (eintrag.benotet && eintrag.bestanden)
        {
            eintragsNote = [[eintrag.note stringValue] stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
        else
        {
            eintragsNote = @"";
        }
        
        deleteEintragButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        deleteEintragButton.backgroundColor = [UIColor redColor];
        deleteEintragButton.layer.cornerRadius = 10.0;
        deleteEintragButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [deleteEintragButton setTitle:NSLocalizedString(@"Eintrag löschen", @"Eintrag löschen") forState:UIControlStateNormal];
        [deleteEintragButton setBackgroundColor:[UIColor redColor]];
        [deleteEintragButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (!gradient)
        {
            gradient = [CAGradientLayer layer];
            gradient.frame = deleteEintragButton.bounds;
            gradient.borderWidth = 1.0;
            gradient.borderColor = [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1.0].CGColor;
            gradient.cornerRadius = 10.0;
            gradient.colors = [NSArray arrayWithObjects:
                               (id)[[UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.9 green:.4 blue:.4 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                               nil];
            [deleteEintragButton.layer insertSublayer:gradient atIndex:0];
        }
        
        [deleteEintragButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [deleteEintragButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
        [deleteEintragButton addTarget:self action:@selector(deleteEintrag:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 54.0)];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:deleteEintragButton];
        tableView.tableFooterView = view;
    }
    else
    {
        eintragsTitel = @"";
        eintragsCP = @"";
        eintragsNote = @"";
        eintragsArtString = [[[NSUserDefaults standardUserDefaults] arrayForKey:kDEFAULTS_ENTRY_TYPES] objectAtIndex:0];
    }
    if (!semester)
    {
        semester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtonItems Pressed

- (IBAction)cancelButtonPressed:(id)sender
{
    NSArray *_semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
    Semester *currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
    for (int i = 0; i < _semesters.count; i++)
    {
        Semester *s = [_semesters objectAtIndex:i];
        if ([s isEqual:currentSemester])
        {
            [[CoreDataDataManager sharedInstance] deleteAllEmptyFutureSemestersAfterIndex:i];
            break;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fertigButtonPressed:(id)sender
{
    if (bestandenSwitch.on)
    {
        int openKriterien = 0;
        for (Kriterium *k in kriterien)
        {
            if (![k.erledigt boolValue])
            {
                openKriterien++;
            }
        }
        for (TMPKriterium *tk in tmpKriterien)
        {
            if (!tk.completed)
            {
                openKriterien++;
            }
        }
        if (openKriterien > 0)
        {
            NSString *alertTitle = openKriterien > 1 ? NSLocalizedString(@"offene Kriterien", @"offene Kriterien") : NSLocalizedString(@"offenes Kriterium", @"offenes Kriterium");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"Noch", @"Noch"), openKriterien, alertTitle]
                                                                message:NSLocalizedString(@"Wenn du den Eintrag als bestanden markierst, werden alle offenen Kriterien als erledigt markiert.", @"Wenn du den Eintrag als bestanden markierst, werden alle offenen Kriterien als erledigt markiert.")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alertView show];
        }
        else
        {
            [self saveEintragToDatabaseSaveAllKriterien:NO];
        }
    }
    else
    {
        [self saveEintragToDatabaseSaveAllKriterien:NO];
    }
}

- (void)saveEintragToDatabaseSaveAllKriterien:(BOOL)saveAll
{
    if (eintrag)
    {
        eintrag.titel = eintragsTitel;
        eintrag.art = eintragsArtString;
        eintrag.cp = [NSNumber numberWithInt:[eintragsCP intValue]];
        eintrag.studiengang = studiengang;
        eintrag.semester = semester;
        eintrag.benotet = [NSNumber numberWithBool:benotetSwitch.on];
        eintrag.bestanden = [NSNumber numberWithBool:bestandenSwitch.on];
        if (bestandenSwitch.on && benotetSwitch.on)
        {
            eintrag.note = [NSNumber numberWithDouble:[[eintragsNote stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue]];
        }
        else
        {
            eintrag.note = nil;
        }
        
        NSArray *_semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
        Semester *currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
        if ([[CoreDataDataManager sharedInstance] compareSemester:currentSemester withSemester:eintrag.semester] == NSOrderedAscending)
        {
            for (int i = 0; i < _semesters.count; i++)
            {
                Semester *s = [_semesters objectAtIndex:i];
                if ([s isEqual:eintrag.semester])
                {
                    [[CoreDataDataManager sharedInstance] deleteAllEmptyFutureSemestersAfterIndex:i];
                    break;
                }
            }
        }
        else
        {
            for (int i = 0; i < _semesters.count; i++)
            {
                Semester *s = [_semesters objectAtIndex:i];
                if ([s isEqual:currentSemester])
                {
                    [[CoreDataDataManager sharedInstance] deleteAllEmptyFutureSemestersAfterIndex:i];
                    break;
                }
            }
        }
    }
    else
    {
        NSNumber *note;
        if (![eintragsNote isEqualToString:@""])
        {
            note = [NSNumber numberWithDouble:[[eintragsNote stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue]];
        }
        else
        {
            note = nil;
        }
        NSNumber *_benotet;
        if (benotet)
        {
            _benotet = [NSNumber numberWithBool:benotet];
        }
        NSNumber *_bestanden;
        if (bestanden)
        {
            _bestanden = [NSNumber numberWithBool:bestanden];
        }
        
        eintrag = [[CoreDataDataManager sharedInstance] createEintragWithTitle:eintragsTitel
                                                                           art:eintragsArtString
                                                                   isBestanden:_bestanden
                                                                     isBenotet:_benotet
                                                                            cp:[NSNumber numberWithInt:[eintragsCP intValue]]
                                                                          note:note
                                                                    inSemester:semester
                                                                 inStudiengang:studiengang];
    }
    
    for (TMPKriterium *k in tmpKriterien)
    {
        Kriterium *kriterium = [k addSelfToDatabaseForEintrag:eintrag];
        if (saveAll)
        {
            kriterium.erledigt = [NSNumber numberWithBool:YES];
        }
    }
    for (Kriterium *k in kriterien)
    {
        if (saveAll)
        {
            k.erledigt = [NSNumber numberWithBool:YES];
        }
    }
    
    [[CoreDataDataManager sharedInstance] saveDatabase];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *objects = [NSArray arrayWithObjects:studiengang.name, studiengang.abschluss, studiengang.erstesFachsemester.name, studiengang.cp, nil];
    NSArray *keys = [NSArray arrayWithObjects:kDEFAULTS_COURSE_OF_STUDY_NAME, kDEFAULTS_COURSE_OF_STUDY_DEGREE, kDEFAULTS_COURSE_OF_STUDY_FIST_SEMESTER, kDEFAULTS_COURSE_OF_STUDY_CP, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [defaults setObject:dict forKey:kDEFAULTS_COURSE_OF_STUDY];
    [defaults synchronize];
    
    ((StudiumsplanerViewController *)[((UITabBarController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).viewControllers objectAtIndex:0]).shouldRefresh = YES;
    ((UebersichtViewController *)[((UITabBarController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).viewControllers objectAtIndex:1]).shouldRefresh = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self saveEintragToDatabaseSaveAllKriterien:YES];
    }
}

#pragma mark - UITableViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return numberOfRows;
    }
    return kriterien.count + tmpKriterien.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Eintrag", @"Eintrag");
    }
    
    return NSLocalizedString(@"Kriterien", @"Kriterien");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil; //NSLocalizedString(@"Einträge können Vorlesungen, Seminare, Kurse, Praktikas, etc. sein.", @"Eintrag-Beschreibungstext");
    }
    
    NSString *footerTitle;
    if (bestanden)
    {
        if ((kriterien.count + tmpKriterien.count) > 0)
        {
            footerTitle = NSLocalizedString(@"Kriterien können nur bearbeiten/angelegt werden, solange der Eintrag noch nicht bestanden ist.", @"Kriterien können nur bearbeiten/angelegt werden, solange der Eintrag noch nicht bestanden ist.");
        }
        else
        {
            footerTitle = NSLocalizedString(@"Kriterien können nur angelegt werden, solange der Eintrag noch nicht bestanden ist.", @"Kriterien können nur angelegt werden, solange der Eintrag noch nicht bestanden ist.");
        }
    }
    else
    {
        footerTitle = NSLocalizedString(@"Kriterien sind Teilleistungen, die für einen Eintrag erfüllt werden müssen. Hierbei kann es sich um Abgaben, Referate, Ausarbeitungen, Praktika etc. handeln.", @"Kriterien-Beschreibungstext");
    }
    return footerTitle;
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    static NSString *reuseIdentifier2 = @"Cell2";
    UITableViewCell *cell;
    if (indexPath.section == 1)
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier2];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier2];
        }
        if (!bestanden)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.imageView.image = nil;
        
        if (kriterien.count > 0)
        {
            if (indexPath.row < kriterien.count)
            {
                Kriterium *kriterium = (Kriterium *)[kriterien objectAtIndex:indexPath.row];
                if ([kriterium.erledigt boolValue])
                {
                    cell.imageView.image = [UIImage imageNamed:@"258-checkmark"];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                else
                {
                    cell.imageView.image = nil;
                    if (bestanden)
                    {
                        cell.textLabel.textColor = [UIColor darkGrayColor];
                    }
                    else
                    {
                        cell.textLabel.textColor = kCUSTOM_BLUE_COLOR;
                    }
                }
                cell.textLabel.text = kriterium.name;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = kFont;
                
                CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
                CGSize labelSize = [kriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                cell.textLabel.frame = CGRectMake(10.0, 10.0, 270.0, labelSize.height);
                
                
                if (kriterium.date && ![kriterium.erledigt boolValue])
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Fällig am", @"Fällig am"), [dateFormatter stringFromDate:kriterium.date]];
                    if ([[self normalizedDateWithDate:kriterium.date] compare:[self normalizedDateWithDate:[NSDate date]]] == NSOrderedAscending)
                    {
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.imageView.image = [UIImage imageNamed:@"184-warning"];
                    }
                }
                else
                {
                    cell.detailTextLabel.text = nil;
                }
            }
            else if (indexPath.row < (kriterien.count + tmpKriterien.count) && tmpKriterien.count > 0)
            {
                TMPKriterium *tmpKriterium = (TMPKriterium *)[tmpKriterien objectAtIndex:(indexPath.row - kriterien.count)];
                if (tmpKriterium.completed)
                {
                    cell.imageView.image = [UIImage imageNamed:@"258-checkmark"];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                else
                {
                    cell.imageView.image = nil;
                    if (bestanden)
                    {
                        cell.textLabel.textColor = [UIColor darkGrayColor];
                    }
                    else
                    {
                        cell.textLabel.textColor = kCUSTOM_BLUE_COLOR;
                    }
                }
                cell.textLabel.text = tmpKriterium.name;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = kFont;
                
                CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
                CGSize labelSize = [tmpKriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                cell.textLabel.frame = CGRectMake(10.0, 10.0, 270.0, labelSize.height);
                
                if (tmpKriterium.dueDate && !tmpKriterium.completed)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Fällig am", @"Fällig am"), [dateFormatter stringFromDate:tmpKriterium.dueDate]];
                    if ([[self normalizedDateWithDate:tmpKriterium.dueDate] compare:[self normalizedDateWithDate:[NSDate date]]] == NSOrderedAscending)
                    {
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.imageView.image = [UIImage imageNamed:@"184-warning"];
                    }
                }
                else
                {
                    cell.detailTextLabel.text = nil;
                }
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Kriterium hinzufügen", @"Kriterium hinzufügen");
                if (bestanden)
                {
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                else
                {
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                cell.detailTextLabel.text = nil;
            }
        }
        else if (tmpKriterien.count > 0)
        {
            if (indexPath.row < tmpKriterien.count)
            {
                TMPKriterium *tmpKriterium = (TMPKriterium *)[tmpKriterien objectAtIndex:indexPath.row];
                if (tmpKriterium.completed)
                {
                    cell.imageView.image = [UIImage imageNamed:@"258-checkmark"];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                else
                {
                    cell.imageView.image = nil;
                    if (bestanden)
                    {
                        cell.textLabel.textColor = [UIColor darkGrayColor];
                    }
                    else
                    {
                        cell.textLabel.textColor = kCUSTOM_BLUE_COLOR;
                    }
                }
                cell.textLabel.text = tmpKriterium.name;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = kFont;
                
                CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
                CGSize labelSize = [tmpKriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                cell.textLabel.frame = CGRectMake(10.0, 10.0, 270.0, labelSize.height);
                
                if (tmpKriterium.dueDate && !tmpKriterium.completed)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Fällig am", @"Fällig am"), [dateFormatter stringFromDate:tmpKriterium.dueDate]];
                    if ([[self normalizedDateWithDate:tmpKriterium.dueDate] compare:[self normalizedDateWithDate:[NSDate date]]] == NSOrderedAscending)
                    {
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.imageView.image = [UIImage imageNamed:@"184-warning"];
                    }
                }
                else
                {
                    cell.detailTextLabel.text = nil;
                }
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Kriterium hinzufügen", @"Kriterium hinzufügen");
                if (bestanden)
                {
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                else
                {
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                cell.detailTextLabel.text = nil;
            }
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"Kriterium hinzufügen", @"Kriterium hinzufügen");
            if (bestanden)
            {
                cell.textLabel.textColor = [UIColor darkGrayColor];
            }
            else
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            cell.detailTextLabel.text = nil;
        }
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
        
        UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
        txtField.font = [UIFont boldSystemFontOfSize:15.0];
        txtField.textColor = [UIColor blackColor];
        txtField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        txtField.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:txtField];
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Titel", @"Titel");
            
            txtField.keyboardType = UIKeyboardTypeDefault;
            txtField.returnKeyType = UIReturnKeyDone;
            txtField.placeholder = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Z.B.", @"Z.B."), NSLocalizedString(@"Veranstaltungstitel", @"Veranstaltungstitel")];
            txtField.text = eintragsTitel;
            
            [cell.contentView addSubview:txtField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Art", @"Art");
            cell.detailTextLabel.text = eintragsArtString;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"CP", @"CP");
            txtField.keyboardType = UIKeyboardTypeNumberPad;
            txtField.text = eintragsCP;
            txtField.placeholder = [NSString stringWithFormat:@"%@ %i", NSLocalizedString(@"Z.B.", @"Z.B."), 6]; //hier aus den UserDefaults die zuletzt eingetragenen CPs eintragen o.ä.
            
            [cell.contentView addSubview:txtField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Studiengang", @"Studiengang");
            cell.textLabel.font = [UIFont boldSystemFontOfSize:11.0];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"Semester", @"Semester");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", semester.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 5)
        {
            cell.textLabel.text = NSLocalizedString(@"Benotet?", @"Benotet?");
            benotetSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(83.0, 8.0, 185.0, 30.0)];
            benotetSwitch.on = benotet;
            if ([benotetSwitch respondsToSelector:@selector(setOnImage:)])
            {
                benotetSwitch.onImage = [UIImage imageNamed:@"checkmark_switch"];
            }
            [benotetSwitch addTarget:self action:@selector(benotetSwitched:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:benotetSwitch];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 6)
        {
            cell.textLabel.text = NSLocalizedString(@"Bestanden?", @"Bestanden?");
            cell.textLabel.font = [UIFont boldSystemFontOfSize:11.0];
            bestandenSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(83.0, 8.0, 185.0, 30.0)];
            bestandenSwitch.on = bestanden;
            if ([bestandenSwitch respondsToSelector:@selector(setOnImage:)])
            {
                bestandenSwitch.onImage = [UIImage imageNamed:@"checkmark_switch"];
            }
            [bestandenSwitch addTarget:self action:@selector(bestandenSwitched:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:bestandenSwitch];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 7)
        {
            cell.textLabel.text = NSLocalizedString(@"Note", @"Note");
            
            txtField.keyboardType = UIKeyboardTypeDecimalPad;
            txtField.placeholder = @"1,0 - 4,0";
            txtField.text = eintrag.note ? [[NSString stringWithFormat:@"%.1f",[eintrag.note floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","] : nil;
            
            [cell.contentView addSubview:txtField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && !bestanden)
    {
        if (tmpKriterien.count > 0)
        {
            if (indexPath.row < kriterien.count + tmpKriterien.count)
            {
                return YES;
            }
        }
        else
        {
            if (indexPath.row < kriterien.count)
            {
                return YES;
            }
        }
    
    }
    return NO;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < kriterien.count)
    {
        [[CoreDataDataManager sharedInstance] deleteKriterium:[kriterien objectAtIndex:indexPath.row]];
        [kriterien removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        ((StudiumsplanerViewController *)[((UIViewController *)self.presentingViewController).tabBarController.viewControllers objectAtIndex:0]).shouldRefresh = YES;
        ((UebersichtViewController *)[((UIViewController *)self.presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
    }
    else
    {
        if (indexPath.row < tmpKriterien.count + kriterien.count)
        {
            [tmpKriterien removeObjectAtIndex:(indexPath.row - kriterien.count)];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
    }
}

#pragma mark - Normalizing a date

- (NSDate *)normalizedDateWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: date];
    return [calendar dateFromComponents:components];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 3)
        {
            NSString *text = [NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss];
            CGSize labelSize = [text sizeWithFont:kFont constrainedToSize:CGSizeMake(200.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            return labelSize.height + 20.0;
        }
    }
    else if (indexPath.section == 1)
    {
        if (kriterien.count > 0)
        {
            if (indexPath.row < kriterien.count)
            {
                Kriterium *kriterium = (Kriterium *)[kriterien objectAtIndex:indexPath.row];
                CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
                CGSize size = [kriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                float height = size.height + 20.0;
                if (kriterium.date)
                {
                    height += 5.0;
                }
                
                return height;
            }
            else if (tmpKriterien.count > 0 && indexPath.row < (kriterien.count + tmpKriterien.count))
            {
                TMPKriterium *tmpKriterium = (TMPKriterium *)[tmpKriterien objectAtIndex:(indexPath.row - kriterien.count)];
                CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
                CGSize size = [tmpKriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                float height = size.height + 20.0;
                if (tmpKriterium.dueDate)
                {
                    height += 5.0;
                }
                
                return height;
            }
            else
            {
                return 44.0;
            }
        }
        else if (indexPath.row < tmpKriterien.count && tmpKriterien.count > 0)
        {
            TMPKriterium *tmpKriterium = (TMPKriterium *)[tmpKriterien objectAtIndex:indexPath.row];
            CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
            CGSize size = [tmpKriterium.name sizeWithFont:kFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            float height = size.height + 20.0;
            if (tmpKriterium.dueDate)
            {
                height += 5.0;
            }
            
            return height;
        }
        else
        {
            return 44.0;
        }
    }
    return 44.0;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES]; //resignsFirstResponder wenn eins der Textfelder firstResponder war
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 || indexPath.row == 2)
        {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [[[[cell contentView] subviews] lastObject] becomeFirstResponder];
        }
        else if (indexPath.row == 1) //Eintrags-Art
        {
            NSArray *strings = [eintragsArtString componentsSeparatedByString:@" + "];
            
            ArtViewController *avc = [[ArtViewController alloc] initWithNibName:@"ArtViewController" bundle:nil];
            avc.selectedCells = strings.mutableCopy;
            [self presentViewController:avc animated:YES completion:nil];
        }
        else if (indexPath.row == 3) //Studiengang
        {
            StudiengangAuswahlViewController *stavc = [[StudiengangAuswahlViewController alloc] initWithNibName:@"StudiengangAuswahlViewController" bundle:nil];
            stavc.chosenStudiengang = studiengang;
            stavc.semester = semester;
            [self presentViewController:stavc animated:YES completion:nil];;
        }
        else if (indexPath.row == 4) //Semester
        {
            SemesterAuswahlViewController *savc = [[SemesterAuswahlViewController alloc] initWithNibName:@"SemesterAuswahlViewController" bundle:nil];
            savc.chosenSemester = semester;
            if (studiengang)
            {
                savc.studiengang = studiengang;
            }
            [self presentViewController:savc animated:YES completion:nil];
        }
    }
    else if (!bestanden)
    {
        KriteriumViewController *kvc = [[KriteriumViewController alloc] initWithNibName:@"KriteriumViewController" bundle:nil];
        
        if (kriterien.count > 0)
        {
            if (indexPath.row < kriterien.count)
            {
                kvc.kriterium = [kriterien objectAtIndex:indexPath.row];
            }
            else if (tmpKriterien.count > 0)
            {
                if (indexPath.row < (kriterien.count + tmpKriterien.count))
                {
                    kvc.tmpKriterium = [tmpKriterien objectAtIndex:(indexPath.row - kriterien.count)];
                }
            }
        }
        else if (tmpKriterien.count > 0)
        {
            if (indexPath.row < tmpKriterien.count)
            {
                kvc.tmpKriterium = [tmpKriterien objectAtIndex:indexPath.row];
            }
        }
        
        [self presentViewController:kvc animated:YES completion:nil];
    }
}

#pragma mark - UISwitchValueChanged

- (void)benotetSwitched:(UISwitch *)sender
{
    if (sender.on)
    {
        benotet = YES;
        if (numberOfRows == 7 && bestandenSwitch.on)
        {
            numberOfRows++;
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    else
    {
        benotet = NO;
        if (numberOfRows == 8)
        {
            numberOfRows--;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    [self checkIfFertigButtonShouldBeEnabled];
}

- (void)bestandenSwitched:(UISwitch *)sender
{   
    if (sender.on)
    {
        bestanden = YES;
        if (numberOfRows == 7 && benotetSwitch.on)
        {
            numberOfRows++;
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            if (![eintragsNote doubleValue])
            {
                [fertigButton setEnabled:NO];
            }
        }
    }
    else
    {
        bestanden = NO;
        if (numberOfRows == 8)
        {
            numberOfRows--;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    
    [self checkIfFertigButtonShouldBeEnabled];
    [tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Delete Kriterium Button States

- (void)highlightButton:(UIButton *)button
{
    CAGradientLayer *hoverGradient = [CAGradientLayer layer];
    hoverGradient.frame = deleteEintragButton.bounds;
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

- (void)removeHighlight:(UIButton *)button
{
    [[[button.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
}

- (void)deleteEintrag:(UIButton *)button
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Eintrag löschen?", @"Eintrag löschen?")
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                destructiveButtonTitle:NSLocalizedString(@"Löschen", @"Löschen")
                                     otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //Kriterium löschen bestätigt
    {
        if (eintrag)
        {
            [[CoreDataDataManager sharedInstance] deleteEintrag:eintrag];
            NSArray *_semesters = [[CoreDataDataManager sharedInstance] getAllSemesters];
            Semester *currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
            for (int i = 0; i < _semesters.count; i++)
            {
                Semester *s = [_semesters objectAtIndex:i];
                if ([s isEqual:currentSemester])
                {
                    [[CoreDataDataManager sharedInstance] deleteAllEmptyFutureSemestersAfterIndex:i];
                    break;
                }
            }
        }
        ((StudiumsplanerViewController *)[((UITabBarController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).viewControllers objectAtIndex:0]).shouldRefresh = YES;
        ((UebersichtViewController *)[((UITabBarController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).viewControllers objectAtIndex:1]).shouldRefresh = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        [self removeHighlight:deleteEintragButton];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (indexPath.row == 2 || indexPath.row == 7)
    {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)checkIfFertigButtonShouldBeEnabled
{
    if (eintragsTitel.length > 0)
    {
        [fertigButton setEnabled:YES];
        if (benotetSwitch.on && bestandenSwitch.on)
        {
            double note = [[eintragsNote stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
            if (!note || note < 1.0 || note > 4.04)
            {
                [fertigButton setEnabled:NO];
            }
        }
    }
    else
    {
        [fertigButton setEnabled:NO];
    }
}

#pragma mark - NotificationCenter

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    
    UITableViewCell *cell = (UITableViewCell *)textfield.superview.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    if (indexPath.row == 0)
    {
        eintragsTitel = textfield.text;
    }
    else if (indexPath.row == 2)
    {
        eintragsCP = textfield.text;
    }
    else if (indexPath.row == 7)
    {
        eintragsNote = textfield.text;
    }
    
    [self checkIfFertigButtonShouldBeEnabled];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}


@end
