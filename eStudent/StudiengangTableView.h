//
//  StudiengangTableView.h
//  eStudent
//
//  Created by Nicolas Autzen on 11.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

//Präsentiert dem Nutzer die Statistiken für einen Studiengang an. Die Daten werden über den Datenmanager geladen.
@interface StudiengangTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)studiengang; //Der Studiengang, dessen Statistiken angezeigt werden sollen.

@end
