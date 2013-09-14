//
//  NeuerStudiengangViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 29.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "NeuerStudiengangViewController.h"
#import "ErstesFachsemesterAuswahlViewController.h"

@interface NeuerStudiengangViewController ()
{
    NSArray *studiengaenge;
    NSString *chosenAbschlussArt;
    NSString *studiengangName;
    NSString *cp;
    UITextField *txtField1;
    UITextField *txtField2;
}

- (void)weiter:(id)sender;
- (void)abbrechen:(id)sender;
- (void)textFieldChanged:(NSNotification *)notification;
- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;

@end

@implementation NeuerStudiengangViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Neuer Studiengang", @"Neuer Studiengang");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Weiter", @"Weiter") style:UIBarButtonItemStylePlain target:self action:@selector(weiter:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStylePlain target:self action:@selector(abbrechen:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Zurück", @"Zurück") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    studiengaenge = [NSArray arrayWithObjects:kDEFAULTS_BACHELOR, kDEFAULTS_MASTER, kDEFAULTS_DIPLOM, kDEFAULTS_STAATSEXAMEN, kDEFAULTS_MAGISTER, nil];
    self.tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    if (!chosenAbschlussArt)
    {
        chosenAbschlussArt = kDEFAULTS_BACHELOR;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Name des Studiengangs", @"Name des Studiengangs");
    }
    else if (section == 1)
    {
        return NSLocalizedString(@"Anzahl der Credit Points für diesen Studiengang", @"Anzahl der Credit Points für diesen Studiengang");
    }
    
    return NSLocalizedString(@"Angestrebter Abschluss", @"Angestrebter Abschluss");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        return 1;
    }
    return studiengaenge.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
    }
    else
    {
         cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    if (indexPath.section == 0)
    {
        txtField1 = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
        txtField1.font = [UIFont boldSystemFontOfSize:15.0];
        txtField1.textColor = [UIColor blackColor];
        txtField1.clearButtonMode = UITextFieldViewModeNever;
        txtField1.keyboardType = UIKeyboardTypeDefault;
        txtField1.returnKeyType = UIReturnKeyDone;
        txtField1.placeholder = NSLocalizedString(@"Studiengang", @"Studiengang.");
        txtField1.delegate = self;
        txtField1.text = studiengangName;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:txtField1];
        
        cell.textLabel.text = @"Name";
        [cell.contentView addSubview:txtField1];
    }
    else if (indexPath.section == 1)
    {
        txtField2 = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
        txtField2.font = [UIFont boldSystemFontOfSize:15.0];
        txtField2.textColor = [UIColor blackColor];
        txtField2.clearButtonMode = UITextFieldViewModeNever;
        txtField2.keyboardType = UIKeyboardTypeNumberPad;
        txtField2.placeholder = [NSString stringWithFormat:@"%@ 180", NSLocalizedString(@"Z.B.", @"Z.B.")];
        txtField2.delegate = self;
        txtField2.text = cp;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:txtField2];
        
        cell.textLabel.text = @"CP";
        [cell.contentView addSubview:txtField2];
    }
    else
    {
        NSString *s = [studiengaenge objectAtIndex:indexPath.row];
        cell.textLabel.text = s;
        if ([s isEqualToString:chosenAbschlussArt])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if ([txtField1 isFirstResponder])
        {
            [txtField1 resignFirstResponder];
        }
        else if ([txtField2 isFirstResponder])
        {
            [txtField2 resignFirstResponder];
        }
        chosenAbschlussArt = [studiengaenge objectAtIndex:indexPath.row];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        UITextField *txt = (UITextField *)[[[[tableView cellForRowAtIndexPath:indexPath] contentView] subviews] lastObject];
        if ([txt isFirstResponder])
        {
            [txt resignFirstResponder];
        }
        else
        {
            [txt becomeFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NotificationCenter

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *txtfield = (UITextField *)notification.object;
    if (txtField1.text.length > 0 && txtField2.text.length > 0)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    if ([txtfield isEqual:txtField1])
    {
        studiengangName = txtField1.text;
    }
    else
    {
        cp = txtField2.text;
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.tableView.contentSize.height - kbSize.height * 1.3, 0.0);
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - NavigationBarButtonItems

- (void)weiter:(id)sender
{
    ErstesFachsemesterAuswahlViewController *efvc = [[ErstesFachsemesterAuswahlViewController alloc] initWithNibName:@"ErstesFachsemesterAuswahlViewController" bundle:nil];
    efvc.studiengangName = studiengangName;
    efvc.abschlussArt = chosenAbschlussArt;
    efvc.cp = [cp intValue];
    [self.navigationController pushViewController:efvc animated:YES];
}

- (void)abbrechen:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
