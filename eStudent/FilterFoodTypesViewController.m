//
//  FilterFoodTypesViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 01.06.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "FilterFoodTypesViewController.h"

@interface FilterFoodTypesViewController ()
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_foodTypes;
    NSMutableArray *_filteredFoodTypes;
}

@end

@implementation FilterFoodTypesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _foodTypes = [NSArray arrayWithObjects:NSLocalizedString(@"Schwein", @"Schwein"), NSLocalizedString(@"Geflügel", @"Geflügel"), NSLocalizedString(@"Rind", @"Rind"), NSLocalizedString(@"Wild", @"Wild"), NSLocalizedString(@"Lamm", @"Lamm"), NSLocalizedString(@"Fisch", @"Fisch"), NSLocalizedString(@"Vegetarisch", @"Vegetarisch"), NSLocalizedString(@"Vegan", @"Vegan"), nil];
        _filteredFoodTypes = ((NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kFILTERED_FOOD_TYPES]).mutableCopy;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kCUSTOM_SETTINGS_BACKGROUND_COLOR;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    
    self.navigationItem.title = NSLocalizedString(@"Essensarten", @"Essensarten");
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = NSLocalizedString(@"Welche Essensarten sollen angezeigt werden?", @"Welche Essensarten sollen angezeigt werden?");
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    footerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.numberOfLines = 0;
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerLabel.text = NSLocalizedString(@"Speisen, deren Essensart uns nicht vorliegt, werden immer angezeigt.", @"Speisen, deren Essenart uns nicht vorliegt, werden immer angezeigt.");
    CGRect frame = footerLabel.frame;
    CGSize size = [footerLabel.text sizeWithFont:footerLabel.font constrainedToSize:CGSizeMake(240.0, MAXFLOAT)];
    frame.size.height = size.height + 20.0;
    frame.size.width = size.width;
    frame.origin.x = 17.0;
    footerLabel.frame = frame;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    frame = view.frame;
    frame.size.width += 20.0;
    frame.origin.x = 0.0;
    view.frame = frame;
    [view addSubview:footerLabel];
    
    return view;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerview = [self tableView:tableView viewForHeaderInSection:section];
    return headerview.frame.size.height;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    UIView *footerview = [self tableView:tableView viewForFooterInSection:section];
    return footerview.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodTypes.count;
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
    cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *text = [_foodTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    if ([_filteredFoodTypes containsObject:text])
    {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    }
    else
    {
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *foodType = [_foodTypes objectAtIndex:indexPath.row];
    
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
    
    [[NSUserDefaults standardUserDefaults] setObject:_filteredFoodTypes forKey:kFILTERED_FOOD_TYPES];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
