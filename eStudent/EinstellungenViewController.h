//
//  SettingsViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EinstellungenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak)IBOutlet UITableView *tableView;

@end
