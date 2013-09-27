//
//  SettingsViewController.h
//  eStudent
//
//  Created by Georg Scharsich on 17.05.13.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Präsentiert dem Nutzer die Maske mit den Einstellungsmöglichkeiten.
@interface EinstellungenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak)IBOutlet UITableView *tableView;

@end
