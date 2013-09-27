//
//  EditEntryView.h
//  eStudent
//
//  Created by Nicolas Autzen on 19.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteEintragenView.h"
@class EintragsView;

//Repräsentiert die Leiste, die unter einem Eintrag auftaucht, über die der Nutzer einen Eintrag als
//bestanden/nicht bestanden markieren kann, sowie diesen bearbeiten kann.
@interface EditEntryView : UIView <NoteEintragenViewDelegate>

@property (nonatomic,strong)UIView *editEntryView;

//Es handelt sich um einen Singleton.
+ (EditEntryView *)sharedInstance;

//Ruft die Leiste in einem bestimmten ViewController unter einem bestimmten EintragsView auf.
- (void)presentSelfWithViewController:(id)sender EintragsView:(EintragsView *)eintragsView;

@end
