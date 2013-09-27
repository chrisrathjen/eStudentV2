//
//  NoteEintragenView.m
//  eStudent
//
//  Created by Nicolas Autzen on 07.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "NoteEintragenView.h"
#import <QuartzCore/QuartzCore.h>

@interface NoteEintragenView ()
{
    UITextField *_notenInputTextField;
    UIButton *cancelButton;
    UIButton *eintragenButton;
}

- (void)highlightButton:(UIButton *)sender;
- (void)removeHighlight:(UIButton *)sender;
- (void)cancelView:(UIButton *)sender;
- (void)setNote:(UIButton *)sender;
- (void)textFieldChanged:(NSNotification *)notification;

@end

@implementation NoteEintragenView

@synthesize delegate;

//Der überschriebene Initializer. erzeugt die Eingabeleiste.
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 5.0;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        [gradient setBorderWidth:1.0f];
        [gradient setBorderColor:[[UIColor blackColor] CGColor]];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] CGColor],
                           nil];
        [self.layer insertSublayer:gradient atIndex:1];
        
        UILabel *notenLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 12.0, 50.0, 21.0)];
        notenLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
        notenLabel.text = NSLocalizedString(@"Note:", @"Note:");
        notenLabel.backgroundColor = [UIColor clearColor];
        notenLabel.textColor = [UIColor whiteColor];
        [self addSubview:notenLabel];
        
        _notenInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(58.0, 8.0, 45.0, 30.0)];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        _notenInputTextField.font = font;
        _notenInputTextField.borderStyle = UITextBorderStyleRoundedRect;
        _notenInputTextField.textAlignment = NSTextAlignmentCenter;
        _notenInputTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _notenInputTextField.backgroundColor = [UIColor whiteColor];
        [self addSubview:_notenInputTextField];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(110.0, 9.0, 105.0, 30.0);
        gradient = [CAGradientLayer layer];
        gradient.cornerRadius = 5.0;
        [gradient setBorderWidth:1.0f];
        [gradient setBorderColor:[[UIColor blackColor] CGColor]];
        gradient.frame = cancelButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0] CGColor],
                           nil];
        [cancelButton.layer insertSublayer:gradient atIndex:0];
        
        [cancelButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [cancelButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
        [cancelButton addTarget:self action:@selector(cancelView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:cancelButton];
        
        eintragenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [eintragenButton setTitle:NSLocalizedString(@"Eintragen", @"Eintragen") forState:UIControlStateNormal];
        eintragenButton.frame = CGRectMake(220.0, 9.0, 95.0, 30.0);
        
        gradient = [CAGradientLayer layer];
        gradient.cornerRadius = 5.0;
        [gradient setBorderWidth:1.0f];
        [gradient setBorderColor:[[UIColor blackColor] CGColor]];
        gradient.frame = eintragenButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.5 green:.9 blue:.5 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.2 green:.4 blue:.2 alpha:1.0] CGColor],
                           nil];
        [eintragenButton.layer insertSublayer:gradient atIndex:0];
        
        [eintragenButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [eintragenButton addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchUpOutside];
        [eintragenButton addTarget:self action:@selector(setNote:) forControlEvents:UIControlEventTouchUpInside];
        [eintragenButton setEnabled:NO];
        
        eintragenButton.layer.opacity = .6;
        
        [self addSubview:eintragenButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_notenInputTextField];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Highlighted die Button, wenn der Nuzter auf sie tippt.
- (void)highlightButton:(UIButton *)sender
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.cornerRadius = 5.0;
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = sender.bounds;
    if (sender == cancelButton)
    {
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0] CGColor],
                           nil];
    }
    else
    {
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.2 green:.4 blue:.2 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.5 green:.9 blue:.5 alpha:1.0] CGColor],
                           nil];
    }
    [sender.layer insertSublayer:gradient atIndex:1];
}

//Löscht die highlights wieder, wenn der Nutzer den Button wieder loslässt.
- (void)removeHighlight:(UIButton *)sender
{
    [[[sender.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
}

//Bricht die Noteneingabe ab.
- (void)cancelView:(UIButton *)sender
{
    [[[sender.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
    _notenInputTextField.text = @"";
    [_notenInputTextField resignFirstResponder];
    [self.delegate noteEintragenViewAbbrechenButtonPressed];
}

//Der Button um die Note einzutragen wird betätigt.
- (void)setNote:(UIButton *)sender
{
    [[[sender.layer sublayers] objectAtIndex:1] removeFromSuperlayer];
    [_notenInputTextField resignFirstResponder];
    [self.delegate noteEintragenViewEintragenButtonPressedWithText:_notenInputTextField.text];
}

//Die Notenleiste wird von oben heruntergefahren.
- (void)slideDown
{
    [_notenInputTextField becomeFirstResponder];
    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0.0, 50.0);
    }];
    [eintragenButton setEnabled:NO];
    eintragenButton.layer.opacity = .6;

}

//Die Notenleiste wird zurückgefahren.
- (void)slideUp
{
    [_notenInputTextField resignFirstResponder];
    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        _notenInputTextField.text = @"";
    }];
}

//Prüft nach einer Eingabe des Nutzers, ob die Note im validen Bereich liegt. Wenn ja, wird der 'Eintragen' Button aktiviert.
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    if (textfield.text.length > 0)
    {
        double note = [[textfield.text stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
        if (note && note >= 1.0 && note <= 4.04)
        {
            [eintragenButton setEnabled:YES];
            eintragenButton.layer.opacity = 1.0;
        }
        else
        {
            [eintragenButton setEnabled:NO];
            eintragenButton.layer.opacity = .6;
        }
    }
    else
    {
        [eintragenButton setEnabled:NO];
        eintragenButton.layer.opacity = .6;
    }
}

@end
