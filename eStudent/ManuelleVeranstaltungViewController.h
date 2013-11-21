//
//  ManuelleVeranstaltungViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 04.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lecture.h"
#import "Semester.h"
#import "TMPDateBlock.h"

//Bietet dem Nutzer eine Eingabemakse um eine Veranstaltung manuell anzulegen, bzw. um eine
//bestehende, manuell angelegte Veranstaltung zu bearbeiten.
@interface ManuelleVeranstaltungViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic,strong)Lecture *veranstaltung; //Die gewählte Veranstaltung, falls keine neue angelegt, sondern eine bestehende bearbeitet werden soll.
@property (nonatomic,copy)NSString *eintragsArtString; //Die Eintrags-Art der Veranstaltung (Vorlesung, Seminar, etc.).
@property (nonatomic,copy)NSString *semester; //Das gewählte Semester, in dem die Veranstaltung stattfindet.
@property (nonatomic,strong)UISwitch *zumStundenplanHinzufuegenSwitch;
@property (nonatomic)BOOL *inDenStundenplan;

- (void)addDates:(NSArray *)dates ToDateBlock:(TMPDateBlock *)dateBlock;
- (void)addDateBlock:(TMPDateBlock *)dateBlock;
- (void)deleteDateBlock:(TMPDateBlock *)dateBlock;

@end
