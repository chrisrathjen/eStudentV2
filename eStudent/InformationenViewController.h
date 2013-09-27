//
//  InformationenViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POI.h"

//Präsentiert dem Nutzer die DetailInformationen zu einem POI.
@interface InformationenViewController : UIViewController <UIAlertViewDelegate>
{
    __weak IBOutlet UIScrollView *scrollView;
}

@property (nonatomic,strong)POI *pointOfInterest; //Der POI, dessen Details angezeigt werden sollen.
@property (nonatomic,copy)NSMutableArray *haltestellen; //Die Haltestellen, die sich unter den gesamten POI-Daten befinden.

@end
