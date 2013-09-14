//
//  UebersichtViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 14.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "UebersichtViewController.h"
#import "Eintrag.h"
#import "CoreDataDataManager.h"
#import "Semester.h"
#import <QuartzCore/QuartzCore.h>
#import "EintragsView.h"
#import "NeuerEintragViewController.h"
#import "EditEntryView.h"
#import "FilterViewController.h"
#import "FPPopoverController.h"

@interface UebersichtViewController ()
{
    UIScrollView *_scrollView;
    __weak IBOutlet UIPageControl *_pageControl;
    UILabel *_studiengangLabel;
    NSArray *_studiengaenge;
    int _currentPage;
    NSArray *_semester;
    FPPopoverController *_popoverController;
    NSUserDefaults *_defaults;
    UIBarButtonItem *_filterButton;
}

- (void)loadView:(UIScrollView *)scrollView Studiengang:(Studiengang *)studiengang;
- (void)filterEntries:(id)sender;
- (void)addEntry:(id)sender;
- (void)showEditEntryView:(UITapGestureRecognizer *)sender;

@end

@implementation UebersichtViewController

@synthesize shouldRefresh = _shouldRefresh;
@synthesize scrollViewWithSelectedEintrag = _scrollViewWithSelectedEintrag;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_defaults)
    {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    if (!_filterButton)
    {
        _filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eye"] style:UIBarButtonItemStylePlain target:self action:@selector(filterEntries:)];
    }
    
    int filter = [_defaults integerForKey:kEINTRAEGE_FILTER];
    if (filter)
    {
        switch (filter)
        {
            case kALL_EINTRAEGE_FILTER:
                self.tabBarController.title = NSLocalizedString(@"Alle", @"Alle");
                break;
            case kPAST_EINTRAEGE_FILTER:
                self.tabBarController.title = NSLocalizedString(@"Bestandene", @"Bestandene");
                break;
            case kOPEN_EINTRAEGE_FILTER:
                self.tabBarController.title = NSLocalizedString(@"Offene", @"Offene");
                break;
            default:
                break;
        }
    }
    else
    {
        self.tabBarController.title = NSLocalizedString(@"Alle", @"Alle");
    }
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEntry:)];
    addButton.style = UIBarButtonItemStyleBordered;
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    [self.tabBarController.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, _filterButton, nil]];
    if (_shouldRefresh)
    {
        [self loadViews];
        _shouldRefresh = NO;
    }
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
    
    [self loadViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadViews
{
    for (UIView *view in _scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    [_popoverController dismissPopoverAnimated:YES];
    
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

- (void)loadView:(UIScrollView *)scrollView Studiengang:(Studiengang *)studiengang
{
    _semester = nil;

    if (!_defaults)
    {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    int filter = [_defaults integerForKey:kEINTRAEGE_FILTER];
    if (filter)
    {
        switch (filter)
        {
            case kALL_EINTRAEGE_FILTER:
                _semester = [[CoreDataDataManager sharedInstance] getAllEntriesForStudiengang:studiengang];
                self.tabBarController.title = NSLocalizedString(@"Alle", @"Alle");
                break;
            case kPAST_EINTRAEGE_FILTER:
                _semester = [[CoreDataDataManager sharedInstance] getAllPastEntriesForStudiengang:studiengang];
                self.tabBarController.title = NSLocalizedString(@"Bestandene", @"Bestandene");
                break;
            case kOPEN_EINTRAEGE_FILTER:
                _semester = [[CoreDataDataManager sharedInstance] getAllOpenEntriesForStudiengang:studiengang];
                self.tabBarController.title = NSLocalizedString(@"Offene", @"Offene");
                break;
            default:
                break;
        }
    }
    else
    {
        _semester = [[CoreDataDataManager sharedInstance] getAllEntriesForStudiengang:studiengang];
        [_defaults setInteger:1 forKey:kEINTRAEGE_FILTER];
        [_defaults synchronize];
        self.tabBarController.title = NSLocalizedString(@"Alle", @"Alle");
    }
    
    double yOffset = 10.0;
    if (_semester.count > 0)
    {
        for (NSArray *eintraege in _semester)
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
            if ([((Eintrag *)((NSArray *)eintraege).lastObject).semester isEqual:[[CoreDataDataManager sharedInstance] getCurrentSemester]])
            {
                gradient.colors = [NSArray arrayWithObjects:
                                   (id)[[UIColor colorWithRed:.44 green:.64 blue:.83 alpha:1.0] CGColor],
                                   (id)[[UIColor colorWithRed:.20 green:.43 blue:.74 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor],
                                   nil];
            }
            else
            {
                gradient.colors = [NSArray arrayWithObjects:
                                   (id)[[UIColor colorWithRed:.63 green:.63 blue:.63 alpha:1.0] CGColor],
                                   (id)[[UIColor colorWithRed:.47 green:.47 blue:.47 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor],
                                   nil];
            }
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
    }
    else //bisher keine Eintraege in diesem Studiengang
    {
        UIImageView *emptySemester;
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        
        int filter = [_defaults integerForKey:kEINTRAEGE_FILTER];
        switch (filter)
        {
            case kPAST_EINTRAEGE_FILTER:
                emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty-bestandene-eintraege"]];
                textView.text = NSLocalizedString(@"Du hast keine Einträge in diesem Studiengang als bestanden markiert.", @"Du hast keine Einträge in diesem Studiengang als bestanden markiert.");
                break;
            case kOPEN_EINTRAEGE_FILTER:
                emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty-offene-eintraege"]];
                textView.text = NSLocalizedString(@"Du hast keine offenen Einträge in diesem Studiengang.", @"Du hast keine offenen Einträge in diesem Studiengang.");
                break;
            default:
                emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty"]];
                textView.text = NSLocalizedString(@"Du hast bisher keine Einträge in diesem Studiengang angelegt.", @"Du hast bisher keine Einträge in diesem Studiengang angelegt.");
                break;
        }
        CGRect frame = emptySemester.frame;
        frame.origin.x = (scrollView.frame.size.width / 2.0) - (frame.size.width / 2.0);
        frame.origin.y = (scrollView.frame.size.height / 2.0) - (frame.size.height);
        emptySemester.frame = frame;
        [scrollView addSubview:emptySemester];
     
        textView.frame = CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 100.0);
        textView.scrollEnabled = NO;
        textView.editable = NO;
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        textView.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
        textView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:textView];
     }
    
    scrollView.contentSize = CGSizeMake(320.0, yOffset);
    [_scrollView addSubview:scrollView];
}

#pragma mark - addEntryButtonPressed

- (void)addEntry:(id)sender
{
    NeuerEintragViewController *nevc = [[NeuerEintragViewController alloc] initWithNibName:@"NeuerEintragViewController" bundle:nil];
    nevc.studiengang = (Studiengang *)[_studiengaenge objectAtIndex:_currentPage];
    nevc.title = NSLocalizedString(@"Neuer Eintrag", @"Neuer Eintrag");
    [self presentViewController:nevc animated:YES completion:nil];
}

#pragma mark - Filter the Entries

- (void)filterEntries:(id)sender
{
    if (!_popoverController)
    {
        FilterViewController *fvc = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
        fvc.viewController = self;
        _popoverController = [[FPPopoverController alloc] initWithViewController:fvc];
        _popoverController.tint = FPPopoverLightGrayTint;
        _popoverController.contentSize = CGSizeMake(265.0, 202.0);
    }
    
    UIView* btnView = [sender valueForKey:@"view"];
    [_popoverController presentPopoverFromView:btnView];
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
