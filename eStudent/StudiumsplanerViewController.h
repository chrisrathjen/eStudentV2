//
//  StudiumsplanerViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Präsentiert dem Nutzer, in Abhängigkeit vom gespeicherten Studiengang und dem dami verbundenen ersten Fachsemester,
//eine oder mehrere Seiten mit den Veranstaltungen, die im Studiumsplaner eingetragen sind.
@interface StudiumsplanerViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic)BOOL shouldRefresh; //Dieser BOOL steuert über die anderen Teil-Module hinweg, ob die Daten neu geladen werden sollen.
@property (nonatomic, strong)UIScrollView *scrollViewWithSelectedEintrag; //Der Scrollview, der den selektierten Eintrag enthält.

@end
