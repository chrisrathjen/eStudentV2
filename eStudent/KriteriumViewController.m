//
//  KriteriumViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 18.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "KriteriumViewController.h"
#import "Kriterium.h"
#import "TMPKriterium.h"
#import "NeuerEintragViewController.h"
#import "CoreDataDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface KriteriumViewController ()
{
    __weak IBOutlet UIBarButtonItem *fertigButton;
    __weak IBOutlet UINavigationBar *navigationBar;
    __weak IBOutlet UITableView *_tableView;
    
    UISwitch *erledigtSwitch;
    NSString *kriterienTitel;
    NSDate *dueDate;
    UIActionSheet *actionSheet;
    UIDatePicker *datePickerView;
    CAGradientLayer *gradient;
    UIButton *deleteKriteriumButton;
}

- (IBAction)abbrechenButtonPressed:(id)sender;
- (IBAction)fertigButtonPressed:(id)sender;

- (void)highlightButton:(UIButton *)button;
- (void)removeHighlight:(UIButton *)button;
- (void)deleteKriterium:(UIButton *)button;
- (void)addDueDate:(id)sender;
- (void)deleteDueDate:(id)sender;
- (void)cancelAddingDueDate:(id)sender;
- (void)textFieldChanged:(NSNotification *)notification;

@end

@implementation KriteriumViewController

@synthesize kriterium;
@synthesize tmpKriterium;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Bereitet das UI vor.n
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
    navigationBar.topItem.title = NSLocalizedString(@"Kriterium", @"Kriterium");
    fertigButton.title = NSLocalizedString(@"Fertig", @"Fertig");
    _tableView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    
    if (kriterium || tmpKriterium)
    {        
        CGFloat height = IS_IPHONE_5 ? 440.0 : 352.0;
        deleteKriteriumButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, height, 300.0, 44.0)];
        deleteKriteriumButton.backgroundColor = [UIColor redColor];
        deleteKriteriumButton.layer.cornerRadius = 10.0;
        deleteKriteriumButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [deleteKriteriumButton setTitle:NSLocalizedString(@"Kriterium löschen", @"Kriterium löschen") forState:UIControlStateNormal];
        [deleteKriteriumButton setBackgroundColor:[UIColor redColor]];
        [deleteKriteriumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (!gradient)
        {
            gradient = [CAGradientLayer layer];
            gradient.frame = deleteKriteriumButton.bounds;
            gradient.borderWidth = 1.0;
            gradient.borderColor = [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1.0].CGColor;
            gradient.cornerRadius = 10.0;
            gradient.colors = [NSArray arrayWithObjects:
                               (id)[[UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.9 green:.4 blue:.4 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                               nil];
            [deleteKriteriumButton.layer insertSublayer:gradient atIndex:0];
        }
        
        [deleteKriteriumButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [deleteKriteriumButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
        [deleteKriteriumButton addTarget:self action:@selector(deleteKriterium:) forControlEvents:UIControlEventTouchUpInside];
        
        if (kriterium)
        {
            [fertigButton setEnabled:YES];
            kriterienTitel = kriterium.name;
            dueDate = kriterium.date;
            [_tableView addSubview:deleteKriteriumButton];
            
        }
        else
        {
            [fertigButton setEnabled:YES];
            kriterienTitel = tmpKriterium.name;
            dueDate = tmpKriterium.dueDate;
            [_tableView addSubview:deleteKriteriumButton];
        }
    }
    else
    {
        kriterienTitel = @"";
    }
    
    [_tableView reloadData];
}

#pragma mark - UIBarButtonItem Pressed

//Das Anlegen/Bearbeiten wird abgebrochen.
- (IBAction)abbrechenButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Ein Kriterium wird gespeichert.
- (IBAction)fertigButtonPressed:(id)sender
{
    NeuerEintragViewController *nevc = (NeuerEintragViewController *)self.presentingViewController;
    if (kriterium)
    {
        kriterium.name = kriterienTitel;
        kriterium.erledigt = [NSNumber numberWithBool:erledigtSwitch.on];
        kriterium.date = dueDate;
        [[CoreDataDataManager sharedInstance] saveDatabase];
    }
    else if (tmpKriterium)
    {
        tmpKriterium.name = kriterienTitel;
        tmpKriterium.completed = erledigtSwitch.on;
        tmpKriterium.dueDate = dueDate;
    }
    else
    {
        [nevc.tmpKriterien addObject:[[TMPKriterium alloc] initWithName:kriterienTitel isCompleted:erledigtSwitch.on dueDate:dueDate]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (!kriterium && !tmpKriterium)
        {
            return NSLocalizedString(@"Neues Kriterium", @"Neues Kriterium");
        }
        return nil;
    }
    return NSLocalizedString(@"Fälligkeitsdatum", @"Fälligkeitsdatum");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
return NSLocalizedString(@"Das Fälligkeitsdatum ist optional und dient als Erinnerungshilfe innerhalb des Studiumsplaners.", @"Fälligkeitsdatum Beschreibung");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Titel", @"Titel");
            
            UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 12.0, 185.0, 30.0)];
            txtField.font = [UIFont boldSystemFontOfSize:15.0];
            txtField.adjustsFontSizeToFitWidth = YES;
            txtField.textColor = [UIColor blackColor];
            txtField.clearButtonMode = UITextFieldViewModeNever;
            txtField.keyboardType = UIKeyboardTypeDefault;
            txtField.returnKeyType = UIReturnKeyDone;
            txtField.placeholder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Kriterienbeschreibung", @"Kriterienbeschreibung")];
            txtField.text = kriterienTitel;
            txtField.delegate = self;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textFieldChanged:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:txtField];
            
            [cell.contentView addSubview:txtField];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Erledigt?", @"Erledigt?");
            erledigtSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(83.0, 8.0, 185.0, 30.0)];
            erledigtSwitch.on = kriterium ? [kriterium.erledigt boolValue] : tmpKriterium ? tmpKriterium.completed : NO;
            
            [cell.contentView addSubview:erledigtSwitch];
        }
    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Datum", @"Datum");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (dueDate)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:dueDate];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

//Tippt der Nutzer auf die erste Zelle, kann er einen Titel eingeben/bearbeiten. Tippt er auf die dritte Zelle, fährt ein DatePicker
//von unten hoch und der Nutzer kann so ein Fälligkeitsdatum zu einem Eintrag anlegen/bearbeiten.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.row == 0)
        {
            [((UITextField *)[cell.contentView.subviews lastObject]) becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        toolBar.tintColor = [UIColor blackColor];
        UIBarButtonItem *addDateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Fertig", @"Fertig") style:UIBarButtonItemStyleDone target:self action:@selector(addDueDate:)];
        addDateButton.tintColor = [UIColor blueColor];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAddingDueDate:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //cancelButton.tintColor = [UIColor blueColor];
        if (dueDate)
        {
            UIBarButtonItem *deleteDueDateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Löschen", @"Löschen") style:UIBarButtonItemStyleDone target:self action:@selector(deleteDueDate:)];
            deleteDueDateButton.tintColor = [UIColor redColor];
            toolBar.items = [NSArray arrayWithObjects:cancelButton, flexibleSpace, deleteDueDateButton, addDateButton, nil];
        }
        else
        {
            toolBar.items = [NSArray arrayWithObjects:cancelButton, flexibleSpace, addDateButton, nil];
        }
        [actionSheet addSubview:toolBar];
        
        // Add the picker
        datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
        if (!dueDate)
        {
            datePickerView.date = [NSDate date];
        }
        else
        {
            datePickerView.date = dueDate;
        }
        
        datePickerView.datePickerMode = UIDatePickerModeDate;
        [actionSheet addSubview:datePickerView];
        [actionSheet showInView:self.view];
        [actionSheet setBounds:CGRectMake(0.0, 0.0, 320.0, 500.0)];
    }
}

//Der Nutzer hat ein Fälligkeitsdatum hinzugefügt.
- (void)addDueDate:(id)sender
{
    dueDate = datePickerView.date;
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

//Das Hinzufügen eines Fälligkeitsdatums wird abgebrochen.
- (void)cancelAddingDueDate:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO];
}

//Das Fälligkeitsdatum wird wieder gelöscht.
- (void)deleteDueDate:(id)sender
{
    dueDate = nil;
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Delete Kriterium Button States

//Der Löschen-Button wird bei Betätigung gehighlighted.
- (void)highlightButton:(UIButton *)button
{
    CAGradientLayer *hoverGradient = [CAGradientLayer layer];
    hoverGradient.frame = deleteKriteriumButton.bounds;
    hoverGradient.borderWidth = 1.0;
    hoverGradient.borderColor = [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1.0].CGColor;
    hoverGradient.cornerRadius = 10.0;
    hoverGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.9 green:.4 blue:.4 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1.0] CGColor],
                            nil];
    [button.layer insertSublayer:hoverGradient atIndex:1];
}

//Das Button Highlight wird wieder entfernt.
- (void)removeHighlight:(UIButton *)button
{
    [[[button.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
}

//Der Nutzer will das Kriterium löschen. Von unten fährt ein ActionsSheet hoch, den der Nutzer zum erfolgreichen Löschen bestätigen muss.
- (void)deleteKriterium:(UIButton *)button
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Kriterium löschen?", @"Kriterium löschen?")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                  destructiveButtonTitle:NSLocalizedString(@"Löschen", @"Löschen")
                                       otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

//Reagiert darauf, ob der Nutzer das Löschen des Kriterium bestätigt oder nicht.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //Kriterium löschen bestätigt
    {
        NeuerEintragViewController *nevc = (NeuerEintragViewController *)self.presentingViewController;
        if (kriterium)
        {
            [[CoreDataDataManager sharedInstance] deleteKriterium:kriterium];
        }
        else
        {
            [nevc.tmpKriterien removeObject:tmpKriterium];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        [self removeHighlight:deleteKriteriumButton];
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
    UITextField *textfield = notification.object;
    
    kriterienTitel = textfield.text;
    if (kriterienTitel.length > 0)
    {
        [fertigButton setEnabled:YES];
    }
    else
    {
        [fertigButton setEnabled:NO];
    }
}

@end
