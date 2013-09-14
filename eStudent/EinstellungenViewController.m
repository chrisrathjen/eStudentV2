//
//  SettingsViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "EinstellungenViewController.h"
#import "NeuerStudiengangViewController.h"
#import "AppDelegate.h"
#import "FilterFoodTypesViewController.h"
#import "ChooseStandardMensaViewController.h"

@interface EinstellungenViewController ()

@end

@implementation EinstellungenViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Einstellungen", @"Einstellungen");
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Zurück", @"Zurück") style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kCUSTOM_SETTINGS_BACKGROUND_COLOR;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
}
- (IBAction)setupNewStudiengang:(id)sender {
    NeuerStudiengangViewController *nstvc = [[NeuerStudiengangViewController alloc] initWithNibName:@"NeuerStudiengangViewController" bundle:nil];
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:nstvc];
    [self presentViewController:aNavController animated:YES completion:nil];
    
}

- (IBAction)deleteData:(id)sender {
    
    // Mensa:
    
    NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *keys = [NSArray arrayWithObjects:@"air", @"bhv", @"uni", @"wer", @"gw2", @"hsb", nil];
    for (NSString *aMensa in keys) {
        NSString *filePath = [library stringByAppendingString:[NSString stringWithFormat:@"/%@",aMensa]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:aMensa];
        }
    }
   // Pois
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedPoiDataFileName] stringByExpandingTildeInPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastCampusPOIRefresh];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = NSLocalizedString(@"Essen", @"Essen");
    CGRect frame = headerLabel.frame;
    CGSize size = [headerLabel.text sizeWithFont:headerLabel.font constrainedToSize:CGSizeMake(240.0, MAXFLOAT)];
    frame.size.height = size.height + 20.0;
    frame.size.width = size.width;
    frame.origin.x = 17.0;
    headerLabel.frame = frame;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    frame = view.frame;
    frame.size.width += 20.0;
    frame.origin.x = 0.0;
    view.frame = frame;
    [view addSubview:headerLabel];
    
    return view;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerview = [self tableView:tableView viewForHeaderInSection:section];
    return headerview.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.opaque = YES;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Standard-Mensa & Lieblingsessen", @"Standard-Mensa & Lieblingsessen");
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
            {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_FOOD_TYPE])
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME], [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_FOOD_TYPE]];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME]];
                }
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Essens-Filter", @"Essens-Filter");
            cell.detailTextLabel.text = nil;
            break;
        default:
            break;
    }
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSString *text = NSLocalizedString(@"Standard-Mensa & Lieblingsessen", @"Standard-Mensa & Lieblingsessen");
        float height = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] constrainedToSize:CGSizeMake(240.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
        {
            return height + 30.0;
        }
        return height + 20.0;
        
    }
    return 44.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) //Essen
    {
        if (indexPath.row == 0) //Standard-Mensa & Lieblingsessen
        {
            [self.navigationController pushViewController:[[ChooseStandardMensaViewController alloc] initWithNibName:@"ChooseStandardMensaViewController" bundle:nil] animated:YES];
        }
        else if (indexPath.row == 1) //Essens-Arten filtern
        {
            [self.navigationController pushViewController:[[FilterFoodTypesViewController alloc] initWithNibName:@"FilterFoodTypesViewController" bundle:nil] animated:YES];
        }
    }
}

@end
