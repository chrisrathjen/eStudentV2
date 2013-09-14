//
//  ManuelleVeranstaltungViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 04.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lecture.h"
#import "Semester.h"

@interface ManuelleVeranstaltungViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic,strong)Lecture *veranstaltung;
@property (nonatomic,copy)NSString *eintragsArtString;
@property (nonatomic,strong)Semester *semester;

@end
