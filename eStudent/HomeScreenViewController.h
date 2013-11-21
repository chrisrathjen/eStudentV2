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

//Der Controller für den Homescreen. Lädt die entsprechenden Daten in die dynamischen Felder
//und kümmert sich darum, dass die korrekten Controller beim auswählen des jeweiligen Feldes geladen werden.
@interface HomeScreenViewController : UITableViewController <ESMensaDataManagerDelegate>
{
    BOOL noDataToParse;
    BOOL noNetworkConnection;
    FoodEntry *foodEntry;
}

@property (nonatomic)BOOL settingsIsVisible; //Wird benötigt, um zu überprüfen, ob das Einstellungsmenü sichtbar ist.
@property (nonatomic,strong)ESMensaDataManager *mensaDataManager; //Lädt die Speiseplan-Informationen für das dynamische Feld Essen.

//Prüft ob der aktuelle tag ein Wochentag ist.
- (BOOL)isWeekDay;
- (void)refreshMensaData;
- (void)refreshLectureLiveTile;

@end
