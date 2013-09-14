//
//  EintragsView.h
//  eStudent
//
//  Created by Nicolas Autzen on 03.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Eintrag;

@interface EintragsView : UIView

@property (nonatomic,strong)Eintrag *eintrag;
@property (nonatomic)BOOL wasMovedDown;

- (id)initWithFrame:(CGRect)frame eintrag:(Eintrag *)eintrag viewController:(UIViewController *)viewController;
- (void)setCheckmarkImage;
- (void)removeKriterienLabel;

@end
