//
//  FoodTypePickerViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 31.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "FoodTypePickerViewController.h"
#import "ChooseDefaultMensaViewController.h"
#import "HomeScreenViewController.h"

@interface FoodTypePickerViewController ()
{
    NSArray *_foodTypes;
    NSMutableArray *_filteredFoodTypes;
}

- (void)fertigButtonClicked:(id)sender;

@end

@implementation FoodTypePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _foodTypes = [NSArray arrayWithObjects:NSLocalizedString(@"Schwein", @"Schwein"), NSLocalizedString(@"Geflügel", @"Geflügel"), NSLocalizedString(@"Rind", @"Rind"), NSLocalizedString(@"Wild", @"Wild"), NSLocalizedString(@"Lamm", @"Lamm"), NSLocalizedString(@"Fisch", @"Fisch"), NSLocalizedString(@"Vegetarisch", @"Vegetarisch"), NSLocalizedString(@"Vegan", @"Vegan"), nil];
        _filteredFoodTypes = ((NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kFILTERED_FOOD_TYPES]).mutableCopy;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Fertig", @"Fertig") style:UIBarButtonItemStyleBordered target:self action:@selector(fertigButtonClicked:)];
        self.navigationItem.title = NSLocalizedString(@"Essensarten", @"Essensarten");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Welche Essensarten sollen angezeigt werden?", @"Welche Essensarten sollen angezeigt werden?");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"Speisen, deren Essensart uns nicht vorliegt, werden immer angezeigt.", @"Speisen, deren Essenart uns nicht vorliegt, werden immer angezeigt.");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *foodType = [_foodTypes objectAtIndex:indexPath.row];
    if ([_filteredFoodTypes containsObject:foodType])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = foodType;
    cell.backgroundColor = [UIColor whiteColor];
    cell.opaque = YES;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *foodType = cell.textLabel.text;
    if ([_filteredFoodTypes containsObject:foodType])
    {
        if (_filteredFoodTypes.count > 1)
        {
            [_filteredFoodTypes removeObject:foodType];
        }
    }
    else
    {
        [_filteredFoodTypes addObject:foodType];
    }
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIBarButtonItems

- (void)fertigButtonClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:_filteredFoodTypes forKey:kFILTERED_FOOD_TYPES];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [((HomeScreenViewController *)self.navigationController.parentViewController) refreshMensaData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
