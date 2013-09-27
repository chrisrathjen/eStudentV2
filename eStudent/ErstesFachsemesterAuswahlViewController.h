//
//  ErstesFachsemesterAuswahlViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 29.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Studiengang.h"

//Präsentiert dem Nutzer eine Auswahl mit Semestern, vom aktuellen bis unendlich weit zurück. Eins der Semester soll er
//als das erste Fachsemester des angelegten Studiengangs wählen.
@interface ErstesFachsemesterAuswahlViewController : UITableViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic,strong)NSString *studiengangName; //Der Name des Studiengangs, den der Nutzer zuvor eingebenen hat.
@property (nonatomic,strong)NSString *abschlussArt; //Die Abschlussart des Studiengangs (Bachelor, Master, usw.).
@property (nonatomic, assign)int cp; //Die Anzahl der CP, die der angelegte Studiengang insgesamt hat.
@property (nonatomic,strong)Studiengang *studiengang;

@end
