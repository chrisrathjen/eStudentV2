//
//  ArtViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 13.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ArtViewController.h"
#import "Eintrag.h"
#import "NeuerEintragViewController.h"
#import "ManuelleVeranstaltungViewController.h"

@implementation ArtViewController

@synthesize selectedCells;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    eintragsArten = [[NSUserDefaults standardUserDefaults] arrayForKey:kDEFAULTS_ENTRY_TYPES].mutableCopy;
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    navigationBar.topItem.title = NSLocalizedString(@"Eintrags-Arten", @"Eintrags-Arten");
    fertigButton.title = NSLocalizedString(@"Fertig", @"Fertig");
    bearbeitenButton.title = NSLocalizedString(@"Bearbeiten", @"Bearbeiten");
    _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    if (!selectedCells)
    {
        selectedCells = [[NSMutableArray alloc] init];
    }
    
    numberOfSections = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationBarItems

- (IBAction)fertigButtonPressed:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:eintragsArten forKey:kDEFAULTS_ENTRY_TYPES];
    [defaults synchronize];
    
    NSMutableString *string = @"".mutableCopy;
    for (int i = 0; i < selectedCells.count-1; i++)
    {
        [string appendString:[selectedCells objectAtIndex:i]];
        [string appendString:@" + "];
    }
    [string appendString:[selectedCells lastObject]];
    
    if ([self.presentingViewController isKindOfClass:[NeuerEintragViewController class]])
    {
        ((NeuerEintragViewController *)self.presentingViewController).eintragsArtString = string;
    }
    else
    {
        ((ManuelleVeranstaltungViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject]).eintragsArtString = string;
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)bearbeitenButtonPressed:(id)sender
{
    if (_tableView.isEditing)
    {
        [_tableView setEditing:NO animated:YES];
        [bearbeitenButton setTitle:NSLocalizedString(@"Bearbeiten", @"Bearbeiten")];
        numberOfSections--;
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        [txtField removeFromSuperview];
        
    }
    else
    {
        [_tableView setEditing:YES animated:YES];
        [bearbeitenButton setTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")];
        numberOfSections++;
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.isEditing)
    {
        if (section == 0)
        {
            return NSLocalizedString(@"Neue Eintrags-Art", @"Neue Eintrags-Art");
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (!tableView.isEditing && selectedCells.count > 1)
    {
        if (section == 0)
        {
            NSMutableString *string = @"".mutableCopy;
            for (int i = 0; i < selectedCells.count-1; i++)
            {
                [string appendString:[selectedCells objectAtIndex:i]];
                [string appendString:@" + "];
            }
            [string appendString:[selectedCells lastObject]];
            
            return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Eintrags-Art", @"Eintrags-Art"), string];
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.isEditing)
    {
        if (section == 0)
        {
            return 1;
        }
        
    }
    return eintragsArten.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell;
    if (tableView.isEditing)
    {
        if (indexPath.section == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    
    if (!cell)
    {
        if (tableView.isEditing)
        {
            if (indexPath.section == 1)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
            else
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            }
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        
    }
    
    
    if (!tableView.isEditing)
    {
        if (indexPath.section == 0)
        {
            NSString *eintragsArt = [eintragsArten objectAtIndex:indexPath.row];
            cell.textLabel.text = eintragsArt;
            
            if ([selectedCells containsObject:eintragsArt])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else
    {
        if (indexPath.section == 0)
        {
            txtField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 12.0, 280.0, 30.0)];
            txtField.font = [UIFont boldSystemFontOfSize:15.0];
            txtField.adjustsFontSizeToFitWidth = YES;
            txtField.textColor = [UIColor blackColor];
            txtField.clearButtonMode = UITextFieldViewModeNever;
            txtField.keyboardType = UIKeyboardTypeDefault;
            txtField.placeholder = NSLocalizedString(@"Bezeichnung", @"Bezeichnung");
            txtField.returnKeyType = UIReturnKeyDone;
            txtField.delegate = self;
            txtField.text = @"";
            
            [cell addSubview:txtField];
        }
        if (indexPath.section == 1)
        {
            NSString *eintragsArt = [eintragsArten objectAtIndex:indexPath.row];
            cell.textLabel.text = eintragsArt;
            
            if ([selectedCells containsObject:eintragsArt])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    cell.showsReorderControl  = YES;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || eintragsArten.count == 1)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    if (!tableView.isEditing)
    {
        if (indexPath.section == 0)
        {
            if ([selectedCells containsObject:cell.textLabel.text])
            {
                [selectedCells removeObject:cell.textLabel.text];
            }
            else
            {
                [selectedCells addObject:cell.textLabel.text];
            }
            if (selectedCells.count <= 0)
            {
                [fertigButton setEnabled:NO];
            }
            else
            {
                [fertigButton setEnabled:YES];
            }
            [tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [eintragsArten removeObject:cell.textLabel.text];
        if ([selectedCells containsObject:cell.textLabel.text])
        {
            [selectedCells removeObject:cell.textLabel.text];
        }
        
        NSArray *array = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int from = fromIndexPath.row;
    int to = toIndexPath.row;
    
    if (to != from)
    {
        id movedObject = [eintragsArten objectAtIndex:from];
        [eintragsArten removeObjectAtIndex:from];
        if (to >= [eintragsArten count])
        {
            [eintragsArten addObject:movedObject];
        }
        else
        {
            [eintragsArten insertObject:movedObject atIndex:to];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        if (![eintragsArten containsObject:textField.text])
        {
            [eintragsArten addObject:textField.text];
        }
        if (![selectedCells containsObject:textField.text])
        {
            [selectedCells addObject:textField.text];
        }
    }
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    [_tableView reloadData];
    
    return YES;
}

@end