//
//  NoteEintragenView.h
//  eStudent
//
//  Created by Nicolas Autzen on 07.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Eintrag.h"

@protocol NoteEintragenViewDelegate
- (void)noteEintragenViewAbbrechenButtonPressed;
- (void)noteEintragenViewEintragenButtonPressedWithText:(NSString *)textfieldString;
@end

@interface NoteEintragenView : UIView

@property (nonatomic,strong)id<NoteEintragenViewDelegate> delegate;

- (void)slideDown;
- (void)slideUp;

@end
