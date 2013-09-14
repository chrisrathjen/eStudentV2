//
//  ChooseDefaultFoodViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 31.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ChooseDefaultFoodViewController.h"
#import "FoodTypePickerViewController.h"

@interface ChooseDefaultFoodViewController ()
{
    NSArray *_essen;
    NSIndexPath *_selectedFood;
}

- (void)weiterButtonClicked:(id)sender;

@end

@implementation ChooseDefaultFoodViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSString *defaultMensa = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_MENSA];
        if ([defaultMensa isEqualToString:[kMENSA_UNI lowercaseString]])
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_UNI];
        }
        else if ([defaultMensa isEqualToString:[kMENSA_GW2 lowercaseString]])
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_GW2];
        }
        else if ([defaultMensa isEqualToString:[kMENSA_AIR lowercaseString]])
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_AIR];
        }
        else if ([defaultMensa isEqualToString:[kMENSA_BHV lowercaseString]])
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_BHV];
        }
        else if ([defaultMensa isEqualToString:[kMENSA_HSB lowercaseString]])
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_HSB];
        }
        else //wer
        {
            _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_WER];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[_essen objectAtIndex:0] forKey:kDEFAULTS_DEFAULT_FOOD_TYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.navigationItem.title = NSLocalizedString(@"Lieblingsessen", @"Lieblingsessen");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Weiter", @"Weiter") style:UIBarButtonItemStyleBordered target:self action:@selector(weiterButtonClicked:)];
        self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
        self.tableView.backgroundView = nil;
    }
    return self;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Lieblingsessen wählen", @"Lieblingsessen wählen");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"Dein Lieblingsessen wird dir an Wochentagen direkt auf der Übersichtsseite angezeigt.", @"Dein Lieblingsessen wird dir an Wochentagen direkt auf der Übersichtsseite angezeigt.");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _essen.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_essen objectAtIndex:indexPath.row];
    cell.opaque = YES;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_selectedFood isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        if (!_selectedFood && indexPath.row == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_selectedFood)
    {
        _selectedFood = indexPath;
        [tableView reloadData];
    }
    else if ([_selectedFood isEqual:indexPath])
    {
        return;
    }
    else
    {
        NSIndexPath *tmpIndexPath = _selectedFood;
        _selectedFood = indexPath;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_selectedFood, tmpIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UIBarButtonItem

- (void)weiterButtonClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[_essen objectAtIndex:_selectedFood.row] forKey:kDEFAULTS_DEFAULT_FOOD_TYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    FoodTypePickerViewController *ftpvc = [[FoodTypePickerViewController alloc] initWithNibName:@"FoodTypePickerViewController" bundle:nil];
    [self.navigationController pushViewController:ftpvc animated:YES];
}

@end
