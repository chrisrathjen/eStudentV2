//
//  InformationenViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POI.h"

@interface InformationenViewController : UIViewController <UIAlertViewDelegate>
{
    __weak IBOutlet UIScrollView *scrollView;
}

@property (nonatomic,strong)POI *pointOfInterest;
@property (nonatomic,copy)NSMutableArray *haltestellen;

@end
