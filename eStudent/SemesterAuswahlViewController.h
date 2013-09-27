//
//  SemesterAuswahlViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 13.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Semester;
@class Studiengang;

//Präsentiert dem Nutzer eine Auswahl von möglichen Semestern, in denen der Eintrag liegen kann.
@interface SemesterAuswahlViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic,strong)Semester *chosenSemester; //Das bisher gewählte Semester.
@property (nonatomic,copy)NSString *semesterString;
@property (nonatomic,strong)Studiengang *studiengang; //Der bisher gewählte Studiengang.

@end