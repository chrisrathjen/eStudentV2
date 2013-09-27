//
//  BelegteVeranstaltungenViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 23.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Der Controller für das Teil-Modul 'Deine Veranstaltungen'. Er stellt sämtliche Veranstaltungen dar, in die der Nutzer sich
//eingetragen hat, egal ob in den Stundenplan, den Studiumsplaner, in beides. Auch manuell angelegte Veranstaltungen werden hier aufgelistet.
@interface BelegteVeranstaltungenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@end
