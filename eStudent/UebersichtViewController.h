//
//  UebersichtViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 14.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Präsentiert dem Nutzer die Übersichtsseite der Einträge.
@interface UebersichtViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic)BOOL shouldRefresh;//Dieser BOOL steuert über die anderen Teil-Module hinweg, ob die Daten neu geladen werden sollen.
@property (nonatomic, strong)UIScrollView *scrollViewWithSelectedEintrag; //Der Scrollview, der den selektierten Eintrag enthält.

- (void)loadViews;

@end
