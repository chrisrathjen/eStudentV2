//
//  ESMensaDataManager.m
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "ESMensaDataManager.h"
#import "ESNetworkManager.h"
#import "FoodEntry.h"
#import "Constants_ES.h"

@interface ESMensaDataManager()<ESNetworkManagerDelegate>
- (void)buildMensaMenu;
- (void)getSelectedFoodEntry;

@property (nonatomic, strong)NSString *foodName;
@property (nonatomic, strong)NSString *aDay;
@property (nonatomic, strong)NSDictionary *mensaData;
@end
@implementation ESMensaDataManager

- (void)setMensaData:(NSDictionary *)mensaData
{
    _mensaData = mensaData;
    if (([[mensaData objectForKey:@"weeknumber"] isEqualToNumber:[self getWeek]])) {
        if (self.foodName) {
            [self getSelectedFoodEntry];
        } else if (self.aDay){
            [self compileDailyMenu];
        } else {
            [self buildMensaMenu]; //start building the menu from JSON Dictionary
        }
    } else {
            //[self.delegate oldDataParsed]; // If the Date (cache/downloaded) is too old, tell the delegate
        [self.delegate noDataToParse];
    }
}

- (void)getMenuDataForMensa:(NSString *)Mensa
{
        //Check for cached Version
    self.currentMensa = Mensa;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:Mensa] stringByExpandingTildeInPath]; //Get PAth to Cached File in the Library Folder
    if (([[defaults objectForKey:Mensa] isEqualToNumber:[self getWeek]]) && ([[NSFileManager defaultManager] fileExistsAtPath:filePath])) {
        self.mensaData = [NSDictionary dictionaryWithContentsOfFile:filePath]; //If the cached Version is current und exist, use the cached Version
    } else {
            //If there is no local copy go download it!
        ESNetworkManager *menuDownloader = [[ESNetworkManager alloc] init];
        [menuDownloader setDelegate:self];
        [menuDownloader getDataFromNetwork:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kMensaDataURL,Mensa,kMensaDataFromat]]];
    }
}

- (void)getFoodEntryForEssen:(NSString *)aFood inMensa:(NSString *)aMensa
{
    self.currentMensa = aMensa;
    self.foodName = aFood;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aMensa] stringByExpandingTildeInPath]; //Get PAth to Cached File in the Library Folder
    if (([[defaults objectForKey:aMensa] isEqualToNumber:[self getWeek]]) && ([[NSFileManager defaultManager] fileExistsAtPath:filePath])) {
        self.mensaData = [NSDictionary dictionaryWithContentsOfFile:filePath]; //If the cached Version is current und exist, use the cached Version
    } else {
        //If there is no local copy go download it!
        ESNetworkManager *menuDownloader = [[ESNetworkManager alloc] init];
        [menuDownloader setDelegate:self];
        [menuDownloader getDataFromNetwork:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kMensaDataURL,aMensa,kMensaDataFromat]]];
    }
}

- (void)getDailyMenuForDay:(NSString *)aDay inMensa:(NSString *)aMensa
{
    self.currentMensa = aMensa;
    self.aDay = aDay;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aMensa] stringByExpandingTildeInPath]; //Get PAth to Cached File in the Library Folder
    if (([[defaults objectForKey:aMensa] isEqualToNumber:[self getWeek]]) && ([[NSFileManager defaultManager] fileExistsAtPath:filePath])) {
        self.mensaData = [NSDictionary dictionaryWithContentsOfFile:filePath]; //If the cached Version is current und exist, use the cached Version
    } else {
        //If there is no local copy go download it!
        ESNetworkManager *menuDownloader = [[ESNetworkManager alloc] init];
        [menuDownloader setDelegate:self];
        [menuDownloader getDataFromNetwork:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kMensaDataURL,aMensa,kMensaDataFromat]]];
    }
}
- (void)getSelectedFoodEntry
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
        int weekday = [components weekday];
        //return (weekday > 1 && weekday < 7);
        NSArray *foodsForDay;
        switch (weekday) {
            case 2: //Monday
                foodsForDay = [self.mensaData objectForKey:@"Monday"];
                break;
            case 3: //Tuesday
                foodsForDay = [self.mensaData objectForKey:@"Tuesday"];
                break;
            case 4: //Wednesday
                foodsForDay = [self.mensaData objectForKey:@"Wednesday"];
                break;
            case 5: //Thursday
                foodsForDay = [self.mensaData objectForKey:@"Thursday"];
                break;
            case 6: //Friday
                foodsForDay = [self.mensaData objectForKey:@"Friday"];
                break;
            default:
                //[self.delegate noDataToParse];
                foodsForDay = [self.mensaData objectForKey:@"Friday"];
                break;
        }
        FoodEntry *aFoodEntry;
        for (NSDictionary *aFood in foodsForDay) {
            if ([[aFood objectForKey:@"name"] isEqualToString:self.foodName]) {
                aFoodEntry = [[FoodEntry alloc] init];
                aFoodEntry.name = [aFood objectForKey:@"name"];
                aFoodEntry.foodDescription = [aFood objectForKey:@"desc"];
                aFoodEntry.staffPrice = [aFood objectForKey:@"staff"];
                aFoodEntry.studentPrice = [aFood objectForKey:@"student"];
                aFoodEntry.types = [[aFood objectForKey:@"types"] copy];
            }
        }
        if (!aFoodEntry) {
            NSDictionary *aFood = [foodsForDay objectAtIndex:0];
            aFoodEntry = [[FoodEntry alloc] init];
            aFoodEntry.name = [aFood objectForKey:@"name"];
            aFoodEntry.foodDescription = [aFood objectForKey:@"desc"];
            aFoodEntry.staffPrice = [aFood objectForKey:@"staff"];
            aFoodEntry.studentPrice = [aFood objectForKey:@"student"];
            aFoodEntry.types = [[aFood objectForKey:@"types"] copy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (aFoodEntry) {
                [self.delegate selectedFoodEntry:aFoodEntry];
            } else {
                [self.delegate noDataToParse];
            }
            
        });
    });
}

- (void)compileDailyMenu
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *foodsForDay = [self.mensaData objectForKey:self.aDay];
            NSMutableArray *foodArray = [[NSMutableArray alloc] init];
            for (NSDictionary *aFood in foodsForDay) {
                FoodEntry *aFoodEntry = [[FoodEntry alloc] init];
                aFoodEntry.name = [aFood objectForKey:@"name"];
                aFoodEntry.foodDescription = [aFood objectForKey:@"desc"];
                aFoodEntry.staffPrice = [aFood objectForKey:@"staff"];
                aFoodEntry.studentPrice = [aFood objectForKey:@"student"];
                aFoodEntry.types = [[aFood objectForKey:@"types"] copy];
                [foodArray addObject:aFoodEntry];
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([foodArray lastObject]) { // If parsing was successfull send it to the Delegate
                [self.delegate parsedMenuForADay:[foodArray copy]];
            } else {
                [self.delegate noDataToParse]; // if parsing failed, tell the Delegate
            }
        });
    });
}

- (void)buildMensaMenu
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *parsedMenu = [NSMutableDictionary dictionary];
        NSArray *dayNames = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", nil];
        NSArray *wantedFoodTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kFILTERED_FOOD_TYPES];
        BOOL filterActive = NO;
        if ([wantedFoodTypes count] < 8) {
            filterActive = YES;
        }
        for (NSString *aDayName in dayNames) {
            NSArray *foodsForDay = [self.mensaData objectForKey:aDayName];
            NSMutableArray *foodArray = [[NSMutableArray alloc] init];
            for (NSDictionary *aFood in foodsForDay) {
                FoodEntry *aFoodEntry = [[FoodEntry alloc] init];
                aFoodEntry.name = [aFood objectForKey:@"name"];
                aFoodEntry.foodDescription = [aFood objectForKey:@"desc"];
                aFoodEntry.staffPrice = [aFood objectForKey:@"staff"];
                aFoodEntry.studentPrice = [aFood objectForKey:@"student"];
                aFoodEntry.types = [[aFood objectForKey:@"types"] copy];
                if (filterActive) { // Wenn alle 8 Typen gewollt sind brauchen wir nicht filtern
                    if (![self filterFoodEntry:aFoodEntry withFoodTypes:wantedFoodTypes]) {
                        [foodArray addObject:aFoodEntry];
                    }
                } else {
                    [foodArray addObject:aFoodEntry];
                }
                
            }
            [parsedMenu setObject:[foodArray copy] forKey:aDayName];
        }        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([parsedMenu objectForKey:@"Monday"]) { // If parsing was successfull send it to the Delegate
                [self.delegate parsedMenuData:[parsedMenu copy]];
                self.Menu = parsedMenu;
            } else {
                [self.delegate noDataToParse]; // if parsing failed, tell the Delegate
            }
        });
    });
}



- (BOOL)filterFoodEntry:(FoodEntry *)aFoodEntry withFoodTypes:(NSArray *)wantedFoodTypes //YES means filter FoodEntry out
{
    NSMutableArray *currentFoodTypes = [aFoodEntry.types mutableCopy];
    for (NSString *aString in currentFoodTypes) {
        if ([aString isEqualToString:@"Bio"]) {
            [currentFoodTypes removeObject:aString];
        }
    }
    if ([currentFoodTypes count] == 1) {
        BOOL keep = NO;
        for (NSString *aWantedFoodType in wantedFoodTypes) {
            if ([aWantedFoodType isEqualToString:[currentFoodTypes lastObject]]) {
                keep = YES;
            }
        }
        if (keep) {
            return NO;
        } else {
            return YES;
        }
    } else if([currentFoodTypes count] > 1) {
        BOOL keep = NO;
        for (NSString *aFoodType in currentFoodTypes) {
            if (([self array:wantedFoodTypes containsString:aFoodType] && [aFoodType isEqualToString:@"Vegetarisch"]) || ([self array:wantedFoodTypes containsString:aFoodType] && [aFoodType isEqualToString:@"Vegan"])) {
                keep = YES;
            }
        }
        if (keep) {
            return NO;
        }
        keep = YES;
        
        for (NSString *aFoodType in currentFoodTypes) {
            if (![self array:wantedFoodTypes containsString:aFoodType]) {
                keep = NO;
            }
        }
        if (!keep) {
            return YES;
        }
    }
    return NO;
    
}

- (BOOL)array:(NSArray *)anArray containsString:(NSString *)aString {
    for (id anObject in anArray) {
        if ([anObject isKindOfClass:[NSString class]]) {
            if ([aString isEqualToString:anObject]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSNumber *)getWeek {
    NSDate *date = [NSDate date];
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"w"];
    NSString *weekDateString = [weekFormatter stringFromDate:date];
    return [NSNumber numberWithInteger:[weekDateString integerValue]];
}

#pragma mark - NSNetworkManagerDelegate
- (void)dataFromRemoteURL:(NSData *)remoteData
{
    [self setMensaData:[NSJSONSerialization JSONObjectWithData:remoteData options:kNilOptions error:nil]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[self.mensaData objectForKey:@"weeknumber"] isEqualToNumber:[self getWeek]]) {
        return;//Die Vom Server bereitgestellten Daten sind nicht aktuell!
    }
    NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [library stringByAppendingString:[NSString stringWithFormat:@"/%@",self.currentMensa]] ;
    if ([self.mensaData writeToFile:filePath atomically:YES]) {
        [defaults setObject:[self.mensaData objectForKey:@"weeknumber"] forKey:self.currentMensa];
        [defaults synchronize];
    }
}

- (void)requestFailedWithError:(NSString *)localizedErrorString
{
    [self.delegate noNetworkConnection:localizedErrorString]; //If the File could noch be downloaded, tell the Delegate
}
@end