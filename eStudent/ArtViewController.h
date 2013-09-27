//
//  ArtViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 13.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Präsentiert dem Nutzer eine Auswahl der Eintragsarten (Vorlesung, Tutorium usw.).
@interface ArtViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *selectedCells;

@end
