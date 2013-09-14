//
//  KriteriumViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 18.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Kriterium;
@class TMPKriterium;

@interface KriteriumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)Kriterium *kriterium;
@property (nonatomic,strong)TMPKriterium *tmpKriterium;

@end
