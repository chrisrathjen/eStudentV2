//
//  NoteEintragenView.h
//  eStudent
//
//  Created by Nicolas Autzen on 07.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Eintrag.h"

//Der Delegate muss auf die Eingaben der Button reagieren.
@protocol NoteEintragenViewDelegate
- (void)noteEintragenViewAbbrechenButtonPressed;
- (void)noteEintragenViewEintragenButtonPressedWithText:(NSString *)textfieldString;
@end

//Repräsentiert die Leiste, die von oben einfährt, über die der Nutzer die Note für einen bestandenen Eintrag eingeben muss.
@interface NoteEintragenView : UIView

@property (nonatomic,strong)id<NoteEintragenViewDelegate> delegate;

//Fährt die Leiste in den sichtbaren Bereich herunter.
- (void)slideDown;
//Versteckt die Leiste wieder.
- (void)slideUp;

@end
