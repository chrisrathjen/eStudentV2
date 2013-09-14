//
//  BestandeneViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 14.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "BestandeneViewController.h"
#import "Eintrag.h"
#import "CoreDataDataManager.h"
#import "Semester.h"
#import <QuartzCore/QuartzCore.h>
#import "EintragsView.h"
#import "NeuerEintragViewController.h"
#import "EditEntryView.h"

@interface BestandeneViewController ()
{
    UIScrollView *_scrollView;
    __weak IBOutlet UIPageControl *_pageControl;
    
    UILabel *_studiengangLabel;
    NSArray *_studiengaenge;
    int _currentPage;
}

- (void)loadView:(UIScrollView *)scrollView Studiengang:(Studiengang *)studiengang;
- (void)addEntry:(id)sender;
- (void)showEditEntryView:(UITapGestureRecognizer *)sender;

@end

@implementation BestandeneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = NSLocalizedString(@"Bestandene Einträge", @"Bestandene Einträge");
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEntry:)];
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    
    self.view.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    
    UIView *heading = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setBorderWidth:1.0f];
    [gradient setBorderColor:[[UIColor blackColor] CGColor]];
    gradient.frame = heading.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:.44 green:.64 blue:.83 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:.20 green:.43 blue:.74 alpha:1.0] CGColor],
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
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = _studiengangLabel.frame;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, frame.size.height, bounds.size.width, (IS_IPHONE_5 ? 440.0 - frame.size.height : 352.0 - frame.size.height))];
    _scrollView.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    if (!_studiengaenge)
    {
        _studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge];
        if (_studiengaenge.count < 2)
        {
            CGRect frame = _scrollView.frame;
            frame.size.height += 15.0;
            _scrollView.frame = frame;
        }
    }
    int studiengaengeCount = _studiengaenge.count;
    [_pageControl setNumberOfPages:studiengaengeCount];
    _scrollView.contentSize = CGSizeMake(bounds.size.width * studiengaengeCount, _scrollView.frame.size.height);
    Studiengang *s = (Studiengang *)[_studiengaenge objectAtIndex:_currentPage];
    _studiengangLabel.text = [NSString stringWithFormat:@"%@, %@", s.name, s.abschluss];
    
    for (int i = 0; i < _pageControl.numberOfPages; i++)
    {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        Studiengang *studiengang = [_studiengaenge objectAtIndex:i];
        [self loadView:scrollView Studiengang:studiengang];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView:(UIScrollView *)scrollView Studiengang:(Studiengang *)studiengang
{
    double yOffset = 10.0;
    
    NSArray *semester = [[CoreDataDataManager sharedInstance] getAllPastEntriesForStudiengang:studiengang];
    
    for (NSArray *eintraege in semester)
    {
        CGSize size = CGSizeMake(300.0, MAXFLOAT);
        UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(10.0, yOffset, size.width, 0.0)];
        labelView.layer.cornerRadius = 5.0;
        
        UILabel *semesterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, 0.0)];
        semesterLabel.textAlignment = NSTextAlignmentCenter;
        semesterLabel.lineBreakMode = NSLineBreakByWordWrapping;
        semesterLabel.numberOfLines = 0;
        UIFont *stFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        semesterLabel.font = stFont;
        semesterLabel.text = ((Eintrag *)((NSArray *)eintraege).lastObject).semester.name;
        semesterLabel.backgroundColor = [UIColor clearColor];
        semesterLabel.textColor = [UIColor whiteColor];
        [labelView addSubview:semesterLabel];
        
        CGSize stSize = [semesterLabel.text sizeWithFont:stFont constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        CGRect frame = labelView.frame;
        frame.size.height = stSize.height + 5.0;
        labelView.frame = frame;
        frame = semesterLabel.frame;
        frame.size.height = stSize.height + 5.0;
        semesterLabel.frame = frame;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = semesterLabel.bounds;
        gradient.borderWidth = 1.0;
        gradient.cornerRadius = 5.0;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:.44 green:.64 blue:.83 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:.20 green:.43 blue:.74 alpha:1.0] CGColor],
                           //(id)[[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0] CGColor],
                           //(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor],
                           nil];
        [labelView.layer insertSublayer:gradient atIndex:0];
        labelView.tag = 98;
        [scrollView addSubview:labelView];
        
        yOffset = labelView.frame.origin.y + labelView.frame.size.height + 5.0;
        
        for (Eintrag *eintrag in eintraege)
        {
            EintragsView *eintragsView = [[EintragsView alloc] initWithFrame:CGRectMake(10.0, yOffset, 300, 60.0) eintrag:eintrag viewController:self];
            [scrollView addSubview:eintragsView];
            
            yOffset = eintragsView.frame.origin.y + eintragsView.frame.size.height + 5.0;
        }
        yOffset += 5.0;
    }
    scrollView.contentSize = CGSizeMake(320.0, yOffset);
    [_scrollView addSubview:scrollView];
}

#pragma mark - addEntryButtonPressed

- (void)addEntry:(id)sender
{
    NeuerEintragViewController *nevc = [[NeuerEintragViewController alloc] initWithNibName:@"NeuerEintragViewController" bundle:nil];
    nevc.studiengang = (Studiengang *)[_studiengaenge objectAtIndex:_currentPage];
    [self presentViewController:nevc animated:YES completion:nil];
}

#pragma mark - Show The EditEntryView

- (void)showEditEntryView:(UITapGestureRecognizer *)sender
{
    [[EditEntryView sharedInstance] presentSelfWithViewController:self EintragsView:(EintragsView *)sender.view];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= _studiengaenge.count)
    {
        return;
    }
    int tmp = _pageControl.currentPage;
    _pageControl.currentPage = page;
    _currentPage = page;
    
    if (tmp > _pageControl.currentPage) //wenn ein Tag zurück gewischt wird
    {
        Studiengang *s = (Studiengang *)[_studiengaenge objectAtIndex:_currentPage];
        _studiengangLabel.text = [NSString stringWithFormat:@"%@, %@", s.name, s.abschluss];
    }
    else if (tmp < _pageControl.currentPage) //wenn ein Tag weiter gewischt wird
    {
        Studiengang *s = (Studiengang *)[_studiengaenge objectAtIndex:_currentPage];
        _studiengangLabel.text = [NSString stringWithFormat:@"%@, %@", s.name, s.abschluss];
    }
}

@end
