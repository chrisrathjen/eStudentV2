//
//  EssenViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EssenViewController.h"
#import "ESMensaDataManager.h"
#import "FoodEntry.h"
#import "MBProgressHUD.h"

@interface EssenViewController ()
{
    __weak IBOutlet UILabel *dateLabel;
    UIPageControl *pageControl;
    UIScrollView *scrollView;
    ESMensaDataManager *dataManager;
    NSDate *currentDateToShow;
    
    UIImageView *_emptyStateImage;
    UITextView *_emptyStateText;
    
    UIImageView *_emptyStateNetwork;
    UITextView *_emptyStateNetworkText;
    
    UIView *_dateLabelHeading;
    CAGradientLayer *_blueGradient;
    CAGradientLayer *_greyGradient;
}

- (void)setDateLabelFromDate:(NSDate *)date;
- (BOOL)isWeekDay;
- (UIScrollView *)fillScrollView:(UIScrollView *)_scrollView withArray:(NSArray *)menu;
- (void)chooseMensa:(id)sender;
- (BOOL)dateIsToday:(NSDate *)date;
- (void)setDateLabelHeadingBackgroundFromDate:(NSDate *)date;

@end

@implementation EssenViewController

//Erstellt den Button und den Titel der NavigationBar.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.navigationItem.title = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSANAME_TO_SHOW] ? [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSANAME_TO_SHOW] : [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mensa", @"Mensa auswählen") style:UIBarButtonItemStylePlain target:self action:@selector(chooseMensa:)];
    }
    return self;
}

//Lädt das User Interface mit den Speiseplan-Daten.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
      //  self.edgesForExtendedLayout = UIRectEdgeNone;
    //}

    
    currentDateToShow = [NSDate date];
    dateLabel.font = kCUSTOM_HEADER_LABEL_FONT;
    
    [dateLabel removeFromSuperview];
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
    dateLabel.backgroundColor = [UIColor clearColor];
    [_dateLabelHeading addSubview:dateLabel];
    [self.view addSubview:_dateLabelHeading];
    
    //scrollView und pageControl werden programmatisch hinzugefügt, weil es im InterfaceBuilder Probleme mit den verschiedenen Geräte-Größen gab
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, (bounds.size.height - 90.0), bounds.size.width, 36.0)];
    pageControl.backgroundColor = [UIColor blackColor];

    [self.view addSubview:pageControl];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, _dateLabelHeading.frame.size.height, bounds.size.width, (bounds.size.height - _dateLabelHeading.frame.size.height - self.navigationController.navigationBar.frame.size.height))];
    scrollView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //setzt den EssenView auf den richtigen Tag
    if ([self isWeekDay]) //prüft ob kein Wochenende ist
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        scrollView.frame = CGRectMake(0.0, dateLabel.frame.size.height, bounds.size.width, (bounds.size.height - pageControl.frame.size.height - dateLabel.frame.size.height - self.navigationController.navigationBar.frame.size.height));
        scrollView.contentSize = CGSizeMake((scrollView.frame.size.width * 5), scrollView.frame.size.height);
        
        //der MensaDataManager wird initialisiert und holt sich die Mensadaten von Server
        dataManager = [[ESMensaDataManager alloc] init];
        [dataManager setDelegate:self];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_TO_SHOW])
        {
            [dataManager getMenuDataForMensa:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_TO_SHOW]];
        }
        else
        {
            [dataManager getMenuDataForMensa:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_MENSA]];
        }
    }
    
    [self setDateLabelFromDate:currentDateToShow];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    pageControl = nil;
    scrollView = nil;
    dataManager = nil;
    currentDateToShow = nil;
}

#pragma mark - UIScrollViewDelegate

//Reagiert darauf, wenn ein Tag vor oder zurück gewischt wird.
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= 5) //will man ueber Freitag hinaus nach rechts scrollen, einfach beenden, sonst stuerzt die App ab.
    {
        return;
    }
    int tmp = pageControl.currentPage;
    pageControl.currentPage = page;
    
    if (tmp > pageControl.currentPage) //wenn ein Tag zurück gewischt wird
    {
        currentDateToShow = [NSDate dateWithTimeInterval:-86400 sinceDate:currentDateToShow];
        [self setDateLabelFromDate:currentDateToShow];
        [self setDateLabelHeadingBackgroundFromDate:currentDateToShow];
    }
    else if (tmp < pageControl.currentPage) //wenn ein Tag weiter gewischt wird
    {
        //setzt das Datum einen Tag weiter
        currentDateToShow = [NSDate dateWithTimeInterval:86400 sinceDate:currentDateToShow];
        [self setDateLabelFromDate:currentDateToShow];
        [self setDateLabelHeadingBackgroundFromDate:currentDateToShow];
    }
}

//Setzt das DateLabel auf ein übergebenes Datum, das zuvor formatiert wird.
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
    dateLabel.text = title;
}

#pragma mark - ESMensaDataManagerDelegate

//Die Speiseplan-Daten werden geliefert.
- (void)parsedMenuData:(NSDictionary *)menu
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    scrollView.frame = CGRectMake(0.0, dateLabel.frame.size.height, bounds.size.width, (bounds.size.height - pageControl.frame.size.height - dateLabel.frame.size.height - self.navigationController.navigationBar.frame.size.height));
    scrollView.contentSize = CGSizeMake((scrollView.frame.size.width * 5), scrollView.frame.size.height);
    
    if (_emptyStateImage && [self.view.subviews containsObject:_emptyStateImage])
    {
        [_emptyStateImage removeFromSuperview];
    }
    if (_emptyStateText && [self.view.subviews containsObject:_emptyStateText])
    {
        [_emptyStateText removeFromSuperview];
    }
    if (_emptyStateNetwork && [self.view.subviews containsObject:_emptyStateNetwork])
    {
        [_emptyStateNetwork removeFromSuperview];
    }
    if (_emptyStateNetworkText && [self.view.subviews containsObject:_emptyStateNetworkText])
    {
        [_emptyStateNetworkText removeFromSuperview];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [components weekday];
    [scrollView setContentOffset:CGPointMake((scrollView.frame.size.width * (weekday-2)), 0.0) animated:NO];
    scrollView.delegate = self;
    pageControl.numberOfPages = 5;
    pageControl.currentPage = (weekday-2);
    
    NSMutableString *day;
    NSEnumerator *dayEnumerator = [menu keyEnumerator];
    while (day = [dayEnumerator nextObject])
    {
        CGRect frame = CGRectMake(0.0, 0.0, scrollView.frame.size.width, scrollView.frame.size.height);
        if ([day isEqualToString:@"Tuesday"])
        {
            frame.origin.x = scrollView.frame.size.width;
        }
        else if ([day isEqualToString:@"Wednesday"])
        {
            frame.origin.x = scrollView.frame.size.width * 2;
        }
        else if ([day isEqualToString:@"Thursday"])
        {
            frame.origin.x = scrollView.frame.size.width * 3;
        }
        else if ([day isEqualToString:@"Friday"])
        {
            frame.origin.x = scrollView.frame.size.width * 4;
        }
        
        UIScrollView *weekdayView = [[UIScrollView alloc] initWithFrame:frame];
        [scrollView addSubview:[self fillScrollView:weekdayView withArray:((NSArray *)[menu objectForKey:day])]];
    }
}

//Jeweils ein Tag wird mit Speiseplan-Daten gefüllt. Das User Interface wird programmatisch erstellt.
- (UIScrollView *)fillScrollView:(UIScrollView *)_scrollView withArray:(NSArray *)menu
{
    float yOffset = 5.0;
    if (menu.count == 0)
    {
        UIImageView *emptyFilteredFoodList = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"essen-empty-state"]];
        CGRect frame = emptyFilteredFoodList.frame;
        frame.origin.x = _scrollView.frame.size.width/2.0 - frame.size.width/2.0;
        frame.origin.y = _scrollView.frame.size.height/2.0 - frame.size.height/1.5 - 20.0;
        emptyFilteredFoodList.frame = frame;
        
        UITextView *emptyFilteredFoodListText = [[UITextView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 200.0)];
        emptyFilteredFoodListText.text = NSLocalizedString(@"Kein Essen entspricht deinen Filtereinstellungen (siehe Einstellungsmenü).", @"Kein Essen entspricht deinen Filtereinstellungen (siehe Einstellungsmenü).");
        emptyFilteredFoodListText.scrollEnabled = NO;
        emptyFilteredFoodListText.editable = NO;
        emptyFilteredFoodListText.textAlignment = NSTextAlignmentCenter;
        emptyFilteredFoodListText.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        emptyFilteredFoodListText.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
        emptyFilteredFoodListText.backgroundColor = [UIColor clearColor];
        
        [_scrollView addSubview:emptyFilteredFoodList];
        [_scrollView addSubview:emptyFilteredFoodListText];
        return _scrollView;
    }
    for (int i = 0; i < menu.count; i++)
    {
        FoodEntry *food = ((FoodEntry *)[menu objectAtIndex:i]);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 241.0, 25.0)];
        label.text = food.name;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize constraintSize = CGSizeMake(241.0, MAXFLOAT);
        CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        CGRect frame = label.frame;
        frame.size.height = labelSize.height;
        label.frame = frame;
        
        UILabel *essensBeschreibung = [[UILabel alloc] initWithFrame:CGRectMake(25.0, (frame.size.height + frame.origin.y + 5.0), 255.0, 50.0)];
        essensBeschreibung.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        essensBeschreibung.textColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
        essensBeschreibung.lineBreakMode = NSLineBreakByWordWrapping;
        essensBeschreibung.numberOfLines = 0;
        essensBeschreibung.text = food.foodDescription;
        frame = essensBeschreibung.frame;
        frame.size.height = [essensBeschreibung.text sizeWithFont:essensBeschreibung.font constrainedToSize:CGSizeMake(255.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
        essensBeschreibung.frame = frame;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10.0, yOffset, (self.view.frame.size.width - 20.0), 100.0)];
        view.layer.cornerRadius = 5.0;
        view.layer.shadowRadius = 1.5;
        view.layer.shadowOffset = CGSizeMake(0, .5);
        view.layer.shadowOpacity = .6;
        view.layer.shouldRasterize = YES; //wichtig für die Performance
        view.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
        //potentieller anderer fix für die Perfomanz Probleme die sich mit den Schatten ergeben hatten
        //view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
        
        //[view addSubview:imageView];
        [view addSubview:label];
        [view addSubview:essensBeschreibung];
        
        frame = essensBeschreibung.frame;
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, (frame.origin.y + frame.size.height + 15.0), frame.size.width, 20.0)];
        if (food.studentPrice && food.staffPrice)
        {
            priceLabel.text = [NSString stringWithFormat:@"%@: %@€,  %@: %@€", NSLocalizedString(@"Studenten", @"Studenten"), food.studentPrice, NSLocalizedString(@"Mitarbeiter", @"Mitarbeiter"), food.staffPrice];
        }
        priceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        priceLabel.numberOfLines = 0;
        [priceLabel sizeToFit];
        
        UILabel *foodTypeLabel;
        if (food.types.count > 0 && priceLabel.text)
        {
            foodTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-1.0, (frame.origin.y + frame.size.height + 38.0), 302.0, 18.0)];
        }
        else
        {
            foodTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-1.0, (frame.origin.y + frame.size.height + 22.0), 302.0, 18.0)];
        }
        foodTypeLabel.textAlignment = NSTextAlignmentCenter;
        foodTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        foodTypeLabel.opaque = YES;
        foodTypeLabel.textColor = [UIColor whiteColor];
        foodTypeLabel.backgroundColor = kCUSTOM_BLUE_COLOR;
        
        foodTypeLabel.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
        foodTypeLabel.layer.borderWidth = 1.0;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:foodTypeLabel.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 5.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = foodTypeLabel.bounds;
        maskLayer.path = maskPath.CGPath;
        foodTypeLabel.layer.mask = maskLayer;
        
        NSMutableString *foodTypeString = [NSMutableString string];
        for (int i = 0; i < food.types.count; i++)
        {
            NSString *foodType = [food.types objectAtIndex:i];
            if (i == 0)
            {
                if ([foodType isEqualToString:@"Schwein"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Schwein", @"Schwein")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:.69 blue:.69 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Vegetarisch"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Vegetarisch", @"Vegetarisch")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.34 green:.91 blue:.43 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Vegan"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Vegan", @"Vegan")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.13 green:.54 blue:.23 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Huhn"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Geflügel", @"Geflügel")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.91 green:.55 blue:.25 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Fisch"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Fisch", @"Fisch")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.85 green:.85 blue:.85 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Rind"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Rind", @"Rind")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.5 green:.31 blue:.11 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Lamm"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Lamm", @"Lamm")];
                }
                else if ([foodType isEqualToString:@"Wild"])
                {
                    [foodTypeString appendString:NSLocalizedString(@"Wild", @"Wild")];
                }
                else
                {
                    [foodTypeString appendString:NSLocalizedString(@"Bio", @"Bio")];
                }
            }
            else
            {
                if ([foodType isEqualToString:@"Schwein"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Schwein", @"Schwein")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:.69 blue:.69 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Vegetarisch"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Vegetarisch", @"Vegetarisch")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.34 green:.91 blue:.43 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Vegan"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Vegan", @"Vegan")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.13 green:.54 blue:.23 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Huhn"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Geflügel", @"Geflügel")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.91 green:.55 blue:.25 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Fisch"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Fisch", @"Fisch")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.85 green:.85 blue:.85 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Rind"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Rind", @"Rind")];
                    //foodTypeLabel.backgroundColor = [UIColor colorWithRed:.5 green:.31 blue:.11 alpha:1.0];
                }
                else if ([foodType isEqualToString:@"Lamm"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Lamm", @"Lamm")];
                }
                else if ([foodType isEqualToString:@"Wild"])
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Wild", @"Wild")];
                }
                else
                {
                    [foodTypeString appendFormat:@", %@",NSLocalizedString(@"Bio", @"Bio")];
                }
            }
        }
        
        if (food.types.count == 0)
        {
            foodTypeLabel = nil;
        }
        
        foodTypeLabel.text = foodTypeString;
        
        [view addSubview:priceLabel];
        [view addSubview:foodTypeLabel];
        
        float viewHeight;
        if (food.types.count > 0)
        {
             viewHeight = priceLabel.frame.origin.y + priceLabel.frame.size.height + 25.0;
        }
        else if (priceLabel.text)
        {
            viewHeight = priceLabel.frame.origin.y + priceLabel.frame.size.height + 10.0;
        }
        else
        {
            viewHeight = priceLabel.frame.origin.y + priceLabel.frame.size.height -5.0;
        }
        
        view.frame = CGRectMake(view.frame.origin.x, yOffset, view.frame.size.width, viewHeight);
        view.backgroundColor = [UIColor whiteColor];
        view.opaque = YES;
        
        [_scrollView addSubview:view];
        
        yOffset = view.frame.origin.y + view.frame.size.height + 5.0;
    }
    CGRect frame = ((UIView *)[_scrollView.subviews objectAtIndex:(menu.count-1)]).frame;
    _scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, (frame.origin.y + frame.size.height + 10.0));
    return _scrollView;
}

//Keine Daten auf dem Server.
- (void)noDataToParse
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (_emptyStateNetwork && [self.view.subviews containsObject:_emptyStateNetwork])
    {
        [_emptyStateNetwork removeFromSuperview];
    }
    if (_emptyStateNetworkText && [self.view.subviews containsObject:_emptyStateNetworkText])
    {
        [_emptyStateNetworkText removeFromSuperview];
    }
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    scrollView.frame = CGRectMake(0.0, 30.0, bounds.size.width, (bounds.size.height - 30.0 - self.navigationController.navigationBar.frame.size.height));
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    
    if (!_emptyStateImage)
    {
        _emptyStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"essen-empty-state"]];
        CGRect frame = _emptyStateImage.frame;
        frame.origin.x = self.view.frame.size.width/2.0 - frame.size.width/2.0;
        frame.origin.y = self.view.frame.size.height/2.0 - frame.size.height/1.5 - 20.0;
        _emptyStateImage.frame = frame;
    }
    if (![[self.view subviews] containsObject:_emptyStateImage])
    {
        [self.view addSubview:_emptyStateImage];
    }
    
    if (!_emptyStateText)
    {
        CGRect frame = _emptyStateImage.frame;
        _emptyStateText = [[UITextView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 200.0)];
        _emptyStateText.text = NSLocalizedString(@"Momentan liegen keine Essenspläne für diese Mensa vor. Bitte versuche es später noch mal.", @"Momentan liegen keine Essenspläne für diese Mensa vor. Bitte versuche es später noch mal.");
        _emptyStateText.scrollEnabled = NO;
        _emptyStateText.editable = NO;
        _emptyStateText.textAlignment = NSTextAlignmentCenter;
        _emptyStateText.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        _emptyStateText.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
        _emptyStateText.backgroundColor = [UIColor clearColor];
    }
    if (![[self.view subviews] containsObject:_emptyStateText])
    {
        [self.view addSubview:_emptyStateText];
    }
}

//Keine Netzwerkverbindung.
- (void)noNetworkConnection:(NSString *)errorString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (_emptyStateImage && [self.view.subviews containsObject:_emptyStateImage])
    {
        [_emptyStateImage removeFromSuperview];
    }
    if (_emptyStateText && [self.view.subviews containsObject:_emptyStateText])
    {
        [_emptyStateText removeFromSuperview];
    }
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    scrollView.frame = CGRectMake(0.0, 30.0, bounds.size.width, (bounds.size.height - 30.0 - self.navigationController.navigationBar.frame.size.height));
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    
    if (!_emptyStateNetwork)
    {
        _emptyStateNetwork = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-network-empty-state"]];
        CGRect frame = _emptyStateNetwork.frame;
        frame.origin.x = self.view.frame.size.width/2.0 - frame.size.width/2.0;
        frame.origin.y = self.view.frame.size.height/2.0 - frame.size.height/1.5 - 20.0;
        _emptyStateNetwork.frame = frame;
    }
    if (![[self.view subviews] containsObject:_emptyStateNetwork])
    {
        [self.view addSubview:_emptyStateNetwork];
    }
    
    if (!_emptyStateNetworkText)
    {
        CGRect frame = _emptyStateNetwork.frame;
        _emptyStateNetworkText = [[UITextView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 200.0)];
        _emptyStateNetworkText.text = NSLocalizedString(@"Verbindungsprobleme. Bitte versuche es später noch mal.", @"Verbindungsprobleme. Bitte versuche es später noch mal.");
        _emptyStateNetworkText.scrollEnabled = NO;
        _emptyStateNetworkText.editable = NO;
        _emptyStateNetworkText.textAlignment = NSTextAlignmentCenter;
        _emptyStateNetworkText.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        _emptyStateNetworkText.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
        _emptyStateNetworkText.backgroundColor = [UIColor clearColor];
    }
    if (![[self.view subviews] containsObject:_emptyStateNetworkText])
    {
        [self.view addSubview:_emptyStateNetworkText];
    }
}

#pragma mark - choose mensa

//Wenn der Nutzer auf den 'Mensa' Button tippt, fährt ein ActionSheet von unten hoch und lässt den Nutzer die Mensa wechseln.
- (void)chooseMensa:(id)sender
{
    UIActionSheet *chooseMensa = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Wähle Mensa", @"Wähle Mensa") delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") destructiveButtonTitle:nil otherButtonTitles:@"Uni Boulevard", @"GW2", @"Airport", @"Bremerhaven", @"Neustadtwall", @"Werderstraße", nil];
    [chooseMensa showFromBarButtonItem:sender animated:YES];
}

#pragma mark - UIActionSheetDelegate

//Der Nutzer wählt eine der vorgegebenen Mensen aus. Die Daten werden entsprechend neu geladen.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == (actionSheet.numberOfButtons - 1)) //Abbrechen-Button
    {
        return;
    }
    if (_emptyStateImage)
    {
        [_emptyStateImage removeFromSuperview];
    }
    if (_emptyStateText)
    {
        [_emptyStateText removeFromSuperview];
    }
    if (_emptyStateNetwork && [self.view.subviews containsObject:_emptyStateNetwork])
    {
        [_emptyStateNetwork removeFromSuperview];
    }
    if (_emptyStateNetworkText && [self.view.subviews containsObject:_emptyStateNetworkText])
    {
        [_emptyStateNetworkText removeFromSuperview];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultMensa = [NSString stringWithString:[actionSheet buttonTitleAtIndex:buttonIndex]];
    if ([defaultMensa isEqualToString:self.navigationItem.title])
    {
        //wenn die selbe Mensa ausgewählt wurde, die gerade angezeigt wird
        return;
    }
    self.navigationItem.title = defaultMensa;
    if ([defaultMensa isEqualToString:@"Uni Boulevard"])
    {
        [defaults setObject:[kMENSA_UNI lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"Uni Boulevard" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    else if([defaultMensa isEqualToString:@"GW2"])
    {
        [defaults setObject:[kMENSA_GW2 lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"GW2" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    else if([defaultMensa isEqualToString:@"Airport"])
    {
        [defaults setObject:[kMENSA_AIR lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"Airport" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    else if([defaultMensa isEqualToString:@"Bremerhaven"])
    {
        [defaults setObject:[kMENSA_BHV lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"Bremerhaven" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    else if([defaultMensa isEqualToString:@"Neustadtwall"])
    {
        [defaults setObject:[kMENSA_HSB lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"Neustadtwall" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    else if([defaultMensa isEqualToString:@"Werderstraße"])
    {
        [defaults setObject:[kMENSA_WER lowercaseString] forKey:kDEFAULTS_MENSA_TO_SHOW];
        [defaults setObject:@"Werderstraße" forKey:kDEFAULTS_MENSANAME_TO_SHOW];
    }
    [defaults synchronize];
    
    for (UIView *view in scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    scrollView.delegate = nil;
    currentDateToShow = [NSDate date];
    [self setDateLabelFromDate:currentDateToShow];
    [dataManager getMenuDataForMensa:[defaults objectForKey:kDEFAULTS_MENSA_TO_SHOW]];
}

//Prüft ob der aktuelle Tag ein Wochentag ist.
- (BOOL)isWeekDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [components weekday];
    return (weekday > 1 && weekday < 7);
}

#pragma mark - Testen ob der angezeigte Tag der heutige ist und ggf. das DatumsLabel in anders faerben

//Prüft ob der angezeigte Tag gleich der aktuelle ist. Das DatumsLabel wird ggf. anders eingefärbt.
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

//Die eigentliche Überprüfung findet hier statt.
- (BOOL)dateIsToday:(NSDate *)date
{
    NSDateComponents *componentsOfDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSDateComponents *componentsOfToday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    return ([componentsOfDate day] == [componentsOfToday day] && [componentsOfDate month] == [componentsOfToday month] && [componentsOfDate year] == [componentsOfToday year]);
}

@end
