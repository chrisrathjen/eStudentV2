//
//  ChooseDefaultMensaViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 31.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ChooseDefaultMensaViewController.h"
#import "ChooseDefaultFoodViewController.h"

@interface ChooseDefaultMensaViewController ()
{
    NSArray *_mensen;
    int _selectedMensaIndex;
}

- (void)abbrechenButtonClicked:(id)sender;
- (void)weiterButtonClicked:(id)sender;

@end

@implementation ChooseDefaultMensaViewController

//Erstellt ein Array mit den verschiedenen Namen der unterstützten Mensen.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _mensen = [NSArray arrayWithObjects:@"Uni Boulevard", @"GW2", @"Airport", @"Bremerhaven", @"Neustadtwall", @"Werderstraße", nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
        {
            _selectedMensaIndex = [_mensen indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME]];
        }
        else
        {
            _selectedMensaIndex = 0;
        }
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStyleBordered target:self action:@selector(abbrechenButtonClicked:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Weiter", @"Weiter") style:UIBarButtonItemStyleBordered target:self action:@selector(weiterButtonClicked:)];
        self.navigationItem.title = NSLocalizedString(@"Mensa", @"Mensa");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Standard-Mensa wählen", @"Standard-Mensa wählen");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"Deine Standard-Mensa wird für die Essens-Anzeige auf der Übersichtsseite benötigt.", @"Deine Standard-Mensa wird für die Essens-Anzeige auf der Übersichtsseite benötigt.");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mensen.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    cell.textLabel.text = [_mensen objectAtIndex:indexPath.row];;
    cell.backgroundColor = [UIColor whiteColor];
    cell.opaque = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_selectedMensaIndex == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

//Wählt die Mensa als Standard-Mensa aus, dessen korrespondierende Zelle angeklickt wird.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedMensaIndex)
    {
        return;
    }
    int tmpIndex = _selectedMensaIndex;
    _selectedMensaIndex = indexPath.row;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:tmpIndex inSection:0], [NSIndexPath indexPathForRow:_selectedMensaIndex inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIBarButtonItem

//Bricht die Auswahl ab und lässt das UI verschwinden.
- (void)abbrechenButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Betätigt der Nutzer den Weiter-Button, wird die gewählte Mensa festgelegt und der Nutzer wird zum Essensarten-Filter navigiert.
- (void)weiterButtonClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (_selectedMensaIndex)
    {
        case 0:
            [defaults setObject:@"uni" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"Uni Boulevard" forKey:kDEFAULTS_MENSA_NAME];
            break;
        case 1:
            [defaults setObject:@"gw2" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"GW2" forKey:kDEFAULTS_MENSA_NAME];
            break;
        case 2:
            [defaults setObject:@"air" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"Airport" forKey:kDEFAULTS_MENSA_NAME];
            break;
        case 3:
            [defaults setObject:@"bhv" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"Bremerhaven" forKey:kDEFAULTS_MENSA_NAME];
            break;
        case 4:
            [defaults setObject:@"hsb" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"Neustadtwall" forKey:kDEFAULTS_MENSA_NAME];
            break;
        case 5:
            [defaults setObject:@"wer" forKey:kDEFAULTS_DEFAULT_MENSA];
            [defaults setObject:@"Werderstraße" forKey:kDEFAULTS_MENSA_NAME];
            break;
        default:
            break;
    }
    [defaults synchronize];
    
    ChooseDefaultFoodViewController *cdfvc = [[ChooseDefaultFoodViewController alloc] initWithNibName:@"ChooseDefaultFoodViewController" bundle:nil];
    [self.navigationController pushViewController:cdfvc animated:YES];
}

@end
