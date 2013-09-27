//
//  NeuerStudiengangViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 29.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Studiengang.h"

//Präsentiert dem Nutzer die Eingabemaske, mit der er einen neuen Studiengang anlegen kann.
@interface NeuerStudiengangViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic,strong)Studiengang *studiengang;

@end
