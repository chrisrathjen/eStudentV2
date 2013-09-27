//
//  EditEntryView.m
//  eStudent
//
//  Created by Nicolas Autzen on 19.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "EditEntryView.h"
#import <QuartzCore/QuartzCore.h>
#import "EintragsView.h"
#import "Eintrag.h"
#import "StudiumsplanerViewController.h"
#import "NeuerEintragViewController.h"
#import "NoteEintragenView.h"
#import "CoreDataDataManager.h"
#import "UebersichtViewController.h"

@interface EditEntryView ()
{
    UIButton *_editEntryButton;
    UIView *_checkEntryAsPassedView;
    UISwitch *_passedSwitch;
    
    id _presentingViewController;
    EintragsView *_selectedEintragsView;
    Eintrag *_selectedEintrag;
    BOOL _isVisible;
    
    NoteEintragenView *_notenView;
    NSString *_noteEintragenTextFieldString;
}

- (void)prepareEditEntryView;
- (void)prepareButtonsForEditingEntries;

- (void)highlightButton:(UIButton *)button;
- (void)editEntry:(UIButton *)button;
- (void)removeHighlight:(UIButton *)button;

- (void)entryPassedValueToggled:(UISwitch *)sender;
- (void)hideSelf;

@end

@implementation EditEntryView

@synthesize editEntryView = _editEntryView;

//Falls noch kein Singleton existiert wird eins erstellt und dann zurückgegeben.
+ (EditEntryView *)sharedInstance
{
    static EditEntryView *editEntryView;
    if (!editEntryView)
    {
        editEntryView = [[self alloc] init];
        [editEntryView prepareEditEntryView];
    }
    
    return editEntryView;
}

//Bereitet die Bearbeiten-Leiste vor.
- (void)prepareEditEntryView
{
    _editEntryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 42.0)];
    _editEntryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_background"]];
    
    //hier wird ein BezierPath erstellt, dadurch werden nur die beiden unteren Ecken abgerundet
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_editEntryView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _editEntryView.bounds;
    maskLayer.path = maskPath.CGPath;
    _editEntryView.layer.mask = maskLayer;
    
    [self prepareButtonsForEditingEntries];
    [_editEntryView addSubview:_editEntryButton];
    [_editEntryView addSubview:_checkEntryAsPassedView];
}

//Erstellt den Bearbeiten-Button und das Bestanden-Feld mit dem Switch drin.
- (void)prepareButtonsForEditingEntries
{
    /* editEntryButton */
    _editEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editEntryButton.frame = CGRectMake(2.0, 5.0, 113.0, 34.0);
    // Draw a custom gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.cornerRadius = 5.0;
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = _editEntryButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] CGColor],
                       nil];
    [_editEntryButton.layer insertSublayer:gradient atIndex:0];
    
    UILabel *editButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 113.0, 22.0)];
    editButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    editButtonLabel.textAlignment = NSTextAlignmentCenter;
    editButtonLabel.text = NSLocalizedString(@"Bearbeiten", @"Bearbeiten");
    editButtonLabel.backgroundColor = [UIColor clearColor];
    editButtonLabel.textColor = [UIColor whiteColor];
    [_editEntryButton addSubview:editButtonLabel];
    
    [_editEntryButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    [_editEntryButton addTarget:self action:@selector(editEntry:) forControlEvents:UIControlEventTouchUpInside];
    [_editEntryButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    /* checkEntryAsPassedView */
    _checkEntryAsPassedView = [[UIView alloc] initWithFrame:CGRectMake(117.0, 5.0, 181.0, 34.0)];
    // Draw a custom gradient
    gradient = [CAGradientLayer layer];
    gradient.cornerRadius = 5.0;
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = _checkEntryAsPassedView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.0] CGColor],
                       nil];
    [_checkEntryAsPassedView.layer insertSublayer:gradient atIndex:0];
    
    UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 102.0, 22.0)];
    checkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    checkLabel.text = NSLocalizedString(@"Bestanden", @"Bestanden");
    checkLabel.textAlignment = NSTextAlignmentCenter;
    checkLabel.backgroundColor = [UIColor clearColor];
    checkLabel.textColor = [UIColor darkTextColor];
    [_checkEntryAsPassedView addSubview:checkLabel];
    
    _passedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    CGRect frame = _passedSwitch.frame;
    frame.origin.x = _checkEntryAsPassedView.frame.size.width - frame.size.width - 5.0;
    frame.origin.y = 3.5;
    _passedSwitch.frame = frame;
    [_passedSwitch addTarget:self action:@selector(entryPassedValueToggled:) forControlEvents:UIControlEventValueChanged];
    if ([_passedSwitch respondsToSelector:@selector(setOnImage:)])
    {
        _passedSwitch.onImage = [UIImage imageNamed:@"checkmark_switch"];
    }
    
    [_checkEntryAsPassedView addSubview:_passedSwitch];
}

#pragma mark - ButtonControlStates

//Highlighted den Bearbeiten-Button, wenn dieser vom Nutzer gedrückt wird.
- (void)highlightButton:(UIButton *)button
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.cornerRadius = 5.0;
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = button.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0] CGColor],
                       nil];
    [button.layer insertSublayer:gradient atIndex:1];
}

//Löscht das Highlight des Buttons wieder.
- (void)removeHighlight:(UIButton *)button
{
    [[[button.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
}

//Wird der Bearbeiten-Button betätigt, wird dem Nutzer die Eingabemaske präsentiert, über den er diesen bestimmten Eintrag bearbeiten kann.
- (void)editEntry:(UIButton *)button
{
    [self removeHighlight:button];
    NeuerEintragViewController *nevc = [[NeuerEintragViewController alloc] initWithNibName:@"NeuerEintragViewController" bundle:nil];
    nevc.title = NSLocalizedString(@"Eintrag bearbeiten", @"Eintrag bearbeiten");
    nevc.eintrag = _selectedEintrag;
    nevc.semester = _selectedEintrag.semester;
    nevc.studiengang = _selectedEintrag.studiengang;
    [((UIViewController *)_presentingViewController).navigationController presentViewController:nevc animated:YES completion:nil];
}

#pragma mark - Present the EditEntryView under a EintragsView

//Lädt die Bearbeiten-Leiste unter dem angetippten Eintrag. Bzw. sollte diese schon ausgefahren sein, wird sie wieder versteckt.
- (void)presentSelfWithViewController:(id)sender EintragsView:(EintragsView *)eintragsView
{
    _selectedEintrag = eintragsView.eintrag;
    _passedSwitch.on = [_selectedEintrag.bestanden boolValue];
    
    float animationHeight = _editEntryView.frame.size.height - 4.0;
    
    //Wenn auf einen Eintrag zweimal getippt wird, wird die Leiste wieder eingefahren.
    if (_selectedEintragsView == eintragsView)
    {
        for (int i = _selectedEintragsView.subviews.count-1; i >= 0; i--)
        {
            UIView *view = [_selectedEintragsView.subviews objectAtIndex:i];
            if ([view isKindOfClass:[UIImageView class]])
            {
                if (view.tag == 22)
                {
                    ((UIImageView *)view).image = [UIImage imageNamed:@"tapIndicator"];
                    break;
                }
            }
        }
        [self hideSelf];
    }
    else
    {
        //Wenn die Leiste bereits unter einem anderen Eintragsview ausgefahren ist, muss sie dort eingefahren werden, damit sie unter dem aktuell
        //angetippten ausfahren kann. Sämtliche nach unten verschobenen Eintragsviews müssen wieder hochgefahren werden.
        if (_isVisible)
        {
            for (int i = _selectedEintragsView.subviews.count-1; i >= 0; i--)
            {
                UIView *view = [_selectedEintragsView.subviews objectAtIndex:i];
                if ([view isKindOfClass:[UIImageView class]])
                {
                    if (view.tag == 22)
                    {
                        ((UIImageView *)view).image = [UIImage imageNamed:@"tapIndicator"];
                        break;
                    }
                }
            }
            [[[_selectedEintragsView.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
            [UIView animateWithDuration:.2 animations:^{
                _editEntryView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
            }];
            
            if ([_presentingViewController isEqual:sender])
            {
                NSArray *subviews;
                if ([sender isKindOfClass:[StudiumsplanerViewController class]])
                {
                    subviews = ((StudiumsplanerViewController*)sender).scrollViewWithSelectedEintrag.subviews;
                }
                else
                {
                    subviews = ((UebersichtViewController*)sender).scrollViewWithSelectedEintrag.subviews;
                }
                for (id e in subviews)
                {
                    if ([e isKindOfClass:[EintragsView class]] && ((EintragsView *)e).wasMovedDown)
                    {
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:.2];
                        CGRect frame = ((EintragsView *)e).frame;
                        frame.origin.y -= animationHeight;
                        ((EintragsView *)e).frame = frame;
                        ((EintragsView *)e).wasMovedDown = NO;
                        [UIView commitAnimations];
                    }
                    else if ([e isKindOfClass:[UIScrollView class]])
                    {
                        for (id ein in ((UIScrollView *)e).subviews)
                        {
                            if ([ein isKindOfClass:[EintragsView class]] && ((EintragsView *)ein).wasMovedDown)
                            {
                                CGRect frame = ((EintragsView *)ein).frame;
                                frame.origin.y -= animationHeight;
                                ((EintragsView *)ein).frame = frame;
                                ((EintragsView *)ein).wasMovedDown = NO;
                            }
                            else if ([ein isKindOfClass:[UIView class]] && ((UIView *)ein).tag == 99)
                            {
                                CGRect frame = ((UIView *)ein).frame;
                                frame.origin.y -= animationHeight;
                                ((UIView *)ein).frame = frame;
                                ((UIView *)ein).tag = 98;
                            }
                        }
                    }
                    else if ([e isKindOfClass:[UIView class]] && ((UIView *)e).tag == 99)
                    {
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:.2];
                        CGRect frame = ((UIView *)e).frame;
                        frame.origin.y -= animationHeight;
                        ((UIView *)e).frame = frame;
                        [UIView commitAnimations];
                        ((UIView *)e).tag = 98;
                    }
                }
                
                if ([sender isKindOfClass:[StudiumsplanerViewController class]])
                {
                    CGSize size = ((StudiumsplanerViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize;
                    size.height -= animationHeight;
                    ((StudiumsplanerViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize = size;
                }
                else
                {
                    CGSize size = ((UebersichtViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize;
                    size.height -= animationHeight;
                    ((UebersichtViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize = size;
                }
                //CGSize size = ((UIScrollView *)eintragsView.superview).contentSize;
                //size.height -= animationHeight;
                //((UIScrollView *)eintragsView.superview).contentSize = size;
            }
            else
            {
                NSArray *subviews;
                if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
                {
                    subviews = ((StudiumsplanerViewController *)_presentingViewController).scrollViewWithSelectedEintrag.subviews;
                }
                else
                {
                    subviews = ((UebersichtViewController *)_presentingViewController).scrollViewWithSelectedEintrag.subviews;
                }
                for (id e in subviews)
                {
                    if ([e isKindOfClass:[EintragsView class]] && ((EintragsView *)e).wasMovedDown)
                    {
                        CGRect frame = ((EintragsView *)e).frame;
                        frame.origin.y -= animationHeight;
                        ((EintragsView *)e).frame = frame;
                        ((EintragsView *)e).wasMovedDown = NO;
                    }
                    else if ([e isKindOfClass:[UIView class]] && ((UIView *)e).tag == 99)
                    {
                        CGRect frame = ((UIView *)e).frame;
                        frame.origin.y -= animationHeight;
                        ((UIView *)e).frame = frame;
                        ((UIView *)e).tag = 98;
                    }
                }
                
                if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
                {
                    CGSize size = ((StudiumsplanerViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize;
                    size.height -= animationHeight;
                    ((StudiumsplanerViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize = size;
                }
                else
                {
                    CGSize size = ((UebersichtViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize;
                    size.height -= animationHeight;
                    ((UebersichtViewController *)_presentingViewController).scrollViewWithSelectedEintrag.contentSize = size;
                }
            }
            
        }
        _presentingViewController = sender;
        _selectedEintragsView = eintragsView;
        
        for (int i = _selectedEintragsView.subviews.count-1; i >= 0; i--)
        {
            UIView *view = [_selectedEintragsView.subviews objectAtIndex:i];
            if ([view isKindOfClass:[UIImageView class]])
            {
                if (view.tag == 22)
                {
                    ((UIImageView *)view).image = [UIImage imageNamed:@"tapIndicator_u"];
                    break;
                }
            }
        }
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.cornerRadius = 5.0;
        [gradient setBorderWidth:1.0f];
        [gradient setBorderColor:[[UIColor grayColor] CGColor]];
        gradient.frame = _selectedEintragsView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0] CGColor],
                           nil];
        [_selectedEintragsView.layer insertSublayer:gradient atIndex:0];
        
        [eintragsView.superview addSubview:_editEntryView];
        [eintragsView.superview sendSubviewToBack:_editEntryView];
        
        CGRect frame = _editEntryView.frame;
        frame.origin.y = (_selectedEintragsView.frame.origin.y + _selectedEintragsView.frame.size.height - 42.0);
        frame.origin.x = _selectedEintragsView.frame.origin.x;
        _editEntryView.frame = frame;
        _editEntryView.hidden = NO;
        
        [UIView animateWithDuration:.2 animations:^{
            _editEntryView.transform = CGAffineTransformMakeTranslation(0.0, 38.0);
        }];
        
        _isVisible = YES;
        
        NSArray *subviews = eintragsView.superview.subviews;
        int indexOfTappedView = [subviews indexOfObject:eintragsView];
        for (int i = indexOfTappedView+1; i < subviews.count; i++)
        {
            id e = [subviews objectAtIndex:i];
            if ([e isKindOfClass:[EintragsView class]])
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.2];
                CGRect frame = ((EintragsView *)e).frame;
                frame.origin.y += animationHeight;
                ((EintragsView *)e).frame = frame;
                ((EintragsView *)e).wasMovedDown = YES;
                [UIView commitAnimations];
            }
            else if (([e isKindOfClass:[UIView class]] && ((UIView *)e).tag == 98))
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.2];
                CGRect frame = ((UIView *)e).frame;
                frame.origin.y += animationHeight;
                ((UIView *)e).frame = frame;
                [UIView commitAnimations];
                ((UIView *)e).tag = 99;
            }
        }
        
        CGSize size = ((UIScrollView *)eintragsView.superview).contentSize;
        size.height += animationHeight;
        ((UIScrollView *)eintragsView.superview).contentSize = size;
        
        if ([sender isKindOfClass:[StudiumsplanerViewController class]])
        {
            ((StudiumsplanerViewController*)sender).scrollViewWithSelectedEintrag = (UIScrollView *)eintragsView.superview;
        }
        else if ([sender isKindOfClass:[UebersichtViewController class]])
        {
            ((UebersichtViewController*)sender).scrollViewWithSelectedEintrag = (UIScrollView *)eintragsView.superview;
        }
        
    }
}

//Die Bearbeiten-Leiste wird wieder eingefahren. Sämtliche darunterliegenden Eintragsviews müssen wieder hochgefahren werden.
- (void)hideSelf
{
    [[[_selectedEintragsView.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
    [UIView animateWithDuration:.2 animations:^{
        _editEntryView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }];
    
    float animationHeight = _editEntryView.frame.size.height - 4.0;
    NSArray *subviews = _selectedEintragsView.superview.subviews;
    for (id e in subviews)
    {
        if ([e isKindOfClass:[EintragsView class]] && ((EintragsView *)e).wasMovedDown)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.2];
            CGRect frame = ((EintragsView *)e).frame;
            frame.origin.y -= animationHeight;
            ((EintragsView *)e).frame = frame;
            ((EintragsView *)e).wasMovedDown = NO;
            [UIView commitAnimations];
        }
        else if ([e isKindOfClass:[UIView class]] && ((UIView *)e).tag == 99)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.2];
            CGRect frame = ((UIView *)e).frame;
            frame.origin.y -= animationHeight;
            ((UIView *)e).frame = frame;
            [UIView commitAnimations];
            ((UIView *)e).tag = 98;
        }
    }
    CGSize size = ((UIScrollView *)_selectedEintragsView.superview).contentSize;
    size.height -= animationHeight;
    ((UIScrollView *)_selectedEintragsView.superview).contentSize = size;
    
    _selectedEintragsView = nil;
    _selectedEintrag = nil;
    _isVisible = NO;
    _presentingViewController = nil;
}

#pragma mark - Switch was switched

//Ein Eintrag wurde über den Switch als bestanden markiert oder die Bestanden-Markierung wurde wieder zurückgenommen.
- (void)entryPassedValueToggled:(UISwitch *)sender
{
    if (sender.on)
    {
        //Wird ein benoteter Eintrag als bestanden markiert fährt von oben die Leiste herunter, über die der Nutzer die Note eintippen muss.
        if ([_selectedEintrag.benotet boolValue])
        {
            if (!_notenView)
            {
                _notenView = [[NoteEintragenView alloc] initWithFrame:CGRectMake(0.0, -50.0, 320.0, 50.0)];
                _notenView.delegate = self;
                
            }
            else
            {
                [_notenView removeFromSuperview];
            }
            [((UIViewController *)_presentingViewController).view addSubview:_notenView];
            [_notenView slideDown];
        }
        //Ist ein Eintrag nich benotet, wird er einfach direkt als bestanden markiert.
        else
        {
            int kriterienCount = _selectedEintrag.kriterien.count;
            for (Kriterium *k in _selectedEintrag.kriterien)
            {
                if ([k.erledigt boolValue])
                {
                    kriterienCount--;
                }
            }
            
            if (kriterienCount > 0)
            {
                NSString *alertTitle = kriterienCount > 1 ? NSLocalizedString(@"offene Kriterien", @"offene Kriterien") : NSLocalizedString(@"offenes Kriterium", @"offenes Kriterium");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"Noch", @"Noch"), kriterienCount, alertTitle]
                                                                    message:NSLocalizedString(@"Wenn du den Eintrag als bestanden markierst, werden alle offenen Kriterien als erledigt markiert.", @"Wenn du den Eintrag als bestanden markierst, werden alle offenen Kriterien als erledigt markiert.")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                                          otherButtonTitles:NSLocalizedString(@"Bestanden", @"Bestanden"), nil];
                alertView.tag = 3;
                [alertView show];
            }
            else
            {
                if ([_presentingViewController isKindOfClass:[UebersichtViewController class]])
                {
                    ((StudiumsplanerViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:0]).shouldRefresh = YES;
                    ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
                }
                else if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
                {
                    ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
                }
                _selectedEintrag.bestanden = [NSNumber numberWithBool:YES];
                [((EintragsView *)_selectedEintragsView) setCheckmarkImage];
                [self hideSelf];
            }
        }
    }
    //Wird die Bestanden-Markierung wieder entfernt, muss der Nutzer diese Eingabe bestätigen.
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bist du sicher?", @"Bist du sicher?")
                                                            message:[_selectedEintrag.benotet boolValue] ? NSLocalizedString(@"Die eingetragene Note wird gelöscht.", @"Die eingetragene Note wird gelöscht.") : nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                                  otherButtonTitles:NSLocalizedString(@"Bestätigen", @"Bestätigen"), nil];
        alertView.tag = 1;
        [alertView show];
    }
}

#pragma mark - NoteEintragenViewDelegate

//Das Eintragen der Note wurde abgebrochen.
- (void)noteEintragenViewAbbrechenButtonPressed
{
    [_notenView slideUp];
    [_passedSwitch setOn:NO animated:YES];
}

//Die Note wurde eingetragen und der Eintrag bestätigt. Die Note wird für den Eintrag gespeichert und die Bestanden-Grafik wird dem Eintragsview hinzugefügt.
- (void)noteEintragenViewEintragenButtonPressedWithText:(NSString *)textfieldString
{
    int kriterienCount = _selectedEintrag.kriterien.count;
    for (Kriterium *k in _selectedEintrag.kriterien)
    {
        if ([k.erledigt boolValue])
        {
            kriterienCount--;
        }
    }
    
    if (kriterienCount > 0)
    {
        _noteEintragenTextFieldString = textfieldString;
        NSString *alertTitle = kriterienCount > 1 ? NSLocalizedString(@"offene Kriterien", @"offene Kriterien") : NSLocalizedString(@"offenes Kriterium", @"offenes Kriterium");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"Noch", @"Noch"), kriterienCount, alertTitle]
                                                            message:NSLocalizedString(@"Wenn du die Note einträgst, werden alle offenen Kriterien als erledigt markiert.", @"Wenn du die Note einträgst, werden alle offenen Kriterien als erledigt markiert.")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                                  otherButtonTitles:NSLocalizedString(@"Note eintragen", @"Note eintragen"), nil];
        alertView.tag = 2;
        [alertView show];
    }
    else
    {
        _selectedEintrag.note = [NSNumber numberWithDouble:[[textfieldString stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue]];
        _selectedEintrag.bestanden = [NSNumber numberWithBool:YES];
        [[CoreDataDataManager sharedInstance] saveDatabase];
        [_notenView slideUp];
        [((EintragsView *)_selectedEintragsView) setCheckmarkImage];
        if ([_presentingViewController isKindOfClass:[UebersichtViewController class]])
        {
            ((StudiumsplanerViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:0]).shouldRefresh = YES;
            ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
        }
        else if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
        {
            ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
        }
        _noteEintragenTextFieldString = nil;
        
        [self hideSelf];
    }
    
}

#pragma mark - UIAlertViewDelegate

//Der Nutzer muss seine Eingabe bestätigen.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (alertView.tag == 1)
        {
            if ([_selectedEintrag.bestanden boolValue])
            {
                [_passedSwitch setOn:YES animated:YES];
            }
            else
            {
                [_passedSwitch setOn:NO animated:YES];
            }
        }
        else if (alertView.tag == 2)
        {
            _noteEintragenTextFieldString = nil;
            [_notenView slideUp];
            [_passedSwitch setOn:NO animated:YES];
        }
        else if (alertView.tag == 3)
        {
            if ([_selectedEintrag.bestanden boolValue])
            {
                [_passedSwitch setOn:YES animated:YES];
            }
            else
            {
                [_passedSwitch setOn:NO animated:YES];
            }
        }
    }
    else if (buttonIndex == 1)
    {
        if (alertView.tag == 1)
        {
            if ([_selectedEintrag.benotet boolValue])
            {
                _selectedEintrag.note = nil;
            }
            
            if ([_presentingViewController isKindOfClass:[UebersichtViewController class]])
            {
                ((StudiumsplanerViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:0]).shouldRefresh = YES;
                ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
            }
            else if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
            {
                ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
            }
            
            if ([_selectedEintrag.bestanden boolValue])
            {
                _selectedEintrag.bestanden = [NSNumber numberWithBool:NO];
                [((EintragsView *)_selectedEintragsView) setCheckmarkImage];
                [self hideSelf];
            }
        }
        else if (alertView.tag == 2 || alertView.tag == 3)
        {
            for (Kriterium *k in _selectedEintrag.kriterien)
            {
                if (![k.erledigt boolValue])
                {
                    [k setErledigt:[NSNumber numberWithBool:YES]];
                }
            }
            [_selectedEintragsView removeKriterienLabel];
            
            if ([_selectedEintrag.benotet boolValue])
            {
                _selectedEintrag.note = [NSNumber numberWithDouble:[[_noteEintragenTextFieldString stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue]];
            }
            _selectedEintrag.bestanden = [NSNumber numberWithBool:YES];
            [[CoreDataDataManager sharedInstance] saveDatabase];
            [((EintragsView *)_selectedEintragsView) setCheckmarkImage];
            if ([_presentingViewController isKindOfClass:[UebersichtViewController class]])
            {
                ((StudiumsplanerViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:0]).shouldRefresh = YES;
                ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
            }
            else if ([_presentingViewController isKindOfClass:[StudiumsplanerViewController class]])
            {
                ((UebersichtViewController *)[((UIViewController *)_presentingViewController).tabBarController.viewControllers objectAtIndex:1]).shouldRefresh = YES;
            }
            
            _noteEintragenTextFieldString = nil;
            [_notenView slideUp];
            [self hideSelf];
        }
    }
}

@end
