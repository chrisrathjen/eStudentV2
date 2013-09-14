//
//  ESRemindersDataManager.h
//  eStudent
//
//  Created by Christian Rathjen on 29/3/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "CoreDataDataManager.h"

@interface ESRemindersDataManager : NSObject

+(ESRemindersDataManager *)sharedInstance;

//Testet/erfragt ob der Nutzer die Reminderes integration nutzen will
- (BOOL)remindersAccessible;
//Testet ob der nutzer der Ntzung bereits zugestimmt hat (keine erneute nachfrage)
- (BOOL)remindersInUse;

//Das Array enthält EKCalendar Objekte, diese habe eine Title Property. Der Titel entspricht der Bezeichnung der Listen in der RemindersApp. Vermutlich musst du "<EventKit/EventKit.h>" importieren um mit den Objekten arbeiten zu können.
- (NSArray *)getAllReminderLists;

//Hier wird ein Reminder aus einem Kriterium erstellt und an das Kriterium gebunden.
- (void)createReminderWithKriterium:(Kriterium *)kriterium;

//Hier wird ein bestehender Reminder mit den Informationen des Kriteriums aktualisert.
- (void)updateReminderForKriterium:(Kriterium *)kriterium;

- (void)deleteReminderForKriterium:(Kriterium *)kriterium;

//Erstellt eine neu Liste in der RemindersApp und kann die neue Liste als Standart für neue Reminders setzen.
- (EKCalendar *)createNewRemindersListWithName:(NSString *)listName setAsDefault:(BOOL)isDefaultList;

//Syncronisiert die bestandenen Kriterien zwischen der Reminders-App und dem eigenen Datensatz
- (void)syncronizeAllLinkedReminders;

//Diese Methode nur mit Vorsicht verwenden hier könnten Nutzerinformationen verloren gehen!!
- (BOOL)deleteRemindersList:(EKCalendar *)theList;

//Setzt den Calendar
@property (nonatomic, strong)EKCalendar *defaultRemindersList;


@end
