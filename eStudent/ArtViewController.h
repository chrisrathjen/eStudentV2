//
//  ArtViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 13.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIBarButtonItem *fertigButton;
    __weak IBOutlet UIBarButtonItem *bearbeitenButton;
    __weak IBOutlet UINavigationBar *navigationBar;
    
    NSMutableArray *eintragsArten;
    int numberOfSections;
    UITextField *txtField;
}

@property (nonatomic,strong)NSMutableArray *selectedCells;

- (IBAction)fertigButtonPressed:(id)sender;
- (IBAction)bearbeitenButtonPressed:(id)sender;

@end
