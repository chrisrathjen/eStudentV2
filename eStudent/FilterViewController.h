//
//  FilterViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 18.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UebersichtViewController.h"

//Präsentiert dem Nutzer die drei Filtermöglichkeiten im Teil-Modul 'Übersicht', wenn der Nutzer auf den 'Auge' Button tippt.
@interface FilterViewController : UITableViewController

@property (nonatomic,strong)UebersichtViewController *viewController; //Eine Instanz des Übersichtscontrollers, um Events an diesen weiterzuleiten.

@end
