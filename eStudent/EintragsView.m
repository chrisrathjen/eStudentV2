//
//  EintragsView.m
//  eStudent
//
//  Created by Nicolas Autzen on 03.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "EintragsView.h"
#import "Eintrag.h"
#import "Kriterium.h"
#import "EditEntryView.h"
#import <QuartzCore/QuartzCore.h>

@interface EintragsView ()
{
    UIImageView *_checkmark;
    UIViewController *_viewController;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_kriterienLabel;
    int _kriterienCounter;
    UILabel *_notenLabel;
    float _heightToMove;
    UIImageView *_tapIndicator;
}

- (void)drawView;
- (void)showEditEntryView:(UITapGestureRecognizer *)sender;
- (NSDate *)normalizedDateWithDate:(NSDate *)date;

@end

@implementation EintragsView

@synthesize eintrag = _eintrag;
@synthesize wasMovedDown;

- (id)initWithFrame:(CGRect)frame eintrag:(Eintrag *)eintrag viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _viewController = viewController;
        _eintrag = eintrag;
        [self drawView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEditEntryView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)drawView
{
    float yOffset = 0.0;
    
    self.layer.cornerRadius = 5.0;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOffset = CGSizeMake(0, .5);
    self.layer.shadowOpacity = .4;
    self.layer.shouldRasterize = YES; //wichtig für die Performance
    self.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
    self.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 10.0, 280, 21.0)];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.numberOfLines = 0;
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
    _titleLabel.font = titleFont;
    _titleLabel.text = [NSString stringWithFormat:@"%@", _eintrag.titel];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLabel];
    
    CGSize constraintSize = CGSizeMake(280.0, MAXFLOAT);
    CGSize titleSize = [_titleLabel.text sizeWithFont:titleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = _titleLabel.frame;
    frame.size = titleSize,
    _titleLabel.frame = frame;
    yOffset = titleSize.height + _titleLabel.frame.origin.y + 5.0;
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, yOffset, 280.0, 21.0)];
    _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = [UIColor grayColor];
    UIFont *detailLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    _detailLabel.font = detailLabelFont;
    _detailLabel.text = [NSString stringWithFormat:@"%@ CP, %@", _eintrag.cp, _eintrag.art];
    _detailLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_detailLabel];
    
    CGSize detailLabelSize = [_detailLabel.text sizeWithFont:detailLabelFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    frame = _detailLabel.frame;
    frame.size = detailLabelSize,
    _detailLabel.frame = frame;
    yOffset = detailLabelSize.height + _detailLabel.frame.origin.y + 10.0;
    
    frame = self.frame;
    frame.size.height = yOffset;
    self.frame = frame;
    
    _kriterienCounter = _eintrag.kriterien.count;
    BOOL kriteriumIsOverdue = NO;
    for (Kriterium *k in _eintrag.kriterien)
    {
        if ([k.erledigt boolValue])
        {
            _kriterienCounter--;
        }
        if (k.date && [[self normalizedDateWithDate:k.date] compare:[self normalizedDateWithDate:[NSDate date]]] == NSOrderedAscending)
        {
            kriteriumIsOverdue = YES;
        }
    }
    if (_kriterienCounter > 0)
    {
        _kriterienLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, yOffset - 10.0, 270.0, 21.0)];
        _kriterienLabel.textAlignment = NSTextAlignmentRight;
        _kriterienLabel.textColor = kriteriumIsOverdue ? [UIColor redColor] : kCUSTOM_BLUE_COLOR;
        UIFont *kriterienLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        _kriterienLabel.font = kriterienLabelFont;
        NSString *kriteriumString = _kriterienCounter > 1 ? NSLocalizedString(@"offene Kriterien", @"offene Kriterien") : NSLocalizedString(@"offenes Kriterium", @"offenes Kriterium");
        _kriterienLabel.text = [NSString stringWithFormat:@"%i %@", _kriterienCounter, kriteriumString];
        _kriterienLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_kriterienLabel];
        
        CGSize kriterienLabelSize = [_kriterienLabel.text sizeWithFont:kriterienLabelFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        frame = _kriterienLabel.frame;
        frame.size.height = kriterienLabelSize.height;
        _kriterienLabel.frame = frame;
        yOffset = kriterienLabelSize.height + _kriterienLabel.frame.origin.y + 10.0;
        
        frame = self.frame;
        frame.size.height = yOffset;
        self.frame = frame;
        yOffset = frame.origin.y + frame.size.height + 10.0;
    }
    
    yOffset = frame.origin.y + frame.size.height + 5.0;
    [self setCheckmarkImage];
    self.opaque = YES;
}

- (void)setCheckmarkImage
{
    if (_eintrag)
    {
        if ([_eintrag.bestanden boolValue])
        {
            if (!_checkmark)
            {
                _checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_done"]];
            }
            CGRect frame = _checkmark.frame;
            frame.origin.y -= 1.0;
            frame.origin.x = 300.0 - frame.size.width;
            _checkmark.frame = frame;
            [self addSubview:_checkmark];
            
            if ([_eintrag.benotet boolValue]) //der Eintrag ist benotet
            {
                float yOffset = _detailLabel.frame.origin.y + _detailLabel.frame.size.height + 5.0;
                _notenLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, yOffset, 270.0, 21.0)];
                _notenLabel.textAlignment = NSTextAlignmentRight;
                _notenLabel.backgroundColor = [UIColor clearColor];
                _notenLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
                _notenLabel.textColor = kCUSTOM_BLUE_COLOR;
                _notenLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Note", @"Note"), [[NSString stringWithFormat:@"%.1f",[_eintrag.note floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","]];
                
                CGSize constraintSize = CGSizeMake(280.0, MAXFLOAT);
                CGSize notenLabelSize = [_notenLabel.text sizeWithFont:_notenLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                frame = _notenLabel.frame;
                frame.size.height = notenLabelSize.height;
                _notenLabel.frame = frame;
                [self addSubview:_notenLabel];
                _heightToMove = notenLabelSize.height + 5.0;
                
                if (!_tapIndicator)
                {
                    _tapIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]];
                    _tapIndicator.tag = 22;
                    frame = _tapIndicator.frame;
                    frame.origin.x = self.frame.size.width/2.0 - frame.size.width/2.0;
                    frame.origin.y = _notenLabel.frame.size.height + _notenLabel.frame.origin.y + 5.0;
                    _tapIndicator.frame = frame;
                    [self addSubview:_tapIndicator];
                }
                else
                {
                    frame = _tapIndicator.frame;
                    frame.origin.y = _notenLabel.frame.size.height + _notenLabel.frame.origin.y + 5.0;
                    _tapIndicator.frame = frame;
                    _tapIndicator.image = [UIImage imageNamed:@"tapIndicator"];
                }
                
                frame = self.frame;
                frame.size.height = _tapIndicator.frame.origin.y + _tapIndicator.frame.size.height + 7.5;
                self.frame = frame;
                
                bool shouldMove = NO;
                for (EintragsView *view in self.superview.subviews)
                {
                    if ([view isEqual:self])
                    {
                        shouldMove = YES;
                        continue;
                    }
                    if (shouldMove)
                    {
                        frame = view.frame;
                        frame.origin.y += _heightToMove;
                        view.frame = frame;
                    }
                }
                CGSize contentSize = ((UIScrollView *)self.superview).contentSize;
                contentSize.height += _heightToMove;
                ((UIScrollView *)self.superview).contentSize = contentSize;
            }
            else
            {
                if (!_tapIndicator)
                {
                    _tapIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]];
                    _tapIndicator.tag = 22;
                    [self addSubview:_tapIndicator];
                    CGRect frame = _tapIndicator.frame;
                    frame.origin.x = self.frame.size.width/2.0 - frame.size.width/2.0;
                    frame.origin.y = self.frame.size.height - _tapIndicator.frame.origin.y - 5.0;
                    _tapIndicator.frame = frame;
                    frame = self.frame;
                    frame.size.height = _tapIndicator.frame.origin.y + _tapIndicator.frame.size.height + 7.5;
                    self.frame = frame;
                    //_heightToMove = _tapIndicator.frame.size.height + 7.5;
                }
                else
                {
                    frame = _tapIndicator.frame;
                    frame.origin.y = _detailLabel.frame.size.height + _detailLabel.frame.origin.y + 5.0;
                    _tapIndicator.frame = frame;
                    _tapIndicator.image = [UIImage imageNamed:@"tapIndicator"];
                    //_heightToMove = _tapIndicator.frame.size.height + 7.5;
                }
                
                frame = [[EditEntryView sharedInstance] editEntryView].frame;
                frame.origin.y = _tapIndicator.frame.size.height + _tapIndicator.frame.origin.y + 7.5;
                [[EditEntryView sharedInstance] editEntryView].frame = frame;
                //_heightToMove = 0.0;
            }
        }
        else
        {
            if (!_tapIndicator)
            {
                _tapIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]];
                _tapIndicator.tag = 22;
                CGRect frame = _tapIndicator.frame;
                frame.origin.x = self.frame.size.width/2.0 - frame.size.width/2.0;
                frame.origin.y = self.frame.size.height - _tapIndicator.frame.origin.y - 5.0;
                _tapIndicator.frame = frame;
                [self addSubview:_tapIndicator];
                frame = self.frame;
                frame.size.height = _tapIndicator.frame.origin.y + _tapIndicator.frame.size.height + 7.5;
                self.frame = frame;
            }
            else
            {
                if ([_eintrag.benotet boolValue])
                {
                    CGRect frame = _tapIndicator.frame;
                    frame.origin.y = _detailLabel.frame.size.height + _detailLabel.frame.origin.y + 5.0;
                    _tapIndicator.frame = frame;
                }
                
                _tapIndicator.image = [UIImage imageNamed:@"tapIndicator"];
            }
            
            if (_checkmark)
            {
                [_checkmark removeFromSuperview];
            }
            if (_notenLabel)
            {
                [_notenLabel removeFromSuperview];
            }
            
            if ([_eintrag.benotet boolValue])
            {
                CGRect frame = self.frame;
                frame.size.height -= _heightToMove;
                self.frame = frame;
                
                bool shouldMove = NO;
                for (EintragsView *view in self.superview.subviews)
                {
                    if ([view isEqual:self])
                    {
                        shouldMove = YES;
                        continue;
                    }
                    if (shouldMove)
                    {
                        frame = view.frame;
                        frame.origin.y -= _heightToMove;
                        view.frame = frame;
                    }
                }
                frame = [[EditEntryView sharedInstance] editEntryView].frame;
                frame.origin.y -= _heightToMove;
                [[EditEntryView sharedInstance] editEntryView].frame = frame;
                CGSize contentSize = ((UIScrollView *)self.superview).contentSize;
                contentSize.height -= _heightToMove;
                ((UIScrollView *)self.superview).contentSize = contentSize;
            }
        }
    }
}

#pragma mark - Show The EditEntryView

- (void)showEditEntryView:(UITapGestureRecognizer *)sender
{
    [[EditEntryView sharedInstance] presentSelfWithViewController:_viewController EintragsView:self];
}

#pragma mark - KriterienLabel entfernen

- (void)removeKriterienLabel
{
    _heightToMove = _kriterienLabel.frame.size.height;
    [_kriterienLabel removeFromSuperview];
    CGRect frame = self.frame;
    frame.size.height -= _heightToMove;
    self.frame = frame;
    bool shouldMove = NO;
    for (EintragsView *view in self.superview.subviews)
    {
        if ([view isEqual:self])
        {
            shouldMove = YES;
            continue;
        }
        if (shouldMove)
        {
            frame = view.frame;
            frame.origin.y -= _heightToMove;
            view.frame = frame;
        }
    }
}

#pragma mark - Normalizing a date

- (NSDate *)normalizedDateWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: date];
    return [calendar dateFromComponents:components];
}

@end
