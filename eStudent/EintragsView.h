//
//  EintragsView.h
//  eStudent
//
//  Created by Nicolas Autzen on 03.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Eintrag;

//Eine Hilfsklasse für den StudiumsplanerViewController. Repräsentiert einen Eintrag für das UI.
@interface EintragsView : UIView

@property (nonatomic,strong)Eintrag *eintrag; //Der Eintrag, aus dem ein View generiert werden soll.
@property (nonatomic)BOOL wasMovedDown; //Ein BOOL Indikator, der sagt, ob ein Eintrag im UI nach unten animiert wurde.

//Der überschriebene Initializer.
- (id)initWithFrame:(CGRect)frame eintrag:(Eintrag *)eintrag viewController:(UIViewController *)viewController;
//Prüft ob ein Eintrag bestanden ist oder nicht. Und setzt entsprechend eine 'Bestanden'-Grafik im Eintrag.
- (void)setCheckmarkImage;
//Löscht das Label, das anzeigt, wie viele offene Kriterien ein Eintrag hat.
- (void)removeKriterienLabel;

@end
