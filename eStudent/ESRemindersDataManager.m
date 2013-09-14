//
//  ESRemindersDataManager.m
//  eStudent
//
//  Created by Christian Rathjen on 29/3/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ESRemindersDataManager.h"


@interface ESRemindersDataManager()
{
    EKEventStore *eventStore;
}
- (void)setupEventStore;

@end

@implementation ESRemindersDataManager
@synthesize defaultRemindersList = _defaultRemindersList;

+(ESRemindersDataManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject setupEventStore];
    });
    return _sharedObject;
}


- (void)setupEventStore
{
    if (![eventStore respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        return;
    }
    eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error){
            if (granted) {
                NSLog(@"Access to Reminders Granted");
                if (!self.defaultRemindersList) {
                    NSString *defaultReminderListTitle = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultReminderCalenderTitle];
                    if (defaultReminderListTitle) {
                        NSArray *allReminderCalendars = [self getAllReminderLists];
                        for (EKCalendar *aCal in allReminderCalendars) {
                            if ([aCal.title isEqualToString:defaultReminderListTitle]) {
                                self.defaultRemindersList = aCal;
                            }
                        }
                    } else {
                        self.defaultRemindersList = [eventStore defaultCalendarForNewReminders];
                    }
                }
            } else {
                NSLog(@"Access to Reminders Denied");
            }
        }];
    }
}

- (void)setDefaultRemindersList:(EKCalendar *)defaultRemindersList
{
    _defaultRemindersList = defaultRemindersList;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultRemindersList.title forKey:kDefaultReminderCalenderTitle];
    [defaults synchronize];
}

- (BOOL)remindersAccessible
{
    if (![eventStore respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        return NO;
    }
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusAuthorized:
            if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                return YES;
            } else {
                return NO;
            }
            break;
            
        case EKAuthorizationStatusDenied:
            return NO;
            break;
            
        case EKAuthorizationStatusNotDetermined:
            NSLog(@"Nutzer noch nicht nach Zugang zu den Reminders gefragt");
            if (eventStore) {
                [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error){
                    if (granted) {
                        NSLog(@"Access to Reminders Granted");
                    } else {
                        NSLog(@"Access to Reminders Denied");
                    }
                }];
            }
            break;
            
        case EKAuthorizationStatusRestricted:
            return NO;
            break;
        default:
            break;
    }
    return NO;
}

- (BOOL)remindersInUse
{
    if (![eventStore respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        return NO;
    }
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusAuthorized:
            if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                return YES;
            } else {
                return NO;
            }
            break;
            
        case EKAuthorizationStatusDenied:
            return NO;
            break;
            
        case EKAuthorizationStatusNotDetermined:
            return NO;
            break;
            
        case EKAuthorizationStatusRestricted:
            return NO;
            break;
        default:
            break;
    }
    return NO;
}

- (NSArray *)getAllReminderLists
{
    return [eventStore calendarsForEntityType:EKEntityTypeReminder];
}

- (void)createReminderWithKriterium:(Kriterium *)kriterium
{
    if (kriterium.calendarItemIdentifier) {
        //Kriterium is already Linked to a Reminder;
        EKReminder *theReminder = (EKReminder *)[eventStore calendarItemWithIdentifier:kriterium.calendarItemIdentifier];
        if (theReminder) {
            NSLog(@"Kriterium ist schon an einen Reminder gelinkt");
            [self updateReminderForKriterium:kriterium];
        }
        
    } else {
        EKReminder *theReminder = [EKReminder reminderWithEventStore:eventStore];
        theReminder.calendar = self.defaultRemindersList;
        theReminder.title = kriterium.name;
        theReminder.completed = kriterium.erledigt;
        
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:kriterium.date];
        dueDateComponents.timeZone = [NSTimeZone systemTimeZone];
        theReminder.dueDateComponents = dueDateComponents;
        
        NSDateComponents *startDateComponents = [cal components:unitFlags fromDate:[NSDate date]];
        startDateComponents.timeZone = [NSTimeZone systemTimeZone];
        theReminder.startDateComponents = startDateComponents;
        
        BOOL success = [eventStore saveReminder:theReminder commit:YES error:nil];
        if (success) {
            kriterium.calendarItemIdentifier = theReminder.calendarItemIdentifier;
            [[CoreDataDataManager sharedInstance] saveDatabase];
        }
        
    }
}

//Diese Methode ignoriert änderungen welche in der RemindersApp gemacht wurden und aktualisiert den Reminder mit App eigenen Daten!
- (void)updateReminderForKriterium:(Kriterium *)kriterium
{
    EKReminder *theReminder = (EKReminder *)[eventStore calendarItemWithIdentifier:kriterium.calendarItemIdentifier];
    if (theReminder) {
        theReminder.title = kriterium.name;
        theReminder.completed = kriterium.erledigt;
        if (theReminder.completed && !theReminder.completionDate) {
            theReminder.completionDate = [NSDate date];
        }
        
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:kriterium.date];
        dueDateComponents.timeZone = [NSTimeZone systemTimeZone];
        theReminder.dueDateComponents = dueDateComponents;
        
        [eventStore saveReminder:theReminder commit:YES error:nil];
    }
}

- (EKCalendar *)createNewRemindersListWithName:(NSString *)listName setAsDefault:(BOOL)isDefaultList
{
    if (listName) {
        EKCalendar *theCalendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:eventStore];
        theCalendar.title = listName;
        if (isDefaultList) {
            self.defaultRemindersList = theCalendar;
        }
        NSArray *sources = [eventStore sources];
        
        for (EKSource *aSource in sources) {
            if ([aSource.title  isEqualToString:@"iCloud"]) {
                theCalendar.source = aSource;
            }
        }
        if (!theCalendar.source) {
            return nil;
        }
        [eventStore saveCalendar:theCalendar commit:YES error:nil];
        return theCalendar;
    }
    return nil;
}

- (BOOL)deleteRemindersList:(EKCalendar *)theList
{
    return [eventStore removeCalendar:theList commit:YES error:nil];
}

- (void)deleteReminderForKriterium:(Kriterium *)kriterium
{
    [eventStore removeReminder:(EKReminder *)[eventStore calendarItemWithIdentifier:kriterium.calendarItemIdentifier] commit:YES error:nil];
}

- (void)syncronizeAllLinkedReminders
{
    NSArray *kriterien = [[CoreDataDataManager sharedInstance] getAllKriteriumsWithLinkedReminder];
    
    for (Kriterium *aKriterium in kriterien) {
        EKReminder *aReminder = (EKReminder *)[eventStore calendarItemWithIdentifier:aKriterium.calendarItemIdentifier];
        if (aReminder.completed && ![aKriterium.erledigt boolValue]) {
            aKriterium.erledigt = [NSNumber numberWithBool:YES];
            [[CoreDataDataManager sharedInstance] saveDatabase];
        } else if (!aReminder.completed && [aKriterium.erledigt boolValue])
        {
            aReminder.completed = YES;
            aReminder.completionDate = [NSDate date];
            [eventStore saveReminder:aReminder commit:YES error:nil];
        }
    }
}









@end
