//
//  StundenplanTableView.h
//  eStudent
//
//  Created by Nicolas Autzen on 26.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Date.h"

@interface StundenplanTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic,copy)NSArray *dates;

- (id)initWithFrame:(CGRect)frame DateArray:(NSArray *)dates;
- (void)setDatesForWeekBack:(NSArray *)dates;
- (void)setDatesForWeekFurther:(NSArray *)dates;

@end
