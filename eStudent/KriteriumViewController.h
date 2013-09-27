//
//  KriteriumViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 18.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Kriterium;
@class TMPKriterium;

//Präsentiert dem Nutzer eine Eingabemaske, über die er Kriterien anlegen, bzw. bestehende Kriterien bearbeiten kann.
@interface KriteriumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)Kriterium *kriterium; //Das Kriterium, falls ein bestehendes berbeitet werden soll.
@property (nonatomic,strong)TMPKriterium *tmpKriterium; //Es kann sich auch um ein temporäres Kriterium handeln, das bearbeitet werden soll.

@end
