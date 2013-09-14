//
//  HomeScreenViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESMensaDataManager.h"
@class FoodEntry;

@interface HomeScreenViewController : UITableViewController <ESMensaDataManagerDelegate>
{
    BOOL noDataToParse;
    BOOL noNetworkConnection;
    FoodEntry *foodEntry;
}
- (void)refreshMensaData;

@property (nonatomic)BOOL settingsIsVisible; //wird benötigt, um zu überprüfen, ob das Einstellungsmenü sichtbar ist
@property (nonatomic,strong)ESMensaDataManager *mensaDataManager;

- (BOOL)isWeekDay;

@end
