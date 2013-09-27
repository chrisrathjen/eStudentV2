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

@interface CampusMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *campusMapView;

- (void)addCampusAnnotations;
@end

@implementation CampusMapViewController

@synthesize pointsOfInterest;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Campus";
    self.campusMapView.delegate = self;
    [self.campusMapView setMapType:MKMapTypeHybrid];
    
    //Die Map soll den Campus anzeigen
    MKCoordinateSpan span = MKCoordinateSpanMake(0.028, 0.02);
    CLLocation *uniCoordinates = [[CLLocation alloc] initWithLatitude:53.107205 longitude:8.854979];
    MKCoordinateRegion region = MKCoordinateRegionMake([uniCoordinates coordinate], span);
    [self.campusMapView setRegion:region];
    
    [self addCampusAnnotations];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locationWhite.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleLocation)];
    
}

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
}

- (void)viewDidUnload
{
    pointsOfInterest = nil;
    [self setCampusMapView:nil];
    [super viewDidUnload];
}

//Die Übergebenen Pois werden in Annotations umgewandelt
- (void)addCampusAnnotations
{    
    NSMutableArray *annotations = [NSMutableArray array];
    for (POI *poi in pointsOfInterest)
    {
        CampusAnnotation *anAnnotation = [[CampusAnnotation alloc] init];
        [anAnnotation setTitle:poi.name];
        [anAnnotation setCoordinate:CLLocationCoordinate2DMake([poi.latitude floatValue], [poi.longitude floatValue])];
        [anAnnotation setPoi:poi];
        [annotations addObject:anAnnotation];
    }
    [self.campusMapView addAnnotations:[annotations copy]];
}

//Erstellt den PopOut View beim anklicken eines POIs
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
        InformationenViewController *informationViewController = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
        [informationViewController setPointOfInterest:selectedAnnotation.poi];
        [self.navigationController pushViewController:informationViewController animated:YES];
    }
}
//Erstellt die einzelnen Pins
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil; //Userlocation (Blauer Punkt) soll nicht geändert werden
    }
    MKPinAnnotationView *aView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"campusAnnotationIdent"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"campusAnnotationIdent"];
        aView.canShowCallout = YES;
        aView.pinColor = MKPinAnnotationColorRed;
        aView.animatesDrop = NO; //takes forever with all POIs
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        
    }
    aView.annotation = annotation;
    return aView;
}
//Quelle:http://brianreiter.org/2012/03/02/size-an-mkmapview-to-fit-its-annotations-in-ios-without-futzing-with-coordinate-systems/ Abgerufen am 7.4.13

#define MINIMUM_ZOOM_ARC 0.01 //(1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSMutableArray *annotations = [mapView.annotations mutableCopy];
    if (mapView.userLocationVisible) {
        NSLog(@"adding UserLocation");
        CampusAnnotation *aCampusAnnotation = [[CampusAnnotation alloc] init];
        [aCampusAnnotation setCoordinate:mapView.userLocation.coordinate];
        [aCampusAnnotation setTitle:@"UserTemp"];
        [annotations addObject:aCampusAnnotation];
    }
    int count = [annotations count];
    NSLog(@"Anzahl an Pois:%d",count);
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


//de-/aktiviert die Anzeige der eigenen Position auf der Karte
- (void)toggleLocation
{
        [self.campusMapView setShowsUserLocation:YES];
        if ([self.campusMapView pointInside:[self.campusMapView convertCoordinate:self.campusMapView.userLocation.coordinate toPointToView:self.campusMapView] withEvent:nil]) {
            [self.campusMapView setCenterCoordinate:self.campusMapView.userLocation.coordinate animated:YES];
            NSLog(@"centering");
        } else {
            //Userlocation nicht im aktuellen Kartenausschnit, erstelle neue Region
            [self zoomMapViewToFitAnnotations:self.campusMapView animated:YES];
            NSLog(@"zooming");
        }
 
}

@end
