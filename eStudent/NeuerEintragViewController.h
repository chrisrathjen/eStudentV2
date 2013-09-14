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

@interface NeuerEintragViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)Eintrag *eintrag;
@property (nonatomic,strong)NSString *eintragsArtString;
@property (nonatomic,strong)Semester *semester;
@property (nonatomic,strong)Studiengang *studiengang;
@property (nonatomic,strong)NSMutableArray *tmpKriterien;



@end
