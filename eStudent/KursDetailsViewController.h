//
//  KursDetailsViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 16.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lecture.h"

//Zeigt dem Nutzer die Details zu einer Veranstaltung an.
@interface KursDetailsViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic,strong)Lecture *veranstaltung; //Die gewählte Veranstaltung.

@end
