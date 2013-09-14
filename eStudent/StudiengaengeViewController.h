//
//  StudiengaengeViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 12.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Term.h"

@interface StudiengaengeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic,strong)Term *chosenSemester;

- (void)loadCoursesforTerm:(Term *)term;

@end
