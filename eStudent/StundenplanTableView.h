//
//  StundenplanTableView.h
//  eStudent
//
//  Created by Nicolas Autzen on 26.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Date.h"

//Diese Klasse ist für das eigentliche Anzeigen der Stundenplan-Daten verantwortlich.
//Diese Auslagerung macht das Laden und Verschieben der Daten einfacher.
@interface StundenplanTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

//Der Setter der Daten wird überschrieben, damit das User Interface nach der Übergabe direkt neu geladen wird.
@property (nonatomic,copy)NSArray *dates;

//Überschreibt den Initializer um gleich die Daten mit übergeben zu können.
- (id)initWithFrame:(CGRect)frame DateArray:(NSArray *)dates;
//Lädt die entsprechenden Daten, wenn der Nutzer eine komplette Woche zurück geht.
- (void)setDatesForWeekBack:(NSArray *)dates;
//Lädt die entsprechenden Daten, wenn der Nutzer eine komplette Woche vor geht.
- (void)setDatesForWeekFurther:(NSArray *)dates;

@end
