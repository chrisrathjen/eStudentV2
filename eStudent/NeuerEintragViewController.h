//
//  NeuerEintragViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.02.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Eintrag;
@class Semester;
@class Studiengang;

//Präsentiert dem Nutzer eine Eingabemaske um einen neuen Eintrag anzulegen, bzw. um einen bestehenden Eintrag zu bearbeiten.
@interface NeuerEintragViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)Eintrag *eintrag; //Der Eintrag, falls einer bearbeitet werden soll.
@property (nonatomic,strong)NSString *eintragsArtString; //Die Eintragsart des Eintrags.
@property (nonatomic,strong)Semester *semester; //Das Semester, in dem der Eintrag angelegt werden soll, bzw. in dem er sich befindet.
@property (nonatomic,strong)Studiengang *studiengang; //Der Studiengang, in dem der Eintrag angelegt/bearbeitet werden soll.
@property (nonatomic,strong)NSMutableArray *tmpKriterien; //Die Kriterien zu dem Eintrag.



@end
