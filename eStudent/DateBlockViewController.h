//
//  DateBlockViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 07.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TMPDateBlock;

//Erzeugt eine Eingabemaske, über die der Nutzer Termine zu einer manuell
//angelegten Veranstaltung hinzufügen/verändern kann.
@interface DateBlockViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)NSString *semester; //Das Semester in dem die manuell angelegte Veranstaltung stattfindet.
@property (nonatomic,retain)TMPDateBlock *dateBlock;

@end
