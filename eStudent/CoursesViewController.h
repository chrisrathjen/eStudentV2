//
//  CoursesViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 15.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "MBProgressHUD.h"

@interface CoursesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MBProgressHUDDelegate>

@property (nonatomic,strong)Course *studiengang;

@end
