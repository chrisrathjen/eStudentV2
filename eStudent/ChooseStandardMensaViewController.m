//
//  ChooseStandardMensaViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 01.06.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ChooseStandardMensaViewController.h"

@interface ChooseStandardMensaViewController ()
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_mensen;
    int _selectedMensaIndex;
    BOOL _isTableViewExpanded;
    NSArray *_essen;
    int _selectedFoodIndex;
}

@end

@implementation ChooseStandardMensaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _mensen = [NSArray arrayWithObjects:@"Uni Boulevard", @"GW2", @"Airport", @"Bremerhaven", @"Neustadtwall", @"Werderstraße", nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
        {
            _selectedMensaIndex = [_mensen indexOfObject:(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME]];
        }
        else
        {
            _selectedMensaIndex = 0;
        }
        switch (_selectedMensaIndex)
        {
            case 0:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_UNI];
                break;
            case 1:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_GW2];
                break;
            case 2:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_AIR];
                break;
            case 3:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_BHV];
                break;
            case 4:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_HSB];
                break;
            case 5:
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_WER];
                break;
            default:
                break;
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_FOOD_TYPE])
        {
            _selectedFoodIndex = [_essen indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_FOOD_TYPE]];
        }
        else
        {
            _selectedFoodIndex = 0;
        }
        
        self.view.backgroundColor = kCUSTOM_SETTINGS_BACKGROUND_COLOR;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        self.navigationItem.title = NSLocalizedString(@"Mensa & Essen", @"Mensa & Essen");
        _isTableViewExpanded = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME] ? YES : NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = NSLocalizedString(@"Standard-Mensa und Lieblingsessen wählen", @"Standard-Mensa und Lieblingsessen wählen");
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    footerLabel.text = NSLocalizedString(@"Dein Lieblingsessen deiner Standard-Mensa wird dir an Wochentagen direkt auf der Übersichtsseite angezeigt.", @"Dein Lieblingsessen deiner Standard-Mensa wird dir an Wochentagen direkt auf der Übersichtsseite angezeigt.");
    footerLabel.numberOfLines = 0;
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    return _isTableViewExpanded ? (_mensen.count + _essen.count) : _mensen.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isTableViewExpanded && indexPath.row > _selectedMensaIndex && indexPath.row < (_selectedMensaIndex + _essen.count + 1))
    {
        return 30.0;
    }
    return 44.0;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_isTableViewExpanded && indexPath.row > _selectedMensaIndex && indexPath.row < (_selectedMensaIndex + _essen.count + 1)) //wenn die Essen auch zusehen sind
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = [_essen objectAtIndex:(indexPath.row - _selectedMensaIndex - 1)];
        cell.detailTextLabel.text = nil;
        if (_selectedFoodIndex + _selectedMensaIndex + 1 == indexPath.row)
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"258-checkmark"]];
        }
        else
        {
            cell.accessoryView = nil;
        }
    }
    else
    {
        if ((_isTableViewExpanded && indexPath.row <= _selectedMensaIndex) || !_isTableViewExpanded)
        {
            NSString *text = [_mensen objectAtIndex:indexPath.row];
            cell.textLabel.text = text;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            NSString *text = [_mensen objectAtIndex:(indexPath.row - _essen.count)];
            cell.textLabel.text = text;
        }
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0];
        
        if (indexPath.row == _selectedMensaIndex && [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
        {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            if (!_isTableViewExpanded)
            {
                cell.detailTextLabel.text = [_essen objectAtIndex:_selectedFoodIndex];
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
        }
        else
        {
            cell.accessoryView = nil;
            cell.detailTextLabel.text = nil;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isTableViewExpanded)
    {
        if (indexPath.row > _selectedMensaIndex && indexPath.row < (_selectedMensaIndex + _essen.count + 1))
        {
            _selectedFoodIndex = indexPath.row - _selectedMensaIndex - 1;
        }
        else if (indexPath.row == _selectedMensaIndex)
        {
            _isTableViewExpanded = NO;
        }
        else
        {
            _selectedMensaIndex = (indexPath.row < _selectedMensaIndex) ? indexPath.row : indexPath.row - _essen.count;
            _selectedFoodIndex = 0;
            _essen = nil;
            switch (_selectedMensaIndex)
            {
                case 0:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_UNI];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_UNI lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 1:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_GW2];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_GW2 lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 2:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_AIR];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_AIR lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 3:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_BHV];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_BHV lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 4:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_HSB];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_HSB lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 5:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_WER];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_WER lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                default:
                    break;
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[_essen objectAtIndex:_selectedFoodIndex] forKey:kDEFAULTS_DEFAULT_FOOD_TYPE];
        [[NSUserDefaults standardUserDefaults] setObject:[_mensen objectAtIndex:_selectedMensaIndex] forKey:kDEFAULTS_MENSA_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadData];
    }
    else
    {
        _isTableViewExpanded = YES;
        
        if (indexPath.row == _selectedMensaIndex)
        {
            if (![[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME] && indexPath.row == 0) //Sonderfall, kann nur einmalig auftreten
            {
                _selectedMensaIndex = 0;
                [[NSUserDefaults standardUserDefaults] setObject:[_mensen objectAtIndex:0] forKey:kDEFAULTS_MENSA_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_UNI lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_UNI];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [_tableView reloadData];
            return;
        }
        else
        {
            _selectedMensaIndex = indexPath.row;
            _selectedFoodIndex = 0;
            [[NSUserDefaults standardUserDefaults] setObject:[_mensen objectAtIndex:_selectedMensaIndex] forKey:kDEFAULTS_MENSA_NAME];
            
            _essen = nil;
            switch (_selectedMensaIndex)
            {
                case 0:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_UNI];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_UNI lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 1:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_GW2];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_GW2 lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 2:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_AIR];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_AIR lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 3:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_BHV];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_BHV lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 4:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_HSB];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_HSB lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                case 5:
                    _essen = [[NSUserDefaults standardUserDefaults] objectForKey:kMENSA_WER];
                    [[NSUserDefaults standardUserDefaults] setObject:[kMENSA_WER lowercaseString] forKey:kDEFAULTS_DEFAULT_MENSA];
                    break;
                default:
                    break;
            }
            if (_selectedMensaIndex != 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"Essen I" forKey:kDEFAULTS_DEFAULT_FOOD_TYPE];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"Pizza" forKey:kDEFAULTS_DEFAULT_FOOD_TYPE];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [tableView reloadData];
        }
    }
}

@end
