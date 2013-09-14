//
//  InformationenViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "InformationenViewController.h"
#import "CampusMapViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface InformationenViewController ()
{
    BOOL _shouldShowBuilding;
    UITableViewCell *_buildingCell;
    UITableViewCell *_haltestellenCell;
}

- (void)highlightCell:(UILongPressGestureRecognizer *)sender;
- (void)highlightBusStopCell:(UILongPressGestureRecognizer *)sender;
- (void)showBuilding:(UITapGestureRecognizer *)sender;
- (void)showBusStop:(id)sender;

- (void)showMapView:(id)sender;
- (void)openWebsite:(id)sender;
- (void)callPhoneNumber:(id)sender;

@end

@implementation InformationenViewController

@synthesize pointOfInterest;
@synthesize haltestellen = _haltestellen;

- (void)viewDidAppear:(BOOL)animated
{
    if (_buildingCell)
    {
        _buildingCell.layer.opacity = 1.0;
    }
    if (_haltestellenCell)
    {
        _haltestellenCell.layer.opacity = 1.0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
//
    
    //UIImage *mapImage = [UIImage imageNamed:@"map"];
    //UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:mapImage landscapeImagePhone:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(showMapView:)];
    //self.navigationItem.rightBarButtonItem = mapButton;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise_lines"]]; //hier wird das Hintergrundbild festgelegt
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)] ;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)] ;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    
    UIView *poiView = [[UIView alloc] init];
    [poiView sizeToFit];
    //poiView.layer.cornerRadius = 5.0;
    poiView.layer.shadowRadius = 1.5;
    poiView.layer.shadowOffset = CGSizeMake(0, .5);
    poiView.layer.shadowOpacity = .4;
    poiView.layer.shouldRasterize = YES; //wichtig für die Performance
    poiView.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
    poiView.backgroundColor = [UIColor whiteColor];
    CGRect frame;
    float width = 300.0;
    
    if ([pointOfInterest.type intValue] == 0) //ist ein Gebaeude
    {
        UIImageView *gebaeudeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gebaeude-b"]];
        frame = gebaeudeImage.frame;
        frame.origin.x = 10.0;
        frame.origin.y = 10.0;
        gebaeudeImage.frame = frame;
        [poiView addSubview:gebaeudeImage];
        
        frame.origin.x = frame.size.width + 20.0;
        frame.size.width = width - (frame.size.width + 20.0);
    }
    else if ([pointOfInterest.type intValue] == 2) //ist eine Essenseinrichtung
    {
        UIImageView *besteckImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"besteck-b"]];
        frame = besteckImage.frame;
        frame.origin.x = 10.0;
        frame.origin.y = 10.0;
        besteckImage.frame = frame;
        [poiView addSubview:besteckImage];
        
        frame.origin.x = frame.size.width + 20.0;
        frame.size.width = width - (frame.size.width + 20.0);
    }
    else if ([pointOfInterest.type intValue] == 4) //ist eine Haltestelle
    {
        UIImageView *besteckImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"haltestelle-b"]];
        frame = besteckImage.frame;
        frame.origin.x = 10.0;
        frame.origin.y = 10.0;
        besteckImage.frame = frame;
        [poiView addSubview:besteckImage];
        
        frame.origin.x = frame.size.width + 20.0;
        frame.size.width = width - (frame.size.width + 20.0);
    }
    else
    {
        frame = CGRectMake(15.0, 10.0, width - 30.0, 21.0);
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:frame];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
    title.numberOfLines = 0;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.text = pointOfInterest.name;
    [poiView addSubview:title];
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize labelSize = [title.text sizeWithFont:title.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    frame = title.frame;
    frame.size.height = labelSize.height;
    title.frame = frame;
    
    if (pointOfInterest.desc) //POI hat eine Beschreibung
    {
        UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 20.0, 20.0)];
        desc.editable = NO;
        desc.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        desc.text = pointOfInterest.desc;
        [poiView addSubview:desc];
        desc.frame = CGRectMake(frame.origin.x, (frame.origin.y + frame.size.height + 5.0), desc.frame.size.width, desc.contentSize.height);
        frame = desc.frame;
        frame.size.height += 5.0;
    }
    else
    {
        frame.size.height += 10;
    }
    
    poiView.frame = CGRectMake(10.0, 10.0, width, (frame.origin.y + frame.size.height));
    [scrollView addSubview:poiView];
    
    frame = poiView.frame;
    frame.origin.y += 5.0;
    
    CGRect tempFrame = frame;
    
    if (pointOfInterest.parentPoi) //POI hat ein Gebaeude
    {
        _buildingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _buildingCell.textLabel.text = pointOfInterest.parentPoi.name;
        _buildingCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
        _buildingCell.textLabel.numberOfLines = 0;
        _buildingCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _buildingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _buildingCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        _buildingCell.imageView.image = [UIImage imageNamed:@"gebaeude-b"];
        //cell.detailTextLabel.text = NSLocalizedString(@"Gebäude", @"Gebäude");
        //cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        
        _buildingCell.frame = CGRectMake(10.0, tempFrame.size.height + tempFrame.origin.y, width, 44.0);
        frame = _buildingCell.frame;
        frame.size.height = [_buildingCell.textLabel.text sizeWithFont:_buildingCell.textLabel.font constrainedToSize:CGSizeMake(_buildingCell.textLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0;
        _buildingCell.frame = frame;
        _buildingCell.backgroundColor = [UIColor whiteColor];
        _buildingCell.layer.shadowRadius = 1.5;
        _buildingCell.layer.shadowOffset = CGSizeMake(0, .5);
        _buildingCell.layer.shadowOpacity = .4;
        _buildingCell.layer.shouldRasterize = YES; //wichtig für die Performance
        _buildingCell.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
        
        [scrollView addSubview:_buildingCell];
        tempFrame = _buildingCell.frame;
        tempFrame.origin.y += 5.0;
        frame = tempFrame;
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBuilding:)];
        [_buildingCell addGestureRecognizer:tgr];
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(highlightCell:)];
        lpgr.minimumPressDuration = .2;
        [_buildingCell addGestureRecognizer:lpgr];
    }
    
    if (pointOfInterest.hours) //POI hat Oeffnungszeiten
    {
        UIView *hoursView = [[UIView alloc] initWithFrame:tempFrame];
        hoursView.layer.shadowRadius = 1.5;
        hoursView.layer.shadowOffset = CGSizeMake(0, .5);
        hoursView.layer.shadowOpacity = .4;
        hoursView.layer.shouldRasterize = YES; //wichtig für die Performance
        hoursView.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
        hoursView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *clockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11-clock"]];
        CGRect imageFrame = clockImage.frame;
        imageFrame.origin.x = 10.0;
        imageFrame.origin.y = 10.0;
        clockImage.frame = imageFrame;
        [hoursView addSubview:clockImage];
        
        UILabel *hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageFrame.origin.x + imageFrame.size.width + 10.0, imageFrame.origin.y, width - (imageFrame.origin.x + imageFrame.size.width + 30.0), imageFrame.size.height)];
        hoursLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
        hoursLabel.text = NSLocalizedString(@"Öffnungszeiten", @"Öffnungszeiten");
        [hoursView addSubview:hoursLabel];
        frame = hoursLabel.frame;
        
        UITextView *hours = [[UITextView alloc] initWithFrame:frame];
        hours.editable = NO;
        hours.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        hours.text = pointOfInterest.hours;
        //hours.textAlignment = NSTextAlignmentRight;
        [hoursView addSubview:hours];
        hours.frame = CGRectMake(frame.origin.x, (frame.origin.y + frame.size.height), frame.size.width, hours.contentSize.height);
        [hours sizeToFit];
        frame = hours.frame;
        
        hoursView.frame = CGRectMake(10.0, (tempFrame.origin.y + tempFrame.size.height), width, (frame.origin.y + frame.size.height + 5.0));
        [scrollView addSubview:hoursView];
        frame = hoursView.frame;
        
        tempFrame = frame;
        tempFrame.origin.y += 5.0;
    }
    if (pointOfInterest.address) //POI hat eine Adresse
    {
        UIView *addressView = [[UIView alloc] initWithFrame:tempFrame];
        addressView.layer.shadowRadius = 1.5;
        addressView.layer.shadowOffset = CGSizeMake(0, .5);
        addressView.layer.shadowOpacity = .4;
        addressView.layer.shouldRasterize = YES; //wichtig für die Performance
        addressView.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
        addressView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *addressImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"18-envelope"]];
        CGRect imageFrame = addressImage.frame;
        imageFrame.origin.x = 10.0;
        imageFrame.origin.y = 10.0;
        addressImage.frame = imageFrame;
        [addressView addSubview:addressImage];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageFrame.origin.x + imageFrame.size.width + 10.0, imageFrame.origin.y, width - (imageFrame.origin.x + imageFrame.size.width + 30.0), imageFrame.size.height)];
        addressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
        addressLabel.text = NSLocalizedString(@"Anschrift", @"Anschrift");
        [addressView addSubview:addressLabel];
        frame = addressLabel.frame;
        
        UITextView *address = [[UITextView alloc] initWithFrame:frame];
        address.editable = NO;
        address.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        address.text = pointOfInterest.address;
        //address.textAlignment = NSTextAlignmentRight;
        [addressView addSubview:address];
        address.frame = CGRectMake(frame.origin.x, (frame.origin.y + frame.size.height), frame.size.width, address.contentSize.height);
        [address sizeToFit];
        frame = address.frame;
        
        addressView.frame = CGRectMake(10.0, (tempFrame.origin.y + tempFrame.size.height), width, (frame.origin.y + frame.size.height + 5.0));
        [scrollView addSubview:addressView];
        frame = addressView.frame;
        
        tempFrame = frame;
        tempFrame.origin.y += 5.0;
    }
    
    if (_haltestellen && [pointOfInterest.type intValue] == 0)
    {
        tempFrame.origin.y += 5.0;
        CLLocation *poiLocation = [[CLLocation alloc] initWithLatitude:[pointOfInterest.latitude doubleValue] longitude:[pointOfInterest.longitude doubleValue]];
        _haltestellen = [_haltestellen sortedArrayUsingComparator:^NSComparisonResult(POI *p1, POI *p2)
        {
            CLLocation *l1 = [[CLLocation alloc] initWithLatitude:[p1.latitude doubleValue] longitude:[p1.longitude doubleValue]];
            CLLocation *l2 = [[CLLocation alloc] initWithLatitude:[p2.latitude doubleValue] longitude:[p2.longitude doubleValue]];
            double delta1 = [l1 distanceFromLocation:poiLocation];
            double delta2 = [l2 distanceFromLocation:poiLocation];
            return delta1 < delta2 ? NSOrderedAscending : NSOrderedDescending;
        }].copy;
        
        for (int i = 0; i < 3; i++)
        {
            POI *haltestelle = [_haltestellen objectAtIndex:i];
            UITableViewCell *haltestellenCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            haltestellenCell.textLabel.text = haltestelle.name;
            haltestellenCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
            haltestellenCell.textLabel.numberOfLines = 0;
            haltestellenCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            haltestellenCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            haltestellenCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            haltestellenCell.imageView.image = [UIImage imageNamed:@"haltestelle-b"];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[haltestelle.latitude doubleValue] longitude:[haltestelle.longitude doubleValue]];
            haltestellenCell.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", (int)[location distanceFromLocation:poiLocation], NSLocalizedString(@"Meter", @"Meter")];
            //cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
            
            haltestellenCell.frame = CGRectMake(10.0, tempFrame.size.height + tempFrame.origin.y, width, 44.0);
            frame = haltestellenCell.frame;
            frame.size.height = [haltestellenCell.textLabel.text sizeWithFont:haltestellenCell.textLabel.font constrainedToSize:CGSizeMake(haltestellenCell.textLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 30.0;
            haltestellenCell.frame = frame;
            haltestellenCell.backgroundColor = [UIColor whiteColor];
            haltestellenCell.layer.shadowRadius = 1.5;
            haltestellenCell.layer.shadowOffset = CGSizeMake(0, .5);
            haltestellenCell.layer.shadowOpacity = .4;
            haltestellenCell.layer.shouldRasterize = YES; //wichtig für die Performance
            haltestellenCell.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
            
            [scrollView addSubview:haltestellenCell];
            tempFrame = haltestellenCell.frame;
            tempFrame.origin.y += 0.5;
            frame = tempFrame;
            
            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBusStop:)];
            [haltestellenCell addGestureRecognizer:tgr];
            UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(highlightBusStopCell:)];
            lpgr.minimumPressDuration = .2;
            [haltestellenCell addGestureRecognizer:lpgr];
        }
        frame.origin.y += 5.0;
    }
    
    
    /********** Ab hier werden die Button Karte, Webseite und Anrufen erstellt und eingefuegt **********/
    
    UIImage *mapImage = [UIImage imageNamed:@"map-button"];
    UIImageView *imageForButtonSize = [[UIImageView alloc] initWithImage:mapImage];
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(10.0, (frame.origin.y + frame.size.height + 5.0), width, imageForButtonSize.frame.size.height)];
    
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapButton.frame = imageForButtonSize.frame;
    [mapButton setImage:mapImage forState:UIControlStateNormal];
    [mapButton setImage:[UIImage imageNamed:@"map-button-i"] forState:UIControlStateHighlighted];
    [mapButton addTarget:self action:@selector(showMapView:) forControlEvents:UIControlEventTouchUpInside];
    mapButton.frame = CGRectMake(0.0, 0.0, imageForButtonSize.frame.size.width, mapButton.frame.size.height);
    [buttonContainer addSubview:mapButton];
    CGRect labelFrame = mapButton.frame;
    UILabel *mapButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelFrame.origin.x, (labelFrame.origin.x + labelFrame.size.height + 3.0), labelFrame.size.width, 20.0)];
    mapButtonLabel.text = NSLocalizedString(@"Karte", @"Karte");
    mapButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    mapButtonLabel.textAlignment = NSTextAlignmentCenter;
    [buttonContainer addSubview:mapButtonLabel];
    mapButtonLabel.backgroundColor = [UIColor clearColor];
    mapButtonLabel.opaque = YES;
    labelFrame = mapButtonLabel.frame;
    
    UIImage *webImage = [UIImage imageNamed:@"website-button"];
    UIButton *webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    webButton.frame = imageForButtonSize.frame;
    [webButton setImage:webImage forState:UIControlStateNormal];
    [webButton setImage:[UIImage imageNamed:@"website-button-i"] forState:UIControlStateHighlighted];
    [webButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
    webButton.frame = CGRectMake(imageForButtonSize.frame.size.width + 2.0, 0.0, imageForButtonSize.frame.size.width, webButton.frame.size.height);
    [buttonContainer addSubview:webButton];
    UILabel *webButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelFrame.origin.x + labelFrame.size.width + 2.0), labelFrame.origin.y, labelFrame.size.width, 20.0)];
    webButtonLabel.text = NSLocalizedString(@"Webseite", @"Webseite");
    webButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    webButtonLabel.textAlignment = NSTextAlignmentCenter;
    [buttonContainer addSubview:webButtonLabel];
    webButtonLabel.backgroundColor = [UIColor clearColor];
    webButtonLabel.opaque = YES;
    labelFrame = webButtonLabel.frame;
    
    UIImage *phoneImage = [UIImage imageNamed:@"phone-button"];
    UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneButton.frame = imageForButtonSize.frame;
    [phoneButton setImage:phoneImage forState:UIControlStateNormal];
    [phoneButton setImage:[UIImage imageNamed:@"phone-button-i"] forState:UIControlStateHighlighted];
    [phoneButton addTarget:self action:@selector(callPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
    phoneButton.frame = CGRectMake(2 * imageForButtonSize.frame.size.width + 4.0, 0.0, imageForButtonSize.frame.size.width, phoneButton.frame.size.height);
    [buttonContainer addSubview:phoneButton];
    UILabel *phoneButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake((2 * imageForButtonSize.frame.size.width + 4.0), labelFrame.origin.y, labelFrame.size.width, 20.0)];
    phoneButtonLabel.text = NSLocalizedString(@"Anrufen", @"Anrufen");
    phoneButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    phoneButtonLabel.textAlignment = NSTextAlignmentCenter;
    phoneButtonLabel.backgroundColor = [UIColor clearColor];
    phoneButtonLabel.opaque = YES;
    [buttonContainer addSubview:phoneButtonLabel];
    
    if (!pointOfInterest.web)
    {
        [webButton setEnabled:NO];
        webButtonLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0];
    }
    if (!pointOfInterest.phone)
    {
        [phoneButton setEnabled:NO];
        phoneButtonLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0];
    }
    
    /********** Bis hier **********/
    
    
    frame = buttonContainer.frame;
    frame.size.height += 25.0;
    buttonContainer.frame = frame;
    [scrollView addSubview:buttonContainer];
    scrollView.contentSize = CGSizeMake(320.0, frame.origin.y + frame.size.height + 30.0);
}

- (void)swipeToLeft:(id)sender
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (![[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[CampusMapViewController class]])
    {
        CampusMapViewController *campusMapVC = [[CampusMapViewController alloc] initWithNibName:@"CampusMapViewController" bundle:nil];
        if (pointOfInterest.parentPoi) //wenn es eine Einrichtung ist, soll der Parent an die Karte uebergeben werden
        {
            campusMapVC.pointsOfInterest = [NSArray arrayWithObject:pointOfInterest.parentPoi];
        }
        else if ([pointOfInterest.type intValue] == 4)
        {
            campusMapVC.pointsOfInterest = [NSArray arrayWithObject:pointOfInterest];
        }
        else
        {
            campusMapVC.pointsOfInterest = [NSArray arrayWithObjects:pointOfInterest, [_haltestellen objectAtIndex:0], [_haltestellen objectAtIndex:1], [_haltestellen objectAtIndex:2], nil];
        }
        [self.navigationController pushViewController:campusMapVC animated:YES];
    }
}

- (void)swipeToRight:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMapView:(id)sender
{
    CampusMapViewController *campusMapVC = [[CampusMapViewController alloc] initWithNibName:@"CampusMapViewController" bundle:nil];
    if (pointOfInterest.parentPoi) //wenn es eine Einrichtung ist, soll der Parent an die Karte uebergeben werden
    {
        campusMapVC.pointsOfInterest = [NSArray arrayWithObject:pointOfInterest.parentPoi];
    }
    else if ([pointOfInterest.type intValue] == 4)
    {
        campusMapVC.pointsOfInterest = [NSArray arrayWithObject:pointOfInterest];
    }
    else
    {
        campusMapVC.pointsOfInterest = [NSArray arrayWithObjects:pointOfInterest, [_haltestellen objectAtIndex:0], [_haltestellen objectAtIndex:1], [_haltestellen objectAtIndex:2], nil];
    }
    [self.navigationController pushViewController:campusMapVC animated:YES];
}

- (void)openWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pointOfInterest.web]];
}

- (void)callPhoneNumber:(id)sender
{
    NSString *theFormat = NSLocalizedString(@"POI anrufen?", @"%@ %@");
    NSString *alertTitle = [NSString stringWithFormat:theFormat, pointOfInterest.name, NSLocalizedString(@"anrufen", @"anrufen")];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:pointOfInterest.phone
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen")
                                              otherButtonTitles: NSLocalizedString(@"Anrufen", @"Anrufen"), nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [pointOfInterest.phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
    }
}

#pragma mark - UIGestureRecognizers

- (void)highlightCell:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        sender.view.layer.opacity = .5;
        _shouldShowBuilding = YES;
    }
    else if (sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateChanged)
    {
        sender.view.layer.opacity = 1.0;
        _shouldShowBuilding = NO;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && _shouldShowBuilding)
    {
        InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
        [ivc setPointOfInterest:pointOfInterest.parentPoi];
        ivc.title = NSLocalizedString(@"Gebäude", @"Gebäude");
        [self.navigationController pushViewController:ivc animated:YES];
        _shouldShowBuilding = NO;
    }
}

- (void)highlightBusStopCell:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        sender.view.layer.opacity = .5;
        _shouldShowBuilding = YES;
    }
    else if (sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateChanged)
    {
        sender.view.layer.opacity = 1.0;
        _shouldShowBuilding = NO;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && _shouldShowBuilding)
    {
        _haltestellenCell = (UITableViewCell *)sender.view;
        sender.view.layer.opacity = .5;
        InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
        UITableViewCell *cell = (UITableViewCell* )sender.view;
        POI *haltestelleToShow = nil;
        for (int i = 0; i < _haltestellen.count; i++)
        {
            POI *haltestelle = [_haltestellen objectAtIndex:i];
            if ([cell.textLabel.text isEqualToString:haltestelle.name])
            {
                haltestelleToShow = haltestelle;
                break;
            }
        }
        [ivc setPointOfInterest:haltestelleToShow];
        ivc.haltestellen = _haltestellen;
        ivc.title = NSLocalizedString(@"Haltestelle", @"Haltestelle");
        [self.navigationController pushViewController:ivc animated:YES];
    }
}

- (void)showBuilding:(UITapGestureRecognizer *)sender
{
    sender.view.layer.opacity = .5;
    InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
    [ivc setPointOfInterest:pointOfInterest.parentPoi];
    ivc.haltestellen = _haltestellen;
    ivc.title = NSLocalizedString(@"Gebäude", @"Gebäude");
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)showBusStop:(UITapGestureRecognizer *)sender
{
    _haltestellenCell = (UITableViewCell *)sender.view;
    sender.view.layer.opacity = .5;
    InformationenViewController *ivc = [[InformationenViewController alloc] initWithNibName:@"Informationen" bundle:nil];
    UITableViewCell *cell = (UITableViewCell* )sender.view;
    POI *haltestelleToShow = nil;
    for (int i = 0; i < _haltestellen.count; i++)
    {
        POI *haltestelle = [_haltestellen objectAtIndex:i];
        if ([cell.textLabel.text isEqualToString:haltestelle.name])
        {
            haltestelleToShow = haltestelle;
            break;
        }
    }
    [ivc setPointOfInterest:haltestelleToShow];
    ivc.haltestellen = _haltestellen;
    ivc.title = NSLocalizedString(@"Haltestelle", @"Haltestelle");
    [self.navigationController pushViewController:ivc animated:YES];
}

@end
