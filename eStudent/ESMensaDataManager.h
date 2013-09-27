//
//  ESMensaDataManager.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoodEntry.h"

@class ESMensaDataManager;
@protocol ESMensaDataManagerDelegate
@optional
- (void)parsedMenuData:(NSDictionary *)menu; // Menu erfolgreich geparsed
- (void)selectedFoodEntry:(FoodEntry *)aFoodEntry;
- (void)parsedMenuForADay:(NSArray *)dailyMenu;
- (void)noDataToParse; // Leeres JSON Menu vom Server geparsed
- (void)noNetworkConnection:(NSString *)errorString; // Localisierter Netzwerk Fehler
@end
@interface ESMensaDataManager : NSObject
- (void)getMenuDataForMensa:(NSString *)Mensa; //Hier kann der Name der Mensa angegeben werden deren Daten geladen werden sollen(uni, gw2, air, ...)!
- (void)getFoodEntryForEssen:(NSString *)aFood inMensa:(NSString *)aMensa;
- (void)getDailyMenuForDay:(NSString *)aDay inMensa:(NSString *)aMensa;
+ (void)resetCache;

- (NSNumber *)getWeek;
@property (nonatomic, weak) id <ESMensaDataManagerDelegate> delegate; //Delegate gibt Auskunft wann die Daten zur verfügung stehen
@property (nonatomic, strong) NSMutableDictionary *Menu; // Enthält den Speiseplan nach erfolgreichem parsen / ladem vom Speicher
@property (nonatomic, strong)NSString *currentMensa; //Aktuelle Mensa, wie beim getMenuData... Aufruf uebergeben@end
@end
