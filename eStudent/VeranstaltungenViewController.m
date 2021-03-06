//
//  VeranstaltungenViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 20.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "VeranstaltungenViewController.h"
#import "MBProgressHUD.h"
#import "CoreDataDataManager.h"
#import "StudiengaengeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateBlock.h"
#import "Date.h"
#import "Lecture.h"
#import "StundenplanTableView.h"

@interface VeranstaltungenViewController ()
{
    UILabel *_dateLabel;
    UIScrollView *_scrollView;
    NSDate *_dateLabelDate;
    int _currentPage;
    StundenplanTableView *_leftView;
    NSArray *_datesForLeftView;
    StundenplanTableView *_middleView;
    NSArray *_datesForMiddleView;
    StundenplanTableView *_rightView;
    NSArray *_datesForRightView;
    BOOL _shouldChangeDay;
    BOOL _swipedToLeft;
    BOOL _swipedToRight;
    BOOL _shouldScroll;
    UIView *_dateLabelHeading;
    CAGradientLayer *_blueGradient;
    CAGradientLayer *_greyGradient;
    
    __weak UIButton *_weekBackButton;
    __weak UIButton *_weekFurtherButton;
}

- (void)loadViews;
- (void)setDateLabelHeadingBackgroundFromDate:(NSDate *)date;
- (BOOL)dateIsToday:(NSDate *)date;
- (void)weekBack:(id)sender;
- (void)weekFurther:(id)sender;

@end

@implementation VeranstaltungenViewController

@synthesize horizontalScrollingDisabled = _horizontalScrollingDisabled;

//Es wird verhindert, dass der Tag gewechselt werden kann, wenn der Nutzer gerade dabei ist eine Notiz anzulegen/zu bearbeiten.
- (void)setHorizontalScrollingDisabled:(BOOL)horizontalScrollingDisabled
{
    if (horizontalScrollingDisabled)
    {
        [_weekBackButton setEnabled:NO];
        [_weekFurtherButton setEnabled:NO];
    }
    else
    {
        [_weekBackButton setEnabled:YES];
        [_weekFurtherButton setEnabled:YES];
    }
    _horizontalScrollingDisabled = horizontalScrollingDisabled;
}

//Setzt den Titel der Navigationbar.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = NSLocalizedString(@"Stundenplan", @"Stundenplan");
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    [self loadViews];
}

//Erzeugt das UI.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    _dateLabelDate = [NSDate date];
    
    _dateLabelHeading = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    _blueGradient = [CAGradientLayer layer];
    [_blueGradient setBorderWidth:1.0f];
    [_blueGradient setBorderColor:[[UIColor blackColor] CGColor]];
    _blueGradient.frame = _dateLabelHeading.bounds;
    _blueGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.44 green:.64 blue:.83 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.20 green:.43 blue:.74 alpha:1.0] CGColor],
                            nil];
    [_dateLabelHeading.layer insertSublayer:_blueGradient atIndex:0];
    
    _greyGradient = [CAGradientLayer layer];
    [_greyGradient setBorderWidth:1.0f];
    [_greyGradient setBorderColor:[[UIColor blackColor] CGColor]];
    _greyGradient.frame = _dateLabelHeading.bounds;
    _greyGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.63 green:.63 blue:.63 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.47 green:.47 blue:.47 alpha:1.0] CGColor],
                            nil];
    
    _weekBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _weekBackButton.frame = CGRectMake(5.0, 4.0, 35.0, 22.0);
    [_weekBackButton setImage:[UIImage imageNamed:@"-7"] forState:UIControlStateNormal];
    [_weekBackButton addTarget:self action:@selector(weekBack:) forControlEvents:UIControlEventTouchUpInside];
    [_dateLabelHeading addSubview:_weekBackButton];
    
    _weekFurtherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _weekFurtherButton.frame = CGRectMake(_dateLabelHeading.frame.size.width - 40.0, 4.0, 35.0, 22.0);
    [_weekFurtherButton setImage:[UIImage imageNamed:@"+7"] forState:UIControlStateNormal];
    [_weekFurtherButton addTarget:self action:@selector(weekFurther:) forControlEvents:UIControlEventTouchUpInside];
    [_dateLabelHeading addSubview:_weekFurtherButton];
    
    [self.view addSubview:_dateLabelHeading];
    
    CGRect frame = _dateLabelHeading.frame;
    frame.origin.x += 5.0;
    frame.size.width -= 10.0;
    _dateLabel = [[UILabel alloc] initWithFrame:frame];
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.textColor = [UIColor whiteColor];
    _dateLabel.font = kCUSTOM_HEADER_LABEL_FONT;
    _dateLabel.adjustsFontSizeToFitWidth = YES;
    [_dateLabelHeading addSubview:_dateLabel];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    frame = _dateLabel.frame;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, _dateLabelHeading.frame.size.height, bounds.size.width, (IS_IPHONE_5 ? 455.0 - frame.size.height : 367.0 - frame.size.height))];
    _scrollView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    _scrollView.contentSize = CGSizeMake((_scrollView.frame.size.width * 3), _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    _currentPage = 1;
    _scrollView.delegate = self;
    _shouldScroll = YES;
    
    [self setDateLabelFromDate:_dateLabelDate];
}

#pragma mark - LoadViews

//Lädt die Stundenplan-Daten in die entsprechenden Views.
- (void)loadViews
{
    _datesForLeftView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:-86400 sinceDate:_dateLabelDate]];
    _datesForMiddleView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:_dateLabelDate];
    _datesForRightView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:86400 sinceDate:_dateLabelDate]];
    
    CGRect frame = _scrollView.frame;
    frame.origin.y = 0.0;
    [_leftView removeFromSuperview];
    _leftView = [[StundenplanTableView alloc] initWithFrame:frame DateArray:_datesForLeftView];
    [_scrollView addSubview:_leftView];
    
    [_middleView removeFromSuperview];
    frame.origin.x = frame.size.width;
    _middleView = [[StundenplanTableView alloc] initWithFrame:frame DateArray:_datesForMiddleView];
    [_scrollView addSubview:_middleView];
    
    [_rightView removeFromSuperview];
    frame.origin.x = frame.size.width * 2.0;
    _rightView = [[StundenplanTableView alloc] initWithFrame:frame DateArray:_datesForRightView];
    [_scrollView addSubview:_rightView];
}

#pragma mark - setDateLabelFromDate

//Setzt den Text des DateLabels auf das übergebene Datum und formatiert es vorher entsprechend.
- (void)setDateLabelFromDate:(NSDate *)date
{
    NSArray *weekdays = [NSArray arrayWithObjects:NSLocalizedString(@"Sonntag", @"Sonntag"), NSLocalizedString(@"Montag", @"Montag"), NSLocalizedString(@"Dienstag", @"Dienstag"), NSLocalizedString(@"Mittwoch", @"Mittwoch"), NSLocalizedString(@"Donnerstag", @"Donnerstag"), NSLocalizedString(@"Freitag", @"Freitag"), NSLocalizedString(@"Samstag", @"Samstag"), nil];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    NSString *weekday = [weekdays objectAtIndex:[components weekday]-1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]]; //hier auch noch die Identifier für andere Sprachen verfügbar machen
    NSString *title = [NSString stringWithFormat:@"%@, %@", weekday, [dateFormatter stringFromDate:date]];
    _dateLabel.text = title;
}

#pragma mark - UIScrollViewDelegate

//Reagiert darauf, wenn der Nutzer einen Tag vor- oder zurückwischt, was das Wechseln eines Tages bedeutet.
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (_horizontalScrollingDisabled)
    {
        if (sender.contentOffset.x != sender.frame.size.width)
        {
            sender.contentOffset = CGPointMake(sender.frame.size.width, sender.contentOffset.y);
        }
    }
    //prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= 5) //will man ueber Freitag hinaus nach rechts scrollen, einfach beenden, sonst stuerzt die App ab.
    {
        return;
    }
    int tmp = _currentPage;
    _currentPage = page;
    
    if (tmp > _currentPage && _shouldScroll) //wenn ein Tag zurück gewischt wird
    {
        _shouldChangeDay = YES;
        _swipedToLeft = YES;
        _swipedToRight = NO;
        _dateLabelDate = [NSDate dateWithTimeInterval:-86400 sinceDate:_dateLabelDate];
        [self setDateLabelFromDate:_dateLabelDate];
        [self setDateLabelHeadingBackgroundFromDate:_dateLabelDate];
    }
    else if (tmp < _currentPage && _shouldScroll) //wenn ein Tag weiter gewischt wird
    {
        _shouldChangeDay = YES;
        _swipedToLeft = NO;
        _swipedToRight = YES;
        //setzt das Datum einen Tag weiter
        _dateLabelDate = [NSDate dateWithTimeInterval:86400 sinceDate:_dateLabelDate];
        [self setDateLabelFromDate:_dateLabelDate];
        [self setDateLabelHeadingBackgroundFromDate:_dateLabelDate];
    }
}

//Diese Methode reagiert darauf, wenn nach dem Wechseln des Tages der Scrollview zum Stehen gekommen ist.
//In dem Fall werden die Stundenplan-Daten verschoben, wodurch der 'unendliche Scrollen' Effekt entsteht.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_shouldChangeDay)
    {
        _shouldChangeDay = NO;
        if (_swipedToLeft) //ein Tag zurückgewischt
        {
            NSArray *tmp = _datesForMiddleView.copy;
            _datesForMiddleView = _datesForLeftView.copy;
            _datesForRightView = tmp.copy;
            [_middleView setDates:_datesForMiddleView];
            [_rightView setDates:_datesForRightView];
            _shouldScroll = NO;
            [_middleView setContentOffset:CGPointZero animated:NO];
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0.0)];
            _shouldScroll = YES;
            _datesForLeftView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:-86400 sinceDate:_dateLabelDate]];
            [_leftView setDates:_datesForLeftView];
        }
        else if (_swipedToRight) //ein Tag weiter gewischt
        {
            NSArray *tmp = _datesForMiddleView.copy;
            _datesForMiddleView = _datesForRightView;
            _datesForLeftView = tmp.copy;
            [_middleView setDates:_datesForMiddleView];
            [_leftView setDates:_datesForLeftView];
            _shouldScroll = NO;
            [_middleView setContentOffset:CGPointZero animated:NO];
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0.0)];
            _shouldScroll = YES;
            _datesForRightView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:86400 sinceDate:_dateLabelDate]];
            [_rightView setDates:_datesForRightView];
        }
    }
}

#pragma mark - Pruefen ob ein Datum heute ist

//Verändert die Farbe des DateLabels. Blau, wenn das übergebene Datum dem aktuellen Tag entspricht und grau andernfalls.
- (void)setDateLabelHeadingBackgroundFromDate:(NSDate *)date

{
    if ([self dateIsToday:date]) //Der gepruefte Tag ist heute
    {
        CAGradientLayer *gradient = [[_dateLabelHeading.layer sublayers] objectAtIndex:0];
        [gradient removeFromSuperlayer];
        [_dateLabelHeading.layer insertSublayer:_blueGradient atIndex:0];
    }
    else
    {
        CAGradientLayer *gradient = [[_dateLabelHeading.layer sublayers] objectAtIndex:0];
        if ([gradient isEqual:_blueGradient])
        {
            [gradient removeFromSuperlayer];
            [_dateLabelHeading.layer insertSublayer:_greyGradient atIndex:0];
        }
    }
    
}

//Prüft ob der übergebene Tag der aktuelle ist.
- (BOOL)dateIsToday:(NSDate *)date
{
    NSDateComponents *componentsOfDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSDateComponents *componentsOfToday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    return ([componentsOfDate day] == [componentsOfToday day] && [componentsOfDate month] == [componentsOfToday month] && [componentsOfDate year] == [componentsOfToday year]);
}

#pragma mark - Eine ganze Woche vor oder zurueck wechseln

//Wechselt eine ganze Woche zurück und lädt die entsprechenden Stundenplan-Daten.
- (void)weekBack:(id)sender
{
    _dateLabelDate = [NSDate dateWithTimeInterval:-604800 sinceDate:_dateLabelDate];
    [self setDateLabelFromDate:_dateLabelDate];
    [self setDateLabelHeadingBackgroundFromDate:_dateLabelDate];
    _datesForLeftView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:-86400 sinceDate:_dateLabelDate]];
    [_leftView setDates:_datesForLeftView];
    _datesForRightView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:86400 sinceDate:_dateLabelDate]];
    [_rightView setDates:_datesForRightView];
    _datesForMiddleView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:_dateLabelDate];
    [_middleView setDatesForWeekBack:_datesForMiddleView];
    if (_datesForMiddleView.count > 0)
    {
        [_middleView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

//Wechselt eine ganze Woche vor und lädt die entsprechenden Stundenplan-Daten.
- (void)weekFurther:(id)sender
{
    _dateLabelDate = [NSDate dateWithTimeInterval:604800 sinceDate:_dateLabelDate];
    [self setDateLabelFromDate:_dateLabelDate];
    [self setDateLabelHeadingBackgroundFromDate:_dateLabelDate];
    _datesForLeftView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:-86400 sinceDate:_dateLabelDate]];
    [_leftView setDates:_datesForLeftView];
    _datesForRightView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:[NSDate dateWithTimeInterval:86400 sinceDate:_dateLabelDate]];
    [_rightView setDates:_datesForRightView];
    _datesForMiddleView = [[CoreDataDataManager sharedInstance] getAllActiveDatesForDate:_dateLabelDate];
    [_middleView setDatesForWeekFurther:_datesForMiddleView];
    if (_datesForMiddleView.count > 0)
    {
        [_middleView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


@end
