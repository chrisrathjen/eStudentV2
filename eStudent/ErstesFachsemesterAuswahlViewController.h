//
//  ErstesFachsemesterAuswahlViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 29.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErstesFachsemesterAuswahlViewController : UITableViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic,strong)NSString *studiengangName;
@property (nonatomic,strong)NSString *abschlussArt;
@property (nonatomic, assign)int cp;

@end
