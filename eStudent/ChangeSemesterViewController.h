//
//  ChangeSemesterViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 14.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Term.h"

//Zeigt die Semester an, die dem Nutzer zur Auswahl stehen.
@interface ChangeSemesterViewController : UITableViewController

@property (nonatomic,strong)UIViewController *pViewController; //Eine Referenz auf den Controller, der diesen Controller anzeigt.
@property (nonatomic,strong)Term *chosenTerm; //Das Semester, welches bisher ausgewählt ist, um dies visuell hervorzuheben.

@end
