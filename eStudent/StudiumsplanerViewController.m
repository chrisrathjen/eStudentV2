//
//  StudiumsplanerViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "StudiumsplanerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NeuerEintragViewController.h"
#import "CoreDataDataManager.h"
#import "EintragsView.h"
#import "NoteEintragenView.h"
#import "UebersichtViewController.h"
#import "OffeneViewController.h"
#import "BestandeneViewController.h"
#import "EditEntryView.h"

@interface StudiumsplanerViewController ()
{
    UIScrollView *scrollview;
    __weak IBOutlet UIToolbar *toolbar;
    __weak IBOutlet UIPageControl *pageControl;
    
    UIView *selectedEntry;
    NSArray *semesters;
    int currentPage;
    Semester *currentSemester;
    NSArray *studiengaenge;
    NSMutableArray *scrollViews;
    UILabel *_semesterLabel;
    
    UIView *_semesterHeading;
    CAGradientLayer *_blueGradient;
    CAGradientLayer *_greyGradient;
}

- (void)fillScrollViewForPage:(int)page;
- (NSString *)nextSemesterStringFromSemesterString:(NSString *)semesterstring;
- (void)addEntry:(id)sender;
- (void)loadViews;
- (void)setSemesterHeadingForSemester:(Semester *)semester;

@end

@implementation StudiumsplanerViewController

@synthesize shouldRefresh;
@synthesize scrollViewWithSelectedEintrag;

//Lädt das aktuelle Semester über den Datenmanagers.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentSemester = [[CoreDataDataManager sharedInstance] getCurrentSemester];
    }
    return self;
}

//Lädt die Daten neu, falls nötig. Setzt den '+' Button und den Titel in der Navigationbar.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEntry:)];
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = addButton;
    
    if (self.shouldRefresh)
    {
        [self loadViews];
    }
    self.tabBarController.title = NSLocalizedString(@"Semesterübersicht", @"Semesterübersicht");
}

//Die Datenbank wird gespeichert, wenn der View den Fokus verliert.
- (void) viewWillUnload
{
    [[CoreDataDataManager sharedInstance] saveDatabase];
}

//Bereitet das UI vor, mit den Veranstaltungen gefüllt zu werden.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    pageControl.backgroundColor = [UIColor blackColor];
    
    _semesterHeading = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    _blueGradient = [CAGradientLayer layer];
    [_blueGradient setBorderWidth:1.0f];
    [_blueGradient setBorderColor:[[UIColor blackColor] CGColor]];
    _blueGradient.frame = _semesterHeading.bounds;
    _blueGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.44 green:.64 blue:.83 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.20 green:.43 blue:.74 alpha:1.0] CGColor],
                            nil];
    [_semesterHeading.layer insertSublayer:_blueGradient atIndex:0];
    
    _greyGradient = [CAGradientLayer layer];
    [_greyGradient setBorderWidth:1.0f];
    [_greyGradient setBorderColor:[[UIColor blackColor] CGColor]];
    _greyGradient.frame = _semesterHeading.bounds;
    _greyGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:.63 green:.63 blue:.63 alpha:1.0] CGColor],
                            (id)[[UIColor colorWithRed:.47 green:.47 blue:.47 alpha:1.0] CGColor],
                            nil];
    
    [self.view addSubview:_semesterHeading];
    CGRect frame = _semesterHeading.frame;
    frame.origin.x += 5.0;
    frame.size.width -= 10.0;
    _semesterLabel = [[UILabel alloc] initWithFrame:frame];
    _semesterLabel.backgroundColor = [UIColor clearColor];
    _semesterLabel.textAlignment = NSTextAlignmentCenter;
    _semesterLabel.textColor = [UIColor whiteColor];
    _semesterLabel.font = kCUSTOM_HEADER_LABEL_FONT;
    _semesterLabel.adjustsFontSizeToFitWidth = YES;
    [_semesterHeading addSubview:_semesterLabel];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    frame = _semesterLabel.frame;
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, frame.size.height, bounds.size.width, (IS_IPHONE_5 ? 440.0 - frame.size.height : 352.0 - frame.size.height))];
    scrollview.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
    scrollview.pagingEnabled = YES;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
    
    [self loadViews];
}

//Lädt die Veranstaltungen in das UI.
- (void)loadViews
{   
    CGRect frame = scrollview.frame;
    
    semesters = nil;
    semesters = [[CoreDataDataManager sharedInstance] getAllSemesters]; //Lädt die angelegten Semester über den Datenmanager.
    studiengaenge = nil;
    studiengaenge = [[CoreDataDataManager sharedInstance] getAllStudiengaenge]; //Lädt die vom Nutzer angelegten Studiengänge über den Datenmanager.
    pageControl.numberOfPages = semesters.count;
    
    scrollview.contentSize = CGSizeMake(frame.size.width * semesters.count, frame.size.height);
    if (semesters.count < 2)
    {
        CGRect frame = scrollview.frame;
        frame.size.height += 15.0;
        scrollview.frame = frame;
    }
    
    if (scrollViews)
    {
        for (UIScrollView *s in scrollViews)
        {
            [s removeFromSuperview];
        }
        scrollViews = nil;
    }
    scrollViews = [NSMutableArray array];
    for (int i = 0; i < semesters.count; i++)
    {
        UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake((frame.size.width * i), 0.0, frame.size.width, frame.size.height)];
        [scrollViews addObject:s];
        
        if (!self.shouldRefresh && [((Semester *)[semesters objectAtIndex:i]).name isEqualToString:currentSemester.name])
        {
            currentPage = i;
            [pageControl setCurrentPage:i];
            scrollview.contentOffset = CGPointMake((frame.size.width * i), 0.0);
        }
    }
    
    //Hier wird eine weitere Methode aufgerufen, der ein ScrollView übergeben wird. Dieser soll mit den entsprechenden Veranstaltungen gefüllt werden.
    if (semesters.count > 1)
    {
        if (currentPage == 0)
        {
            [self fillScrollViewForPage:currentPage];
            [self fillScrollViewForPage:currentPage+1];
        }
        else if (currentPage == semesters.count-1)
        {
            [self fillScrollViewForPage:currentPage];
            [self fillScrollViewForPage:currentPage-1];
        }
        else
        {
            [self fillScrollViewForPage:currentPage-1];
            [self fillScrollViewForPage:currentPage];
            [self fillScrollViewForPage:currentPage+1];
        }
    }
    else
    {
        [self fillScrollViewForPage:currentPage];
    }
    _semesterLabel.text = ((Semester *)[semesters objectAtIndex:currentPage]).name;
    
    self.shouldRefresh = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Präsentiert einen Controller, über den der Nutzer einen neuen Eintrag manuell anlegen kann.
- (void)addEntry:(id)sender
{
    NeuerEintragViewController *nevc = [[NeuerEintragViewController alloc] initWithNibName:@"NeuerEintragViewController" bundle:nil];
    nevc.semester = [semesters objectAtIndex:currentPage];
    nevc.title = NSLocalizedString(@"Neuer Eintrag", @"Neuer Eintrag");
    if (studiengaenge.count > 1)
    {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_COURSE_OF_STUDY];
        Studiengang *defaultStudiengang = [[CoreDataDataManager sharedInstance] getStudiengangForName:[dict objectForKey:kDEFAULTS_COURSE_OF_STUDY_NAME] abschluss:[dict objectForKey:kDEFAULTS_COURSE_OF_STUDY_DEGREE]];
        if ([[CoreDataDataManager sharedInstance] compareSemester:nevc.semester withSemester:defaultStudiengang.erstesFachsemester] != NSOrderedAscending)
        {
            nevc.studiengang = defaultStudiengang;
        }
        else
        {
            for (Studiengang *s in studiengaenge)
            {
                if ([s isEqual:defaultStudiengang] || [[CoreDataDataManager sharedInstance] compareSemester:nevc.semester withSemester:s.erstesFachsemester] == NSOrderedAscending)
                {
                    continue;
                }
                nevc.studiengang = s;
                break;
            }
        }
    }
    [self presentViewController:nevc animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

//Wird aufgerufen, wenn der Nutzer den Screen gewischt hat.
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = scrollview.frame.size.width;
    int page = floor((scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= semesters.count)
    {
        return;
    }
    int tmp = pageControl.currentPage;
    pageControl.currentPage = page;
    currentPage = page;
    
    if (tmp > pageControl.currentPage) //wenn ein Semester zurück gewischt wird
    {
        Semester *semester = (Semester *)[semesters objectAtIndex:currentPage];
        _semesterLabel.text = semester.name;
        [self setSemesterHeadingForSemester:semester];
        if (semesters.count >= 3)
        {
            UIScrollView *s = (tmp+1 < semesters.count) ? [scrollViews objectAtIndex:tmp+1] : nil;
            if (s)
            {
                for (UIView *view in s.subviews)
                {
                    [view removeFromSuperview];
                }
            }
            [self fillScrollViewForPage:currentPage-1];
        }
    }
    else if (tmp < pageControl.currentPage) //wenn ein Semester weiter gewischt wird
    {
        Semester *semester = (Semester *)[semesters objectAtIndex:currentPage];
        _semesterLabel.text = semester.name;
        [self setSemesterHeadingForSemester:semester];
        if (semesters.count >= 3)
        {
            UIScrollView *s = (tmp-1 >= 0) ? [scrollViews objectAtIndex:tmp-1] : nil;
            if (s)
            {
                for (UIView *view in s.subviews)
                {
                    [view removeFromSuperview];
                }
            }
            [self fillScrollViewForPage:currentPage+1];
        }
    }
}

#pragma mark - Testet ob das uebergebene Semester das aktuelle ist und setzt die Farbe des Semesterlabels entsprechend

//Aktualisiert die Farbe des SemesterLabels - nur das aktuelle Semester wird blau hinterlegt, die anderen grau.
- (void)setSemesterHeadingForSemester:(Semester *)semester
{
    if ([semester isEqual:[[CoreDataDataManager sharedInstance] getCurrentSemester]])
    {
        CAGradientLayer *gradient = [[_semesterHeading.layer sublayers] objectAtIndex:0];
        [gradient removeFromSuperlayer];
        [_semesterHeading.layer insertSublayer:_blueGradient atIndex:0];
    }
    else
    {
        CAGradientLayer *gradient = [[_semesterHeading.layer sublayers] objectAtIndex:0];
        if ([gradient isEqual:_blueGradient])
        {
            [gradient removeFromSuperlayer];
            [_semesterHeading.layer insertSublayer:_greyGradient atIndex:0];
        }
    }
}

#pragma mark - Fuellt die verschiedenen Semester mit Eintraegen

//Füllt die verschiedenen Semester mit den Veranstaltungseinträgen.
- (void)fillScrollViewForPage:(int)page
{
    if (page >= 0 && page < semesters.count)
    {
        UIScrollView *_scrollview = [scrollViews objectAtIndex:page];
        Semester *semester = [semesters objectAtIndex:page];
        NSSet *eintraege = semester.kurse;
        NSMutableDictionary *studiengaengeMitEintraegen = [NSMutableDictionary dictionary];
        for (Studiengang *s in studiengaenge)
        {
            if ([[CoreDataDataManager sharedInstance] compareSemester:s.erstesFachsemester withSemester:semester] != NSOrderedDescending)
            {
                //Hier werden die Einträge eines Studiengangs zusammengeführt.
                NSMutableArray *sortedEintraege = [NSMutableArray  array];
                for (Eintrag *e in eintraege)
                {
                    if ([e.studiengang isEqual:s])
                    {
                        [sortedEintraege addObject:e];
                    }
                }
                
                //Sortiert die Einträge nach ihrem Titel alphabetisch.
                [sortedEintraege sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
                
                int count = 1;
                NSString *semestersString = s.erstesFachsemester.name;
                while (![semestersString isEqualToString:semester.name])
                {
                    semestersString = [self nextSemesterStringFromSemesterString:semestersString];
                    count++;
                }
                [sortedEintraege addObject:[NSNumber numberWithInt:count]]; //das letzte Element des Eintraege Array enthaelt den Zaehler, um das wie vielte Fachsemester es sich handelt
                [studiengaengeMitEintraegen setObject:sortedEintraege forKey:[NSString stringWithFormat:@"%@, %@", s.name, s.abschluss]];
            }
        }
        
        double yOffset = 10.0;
        NSEnumerator *enumerator = [studiengaengeMitEintraegen keyEnumerator];
        id key;
        int counter = 0;
        //Hier wird aus dem Eintrag ein View für das UI gemacht.
        while (key = [enumerator nextObject])
        {
            NSMutableArray *_eintraege = [studiengaengeMitEintraegen objectForKey:key];
            if (_eintraege.count > 1)
            {
                CGSize size = CGSizeMake(300.0, MAXFLOAT);
                UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(10.0, yOffset, size.width, 0.0)];
                labelView.layer.cornerRadius = 5.0;
                
                UILabel *studiengangsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, 0.0)];
                studiengangsLabel.textAlignment = NSTextAlignmentCenter;
                studiengangsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                studiengangsLabel.numberOfLines = 0;
                UIFont *stFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
                studiengangsLabel.font = stFont;
                studiengangsLabel.text = [NSString stringWithFormat:@"%@, %@. Semester", key, [_eintraege lastObject]];
                studiengangsLabel.backgroundColor = [UIColor clearColor];
                studiengangsLabel.textColor = [UIColor whiteColor];
                [labelView addSubview:studiengangsLabel];
                
                CGSize stSize = [studiengangsLabel.text sizeWithFont:stFont constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
                CGRect frame = labelView.frame;
                frame.size.height = stSize.height + 5.0;
                labelView.frame = frame;
                frame = studiengangsLabel.frame;
                frame.size.height = stSize.height + 5.0;
                studiengangsLabel.frame = frame;
                
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = studiengangsLabel.bounds;
                gradient.borderWidth = 1.0;
                gradient.cornerRadius = 5.0;
                gradient.colors = [NSArray arrayWithObjects:
                                   (id)[[UIColor colorWithRed:.63 green:.63 blue:.63 alpha:1.0] CGColor],
                                   (id)[[UIColor colorWithRed:.47 green:.47 blue:.47 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0] CGColor],
                                   //(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor],
                                   nil];
                [labelView.layer insertSublayer:gradient atIndex:0];
                labelView.tag = 98;
                [_scrollview addSubview:labelView];
                
                yOffset = stSize.height + labelView.frame.origin.y + 10.0;
                
                int cpCount = 0;
                for (int i = 0; i < _eintraege.count -1; i++)
                {
                    Eintrag *e = [_eintraege objectAtIndex:i];
                    counter++;
                    cpCount += [e.cp intValue];
                    EintragsView *eintragsView = [[EintragsView alloc] initWithFrame:CGRectMake(10.0, yOffset, 300, 60.0) eintrag:e viewController:self];
                    [_scrollview addSubview:eintragsView];
                    
                    yOffset = (eintragsView.frame.size.height + eintragsView.frame.origin.y + 5.0);
                }
                NSMutableString *title = studiengangsLabel.text.mutableCopy;
                [title appendFormat:@", %i CP", cpCount];
                studiengangsLabel.text = title;
                yOffset += 10.0;
            }
        }
        //Das Semester hat keine Einträge. Es wird ein Empty State angezeigt.
        if (counter < 1)
        {
            UIImageView *emptySemester = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"studiumsplaner-empty"]];
            CGRect frame = emptySemester.frame;
            frame.origin.x = (_scrollview.frame.size.width / 2.0) - (frame.size.width / 2.0);
            frame.origin.y = (_scrollview.frame.size.height / 2.0) - (frame.size.height);
            emptySemester.frame = frame;
            [_scrollview addSubview:emptySemester];
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y + frame.size.height + 10.0, 240.0, 100.0)];
            textView.text = NSLocalizedString(@"Du hast bisher keine Einträge in diesem Semester angelegt.", @"Du hast bisher keine Einträge in diesem Semester angelegt.");
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.textAlignment = NSTextAlignmentCenter;
            textView.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
            textView.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
            textView.backgroundColor = [UIColor clearColor];
            [_scrollview addSubview:textView];
        }
        
        _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, yOffset);
        [scrollview addSubview:_scrollview];
    }
}

#pragma mark - Liefert von einem übergebenen Semester (als String) das folgende Semester als String

//Liefert zu einem Namen eines Semesters den Namen des nachfolgenden Semesters als String.
- (NSString *)nextSemesterStringFromSemesterString:(NSString *)semesterstring
{
    NSLog(@"SemesterString: %@", semesterstring);
    NSMutableString *nextSemester = [NSMutableString string];
    
    NSArray *firstSplit = [semesterstring componentsSeparatedByString:@" "];
    if ([[firstSplit objectAtIndex:0] isEqualToString:@"WiSe"])
    {
        [nextSemester appendString:@"SoSe "];
    }
    else
    {
        [nextSemester appendString:@"WiSe "];
    }
    
    NSArray *secondSplit = [[firstSplit objectAtIndex:1] componentsSeparatedByString:@"/"];
    int i = [[secondSplit objectAtIndex:0] intValue];
    
    if (secondSplit.count == 1)
    {
        [nextSemester appendFormat:@"%i", i];
        int j = [[secondSplit objectAtIndex:0] intValue];
        [nextSemester appendFormat:@"/%i", (j%100)+1];
    }
    else
    {
        [nextSemester appendFormat:@"%i", i+1];
    }
    
    return [NSString stringWithString:nextSemester];
}

@end
