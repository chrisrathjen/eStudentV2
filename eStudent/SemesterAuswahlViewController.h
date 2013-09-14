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

@interface SemesterAuswahlViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic,strong)Semester *chosenSemester;
@property (nonatomic,strong)Studiengang *studiengang;

@end