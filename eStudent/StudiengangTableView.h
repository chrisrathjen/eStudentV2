//
//  StudiengangTableView.h
//  eStudent
//
//  Created by Nicolas Autzen on 11.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudiengangTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)studiengang;

@end
