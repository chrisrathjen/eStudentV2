//
//  StudiengangAuswahlViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "StudiengangAuswahlViewController.h"
#import "CoreDataDataManager.h"
#import "NeuerEintragViewController.h"

@interface StudiengangAuswahlViewController ()
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UINavigationBar *navigationBar;
    __weak IBOutlet UIBarButtonItem *fertigButton;
    
    NSArray *studiengaenge;
}

- (IBAction)fertigButtonPressed:(id)sender;

@end

@implementation StudiengangAuswahlViewController

@synthesize chosenStudiengang;
@synthesize semester = _semester;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

//Lädt über den Datenmanager die angelegten Studiengänge und bereitet das UI vor.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge];
    /*NSMutableArray *tmpStudiengaenge = [NSMutableArray array];
    for (Studiengang *s in studiengaenge)
    {
        if ([[CoreDataDataManager sharedInstance] compareSemester:_semester withSemester:s.erstesFachsemester] == NSOrderedAscending)
        {
            continue;
        }
        [tmpStudiengaenge addObject:s];
    }
    studiengaenge = tmpStudiengaenge.copy;*/
    
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    navigationBar.topItem.title = NSLocalizedString(@"Wähle Studiengang", @"Wähle Studiengang");
    fertigButton.title = NSLocalizedString(@"Fertig", @"Fertig");
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise_lines"]];
}

#pragma mark - BarButtonItem

//Reagiert auf die Betätigung des 'Fertig' Buttons. Dem NeuerEintragViewController wird der gewählte Studiengang als Studiengang übergeben.
- (IBAction)fertigButtonPressed:(id)sender
{
    ((NeuerEintragViewController *)self.presentingViewController).studiengang = chosenStudiengang;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return studiengaenge.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"Weitere Studiengänge können in den Einstellungen angelegt werden.", @"Weitere Studiengänge können in den Einstellungen angelegt werden.");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    Studiengang *s = (Studiengang *)[studiengaenge objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", s.name, s.abschluss];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if ([chosenStudiengang.name isEqualToString:s.name] && [chosenStudiengang.abschluss isEqualToString:s.abschluss])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Studiengang *studiengang = [studiengaenge objectAtIndex:indexPath.row];
    CGSize constraintSize = CGSizeMake(280.0, MAXFLOAT);
    if ([chosenStudiengang.name isEqualToString:studiengang.name] && [chosenStudiengang.abschluss isEqualToString:studiengang.abschluss])
    {
        constraintSize = CGSizeMake(250.0, MAXFLOAT);
    }
    NSString *text = [NSString stringWithFormat:@"%@, %@", studiengang.name, studiengang.abschluss];
    CGSize labelSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:17.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 20.0;
}

//Durch tippen auf einen Zelle, wählt der Nutzer ebenfalls einen Studiengang aus.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTitle = cell.textLabel.text;
    for (Studiengang *s in studiengaenge)
    {
        if ([[NSString stringWithFormat:@"%@, %@", s.name, s.abschluss] isEqualToString:cellTitle])
        {
            chosenStudiengang = s;
        }
    }
    if ([[CoreDataDataManager sharedInstance] compareSemester:_semester withSemester:chosenStudiengang.erstesFachsemester] == NSOrderedAscending) //stellt sicher, dass kein Semester ausgewählt werden kann, das vor dem ersten Fachsemester des gewählten Studiengangs liegt
    {
        ((NeuerEintragViewController *)self.presentingViewController).semester = chosenStudiengang.erstesFachsemester;
    }
    
    ((NeuerEintragViewController *)self.presentingViewController).studiengang = chosenStudiengang;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
