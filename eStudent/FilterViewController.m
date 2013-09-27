//
//  FilterViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 18.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()
{
    NSIndexPath *_selectedIndexPath;
}

@end

@implementation FilterViewController

@synthesize viewController = _viewController;

//Setzt den Titel.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Einträge filtern", @"Einträge filtern");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int filter = [defaults integerForKey:kEINTRAEGE_FILTER];
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Alle Einträge", @"Alle Einträge");
            cell.imageView.image = [UIImage imageNamed:@"259-list-b"];
            if (filter == kALL_EINTRAEGE_FILTER)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                _selectedIndexPath = indexPath;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Offene Einträge", @"Offene Einträge");
            cell.imageView.image = [UIImage imageNamed:@"216-compose-b"];
            if (filter == kOPEN_EINTRAEGE_FILTER)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                _selectedIndexPath = indexPath;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Bestandene Einträge", @"Bestandene Einträge");
            cell.imageView.image = [UIImage imageNamed:@"258-checkmark"];
            if (filter == kPAST_EINTRAEGE_FILTER)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                _selectedIndexPath = indexPath;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        default:
            break;
    }
    cell.textLabel.font = kCUSTOM_HEADER_LABEL_FONT;
    return cell;
}

#pragma mark - Table view delegate

//Nimmt die Auswahl, wie die Einträge gefiltert werden sollen und leitet sie an den UebersichtViewController weiter.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedIndexPath = indexPath;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row)
    {
        case 0:
            [defaults setInteger:kALL_EINTRAEGE_FILTER forKey:kEINTRAEGE_FILTER];
            break;
        case 1:
            [defaults setInteger:kOPEN_EINTRAEGE_FILTER forKey:kEINTRAEGE_FILTER];
            break;
        case 2:
            [defaults setInteger:kPAST_EINTRAEGE_FILTER forKey:kEINTRAEGE_FILTER];
            break;
        default:
            break;
    }
    
    [defaults synchronize];
    [((UebersichtViewController *)_viewController) loadViews];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
