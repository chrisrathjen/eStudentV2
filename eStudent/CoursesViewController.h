//
//  CoursesViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 15.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"

//Diese Klasse stellt dem Nutzer sämtliche Veranstaltungen zu einem Studiengang in einem bestimmten Semester zur Verfügung.
@interface CoursesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic,strong)Course *studiengang; //Der gewählte Studiengang.

@end
