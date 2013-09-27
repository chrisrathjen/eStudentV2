
//
//  HomeScreenViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "HomeScreenViewController.h"
#import "EssenViewController.h"
#import "VeranstaltungenViewController.h"
#import "InformationenViewController.h"
#import "StudiumsplanerViewController.h"
#import "HomeScreenEssenCell.h"
#import "HomeScreenVeranstaltungenCell.h"
#import "HomeScreenCampusInformationenCell.h"
#import "HomeScreenStudiumsplanerCell.h"
#import "CampusMapViewController.h"
#import "PoiListViewController.h"
#import "ESMensaDataManager.h"
#import "FoodEntry.h"
#import "CoreDataDataManager.h"
#import "Studiengang.h"
#import "NeuerStudiengangViewController.h"
#import "UebersichtViewController.h"
#import "OffeneViewController.h"
#import "BestandeneViewController.h"
#import "StatistikViewController.h"
#import "ChooseDefaultMensaViewController.h"
#import "StudiengaengeViewController.h"
#import "BelegteVeranstaltungenViewController.h"

@interface HomeScreenViewController ()

- (void)swipedLeft:(id)sender;
- (void)swipedRight:(id)sender;

@end

@implementation HomeScreenViewController

@synthesize settingsIsVisible;
@synthesize mensaDataManager;

//Initialisiert die Daten für die UserDefaults, bevor der Nutzer selbst schon welche festgelegt hat.
+ (void)initialize
{
    NSArray *uni = [NSArray arrayWithObjects:@"Essen I", @"Essen II", @"Vegetarisch", @"Pfanne, Wok & Co.", nil];
    NSArray *gw2 = [NSArray arrayWithObjects:@"Pizza", @"Pasta", @"Frisch aus dem Wok", @"Suppe", nil];
    NSArray *air = [NSArray arrayWithObjects:@"Essen I", @"Essen II", nil];
    NSArray *bhv = [NSArray arrayWithObjects:@"Essen I", @"Essen II", @"Vegetarisch", @"Extra", nil];
    NSArray *hsb = [NSArray arrayWithObjects:@"Essen I", @"Essen II", @"Front-Cooking", @"Bio-Menü", nil];
    NSArray *wer = [NSArray arrayWithObjects:@"Essen I", @"Essen II", @"Wok & Pfanne", nil];
    //setzt die Eintrags-Arten Liste
    NSArray *eintragsArten = [NSArray arrayWithObjects:NSLocalizedString(@"Vorlesung", @"Vorlesung"), NSLocalizedString(@"Seminar", @"Seminar"), NSLocalizedString(@"Kurs", @"Kurs"), NSLocalizedString(@"Übung", @"Übung"), NSLocalizedString(@"Tutorium", @"Tutorium"), NSLocalizedString(@"Praktikum", @"Praktikum"), NSLocalizedString(@"Projektplenum", @"Projektplenum"), NSLocalizedString(@"Labor", @"Labor"), NSLocalizedString(@"Abschlussarbeit", @"Abschlussarbeit"), nil];
    
    NSArray *essensArten = [NSArray arrayWithObjects:NSLocalizedString(@"Schwein", @"Schwein"), NSLocalizedString(@"Geflügel", @"Geflügel"), NSLocalizedString(@"Rind", @"Rind"), NSLocalizedString(@"Wild", @"Wild"), NSLocalizedString(@"Lamm", @"Lamm"), NSLocalizedString(@"Fisch", @"Fisch"), NSLocalizedString(@"Vegetarisch", @"Vegetarisch"), NSLocalizedString(@"Vegan", @"Vegan"), nil];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:eintragsArten, essensArten, uni, gw2, air, bhv, hsb, wer, nil]
                                                         forKeys:[NSArray arrayWithObjects:kDEFAULTS_ENTRY_TYPES, kFILTERED_FOOD_TYPES, kMENSA_UNI, kMENSA_GW2, kMENSA_AIR, kMENSA_BHV, kMENSA_HSB, kMENSA_WER, nil]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Universität Bremen", @"Titel des HomeScreens"); //Titel des HomeScreens
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil]; //Der Zurück-Button des NavigationControllers hat einen anderen Titel (aufgrund der Länge des Titels des HomeScreens), wenn ein ViewController geladen wird
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!foodEntry)
    {
        [self refreshMensaData];
    }
}

//Lädt die Instanzen für die vier Felder und den Mensa-Datenmanager.
- (void)viewDidLoad
{
    [super viewDidLoad];
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
    // EssenCell
    UINib *essenCell = [UINib nibWithNibName:@"HomeScreenEssenCell" bundle:nil];
    [self.tableView registerNib:essenCell forCellReuseIdentifier:@"HomeScreenEssenCell"];
    // VeranstaltungenCell
    UINib *veranstaltungenCell = [UINib nibWithNibName:@"HomeScreenVeranstaltungenCell" bundle:nil];
    [self.tableView registerNib:veranstaltungenCell forCellReuseIdentifier:@"HomeScreenVeranstaltungenCell"];
    // CampusInformationenCell
    UINib *campusInformationenCell = [UINib nibWithNibName:@"HomeScreenCampusInformationenCell" bundle:nil];
    [self.tableView registerNib:campusInformationenCell forCellReuseIdentifier:@"HomeScreenCampusInformationenCell"];
    // StudiumsplanerCell
    UINib *studiumsPlanerCell = [UINib nibWithNibName:@"HomeScreenStudiumsplanerCell" bundle:nil];
    [self.tableView registerNib:studiumsPlanerCell forCellReuseIdentifier:@"HomeScreenStudiumsplanerCell"];
    
    mensaDataManager = [[ESMensaDataManager alloc] init];
    mensaDataManager.delegate = self;
}

//Erneuert die Mensa-Daten.
- (void)refreshMensaData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_MENSA])
    {
        HomeScreenEssenCell *essenCell = (HomeScreenEssenCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [essenCell.activitiyIndicator startAnimating];
        [self.mensaDataManager getFoodEntryForEssen:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_FOOD_TYPE] inMensa:[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_DEFAULT_MENSA]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4; // Anzahl der Funktionen der App
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *customBlueColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
    if (indexPath.row == 0) //Essen
    {
        HomeScreenEssenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenEssenCell"];
        cell.essenFunktionLabel.text = NSLocalizedString(@"Essen", @"Essen");
        cell.essensTypLabel.textColor = customBlueColor;
        cell.essensBeschreibungsTextView.textColor = customBlueColor;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
        {
            if ([self isWeekDay])
            {
                if (foodEntry && !noDataToParse && !noNetworkConnection)
                {
                    [cell.activitiyIndicator stopAnimating];
                    cell.essensTypLabel.text = [NSString stringWithFormat:@"%@ %@:", NSLocalizedString(@"Heute bei", @"Heute bei"), foodEntry.name];
                    cell.essensBeschreibungsTextView.text = foodEntry.foodDescription;
                    
                }
                else if (noDataToParse)
                {
                    [cell.activitiyIndicator stopAnimating];
                    cell.essensTypLabel.text = NSLocalizedString(@"Momentan liegen keine Daten für das gewählte Essen vor.", @"Momentan liegen keine Daten für das gewählte Essen vor.");
                    cell.essensBeschreibungsTextView.text = @"";
                }
                else if (noNetworkConnection)
                {
                    [cell.activitiyIndicator stopAnimating];
                    cell.essensTypLabel.text = NSLocalizedString(@"Verbindungsprobleme. Bitte versuche es später noch mal.", @"Verbindungsprobleme. Bitte versuche es später noch mal.");
                    cell.essensBeschreibungsTextView.text = @"";
                }
            }
            else
            {
                [cell.activitiyIndicator stopAnimating];
                cell.essensTypLabel.text = NSLocalizedString(@"Alle Mensen haben am Wochenende geschlossen.", @"Alle Mensen haben am Wochenende geschlossen.");
                cell.essensBeschreibungsTextView.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
        else
        {
            cell.essensTypLabel.text = NSLocalizedString(@"Speisepläne der Bremer Mensen", @"Speisepläne der Bremer Mensen");
            cell.essensTypLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        }
        
        cell.essensTypLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.essensTypLabel.numberOfLines = 0;
        [cell.essensTypLabel sizeToFit];
#warning uncomment for iOS7 only
        //[cell.essensBeschreibungsTextView.layoutManager ensureLayoutForTextContainer:cell.essensBeschreibungsTextView.textContainer];
        //[cell.essensBeschreibungsTextView layoutIfNeeded];
        
        CGRect frame = cell.essensBeschreibungsTextView.frame;
        frame.size.height = cell.essensBeschreibungsTextView.contentSize.height;
        frame.origin.y = (cell.essensTypLabel.frame.origin.y + cell.essensTypLabel.frame.size.height - 5.0);
        cell.essensBeschreibungsTextView.frame = frame;
        
       // [cell.essensBeschreibungsTextView sizeToFit];
        
        
        
        UISwipeGestureRecognizer *sgrLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        sgrLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *sgrRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        sgrRight.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:sgrLeft];
        [cell addGestureRecognizer:sgrRight];
        
        return cell;
    }
    else if (indexPath.row == 1) //Veranstaltungen
    {
        //UIColor *customBlueColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
        HomeScreenVeranstaltungenCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenVeranstaltungenCell"];
        cell.veranstaltungenFunktionLabel.text = NSLocalizedString(@"Veranstaltungen", @"Veranstaltungen");
        [cell.veranstaltungsBeschreibungsTextView removeFromSuperview];
        /*cell.veranstaltungsTitelLabel.textColor = customBlueColor;
        cell.veranstaltungsBeschreibungsTextView.textColor = customBlueColor;
        
        cell.veranstaltungsTitelLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.veranstaltungsTitelLabel.numberOfLines = 0;
        [cell.veranstaltungsTitelLabel sizeToFit];
        
        CGRect frame = cell.veranstaltungsBeschreibungsTextView.frame;
        frame.size.height = cell.veranstaltungsBeschreibungsTextView.contentSize.height;
        frame.origin.y = (cell.veranstaltungsTitelLabel.frame.origin.y + cell.veranstaltungsTitelLabel.frame.size.height - 5.0);
        cell.veranstaltungsBeschreibungsTextView.frame = frame;
        */
        
        UISwipeGestureRecognizer *sgrLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        sgrLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *sgrRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        sgrRight.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:sgrLeft];
        [cell addGestureRecognizer:sgrRight];
        
        return cell;
    }
    else if (indexPath.row == 2) //Studiumsplaner
    {
        HomeScreenStudiumsplanerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenStudiumsplanerCell"];
        cell.studiumsplanerFunktionLabel.text = NSLocalizedString(@"Studiumsplaner", @"Studiumsplaner");
        
        UISwipeGestureRecognizer *sgrLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        sgrLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *sgrRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        sgrRight.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:sgrLeft];
        [cell addGestureRecognizer:sgrRight];
        
        return cell;
    }
    
    //Campus-Info
    HomeScreenCampusInformationenCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenCampusInformationenCell"];
    cell.campusInformationenFunktionLabel.text = NSLocalizedString(@"Campus-Info", @"Campus-Info");
    
    UISwipeGestureRecognizer *sgrLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    sgrLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *sgrRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    sgrRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell addGestureRecognizer:sgrLeft];
    [cell addGestureRecognizer:sgrRight];
    cell.campusInformationenTitelLabel.text = NSLocalizedString(@"Gebäude & Einrichtungen auf dem Uni-Campus", @"Gebäude & Einrichtungen auf dem Uni-Campus");
    cell.campusInformationenTitelLabel.textColor = customBlueColor;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hier dynamisch die Größe der einzelnen Zellen berechnen
    if (indexPath.row == 0) //Essen
    {
        HomeScreenEssenCell *cell = (HomeScreenEssenCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        float origin = 0.0;
        float height = 0.0;
        CGRect frame;
        if (!noNetworkConnection && !noDataToParse && cell.essensBeschreibungsTextView.text.length > 0)
        {
//            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//                [cell.essensBeschreibungsTextView.layoutManager ensureLayoutForTextContainer:cell.essensBeschreibungsTextView.textContainer];
//                [cell.essensBeschreibungsTextView layoutIfNeeded];
//            }
            
            height = cell.essensBeschreibungsTextView.contentSize.height;
            frame = cell.essensBeschreibungsTextView.frame;
            origin = frame.origin.y;
        }
        else
        {
            frame = cell.essensTypLabel.frame;
            origin = frame.origin.y;
            height = frame.size.height + 5.0;
        }
        
        return (origin + height + 10.0);
    }
    else if (indexPath.row == 3) //Campus-Info
    {
        HomeScreenCampusInformationenCell *cell = (HomeScreenCampusInformationenCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        CGRect frame = cell.campusInformationenTitelLabel.frame;
        float origin = frame.origin.y;
        float height = frame.size.height;
        return (origin + height + 15.0);
    }
    else if (indexPath.row == 1 || indexPath.row == 2)
    {
        return 110.0;
    }
    else
    {
        return 70.0;
    }
}


// Lädt das entsprechende App-Modul, wenn auf eines der Felder getippt wurde.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!settingsIsVisible)
    {
        if (indexPath.row == 0) // Essen
        {
            if (![[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_MENSA_NAME])
            {
                ChooseDefaultMensaViewController *cdmvc = [[ChooseDefaultMensaViewController alloc] initWithNibName:@"ChooseDefaultMensaViewController" bundle:nil];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cdmvc];
                navigationController.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
                [self presentViewController:navigationController animated:YES completion:nil];
            }
            else if ([self isWeekDay])
            {
                EssenViewController *evc = [[EssenViewController alloc] initWithNibName:@"Essen" bundle:nil];
                [self.navigationController pushViewController:evc animated:YES];
            }
        }
        else if (indexPath.row == 1) // Veranstaltungen
        {
            VeranstaltungenViewController *vvc = [[VeranstaltungenViewController alloc] initWithNibName:@"Veranstaltungen" bundle:nil];
            vvc.title = NSLocalizedString(@"Stundenplan", @"Stundenplan");
            vvc.tabBarItem.image = [UIImage imageNamed:@"calendar"];
            
            StudiengaengeViewController *svc = [[StudiengaengeViewController alloc] initWithNibName:@"StudiengaengeViewController" bundle:nil];
            svc.title = NSLocalizedString(@"Veranstaltungsverzeichnis", @"Veranstaltungsverzeichnis");
            svc.tabBarItem.image = [UIImage imageNamed:@"259-list"];
            //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:svc];
            //nc.navigationBarHidden = YES;
            
            BelegteVeranstaltungenViewController *bvvc = [[BelegteVeranstaltungenViewController alloc] initWithNibName:@"BelegteVeranstaltungenViewController" bundle:nil];
            bvvc.title = NSLocalizedString(@"Deine Veranstaltungen", @"Deine Veranstaltungen");
            bvvc.tabBarItem.image = [UIImage imageNamed:@"104-index-cards"];
            
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers:[NSArray arrayWithObjects:vvc, bvvc, svc, nil]];
            [self.navigationController pushViewController:tbc animated:YES];
        }
        else if (indexPath.row == 3) // Campus-Informationen
        {
          POIListViewController *poivc = [[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil];
          [self.navigationController pushViewController:poivc animated:YES];
        }
        else // Studiumsplaner
        {
            if ([[CoreDataDataManager sharedInstance] getAllStudiengaenge].count == 0)
            {
                NeuerStudiengangViewController *nstvc = [[NeuerStudiengangViewController alloc] initWithNibName:@"NeuerStudiengangViewController" bundle:nil];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:nstvc];
                nc.navigationBar.tintColor = kCUSTOM_BLUE_COLOR;
                
                [self presentViewController:nc animated:YES completion:nil];
            }
            else
            {
                StudiumsplanerViewController *spvc = [[StudiumsplanerViewController alloc] initWithNibName:@"Studiumsplaner" bundle:nil];
                spvc.tabBarItem.image = [UIImage imageNamed:@"calendar"];
                spvc.tabBarItem.title = NSLocalizedString(@"Semester", @"Semester");
                
                UebersichtViewController *uevc = [[UebersichtViewController alloc] initWithNibName:@"UebersichtViewController" bundle:nil];
                uevc.tabBarItem.image = [UIImage imageNamed:@"259-list"];
                uevc.tabBarItem.title = NSLocalizedString(@"Übersicht", @"Übersicht");
                StatistikViewController *svc = [[StatistikViewController alloc] initWithNibName:@"StatistikViewController" bundle:nil];
                svc.tabBarItem.image = [UIImage imageNamed:@"stats"];
                svc.tabBarItem.title = NSLocalizedString(@"Statistik", @"Statistik");
                
                UITabBarController *tbc = [[UITabBarController alloc] init];
                [tbc setViewControllers:[NSArray arrayWithObjects:spvc, uevc, svc, nil]];
                
                [self.navigationController pushViewController:tbc animated:YES];
                
                //[self.navigationController pushViewController:spvc animated:YES];
            }
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //Liefert den AppDelegate
        [appDelegate toggleSettings:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - ESMensaDataManagerDelegate

//Liefert die aufbereiteten Mensa-Daten.
- (void)parsedMenuData:(NSDictionary *)menu
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)selectedFoodEntry:(FoodEntry *)aFoodEntry
{
    noDataToParse = NO;
    noNetworkConnection = NO;
    
    foodEntry = aFoodEntry;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

//Keine Daten auf dem Server.
- (void)noDataToParse
{
    noDataToParse = YES;
    noNetworkConnection = NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

//Keine Netzwerkverbindung ist möglich.
- (void)noNetworkConnection:(NSString *)errorString
{
    noNetworkConnection = YES;
    noDataToParse = NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)isWeekDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [components weekday];
    
    return (weekday > 1 && weekday < 7);
}

#pragma mark - UISwipeGestureRecognizer


- (void)swipedLeft:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //Liefert den AppDelegate
    if (appDelegate.settingsIsVisible)
    {
        [appDelegate toggleSettings:nil];
    }
}

- (void)swipedRight:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //Liefert den AppDelegate
    if (!appDelegate.settingsIsVisible)
    {
        [appDelegate toggleSettings:nil];
    }
}

@end
