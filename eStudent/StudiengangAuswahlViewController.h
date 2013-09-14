//
//  StudiengangAuswahlViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Studiengang;
@class Semester;

@interface StudiengangAuswahlViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)Studiengang *chosenStudiengang;
@property (nonatomic,strong)Semester *semester;

@end
