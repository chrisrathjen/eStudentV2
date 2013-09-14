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

@interface EditEntryView : UIView <NoteEintragenViewDelegate>

@property (nonatomic,strong)UIView *editEntryView;

+ (EditEntryView *)sharedInstance;

- (void)presentSelfWithViewController:(id)sender EintragsView:(EintragsView *)eintragsView;

@end
