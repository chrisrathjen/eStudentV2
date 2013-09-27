//
//  CampusMapViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "CampusMapViewController.h"
#import "CampusAnnotation.h"
#import "InformationenViewController.h"
#import "PoiListViewController.h"
#import "POI.h"


@interface CampusMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *campusMapView;
@property (assign, nonatomic) BOOL showLocationWarning;

- (void)addCampusAnnotations;
@property (strong, nonatomic) CLLocationManager *campusMapLocationManager;
@end

@implementation CampusMapViewController

@synthesize pointsOfInterest, campusMapLocationManager;
@synthesize haltestellen = _haltestellen;

//Prüft, ob der Nutzer seinen Standort freigegeben hat. Entsprechend wird der Lokalisationsbutton aktiviert oder deaktiviert.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Wenn nur ein POI vorhanden ist soll die Karte entsprechend herran gezoomt werden
    if ([self.pointsOfInterest count] == 1) {
        POI *singlePOI = [self.pointsOfInterest lastObject];
        CLLocation *poiCoordinates = [[CLLocation alloc] initWithLatitude:[singlePOI.latitude doubleValue] longitude:[singlePOI.longitude doubleValue]];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.001);
        MKCoordinateRegion region = MKCoordinateRegionMake([poiCoordinates coordinate], span);
        [self.campusMapView setRegion:region];
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) //Der Nutzer hat den Zugriff auf seinen Standort erlaubt.
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        if (!self.showLocationWarning)
        {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.campusMapLocationManager stopUpdatingLocation];
    self.campusMapView.showsUserLocation = NO;
    [super viewWillDisappear:animated];
}

//Lädt die Karte und setzt den Kartenausschnitt auf die Koordinaten des Uni-Campus.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    self.title = NSLocalizedString(@"Karte", @"Karte");
    self.campusMapView.delegate = self;
    [self.campusMapView setMapType:MKMapTypeHybrid];
    self.showLocationWarning = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locationWhite.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(setupLocationServices)];
    
    //Die Map soll den Campus anzeigen
    MKCoordinateSpan span = MKCoordinateSpanMake(0.028, 0.02);
    CLLocation *uniCoordinates = [[CLLocation alloc] initWithLatitude:53.107205 longitude:8.854979];
    MKCoordinateRegion region = MKCoordinateRegionMake([uniCoordinates coordinate], span);
    [self.campusMapView setRegion:region];
    
    [self addCampusAnnotations];
}

- (void)viewDidUnload
{
    pointsOfInterest = nil;
    [self setCampusMapView:nil];
    [super viewDidUnload];
}

//Fordert den Nutzer dazu auf in die Geräteeinstellungen zu gehen und seinen Standort wieder freizugeben.
- (void)rerequestLocationServices
{
    UIAlertView *statusAlterView;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            if (self.showLocationWarning) {
                statusAlterView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Standort freigeben", nil) message:@"Damit dein Standort angezeigt wird, musst du der App die Ortung erlauben (Einstellungen - Datenschutz - Ortungsdienste)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [statusAlterView show];
                self.campusMapLocationManager = [[CLLocationManager alloc] init];
                self.campusMapLocationManager.delegate = self;
                self.showLocationWarning = NO;
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
            }
            break;
        case kCLAuthorizationStatusNotDetermined:
            //Ask the User
            self.campusMapLocationManager = [[CLLocationManager alloc] init];
            self.campusMapLocationManager.delegate = self;
            [self.campusMapLocationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusRestricted:
            [self zoomMapViewToFitAnnotationsWithoutUserLocation:self.campusMapView animated:YES];
            break;
            
        default:
            break;
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//Fordert den Nutzer dazu auf in die Geräteeinstellungen zu gehen und seinen Standort wieder freizugeben.
- (void)setupLocationServices
{
    UIAlertView *statusAlterView;
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusAuthorized:
            //All is Well
            self.campusMapLocationManager = [[CLLocationManager alloc] init];
            self.campusMapLocationManager.delegate = self;
            [self.campusMapLocationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
            if (self.showLocationWarning) {
                statusAlterView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Standort freigeben", nil) message:@"Damit dein Standort angezeigt wird, musst du der App die Ortung erlauben (Einstellungen - Datenschutz - Ortungsdienste)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [statusAlterView show];
                self.campusMapLocationManager = [[CLLocationManager alloc] init];
                self.campusMapLocationManager.delegate = self;
                self.showLocationWarning = NO;
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
            }
            
            break;
        case kCLAuthorizationStatusNotDetermined:
            //Ask the User
            self.campusMapLocationManager = [[CLLocationManager alloc] init];
            self.campusMapLocationManager.delegate = self;
            [self.campusMapLocationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusRestricted:
            break;
            
        default:
            break;
    }
}

//Die Übergebenen POI werden in Annotationen umgewandelt.
- (void)addCampusAnnotations
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *annotations = [NSMutableArray array];
        NSMutableArray *poisWithParents = [pointsOfInterest mutableCopy];
        for (POI *poi in pointsOfInterest)
        {
            if (poi.parentPoi) {
                if (![poisWithParents containsObject:poi.parentPoi]) {
                    [poisWithParents addObject:poi.parentPoi];
                }
            }
        }
        pointsOfInterest = [poisWithParents copy];
        for (POI *poi in pointsOfInterest)
        {
            if (!poi.latitude || !poi.longitude) {
                continue;
            }
            CampusAnnotation *anAnnotation = [[CampusAnnotation alloc] init];
            [anAnnotation setTitle:poi.name];
            [anAnnotation setCoordinate:CLLocationCoordinate2DMake([poi.latitude floatValue], [poi.longitude floatValue])];
            [anAnnotation setPoi:poi];
            [annotations addObject:anAnnotation];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.campusMapView addAnnotations:[annotations copy]];
        });
    });
}

//Erstellt den PopOut View beim anklicken eines Pins. Die entsprechende Annotation wird dem Nutzer als Information angezeigt.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[InformationenViewController class]])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        CampusAnnotation *selectedAnnotation = view.annotation;
        InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
        if ([selectedAnnotation.poi.type intValue] == 0)
        {
            ivc.title = NSLocalizedString(@"Gebäude", @"Gebäude");
        }
        else
        {
            ivc.title = NSLocalizedString(@"Haltestelle", @"Haltestelle");
        }
        ivc.haltestellen = _haltestellen;
        [ivc setPointOfInterest:selectedAnnotation.poi];
        [self.navigationController pushViewController:ivc animated:YES];
    }
}
//Erstellt die einzelnen Pins und färbt sie entsprechend ein..
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    MKPinAnnotationView *aView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"campusAnnotationIdent"];
    if (!aView)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"campusAnnotationIdent"];
        aView.canShowCallout = YES;
        if ([annotation isKindOfClass:[MKUserLocation class]]) //Wenn es sich um den Nutzerstandort handelt wird nil zurueckgegeben, dadurch wird der blaue Punkt angezeigt.
        {
            return nil;
        }
        else if ([((CampusAnnotation *)annotation).poi.type intValue] == 4) //Ist eine Haltestelle - grün.
        {
            aView.pinColor = MKPinAnnotationColorGreen;
        }
        else //Alle anderen Pins werden rot eingefärbt.
        {
            aView.pinColor = MKPinAnnotationColorRed;
        }
        aView.animatesDrop = NO; //takes forever with all POIs
        if ([annotation isKindOfClass:[MKUserLocation class]] || [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[InformationenViewController class]])
        {
            aView.rightCalloutAccessoryView = nil;
        }
        else
        {
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }
    aView.annotation = annotation;
    return aView;
}
//Quelle:http://brianreiter.org/2012/03/02/size-an-mkmapview-to-fit-its-annotations-in-ios-without-futzing-with-coordinate-systems/ Abgerufen am 7.4.13

#define MINIMUM_ZOOM_ARC 0.01 //(1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotationsWithoutUserLocation:(MKMapView *)mapView animated:(BOOL)animated
{
    NSMutableArray *annotations = [mapView.annotations mutableCopy];
    int count = [annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    
    
    MKMapPoint points[count]; //C array of MKMapPoint struct
    
    
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

//Zoomed die Karte soweit aus, bis alle Pins drauf Platz haben.
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    BOOL userlocationActive = NO;
    for (id annotation in mapView.annotations)
    {
        if ([annotation isKindOfClass:[MKUserLocation class]])
        {
            userlocationActive= YES;
        }
    }
    if (!userlocationActive)
    {
        return;
    }
    else
    {
        [self.campusMapLocationManager stopUpdatingLocation];
    }
    NSMutableArray *annotations = [mapView.annotations mutableCopy];
    int count = [annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    
    MKMapPoint points[count]; //C array of MKMapPoint struct
    
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

//Der LocationManager hat den Nutzerstandort geupdated.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.campusMapView.showsUserLocation = YES;
    [self zoomMapViewToFitAnnotations:self.campusMapView animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.campusMapView.showsUserLocation = YES;
    [self zoomMapViewToFitAnnotations:self.campusMapView animated:YES];
}

//Der Nutzer hat seine Zustimmung zur Verwendung seines Standortes entzogen oder erteilt.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined )
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else
    {
        self.campusMapView.showsUserLocation = NO;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self zoomMapViewToFitAnnotationsWithoutUserLocation:self.campusMapView animated:YES];
    }
}

@end
