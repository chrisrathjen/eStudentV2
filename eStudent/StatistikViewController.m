//
//  StatistikViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 19.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "StatistikViewController.h"
#import "CoreDataDataManager.h"
#import "StudiengangTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface StatistikViewController ()
{
    __weak IBOutlet UIPageControl *_pageControl;
    UIScrollView *_scrollview;
    NSArray *_studiengaenge;
    int _page;
    UILabel *_studiengangLabel;
}

- (void)loadViews;
- (void)setTitleForPage:(int)page;

@end

@implementation StatistikViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    }
    return self;
}

//Setzt den Titel der Navigationbar und lädt die Views.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = NSLocalizedString(@"Statistik", @"Statistik");
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    [self loadViews];
}

//Bereitet das UI vor.
- (void)viewDidLoad
{
    [super viewDidLoad];

    _pageControl.backgroundColor = [UIColor blackColor];

    UIView *heading = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = heading.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:.63 green:.63 blue:.63 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:.47 green:.47 blue:.47 alpha:1.0] CGColor],
                       nil];
    [heading.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:heading];
    
    if (!_studiengangLabel)
    {
        CGRect frame = heading.frame;
        frame.origin.x += 5.0;
        frame.size.width -= 10.0;
        _studiengangLabel = [[UILabel alloc] initWithFrame:frame];
        _studiengangLabel.backgroundColor = [UIColor clearColor];
        _studiengangLabel.textAlignment = NSTextAlignmentCenter;
        _studiengangLabel.textColor = [UIColor whiteColor];
        _studiengangLabel.font = kCUSTOM_HEADER_LABEL_FONT;
        _studiengangLabel.adjustsFontSizeToFitWidth = YES;
    }
    [heading addSubview:_studiengangLabel];
    
    [self loadViews];
}

#pragma mark - LoadViews

//Pro Studiengang wird eine Tabelle mit den dazugehörigen Statistiken geladen.
- (void)loadViews
{
    _scrollview = nil;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, _studiengangLabel.frame.size.height, bounds.size.width, (IS_IPHONE_5 ? 440.0 - _studiengangLabel.frame.size.height : 352.0 - _studiengangLabel.frame.size.height))];
    _scrollview.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    _scrollview.pagingEnabled = YES;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.delegate = self;
    [self.view addSubview:_scrollview];
    
    CGRect frame = _scrollview.frame;
    
    _studiengaenge = nil;
    _studiengaenge = [[CoreDataDataManager sharedInstance] getStatistics];
    _pageControl.numberOfPages = _studiengaenge.count;
    _pageControl.currentPage = _page;
    
    _scrollview.contentSize = CGSizeMake(frame.size.width * _studiengaenge.count, frame.size.height);
    _scrollview.contentOffset = CGPointMake((frame.size.width * _page), 0.0);
    if (_studiengaenge.count < 2)
    {
        CGRect frame = _scrollview.frame;
        frame.size.height += 15.0;
        _scrollview.frame = frame;
    }
    
    for (int i = 0; i < _studiengaenge.count; i++)
    {
        CGRect frame = _scrollview.frame;
        frame.origin.x = frame.origin.x + (frame.size.width * i);
        frame.origin.y = 0.0;
        StudiengangTableView *studiengangTableView = [[StudiengangTableView alloc] initWithFrame:frame dictionary:[_studiengaenge objectAtIndex:i]];
        [_scrollview addSubview:studiengangTableView];
    }
    [self setTitleForPage:_page];
}

//Setzt den Titel eines Studiengangs als Titel einer Seite.
- (void)setTitleForPage:(int)page
{
    NSDictionary *firstStudiengang = [_studiengaenge objectAtIndex:page];
    NSString *title = [NSString stringWithFormat:@"%@, %@", [firstStudiengang objectForKey:kStudiengangName], [firstStudiengang objectForKey:kStudiengangAbschluss]];
    _studiengangLabel.text = title;
}

#pragma mark - UIScrollViewDelegate

//Reagiert darauf, wenn eine Studiengang gewischt wurde.
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = _scrollview.frame.size.width;
    int page = floor((_scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= _studiengaenge.count) //will man ueber Freitag hinaus nach rechts scrollen, einfach beenden, sonst stuerzt die App ab.
    {
        return;
    }
    int tmp = _pageControl.currentPage;
    _pageControl.currentPage = page;
    _page = page;
    
    if (tmp > _pageControl.currentPage) //wenn ein Studiengang zurück gewischt wird
    {
        [self setTitleForPage:page];
    }
    else if (tmp < _pageControl.currentPage) //wenn ein Studiengang weiter gewischt wird
    {
        [self setTitleForPage:page];
    }
}

@end
