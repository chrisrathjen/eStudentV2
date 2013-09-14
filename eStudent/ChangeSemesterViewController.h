//
//  ChangeSemesterViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 14.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Term.h"

@interface ChangeSemesterViewController : UITableViewController

@property (nonatomic,strong)UIViewController *pViewController;
@property (nonatomic,strong)Term *chosenTerm;

@end
