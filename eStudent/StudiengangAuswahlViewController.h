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

//Präsentiert dem Nutzer die auswählbaren Studiengänge, von denen er einen, für den Eintrag, wählen kann.
@interface StudiengangAuswahlViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)Studiengang *chosenStudiengang; //Der vorausgewählte Studiengang.
@property (nonatomic,strong)Semester *semester; //Das Semester, das bisher ausgewählt wurde.

@end
