//
//  StudiengaengeViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 12.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Term.h"

//Eine Klasse des Teil-Moduls Veranstaltungsverzeichnis. Zeigt die Studiengänge zu einem Semester an.
@interface StudiengaengeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic,strong)Term *chosenSemester; //Das Semester, dessen Studiengänge geladen werden sollen.

//Lädt die Veranstaltungen zu einem Semester.
- (void)loadCoursesforTerm:(Term *)term;

@end
