//
//  CoreDataDataManager.m
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "CoreDataDataManager.h"
#import <EventKit/EventKit.h>
#import "ESRemindersDataManager.h"


@interface CoreDataDataManager() 
//FetchRequest/DateFormatter werden wieder verwendet da sie sehr oft gebraucht werden
@property (nonatomic, strong) NSDateFormatter *aDateFormatter;
@property (nonatomic, strong) NSFetchRequest *courseFetchRequest;
@property (nonatomic, strong) NSFetchRequest *lectureFetchRequest;
@property (nonatomic, strong) NSFetchRequest *lecturerFetchRequest;
@property (nonatomic, strong) NSMutableArray *replacedLectures;
- (void)setupSharedInstance;
- (void)useDocument;
@end

@implementation CoreDataDataManager
@synthesize document = _document;

#pragma mark - Setup (Singleton, CoreData)
+(CoreDataDataManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject setupSharedInstance];
    });
    return _sharedObject;
}

- (void)setupSharedInstance
{
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    filePath = [filePath URLByAppendingPathComponent:@"CoreDataStorage"];
    if (!self.document) {
        self.document = [[UIManagedDocument alloc]initWithFileURL:filePath];
        [self useDocument];
    }
}

- (void)setDocument:(UIManagedDocument *)document
{
    if (_document != document){
        _document = document;
    }
}

//Diese Methode erstelt eine neue Datenbank wenn es noch keine Datenbank im Dateisystem gibt. Wenn es bereits eine Datenbank gibt wird diese bei bedarf geöffnet.
- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
        }];
        
    } else if (self.document.documentState == UIDocumentStateClosed)
    {
        [self.document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"Using existing (closed) DB");
        }];
    } else if (self.document.documentState == UIDocumentStateNormal)
    {
        NSLog(@"Using existing open DB");
    }
}
#pragma mark - Database Maintanence

- (void)saveDatabase
{
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
}

#pragma mark - Studiumsplaner
#pragma mark - Create
//Diese Methode erstellt ein neues Semester. Falls bereits ein Semester mit gleichem Namen existiert wird das bestehende Semester zurückgegeben
- (Semester *)createSemesterWithName:(NSString *)name
{
    NSPredicate *exitingSemesterWithName = [NSPredicate predicateWithFormat:@"name LIKE %@",name];
    NSFetchRequest *existingSemesterFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Semester"];
    existingSemesterFetchRequest.predicate = exitingSemesterWithName;
    if ([self.document.managedObjectContext countForFetchRequest:existingSemesterFetchRequest error:nil] > 0) {
        //Wenn es schon ein Semester mit dem Namen gibt wird dieses returned

        return [[self.document.managedObjectContext executeFetchRequest:existingSemesterFetchRequest error:nil] lastObject];
    }
    
    Semester *aSemester = [Semester CreateSemesterWithName:name inManagedContext:self.document.managedObjectContext];
    return aSemester;
}

//Ein bestehender Eintrag wird in die Datenbank ko[iert
//Dies sollte nicht verwendet werden da CoreData nicht fuer diesen UseCase ausgelegt ist!
- (void)addEintragToDatabase:(Eintrag *)einEintrag
{
    [self.document.managedObjectContext insertObject:einEintrag];
}

- (Eintrag *)createEintragWithTitle:(NSString *)title
                                art:(NSString *)art
                        isBestanden:(BOOL)bestanden
                          isBenotet:(BOOL)benotet
                                 cp:(NSNumber *)cp
                               note:(NSNumber *)note
                         inSemester:(Semester *)semester
                      inStudiengang:(Studiengang *)studiengang

{
    Eintrag *aEintrag = [Eintrag CreateEintragWithTitle:title art:art isBestanden:bestanden isBenotet:benotet cp:cp note:note inSemester:semester inStudiengang:studiengang inManagedContext:self.document.managedObjectContext];
    return aEintrag;
}

- (Kriterium *)createKriteriumWithName:(NSString *)name
                            isErledigt:(BOOL)erledigt
                                  date:(NSDate *)date
                            forEintrag:(Eintrag *)eintrag
{
    Kriterium *aKriterium = [Kriterium CreateKriteriumWithName:name isErledigt:erledigt date:date forEintrag:eintrag inManagedContext:self.document.managedObjectContext];
    return aKriterium;
}

- (Studiengang *)createStudiengangWithName:(NSString *)name
                                 abschluss:(NSString *)abschluss
                                        cp:(NSNumber *)cp
                        erstesFachsemester:(Semester *)semester
{
    Studiengang *aStudiengang = [Studiengang CreateStudiengangWithName:name abschluss:abschluss cp:cp erstesFachsemester:semester inManagedContext:self.document.managedObjectContext];
    return aStudiengang;
}

#pragma mark - Delete
- (void)deleteSemester:(Semester *)semester
{
    [self.document.managedObjectContext deleteObject:semester];
}

- (void)deleteEintrag:(Eintrag *)eintrag
{
    for (Kriterium *aKriterium in eintrag.kriterien) {
        [self deleteKriterium:aKriterium];
    }
    [self.document.managedObjectContext deleteObject:eintrag];
}

- (void)deleteStudiengang:(Studiengang *)studiengang
{
    for (Eintrag *anEintrag in studiengang.eintraege) {
        [self deleteEintrag:anEintrag];
    }
    [self.document.managedObjectContext deleteObject:studiengang];
}

- (void)deleteKriterium:(Kriterium *)kriterium
{
//    if (kriterium.calendarItemIdentifier) {
//        [[ESRemindersDataManager sharedInstance] deleteReminderForKriterium:kriterium];
//    }
    [self.document.managedObjectContext deleteObject:kriterium];
}

#pragma mark - List


- (NSArray *)getAllSemesters
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Semester"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    NSArray *results = [self.document.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0)
    {
        NSArray *sortedResults = [NSArray array];
        sortedResults = [results sortedArrayUsingComparator:^NSComparisonResult(Semester *a, Semester *b)
                     {
                         NSArray *splitA = [a.name componentsSeparatedByString:@" "];
                         NSString *_a = [splitA objectAtIndex:1];
                         NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
                         
                         NSArray *splitB = [b.name componentsSeparatedByString:@" "];
                         NSString *_b = [splitB objectAtIndex:1];
                         NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
                         
                         if (splitA2.count == 2)
                         {
                             if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
                             {
                                 return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
                             }
                             else //hier wird ein Wintersemester mit einem Sommersemester verglichen
                             {
                                 return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
                             }
                         }
                         else
                         {
                             if (splitB2.count == 2) //hier wird ein Wintersemester mit einem Sommersemester verglichen
                             {
                                 return ([[splitA2 objectAtIndex:0] intValue] <= [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
                             }
                             else //hier werden zwei Sommersemester miteinander verglichen
                             {
                                 return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
                             }
                         }
                         
                         return NSOrderedAscending;
                     }];
        return sortedResults;
    }
    else
    {
        return [NSArray array];
    }
}

- (void)setNewFirstSemester:(Semester *)aSemester forStudiengang:(Studiengang *)aStudiengang
{
    NSArray *allSemesters = [self getAllSemesters];
    int indexNewFirstSemester = [allSemesters indexOfObject:aSemester];
    int indexOldFirstSemester = [allSemesters indexOfObject:aStudiengang.erstesFachsemester];
    if (indexNewFirstSemester > indexOldFirstSemester) {
        NSMutableArray *oldSemestersWithEintrag = [NSMutableArray array];
        for (int i = indexOldFirstSemester; i < indexNewFirstSemester; i++) {
            Semester *oldSemester = [allSemesters objectAtIndex:i];
            [oldSemestersWithEintrag addObject:oldSemester];
            NSSet *oldEintraege = [oldSemester.kurse copy];
            for (Eintrag *anEintrag in oldEintraege) {
                if ([anEintrag.studiengang isEqual:aStudiengang]) {
                    anEintrag.semester = aSemester;
                }
            }
        }
        aStudiengang.erstesFachsemester = aSemester;
        if ([self getAllStudiengaenge].count == 1) {
            //There is only one Studiengang, old Semesters can be Deleted
            for (Semester *oldSemester in oldSemestersWithEintrag) {
                [self deleteSemester:oldSemester];
            }
        } else {
#warning Hier noch korrekt aufraeumen
        }
    } else {
        aStudiengang.erstesFachsemester = aSemester;
    }
}

/* das aktuelle Semester wird zurückgegeben. Wenn das aktuelle Semester noch nicht existiert, wird es vorher angelegt */
- (Semester *)getCurrentSemester
{
    NSArray *semesters = [self getAllSemesters];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    int month = [components month];
    int year = [components year];
    
    NSMutableString *semester = [NSMutableString string];
    if (month > 3 && month < 10) //Wintersemester
    {
        [semester appendString:@"SoSe "];
        [semester appendString:[NSString stringWithFormat:@"%i", year]];
    }
    else
    {
        [semester appendString:@"WiSe "];
        if (month < 10) //Januar - März
        {
            [semester appendString:[NSString stringWithFormat:@"%i/%i", year-1, year%100]];
        }
        else
        {
            [semester appendString:[NSString stringWithFormat:@"%i/%i", year, (year%100)+1]];
        }
    }
    for (Semester *s in semesters)
    {
        if ([s.name isEqualToString:semester])
        {
            return s;
        }
    }
    
    return [self createSemesterWithName:semester];
}

- (Semester *)getSemesterForTerm:(Term *)term
{
    NSArray *semesters = [self getAllSemesters];
    for (Semester *s in semesters)
    {
        if ([s.name isEqualToString:term.title])
        {
            return s;
        }
    }
    return [self getCurrentSemester];
}

- (NSArray *)getAllStudiengaenge
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Studiengang"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    NSArray *results = [self.document.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0)
    {
        return results;
    }
    else
    {

        return [NSArray array];
    }
}

- (Studiengang *)getStudiengangForName:(NSString *)name abschluss:(NSString *)abschluss
{
    NSFetchRequest *aFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Studiengang"];
    aFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(name LIKE %@) AND (abschluss LIKE %@)", name, abschluss];
    NSArray *theStudiengang = [self.document.managedObjectContext executeFetchRequest:aFetchRequest error:nil];
    if ([theStudiengang count] == 1) {
        return [theStudiengang lastObject];
    } else {
        return nil;
    }
}

- (NSArray *)getSortedKriterienForEintrag:(Eintrag *)anEintrag
{
    return [[anEintrag.kriterien allObjects] sortedArrayUsingComparator:^(Kriterium * a, Kriterium * b) {
        NSDate *d1 = a.date;
        NSDate *d2 = b.date;
        
        //Einträge ohne Datum kommen ans Ende der Liste
        if (!d1) {
            return NSOrderedDescending;
        } else if (!d2) {
            return NSOrderedAscending;
        }
        
        return [d1 compare: d2];
    }];
}

- (NSArray *)getAllSemestersWithCoursesInStudiengang:(Studiengang *)aStudiengang
{
    NSArray *Semesters = [self getAllSemesters];
    NSMutableArray *semestersInStudiengang = [NSMutableArray array];
    
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        if (![semestersInStudiengang containsObject:anEintrag.semester]) {
            [semestersInStudiengang addObject:anEintrag.semester];
        }
    }
    NSMutableArray *returnSemesters = [Semesters mutableCopy];
    for (Semester *aSemester in Semesters) {
        if (![semestersInStudiengang containsObject:aSemester]) {
            [returnSemesters removeObject:aSemester];
        }
    }
    return [returnSemesters copy];
}

- (NSArray *)getAllEntriesForStudiengang:(Studiengang *)aStudiengang
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        if ([aSemester.kurse count] < 1) {
            continue;
        }
        NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (studiengang.name LIKE %@) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
        NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
        studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        studiengangFetchRequest.predicate = studiengangPredicate;
        if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
            [semesterArray addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
        }
    }
    return [semesterArray copy];
}

- (NSArray *)getAllOpenEntriesForStudiengang:(Studiengang *)aStudiengang
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        if ([aSemester.kurse count] < 1) {
            continue;
        }
        NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (bestanden == NO) AND (studiengang.name LIKE %@) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
        NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
        studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        studiengangFetchRequest.predicate = studiengangPredicate;
        if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
            [semesterArray addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
        }
    }
    return [semesterArray copy];
}
- (NSArray *)getAllPastEntriesForStudiengang:(Studiengang *)aStudiengang
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        if ([aSemester.kurse count] < 1) {
            continue;
        }
        NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (bestanden == YES) AND (studiengang.name LIKE %@) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
        NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
        studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        studiengangFetchRequest.predicate = studiengangPredicate;
        if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
            [semesterArray addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
        }
    }
    return [semesterArray copy];
}



- (Kriterium *)getKriteriumForCalendarItemIdentifier:(NSString *)identifier
{
    NSPredicate *kriteriumPredicate = [NSPredicate predicateWithFormat:@"calendarItemIdentifier LIKE %@",identifier];
    NSFetchRequest *kriteriumFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Kriterium"];
    kriteriumFetchRequest.predicate = kriteriumPredicate;
    if ([self.document.managedObjectContext countForFetchRequest:kriteriumFetchRequest error:nil] == 1) {
        return [[self.document.managedObjectContext executeFetchRequest:kriteriumFetchRequest error:nil] lastObject];
    }
    return nil;
}

#pragma mark - Transfer methods

- (Eintrag *)createEintragFromLecture:(Lecture *)aLecture inStudiengang:(Studiengang *)aStudiengang forSemester:(Semester *)aSemester
{
    Eintrag *anEintrag = [Eintrag CreateEintragWithTitle:aLecture.title art:aLecture.type isBestanden:NO isBenotet:YES cp:aLecture.cp note:nil inSemester:aSemester inStudiengang:aStudiengang inManagedContext:self.document.managedObjectContext];
    [self saveDatabase];
    return anEintrag;
}



#pragma mark - compare two Semesters

- (NSComparisonResult)compareSemester:(Semester *)s1 withSemester:(Semester *)s2
{
    NSArray *splitA = [s1.name componentsSeparatedByString:@" "];
    NSString *_a = [splitA objectAtIndex:1];
    NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
    
    NSArray *splitB = [s2.name componentsSeparatedByString:@" "];
    NSString *_b = [splitB objectAtIndex:1];
    NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
    
    if (splitA2.count == 2)
    {
        if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:0] intValue] == [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
        else //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
    }
    else
    {
        if (splitB2.count == 2) //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] <= [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
        else //hier werden zwei Sommersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:0] intValue] == [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
    }
    
    return NSOrderedAscending;
}

- (NSComparisonResult)compareTerm:(Term *)term withSemester:(Semester *)semester
{
    NSArray *splitA = [term.title componentsSeparatedByString:@" "];
    NSString *_a = [splitA objectAtIndex:1];
    NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
    
    NSArray *splitB = [semester.name componentsSeparatedByString:@" "];
    NSString *_b = [splitB objectAtIndex:1];
    NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
    
    if (splitA2.count == 2)
    {
        if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:1] intValue] < [[splitB2 objectAtIndex:1] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:1] intValue] == [[splitB2 objectAtIndex:1] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
        else //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
    }
    else
    {
        if (splitB2.count == 2) //hier wird ein Wintersemester mit einem Sommersemester verglichen
        {
            return ([[splitA2 objectAtIndex:0] intValue] <= [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedAscending : NSOrderedDescending;
        }
        else //hier werden zwei Sommersemester miteinander verglichen
        {
            if ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[splitA2 objectAtIndex:0] intValue] == [[splitB2 objectAtIndex:0] intValue])
            {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
    }
    
    return NSOrderedAscending;
}

- (void)deleteAllEmptyFutureSemestersAfterIndex:(int)index
{
    NSArray *allSemesters = [self getAllSemesters];
    for (int i = allSemesters.count-1; i >= 0; i--)
    {
        Semester *s = [allSemesters objectAtIndex:i];
        if ([[CoreDataDataManager sharedInstance] compareSemester:[[CoreDataDataManager sharedInstance] getCurrentSemester] withSemester:s] == NSOrderedAscending && s.kurse.count == 0 && i > index)
        {
            [self deleteSemester:s];
        }
        else
        {
            break;
        }
    }
}

#pragma mark - Overview List

    //Die Methode erstellt ein 3D Array. Im ersten Array sind alle Semester in Form eines Arrays enthalten. Jedes Semester Array enthält wiederrum ein Array für jeden Studiengang der in dem Semester Kurse hat. In diesem 3. Array sind dann die entsprechenen Eintrag Objekte.
- (NSArray *)getAllEntriesForOverview
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        NSMutableArray *studiengaenge = [NSMutableArray array];
        
        //Erstelle Liste welche die verschiedenen Studiengaenge des aktuellen Semesters enthällt enthaelt
        for (Eintrag *anEintrag in aSemester.kurse) {
            if (![studiengaenge containsObject:anEintrag.studiengang]) {
                [studiengaenge addObject:anEintrag.studiengang];
            }
        }
        if (![studiengaenge count] > 0) { //Semester ohne Kurse werden ignoriert
            continue;
        }
        
        NSMutableArray *studiengaengeForSemester = [NSMutableArray array];
        for (int i = 0; i < [studiengaenge count]; i++) {
            Studiengang *aStudiengang = [studiengaenge objectAtIndex:i];
            NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (studiengang.name LIKE %@) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
            NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
            studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            studiengangFetchRequest.predicate = studiengangPredicate;
            if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
                [studiengaengeForSemester addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
            }
        }
        
        [semesterArray addObject:[studiengaengeForSemester copy]];
    }
    return [semesterArray copy];
}

- (NSArray *)getAllOpenEntriesForOverview
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        NSMutableArray *studiengaenge = [NSMutableArray array];
        
        //Erstelle Liste welche die verschiedenen Studiengaenge des aktuellen Semesters enthällt enthaelt
        for (Eintrag *anEintrag in aSemester.kurse) {
            if (![studiengaenge containsObject:anEintrag.studiengang]) {
                [studiengaenge addObject:anEintrag.studiengang];
            }
        }
        if (![studiengaenge count] > 0) { //Semester ohne Kurse werden ignoriert
            continue;
        }
        
        NSMutableArray *studiengaengeForSemester = [NSMutableArray array];
        for (int i = 0; i < [studiengaenge count]; i++) {
            Studiengang *aStudiengang = [studiengaenge objectAtIndex:i];
            NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (studiengang.name LIKE %@) AND (bestanden == NO) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
            NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
            studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            studiengangFetchRequest.predicate = studiengangPredicate;
            if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
                [studiengaengeForSemester addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
            }
        }
        if (![studiengaengeForSemester count] > 0) {
            continue;
        }
        [semesterArray addObject:[studiengaengeForSemester copy]];
    }
    return [semesterArray copy];
}

- (NSArray *)getAllPastEntriesForOverview
{
    NSMutableArray *semesterArray = [NSMutableArray array];
    for (Semester *aSemester in [self getAllSemesters]) {
        NSMutableArray *studiengaenge = [NSMutableArray array];
        
        //Erstelle Liste welche die verschiedenen Studiengaenge des aktuellen Semesters enthällt enthaelt
        for (Eintrag *anEintrag in aSemester.kurse) {
            if (![studiengaenge containsObject:anEintrag.studiengang]) {
                [studiengaenge addObject:anEintrag.studiengang];
            }
        }
        if (![studiengaenge count] > 0) { //Semester ohne Kurse werden ignoriert
            continue;
        }
        
        NSMutableArray *studiengaengeForSemester = [NSMutableArray array];
        for (int i = 0; i < [studiengaenge count]; i++) {
            Studiengang *aStudiengang = [studiengaenge objectAtIndex:i];
            NSPredicate *studiengangPredicate = [NSPredicate predicateWithFormat:@"(semester.name LIKE %@) AND (studiengang.name LIKE %@) AND (bestanden == YES) AND (studiengang.abschluss LIKE %@)",aSemester.name, aStudiengang.name, aStudiengang.abschluss];
            NSFetchRequest *studiengangFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
            studiengangFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            studiengangFetchRequest.predicate = studiengangPredicate;
            if ([self.document.managedObjectContext countForFetchRequest:studiengangFetchRequest error:nil] > 0) {
                [studiengaengeForSemester addObject:[self.document.managedObjectContext executeFetchRequest:studiengangFetchRequest error:nil]];
            }
        }
        if (![studiengaengeForSemester count] > 0) {
            continue;
        }
        [semesterArray addObject:[studiengaengeForSemester copy]];
    }
    return [semesterArray copy];
}


#pragma mark - Statistics

//Anzahl der Semester eines Studiengangs (vom ersten bis zum aktuellen oder falls abgeschlossen dem letzten)
- (int)currentSemesterIndexForStudiengang:(Studiengang *)aStudiengang
{
    NSArray *allSemesters = [self getAllSemesters];
    NSUInteger firstSemesterIndex = [allSemesters indexOfObject:aStudiengang.erstesFachsemester] - 1;
    NSUInteger latestSemesterIndex;
    if (aStudiengang.letztesFachsemester) {
        latestSemesterIndex = [allSemesters indexOfObject:aStudiengang.letztesFachsemester];
    } else {
        latestSemesterIndex = [allSemesters indexOfObject:[self getCurrentSemester]];
    }

    return (latestSemesterIndex - firstSemesterIndex );
}

- (int)lastSemesterIndexWithAchievedEintragInStudiengang:(Studiengang *)aStudiengang
{
    NSArray *allSemesters = [self getAllSemesters];
    NSUInteger firstSemesterIndex = [allSemesters indexOfObject:aStudiengang.erstesFachsemester];
    NSUInteger latestSemesterIndex = firstSemesterIndex;
    if (aStudiengang.letztesFachsemester) {
        latestSemesterIndex = [allSemesters indexOfObject:aStudiengang.letztesFachsemester];
    } else {
        NSMutableArray *semestersWithAchievedEintrag = [NSMutableArray array];
        for (Eintrag *anEintrag in aStudiengang.eintraege) {
            if ([anEintrag.bestanden boolValue] && ![semestersWithAchievedEintrag containsObject:anEintrag.semester]) {
                [semestersWithAchievedEintrag addObject:anEintrag.semester];
            }
        }
        for (Semester *aSemester in semestersWithAchievedEintrag) {
            if ([allSemesters indexOfObject:aSemester] > latestSemesterIndex) {
                latestSemesterIndex = [allSemesters indexOfObject:aSemester];
            }
        }
        
    }
    return (latestSemesterIndex - firstSemesterIndex + 1);
}

- (int)lastSemesterIndexWithEintragInStudiengang:(Studiengang *)aStudiengang
{
    NSArray *allSemesters = [self getAllSemesters];
    NSUInteger firstSemesterIndex = [allSemesters indexOfObject:aStudiengang.erstesFachsemester];
    NSUInteger latestSemesterIndex = firstSemesterIndex;
    if (aStudiengang.letztesFachsemester) {
        latestSemesterIndex = [allSemesters indexOfObject:aStudiengang.letztesFachsemester];
    } else {
        NSMutableArray *semestersWithEintrag = [NSMutableArray array];
        for (Eintrag *anEintrag in aStudiengang.eintraege) {
            if (![semestersWithEintrag containsObject:anEintrag.semester]) {
                [semestersWithEintrag addObject:anEintrag.semester];
            }
        }
        for (Semester *aSemester in semestersWithEintrag) {
            if ([allSemesters indexOfObject:aSemester] > latestSemesterIndex) {
                latestSemesterIndex = [allSemesters indexOfObject:aSemester];
            }
        }
    }
    return (latestSemesterIndex - firstSemesterIndex + 1);
}

//Durschnittliche Cp per Semester (bestanden oder nicht bestanden)
- (NSNumber *)avarageCpPerSemesterInStudiengang:(Studiengang *)aStudiengang
{
    int cp = 0;
    NSArray *allSemesters = [self getAllSemesters];
    int currentSemesterIndex = [allSemesters indexOfObject:[self getCurrentSemester]];
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        if ([allSemesters indexOfObject:anEintrag.semester] <= currentSemesterIndex) {
            cp += [anEintrag.cp intValue];
        }
    }
    currentSemesterIndex = [self currentSemesterIndexForStudiengang:aStudiengang];
    if (currentSemesterIndex == 0) {
        currentSemesterIndex = 1;
    }
    return [NSNumber numberWithFloat:(cp / currentSemesterIndex)];
}


- (NSNumber *)worstMarkInStudiengang:(Studiengang *)aStudiengang
{
    float worstMark = 0;
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        //Die 6 ist kein hguter Startwert
        if ([anEintrag.note floatValue] > worstMark && [anEintrag.note floatValue] >= 1.0 && [anEintrag.note floatValue] <= 5.0) {
            worstMark = [anEintrag.note floatValue];
        }
    }
    if (worstMark < 1) {
        return nil;
    }
    return [NSNumber numberWithFloat:worstMark];
}

- (NSNumber *)bestMarkInStudiengang:(Studiengang *)aStudiengang
{
    float bestMark = 6.0f;
    
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
            if ([anEintrag.note floatValue] < bestMark && [anEintrag.note floatValue] >= 1.0f && [anEintrag.note floatValue] <= 5.0f) {
                bestMark = [anEintrag.note floatValue];
            }
        }
    if (bestMark > 5.0) {
        return nil;
    }
    return [NSNumber numberWithFloat:bestMark];
}


- (NSNumber *)avarageMarkForStudiengang:(Studiengang *)aStudiengang
{
    float mark = 0.0;
    int cps = 0;
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        if ([anEintrag.benotet boolValue] && [anEintrag.bestanden boolValue]) {
            mark += [anEintrag.note floatValue] * [anEintrag.cp floatValue];
            cps += [anEintrag.cp intValue];
        }
    }
    return [NSNumber numberWithFloat:(mark / cps)];
}


//Summe CP, von allen nicht bestandenen Kursen
- (NSNumber *)openCreditPointsInStudiengang:(Studiengang *)aStudiengang
{
    int openCP = 0;
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        if (![anEintrag.bestanden boolValue]) {
            openCP += [anEintrag.cp intValue];
        }
    }
    return [NSNumber numberWithInt:openCP];
}

// Summe CP, von alles bestandenen Kursen
- (NSNumber *)achievedCreditPointsInStudiengang:(Studiengang *)aStudiengang
{
    int achievedCP = 0;
    for (Eintrag *anEintrag in aStudiengang.eintraege) {
        if ([anEintrag.bestanden boolValue]) {
            achievedCP += [anEintrag.cp intValue];
        }
    }
    return [NSNumber numberWithInt:achievedCP];
}

- (NSNumber *)CPNeededToCompletionInStudiengang:(Studiengang *)aStudiengang
{
    return [NSNumber numberWithInt:([aStudiengang.cp intValue] - [[self achievedCreditPointsInStudiengang:aStudiengang] intValue])];
}

- (NSDictionary *)getStatisticsForStudiengang:(Studiengang *)aStudiengang
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    [results setObject:aStudiengang.name forKey:kStudiengangName];
    [results setObject:aStudiengang.cp forKey:kStudiengangCP];
    [results setObject:aStudiengang.abschluss forKey:kStudiengangAbschluss];
    [results setObject:[self achievedCreditPointsInStudiengang:aStudiengang] forKey:kAchievedCP];
    [results setObject:[self openCreditPointsInStudiengang:aStudiengang] forKey:kOpenCP];
    [results setObject:[self CPNeededToCompletionInStudiengang:aStudiengang] forKey:kCPNeededToCompletion];
    [results setObject:[self avarageCpPerSemesterInStudiengang:aStudiengang] forKey:kAvarageCPPerSemester];
    NSNumber *bestMark = [self bestMarkInStudiengang:aStudiengang];
    if (bestMark) {
        [results setObject:bestMark forKey:kBestMark];
    }
    NSNumber *worstMark = [self worstMarkInStudiengang:aStudiengang];
    if (worstMark) {
        [results setObject:worstMark forKey:kWorstMark];
    }
    NSNumber *avarageMark = [self avarageMarkForStudiengang:aStudiengang];
    if (avarageMark) {
        [results setObject:avarageMark forKey:kAvarageMark];
    }
    [results setObject:[NSNumber numberWithInt:[self lastSemesterIndexWithAchievedEintragInStudiengang:aStudiengang]] forKey:kLastSemesterIndexWithAchievedEintraege];
    [results setObject:[NSNumber numberWithInt:[self lastSemesterIndexWithEintragInStudiengang:aStudiengang]] forKey:kLastSemesterIndexForAnyEintraege];
    [results setObject:[NSNumber numberWithInt:[self currentSemesterIndexForStudiengang:aStudiengang]] forKey:kCurrentSemesterIndex];
    
    return [results copy];
}

- (NSArray *)getStatistics
{
    NSMutableArray *results = [NSMutableArray array];
    for (Studiengang *aStudiengang in [self getAllStudiengaenge]) {
        if (!aStudiengang.letztesFachsemester) {
            [results addObject:[self getStatisticsForStudiengang:aStudiengang]];
        }
    }
    return [results copy];
}

- (NSArray *)getAllKriteriumsWithLinkedReminder
{
    NSFetchRequest *kriteriumFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Kriterium"];
    kriteriumFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *allKriterium = [self.document.managedObjectContext executeFetchRequest:kriteriumFetchRequest error:nil];
    NSMutableArray *kriteriumWithReminder = [NSMutableArray array];
    for (Kriterium *aKriterium in allKriterium) {
        if (aKriterium.calendarItemIdentifier) {
            [kriteriumWithReminder addObject:aKriterium];
        }
    }
    return [kriteriumWithReminder copy];
}


#pragma mark - Parse Vorlesungsverzeichnis

- (Term *)existingTermWithTitle:(NSString *)title inContext:(NSManagedObjectContext *)aContext
{
    NSPredicate *termPredicate = [NSPredicate predicateWithFormat:@"title LIKE %@",title];
    NSFetchRequest *termFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Term"];
    termFetchRequest.predicate = termPredicate;
    NSArray *terms = [aContext executeFetchRequest:termFetchRequest error:nil];
    if (terms.count > 0) {
        return [terms lastObject];
    } else {
        return nil;
    }
}

- (NSDate *)dateWithString:(NSString *)dateString //(zB 21.10.2012)
{
    if (!self.aDateFormatter) { //DateFormatter sind teuer in der einrichtung deswegen bekommt die KLasse eine eigene Instanz die wieder verwendet werden kann
        self.aDateFormatter = [[NSDateFormatter alloc] init];
        self.aDateFormatter.calendar = [NSCalendar currentCalendar];
        self.aDateFormatter.timeZone = [NSTimeZone systemTimeZone];
        [self.aDateFormatter setDateFormat:@"dd.MM.yyyy"];
    }
    return [self.aDateFormatter dateFromString:dateString];
}

- (void)addDatesToDateBlock:(DateBlock *)aDateBlock inContext:(NSManagedObjectContext *)aContext
{
    switch ([aDateBlock.repeatModifier intValue]) {
        case 0: //Single Date
            [Date createDateWithDateBlock:aDateBlock date:aDateBlock.startDate startTime:aDateBlock.startTime stopTime:aDateBlock.stopTime active:NO forLecture:aDateBlock.lecture inManagedContext:aContext];
            break;
        case 1: // Weekly Date
        {
            NSDate *tempDate = aDateBlock.startDate;
            NSDateComponents *weekComponent = [[NSDateComponents alloc] init];
            weekComponent.week = 1;
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            while ([[tempDate laterDate:aDateBlock.stopDate] isEqual:aDateBlock.stopDate]) {
                //create Date based on temp date
                [Date createDateWithDateBlock:aDateBlock date:tempDate startTime:aDateBlock.startTime stopTime:aDateBlock.stopTime active:NO forLecture:aDateBlock.lecture inManagedContext:aContext];
                //increase tempdate
                tempDate = [theCalendar dateByAddingComponents:weekComponent toDate:tempDate options:0];
            }
        }
            break;
        case 2: //biweekly Date
        {
            NSDate *tempDate = aDateBlock.startDate;
            NSDateComponents *weekComponent = [[NSDateComponents alloc] init];
            weekComponent.week = 2;
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            while ([[tempDate laterDate:aDateBlock.stopDate] isEqual:aDateBlock.stopDate]) {
                //create Date based on temp date
                [Date createDateWithDateBlock:aDateBlock date:tempDate startTime:aDateBlock.startTime stopTime:aDateBlock.stopTime active:NO forLecture:aDateBlock.lecture inManagedContext:aContext];
                //increase tempdate
                tempDate = [theCalendar dateByAddingComponents:weekComponent toDate:tempDate options:0];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSDictionary *)setStartDate:(NSDate *)startDate stopDate:(NSDate *)stopDate fromDay:(NSString *)aDay inTerm:(Term *)aTerm
{
    int targetWeekday;
    if ([aDay isEqualToString:@"Mo"]) {
        targetWeekday = 2;
    } else if ([aDay isEqualToString:@"Di"]) {
        targetWeekday = 3;
    } else if ([aDay isEqualToString:@"Mi"]) {
        targetWeekday = 4;
    } else if ([aDay isEqualToString:@"Do"]) {
        targetWeekday = 5;
    } else if ([aDay isEqualToString:@"Fr"]) {
        targetWeekday = 6;
    } else if ([aDay isEqualToString:@"Sa"]) {
        targetWeekday = 7;
    } else if ([aDay isEqualToString:@"So"]) {
        targetWeekday = 1;
    } else {
        return nil; //Bail if incorrect Data
    }
    
    
    //find first Date
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit | NSWeekCalendarUnit |NSWeekdayCalendarUnit) fromDate:aTerm.lectureStart];
    NSDateComponents *startComponents = [dateComponents copy];
    
    if (targetWeekday >= dateComponents.weekday) {
        startComponents.weekday = dateComponents.weekday + (targetWeekday - dateComponents.weekday);
    } else if (targetWeekday < dateComponents.weekday) {
        startComponents.weekday = dateComponents.weekday - (dateComponents.weekday - targetWeekday);
        startComponents.week++;
    }
    
    startDate = [calendar dateFromComponents:startComponents];
    //find last Date
    dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit | NSWeekCalendarUnit |NSWeekdayCalendarUnit) fromDate:aTerm.lectureEnd];
    NSDateComponents *endComponents = [dateComponents copy];
    
    if (targetWeekday <= dateComponents.weekday) {
        endComponents.weekday = dateComponents.weekday - (targetWeekday - dateComponents.weekday);
    } else if (targetWeekday > dateComponents.week) {
        endComponents.weekday = dateComponents.weekday + (targetWeekday - dateComponents.weekday);
        endComponents.week--;
    }
    stopDate = [calendar dateFromComponents:endComponents];
    return [NSDictionary dictionaryWithObjectsAndKeys:startDate, @"startDate", stopDate, @"stopDate", nil];
}

- (void)addDateBlocksToLecture:(Lecture *)aLecture fromDateBlockArray:(NSArray *)dateBlocks inContext:(NSManagedObjectContext *)aContext
{
    if (![dateBlocks isKindOfClass:[NSNull class]]) { //could be NULL in JSON
        for (NSDictionary *aDateBlockDict in dateBlocks) {
            NSString *aDayString = [aDateBlockDict objectForKey:kDateBlockDay];
            NSDate *startDate = [self dateWithString:[aDateBlockDict objectForKey:kDateBlockFirstDate]];
            NSDate *stopDate = [self dateWithString:[aDateBlockDict objectForKey:kDateBlockLastDate]];
            
            if (aDayString && !startDate) {
                NSDictionary *dates = [self setStartDate:startDate stopDate:stopDate fromDay:aDayString inTerm:aLecture.course.semester];
                if (dates) {
                    startDate = [dates objectForKey:@"startDate"];
                    stopDate = [dates objectForKey:@"stopDate"];
                }
            }
            
            DateBlock *aDateBlock = [DateBlock createDateBlockWithRoom:[aDateBlockDict objectForKey:kDateBlockRoom] startTime:[aDateBlockDict objectForKey:kDateBlockStartTime] stopTime:[aDateBlockDict objectForKey:kDateBlockStopTime] startDate:startDate stopDate:stopDate repeatModifier:[NSNumber numberWithInt:[[aDateBlockDict objectForKey:kDateBlockRepeat] intValue]] lecture:aLecture inManagedContext:aContext];
            [self addDatesToDateBlock:aDateBlock inContext:aContext];
            [aLecture addDateBlocksObject:aDateBlock];
        }
        [self mergeDateBlocksInLecture:aLecture inContext:aContext];
    }
}


- (void)mergeDateBlocksInLecture:(Lecture *)aLecture inContext:(NSManagedObjectContext *)aContext
{
    NSArray *allDateBlocks = [aLecture.dateBlocks allObjects];
    NSMutableArray *completedDateBlocks = [NSMutableArray arrayWithCapacity:[allDateBlocks count]];
    NSMutableArray *groupedDateBlocks = [NSMutableArray array];
    for (DateBlock *aDateBlock in allDateBlocks) {
        if ([completedDateBlocks containsObject:aDateBlock]) {
            continue;
        }
        
        NSArray *matchingDateBlocks = [self findAllMatchingDateBlocksForDateBlock:aDateBlock inDateBlockArray:allDateBlocks];
        [completedDateBlocks addObjectsFromArray:matchingDateBlocks];
        if ([matchingDateBlocks count] > 1) {
            [groupedDateBlocks addObject:[matchingDateBlocks copy]];
        }
    }
    for (NSArray *anArray in groupedDateBlocks) {
        [self mergeDateBlocksInArray:anArray inContext:aContext];
    }
    
}

- (void)mergeDateBlocksInArray:(NSArray *)dateBlocks inContext:(NSManagedObjectContext *)aContext
{
    //pick one DateBlock
    DateBlock *theDateBlock = [dateBlocks lastObject];
    //Add all other Dates to the choosen one
    
    NSDate *startDate = theDateBlock.startDate;
    NSDate *stopDate = theDateBlock.stopDate;
    for (DateBlock *aDateBlock in dateBlocks) {
        if ([theDateBlock isEqual:aDateBlock]) {
            continue;
        }
        [theDateBlock addDates:aDateBlock.dates];
        if (aDateBlock.startDate) {
            startDate = [aDateBlock.startDate earlierDate:startDate];
        }
        if (aDateBlock.stopDate) {
            stopDate = [aDateBlock.stopDate laterDate:stopDate];
        }
        [aContext deleteObject:aDateBlock];
    }
    
    theDateBlock.startDate = startDate;
    theDateBlock.stopDate = stopDate;
    if ([theDateBlock.dates count] > 1) {
        theDateBlock.repeatModifier = [NSNumber numberWithInt:1];
    } else if ([theDateBlock.dates count] == 1) {
        theDateBlock.repeatModifier = [NSNumber numberWithInt:0];
    }
}

- (NSArray *)findAllMatchingDateBlocksForDateBlock:(DateBlock *)matchingDateBlock inDateBlockArray:(NSArray *)allDateBlocks
{
    NSMutableArray *matchingDateBlocks = [NSMutableArray arrayWithCapacity:[allDateBlocks count]];
    for (DateBlock *aDateBlock in allDateBlocks) {
        if ([matchingDateBlock isEqual:aDateBlock] && ![matchingDateBlocks containsObject:matchingDateBlock]) {
            [matchingDateBlocks addObject:matchingDateBlock];
            continue; 
        }
        if ([matchingDateBlock.startTime isEqualToString:aDateBlock.startTime] && [matchingDateBlock.stopTime isEqualToString:aDateBlock.stopTime] && [matchingDateBlock.room isEqualToString:aDateBlock.room] && [[self getLocalizedWeekDayForDate:matchingDateBlock.startDate] isEqualToString:[self getLocalizedWeekDayForDate:aDateBlock.startDate]]) {
            [matchingDateBlocks addObject:aDateBlock];
        }
    }
    return [matchingDateBlocks copy];
}

- (void)addLecturerToLecture:(Lecture *)aLecture fromArray:(NSArray *)anArray inContext:(NSManagedObjectContext *)aContext
{
    if ([anArray isKindOfClass:[NSNull class]]) {
        return;
    }
    for (NSString *aLecturerName in anArray) {
        //Search in DB if the guy exists
        NSPredicate *lecturerPredicate = [NSPredicate predicateWithFormat:@"title LIKE %@",aLecturerName];
        NSFetchRequest *lecturerFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lecturer"];
        lecturerFetchRequest.predicate = lecturerPredicate;
        NSArray *lecturerArray = [aContext executeFetchRequest:lecturerFetchRequest error:nil];
        if ([lecturerArray count] > 0) {
            Lecturer *aLecturer = [lecturerArray lastObject];
            [aLecturer addLecturesObject:aLecture];
        } else {
            Lecturer *aLecturer = [Lecturer createLecturerWithTitle:aLecturerName inManagedContext:aContext];
            [aLecturer addLecturesObject:aLecture];
        }

    }
}

- (void)addLecturerToLecture:(Lecture *)aLecture fromArray:(NSArray *)anArray
{
    for (Lecturer *aLecturer in aLecture.lecturers) {
        [aLecturer removeLecturesObject:aLecture];
        if ([aLecturer.lectures count] < 1) {
            [self.document.managedObjectContext deleteObject:aLecturer];
        }
    }
    
    for (NSString *aLecturerName in anArray) {
        //Search in DB if the guy exists
        NSPredicate *lecturerPredicate = [NSPredicate predicateWithFormat:@"title LIKE %@",aLecturerName];
        NSFetchRequest *lecturerFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lecturer"];
        lecturerFetchRequest.predicate = lecturerPredicate;
        NSArray *lecturerArray = [self.document.managedObjectContext executeFetchRequest:lecturerFetchRequest error:nil];
        if ([lecturerArray count] > 0) {
            Lecturer *aLecturer = [lecturerArray lastObject];
            [aLecturer addLecturesObject:aLecture];
        } else {
            Lecturer *aLecturer = [Lecturer createLecturerWithTitle:aLecturerName inManagedContext:self.document.managedObjectContext];
            [aLecturer addLecturesObject:aLecture];
        }
        
    }
    [self saveDatabase];
}


- (void)createLectureWithDict:(NSDictionary *)aLectureDict inCourse:(Course *)aCourse inContext:(NSManagedObjectContext *)aContext
{
    NSNumber *cp = nil;
    if (![[aLectureDict objectForKey:kLectureCP] isKindOfClass:[NSNull class]]) {
        cp = [NSNumber numberWithInt:[[aLectureDict objectForKey:kLectureCP] intValue]];
    }
    Lecture *aLecture = [Lecture createLectureWithTitle:[aLectureDict objectForKey:kLectureTitle] vak:[aLectureDict objectForKey:kLectureVAK] cp:cp type:[aLectureDict objectForKey:kLectureType] activeInSchedule:NO inCourse:aCourse inManagedContext:aContext];
    [self addDateBlocksToLecture:aLecture fromDateBlockArray:[aLectureDict objectForKey:kLectureDates] inContext:aContext];
    [self addLecturerToLecture:aLecture fromArray:[aLectureDict objectForKey:kLectureLecturers] inContext:aContext];
}

- (BOOL)addLecturesToCourse:(Course *)aCourse inContext:(NSManagedObjectContext *)aContext
{
        NSError *networkError = nil;
        NSError *parsingError = nil;
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[aCourse.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:NSDataReadingUncached error:&networkError];
        if (!jsonData || networkError) {
            return NO;
        }
        NSArray *allLectures = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&parsingError];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *aLectureDict in allLectures) {
                [self createLectureWithDict:aLectureDict inCourse:aCourse inContext:aContext];
            }
            NSLog(@"%@ hat nun %d kurse",aCourse.title, [aCourse.lectures count]);
        });
    return YES;
}

- (Term *)createTermFormURL:(NSURL *)termURL inContext:(NSManagedObjectContext *)aContext
{
    NSError *networkError = nil;
    NSError *parsingError = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:termURL options:NSDataReadingUncached error:&networkError];
    if (!jsonData || networkError) {
        return nil;
    }
    NSDictionary *termData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&parsingError];
    Term *aTerm = [Term createTermWithTitle:[termData objectForKey:kTermTitle] termStart:[self dateWithString:[termData objectForKey:kTermStart]] termEnd:[self dateWithString:[termData objectForKey:kTermEnd]] lectureStart:[self dateWithString:[termData objectForKey:kLectureStart]] lectureEnd:[self dateWithString:[termData objectForKey:kLectureEnd]] inManagedContext:aContext];
    for (NSDictionary *aCourseDict in [termData objectForKey:kTermFiles]) {
       [Course createCourseWithTitle:[aCourseDict objectForKey:kTermFileName] url:[aCourseDict objectForKey:kTermFileURL] inTerm:aTerm inManagedContext:aContext];
    }
    
    return aTerm;
}

- (void)updateSemesters
{
    [self updateTermsInContext:self.document.managedObjectContext.parentContext];
}

#pragma mark - update Vorlesungsverzeichnis
- (void)updateTermsInContext:(NSManagedObjectContext *)aContext
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSError *networkError = nil;
    NSError *parsingError = nil;
    NSData *semesterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kAllSemestersJSONURL] options:NSDataReadingUncached error:&networkError];
    if (!semesterData || networkError) {
        NSLog(@"No SemesterData. Error: %@, %@", [networkError localizedDescription], [networkError localizedFailureReason]);
        return;
    }
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:semesterData options:kNilOptions error:&parsingError];
    NSString *updateString = [data objectForKey:kAllSemestersUpdateKey];
    NSString *oldUpdateString = [defaults objectForKey:kAllSemestersUpdateKey];
    if ([oldUpdateString isEqualToString:updateString] && kDEBUG == 0) {
        NSLog(@"SKIPPING: No new Data");
        return;
    } else {
        NSArray *allSemesters = [data objectForKey:kAllSemesterKey];
        for (NSDictionary *aNewTermDict in allSemesters) {
            Term *existingTerm = [self existingTermWithTitle:[Term convertTermTitleWithString:[aNewTermDict objectForKey:kSemesterTitle]] inContext:aContext];
            networkError = nil;
            parsingError = nil;
            if (existingTerm) {
                NSLog(@"updating existing Term: %@", existingTerm.title);
                //UpdateTerm
                NSError *networkError = nil;
                NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[aNewTermDict objectForKey:kSemesterURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:NSDataReadingUncached error:&networkError];
                if (!jsonData || networkError) {
                    return;
                }
                NSDictionary *newTermInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
                //TermDates
                existingTerm.termStart = [self dateWithString:[newTermInfo objectForKey:kTermStart]];
                existingTerm.termEnd = [self dateWithString:[newTermInfo objectForKey:kTermEnd]];
                existingTerm.lectureStart = [self dateWithString:[newTermInfo objectForKey:kLectureStart]];
                existingTerm.lectureEnd = [self dateWithString:[newTermInfo objectForKey:kLectureEnd]];
                //Courses
                
                //bail if past/old Term
                if ([self isPastTerm:existingTerm]) {
                    NSLog(@"Skipping %@ since it is in the past!", existingTerm.title);
                    continue;
                }
                NSArray *allCourseDicts = [newTermInfo objectForKey:kTermFiles];
                for (NSDictionary *aCourseDict in allCourseDicts) {
                    NSString *courseName = [aCourseDict objectForKey:kTermFileName];
                    Course *existingCourse = [self searchForExistingCourseWithTitle:courseName inTerm:existingTerm inContext:aContext];
                    if (existingCourse && existingCourse.lectures.count > 0) {
                        NSLog(@"updating: %@",existingCourse.title);
                        [self updateExistingCourse:existingCourse withURL:[NSURL URLWithString:[[aCourseDict objectForKey:kTermFileURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] inContext:aContext];
                    } else {
                        if (existingCourse) {
                            [aContext deleteObject:existingCourse];
                        }
                        [Course createCourseWithTitle:[aCourseDict objectForKey:kTermFileName] url:[aCourseDict objectForKey:kTermFileURL] inTerm:existingTerm inManagedContext:aContext];
                    }
                }
            } else {
                //NewTerm
                Term *aTerm = [self createTermFormURL:[NSURL URLWithString:[[aNewTermDict objectForKey:kSemesterURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] inContext:aContext];
                NSLog(@"Added new Term %@", aTerm.title);
            }
        }
        [defaults setObject:updateString forKey:kAllSemestersUpdateKey];
        [defaults synchronize];
        [self saveDatabase];
    }
}


- (BOOL)isPastTerm:(Term *)aTerm
{
    NSArray *allTerms = [self getAllTermsFromCoreData];
    Term *currentterm = [self currentTerm];
    int indexCurrentTerm;
    int indexATerm;
    for (int i = 0; i < allTerms.count; i++) {
        Term *theTerm = [allTerms objectAtIndex:i];
        if ([theTerm.title isEqualToString:currentterm.title]) {
            indexCurrentTerm = i;
        }
        if ([theTerm.title isEqualToString:aTerm.title]) {
            indexATerm = i;
        }
    }
    
    if (indexATerm > indexCurrentTerm) {
        return YES;
    }
    return NO;
}

- (Course *)searchForExistingCourseWithTitle:(NSString *)aCourseTitle inTerm:(Term *)aTerm inContext:(NSManagedObjectContext *)aContext
{
    if (!self.courseFetchRequest) {
        self.courseFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    }
    if (!aTerm || aCourseTitle) {
        return nil;
    }
    self.courseFetchRequest.predicate = [NSPredicate predicateWithFormat:@"title LIKE %@ AND semester.title LIKE %@", aCourseTitle, aTerm.title];
    NSArray *aCourseArray = [aContext executeFetchRequest:self.courseFetchRequest error:nil];
    if ([aCourseArray count] > 0) {
        return [aCourseArray lastObject];
    } else {
        return nil;
    }
}

- (Lecture *)searchForExistingLectureWithTitle:(NSString *)aTitle inCourse:(Course *)aCourse inContext:(NSManagedObjectContext *)aContext
{
    if (!self.lectureFetchRequest) {
        self.lectureFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Lecture"];
        self.lectureFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(course.title LIKE %@) AND (title LIKE %@)", aCourse.title, aTitle];
    }
    NSArray *aLectureArray = [aContext executeFetchRequest:self.lectureFetchRequest error:nil];
    if ([aLectureArray count] > 0) {
        return [aLectureArray lastObject];
    } else {
        return nil;
    }
}


- (void)updateExistingCourse:(Course *)aCourse withURL:(NSURL *)newURL inContext:(NSManagedObjectContext *)aContext
{
    NSLog(@"Updating %@ with %i Lectures", aCourse.title, aCourse.lectures.count);
    if (!self.replacedLectures) {
        self.replacedLectures = [NSMutableArray array];
    }
    NSError *coreDataError = nil;

    //check for active Lectures! (Studiumsplaner & Stundenplan)
    NSFetchRequest *lecturesActiveFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lecture"];
    lecturesActiveFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(activeInSchedule == YES OR eintrag != NIL) AND course.title LIKE %@ AND course.semester.title LIKE %@", aCourse.title, aCourse.semester.title];
    NSArray *oldActiveLectureArray = [aContext executeFetchRequest:lecturesActiveFetchRequest error:&coreDataError];
    NSLog(@"Found %i old active lectures", oldActiveLectureArray.count);
    //if none delete all parse anew
    NSSet *oldLecturesSet = [NSSet setWithArray:oldActiveLectureArray]; //Using NSSet for more efficiant containsObject calls
    for (Lecture *aLecture in aCourse.lectures) {
        if (![oldLecturesSet containsObject:aLecture]) { //dont delete active Lectures
            [aContext deleteObject:aLecture];
        }
    }
    
    [self getLecturesForCourse:aCourse inContext:aContext withCallback:^(BOOL wasSuccessful, NSArray *lectures) {
        if (wasSuccessful) {
            for (Lecture *anOldLecture in oldActiveLectureArray) {
                for (Lecture *aNewLecture in lectures) {
                    if (![aNewLecture isEqual:anOldLecture]) { //dont compare same Object
                        if ([aNewLecture.title isEqualToString:anOldLecture.title]) {
                            if ([self lecture:anOldLecture isEqualToLecture:aNewLecture]) { //if equal use old, delete new
                                [aContext deleteObject:aNewLecture];
                            } else { //if !equal use new Data with all dates active, delete Old Data
                                if (anOldLecture.eintrag) {
                                    aNewLecture.eintrag = anOldLecture.eintrag; //Studiumsplaner Link erhalten
                                }
                                [aContext deleteObject:anOldLecture];
                                [self setAllDatesActiveForLecture:aNewLecture];
                                [self.replacedLectures addObject:aNewLecture];
                            }
                        }
                    }
                    
                }
            }
        }
    }];
}

- (BOOL)lecture:(Lecture *)firstLecture isEqualToLecture:(Lecture *)secondLecture
{
    if (![firstLecture.cp isEqualToNumber:secondLecture.cp]) {
        return NO;
    }
    if (![firstLecture.type isEqualToString:secondLecture.type]) {
        return NO;
    }
    if (![firstLecture.vak isEqualToString:secondLecture.vak]) {
        return NO;
    }
    if (([firstLecture.dateBlocks count] != [secondLecture.dateBlocks count]) || ([firstLecture.dates count] != [secondLecture.dates count])) {
        return NO;
    }
    //quite expensive
    for (DateBlock *aDateBlockFirst in firstLecture.dateBlocks) {
        BOOL foundEqualDateBlock = NO;
        for (DateBlock *aDateBlockSecond in secondLecture.dateBlocks) {
            if (![aDateBlockFirst.startTime isEqualToString:aDateBlockSecond.startTime]) {
                continue;
            }
            if (![aDateBlockFirst.stopTime isEqualToString:aDateBlockSecond.stopTime]) {
                continue;
            }
            if (![aDateBlockFirst.repeatModifier isEqualToNumber:aDateBlockSecond.repeatModifier]) {
                continue;
            }
            foundEqualDateBlock = YES;
        }
        if (!foundEqualDateBlock) {
            return NO;
        }
    }
    
    NSLog(@"found equal lecture");
    return YES;
}

- (void)setAllDatesActiveForLecture:(Lecture *)aLecture
{
    aLecture.activeInSchedule = [NSNumber numberWithBool:YES];
    for (Date *aDate in aLecture.dates) {
        aDate.active = [NSNumber numberWithBool:YES];
    }
}

- (BOOL) isDateBlock:(DateBlock *)firstDateBlock equalToDateBlock:(DateBlock *)secondDateBlock
{
    if ([firstDateBlock.repeatModifier isEqualToNumber:secondDateBlock.repeatModifier] && [firstDateBlock.room isEqualToString:secondDateBlock.room] && [firstDateBlock.startDate isEqualToDate:secondDateBlock.startDate] && [firstDateBlock.stopDate isEqualToDate:secondDateBlock.stopDate] && [firstDateBlock.startTime isEqualToString:secondDateBlock.startTime] && [firstDateBlock.stopTime isEqualToString:secondDateBlock.stopTime]) {
        return YES;
    }
    return NO;
}

- (Lecturer *)searchForExistingLecturerWithTitle:(NSString *)aTitle inContext:(NSManagedObjectContext *)aContext
{
    if (!self.lecturerFetchRequest) {
        self.lecturerFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Lecturer"];
        self.lecturerFetchRequest.predicate = [NSPredicate predicateWithFormat:@"title LIKE %@", aTitle];
    }
    NSArray *lecturerArray = [aContext executeFetchRequest:self.lecturerFetchRequest error:nil];
    if ([lecturerArray count] > 0) {
        return [lecturerArray lastObject];
    } else {
        return nil;
    }
}

- (void)updateLectureresForLecture:(Lecture *)aLecture withLecturerArray:(NSArray *)aLecturerArray inContext:(NSManagedObjectContext *)aContex
{
    for (NSString *aLecturerName in aLecturerArray) {
        Lecturer *aLecturer = [self searchForExistingLecturerWithTitle:aLecturerName inContext:aContex];
        if (aLecturer) { // Es gibt den Dozenten aber er ist nicht dem Kurs zugeordnet
            if (![aLecturer.lectures containsObject:aLecture]) {
                [aLecturer addLecturesObject:aLecture];
            }
        } else { // Lecturer existierte noch nicht in CD
            aLecturer = [Lecturer createLecturerWithTitle:aLecturerName inManagedContext:aContex];
            [aLecturer addLecturesObject:aLecture];
        }
    }
    for (Lecturer *aLecturer in aLecture.lecturers) { //Hier werden Dozenten gesucht die dem Kurs bereits zugeordnet waren aber nicht im neuen Datensatz auftauchen
        BOOL isInNewData = NO;
        for (NSString *aLecturerName in aLecturerArray) {
            if ([aLecturer.title isEqualToString:aLecturerName]) {
                isInNewData = YES;
            }
        }
        if (!isInNewData) {
            if ([aLecturer.lectures count] > 1) {
                [aLecturer removeLecturesObject:aLecture]; //Hat der Dozent noch mindestens einen anderen Kurs so wird er lediglich aus dem aktuellen Kurs ausgetragen
            } else {
                [aContex deleteObject:aLecturer]; // Hat der Dozent nur diesen einen Kurs wird er gelöscht
            }
        }
    }
}

#pragma mark - Vorlesungsverzeichnis / Stundenplan Interface MEthoden


- (Lecture *)createLectureWithTitle:(NSString *)aTitle type:(NSString *)aType cp:(NSNumber *)cp vak:(NSString *)vak inTerm:(Term *)aTerm
{
    NSFetchRequest *courseFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    courseFetchRequest.predicate = [NSPredicate predicateWithFormat:@"title LIKE %@ AND semester.title LIKE %@", kUserCreatedCourse, aTerm.title];
    NSArray *courses = [self.document.managedObjectContext executeFetchRequest:courseFetchRequest error:nil];
    Course *aCourse = nil;
    if ([courses count] < 1) {
        aCourse = [Course createCourseWithTitle:kUserCreatedCourse url:nil inTerm:aTerm inManagedContext:self.document.managedObjectContext];
    } else {
        aCourse = [courses lastObject];
    }
    Lecture *aLecture = [Lecture createLectureWithTitle:aTitle vak:vak cp:cp type:aType activeInSchedule:YES inCourse:aCourse inManagedContext:self.document.managedObjectContext];
    aLecture.createdByUser = [NSNumber numberWithBool:YES];
    [self saveDatabase];
    return aLecture;
}

- (Lecture *)createUserCreatedLectureWithTitle:(NSString *)aTitle type:(NSString *)aType cp:(NSNumber *)cp vak:(NSString *)vak isInSchedule:(BOOL)inSchedule tmpDateBlocks:(NSArray *)tmpDateBlocks lecturer:(NSArray *)lecturerArray inSemester:(NSString *)aSemesterString
{
    Term *aTerm = [self existingTermWithTitle:aSemesterString inContext:self.document.managedObjectContext];
    if (!aTerm) {
        aTerm = [Term createTermWithSemesterTitle:aSemesterString termStart:nil termEnd:nil lectureStart:nil lectureEnd:nil inManagedContext:self.document.managedObjectContext];
    }
    //get user Created Course for Term
    Course *aCourse = [self searchForExistingCourseWithTitle:kUserCreatedCourse inTerm:aTerm inContext:self.document.managedObjectContext];
    if (!aCourse) {
        aCourse = [Course createCourseWithTitle:kUserCreatedCourse url:nil inTerm:aTerm inManagedContext:self.document.managedObjectContext];
    }
    
    Lecture *aLecture = [Lecture createLectureWithTitle:aTitle vak:vak cp:cp type:aType activeInSchedule:inSchedule inCourse:aCourse inManagedContext:self.document.managedObjectContext];
    aLecture.createdByUser = [NSNumber numberWithBool:YES];
    //create DateBlock for TMPDateBlocks
    [self addDateBlockToLecture:aLecture fromTMPDateBlocks:tmpDateBlocks];
    [self addLecturerToLecture:aLecture fromArray:lecturerArray inContext:self.document.managedObjectContext];

    [self saveDatabase];
    return aLecture;
}

- (void)addDateBlockToLecture:(Lecture *)aLecture fromTMPDateBlocks:(NSArray *)tmpDateBlocks
{
    for (TMPDateBlock *aTMPDateBlock in tmpDateBlocks) {
        [DateBlock createDateBlockWithRoom:aTMPDateBlock.room startTime:aTMPDateBlock.startTime stopTime:aTMPDateBlock.stopTime startDate:aTMPDateBlock.startDate stopDate:aTMPDateBlock.stopDate repeatModifier:aTMPDateBlock.repeatModifier lecture:aLecture inManagedContext:self.document.managedObjectContext];
    }
        //merge DateBlocks
    [self mergeDateBlocksInLecture:aLecture inContext:self.document.managedObjectContext];
}

- (NSArray *)getTMPDateBlocksForLecture:(Lecture *)aLecture
{
    NSMutableArray *tmpDateBlocks = [NSMutableArray arrayWithCapacity:aLecture.dateBlocks.count];
    for (DateBlock *aDateBlock in aLecture.dateBlocks) {
        TMPDateBlock * aTMPDateBlock = [[TMPDateBlock alloc] initWithRepeatModifier:aDateBlock.repeatModifier Room:aDateBlock.room StartDate:aDateBlock.startDate StartTime:aDateBlock.startTime StopDate:aDateBlock.stopDate StopTime:aDateBlock.stopTime Dates:[self getTMPDateFromDatesArray:[aDateBlock.dates allObjects]]];
        [tmpDateBlocks addObject:aTMPDateBlock];
        
    }
    return [tmpDateBlocks copy];
}

- (NSArray *)getTMPDateFromDatesArray:(NSArray *)datesArray
{
    NSMutableArray *tmpDates = [NSMutableArray arrayWithCapacity:datesArray.count];
    for (Date *aDate in datesArray) {
        TMPDate *aTMPDate = [[TMPDate alloc] init];
        aTMPDate.date = aDate.date;
        aTMPDate.startTime = aDate.startTime;
        aTMPDate.stopTime = aDate.stopTime;
        aTMPDate.note = aDate.note;
        aTMPDate.active = aDate.active;
        [tmpDates addObject:aTMPDate];
    }
    return [tmpDates copy];
}

- (Lecture *)updateUserCreatedLecture:(Lecture *)aLecture title:(NSString *)aTitle type:(NSString *)aType cp:(NSNumber *)cp vak:(NSString *)vak isInSchedule:(BOOL)inSchedule tmpDateBlocks:(NSArray *)tmpDateBlocks lecturer:(NSArray *)lecturerArray inSemester:(NSString *)aSemesterString
{
    Term *aTerm = [self existingTermWithTitle:aSemesterString inContext:self.document.managedObjectContext];
    if (!aType) {
        aTerm = [Term createTermWithSemesterTitle:aSemesterString termStart:nil termEnd:nil lectureStart:nil lectureEnd:nil inManagedContext:self.document.managedObjectContext];
    }
    //get user Created Course for Term
    Course *aCourse = [self searchForExistingCourseWithTitle:kUserCreatedCourse inTerm:aTerm inContext:self.document.managedObjectContext];
    if (!aCourse) {
        aCourse = [Course createCourseWithTitle:kUserCreatedCourse url:nil inTerm:aTerm inManagedContext:self.document.managedObjectContext];
    }
    
    aLecture.title = aTitle;
    aLecture.type = aType;
    aLecture.cp = cp;
    aLecture.vak = vak;
    aLecture.course = aCourse;
    aLecture.activeInSchedule = [NSNumber numberWithBool:inSchedule];
    
    //lecturer
    [self updateLectureresForLecture:aLecture withLecturerArray:lecturerArray inContext:self.document.managedObjectContext];
    
    for (DateBlock *aDateBlock in aLecture.dateBlocks) {
        [self.document.managedObjectContext deleteObject:aDateBlock];
    }
    for (Date *aDate in aLecture.dates) {
        [self.document.managedObjectContext deleteObject:aDate];
    }
    //create DateBlock for TMPDateBlocks
    [self addDateBlockToLecture:aLecture fromTMPDateBlocks:tmpDateBlocks];
    
    [self saveDatabase];
    return aLecture;
}






- (NSArray *)getAllTermsFromCoreData
{
    NSFetchRequest *termFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Term"];
    //Update first? Or manage updates outside of this methode
    //sortieren falls nötig
    NSError *dbERROr;
    NSArray *result = [[self.document.managedObjectContext executeFetchRequest:termFetchRequest error:&dbERROr] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                       {
                           NSArray *splitA = [((Term *)a).title componentsSeparatedByString:@" "];
                           NSString *_a = [splitA objectAtIndex:1];
                           NSArray *splitA2 = [_a componentsSeparatedByString:@"/"];
                           
                           NSArray *splitB = [((Term *)b).title componentsSeparatedByString:@" "];
                           NSString *_b = [splitB objectAtIndex:1];
                           NSArray *splitB2 = [_b componentsSeparatedByString:@"/"];
                           
                           if (splitA2.count == 2)
                           {
                               if (splitB2.count == 2) //hier werden zwei Wintersemester miteinander verglichen
                               {
                                   return ([[splitA2 objectAtIndex:1] intValue] < [[splitB2 objectAtIndex:1] intValue]) ? NSOrderedDescending  : NSOrderedAscending;
                               }
                               else //hier wird ein Wintersemester mit einem Sommersemester verglichen
                               {
                                   return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedDescending : NSOrderedAscending;
                               }
                           }
                           else
                           {
                               if (splitB2.count == 2) //hier wird ein Wintersemester mit einem Sommersemester verglichen
                               {
                                   return ([[splitA2 objectAtIndex:0] intValue] <= [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedDescending : NSOrderedAscending;
                               }
                               else //hier werden zwei Sommersemester miteinander verglichen
                               {
                                   return ([[splitA2 objectAtIndex:0] intValue] < [[splitB2 objectAtIndex:0] intValue]) ? NSOrderedDescending : NSOrderedAscending;
                               }
                           }
                           
                           return NSOrderedAscending;
                       }];
#warning remove empty Terms (even with user created stuff)
    NSMutableArray *filteredResult = [result mutableCopy];
    for (Term *aTerm in result) {
        if (aTerm.courses.count == 0) {
            [filteredResult removeObject:aTerm];
        } else if (aTerm.courses.count == 1) {
            Course *aCourse = [aTerm.courses anyObject];
            if ([aCourse.title isEqualToString:kUserCreatedCourse]) {
                [filteredResult removeObject:aTerm];
            }
        }
    }
    return [filteredResult copy];
}

- (Term *)currentTerm //In der Vorlseungszeit wird das aktuelle Semester zurück gegeben. In der Vorlesungsfreien Zeit wenn vorhanden das naechste. Sonst das aktuelle.
{
    NSDate *aCurrentDate = [NSDate date];
    NSArray *allTerms = [self getAllTermsFromCoreData];
    for (int i = 0; i < [allTerms count]; i++) {
        Term *aTerm = [allTerms objectAtIndex:i];
        Term *nextTerm;
        if (i > 0) {nextTerm = [allTerms objectAtIndex:(i - 1)];}
        if (([[aCurrentDate laterDate:aTerm.termStart] isEqualToDate:aCurrentDate]) && ([[aCurrentDate laterDate:aTerm.lectureEnd] isEqualToDate:aTerm.lectureEnd])) {
            //Wir befinden uns in der aktiven Phase dieses Semesters:
            return aTerm;
        } else if (([[aCurrentDate laterDate:aTerm.lectureEnd] isEqualToDate:aCurrentDate]) && ([[aCurrentDate laterDate:aTerm.termEnd] isEqualToDate:aTerm.termEnd])) { //Wir befinden uns in der Vorlesungsfreien Zeit des aktuellen Semesters. Hier sollte wenn vorhanden das naechste Semester angezeigt werden
            if (nextTerm) {
                return nextTerm;
            } else {
                return aTerm;
            }
        }
    }
    return [allTerms lastObject]; // Wenn die Daten veraltet sind wird immer das aktuelleste Semester zurück gegeben
}

- (NSDate *)normalizeDate:(NSDate *)aDate
{
    if (!self.aDateFormatter) { //DateFormatter sind teuer in der einrichtung deswegen bekommt die KLasse eine eigene Instanz die wieder verwendet werden kann
        self.aDateFormatter = [[NSDateFormatter alloc] init];
        self.aDateFormatter.calendar = [NSCalendar currentCalendar];
        self.aDateFormatter.timeZone = [NSTimeZone systemTimeZone];
        [self.aDateFormatter setDateFormat:@"dd.MM.yyyy"];
    }
    return [self dateWithString:[self.aDateFormatter stringFromDate:aDate]];
}

- (NSArray *)getAllActiveDatesForDate:(NSDate *)aDate
{
    NSFetchRequest *datesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    datesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"date == %@ AND active == YES", [self normalizeDate:aDate]];
    datesFetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"lecture.title" ascending:YES],nil];
    NSArray *stuff = [self.document.managedObjectContext executeFetchRequest:datesFetchRequest error:nil];
    for (Date *aDateTest in stuff) {
        NSLog(@"%@ %@ bis %@",[self getLocalizedWeekDayForDate:aDateTest.date], aDateTest.startTime, aDateTest.stopTime);
    }
    return stuff;
}

- (NSArray *)getAllActiveLectures
{
    NSFetchRequest *lecturesActiveFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lecture"];
    lecturesActiveFetchRequest.predicate = [NSPredicate predicateWithFormat:@"activeInSchedule == YES OR eintrag != NIL OR createdByUser == YES"];
    return [self.document.managedObjectContext executeFetchRequest:lecturesActiveFetchRequest error:nil];
}

- (Date *)createDateObjectWithDate:(NSDate *)date startTime:(NSString *)startTime stopTime:(NSString *)stopTime isActive:(BOOL)active inLecture:(Lecture *)aLecture inManagedContext:(NSManagedObjectContext *)moc
{
    return [Date createDateWithDateBlock:nil date:date startTime:startTime stopTime:stopTime active:active forLecture:aLecture inManagedContext:moc];
    
}

- (DateBlock *)createDateBlockWithStartDate:(NSDate *)startDate stopDate:(NSDate *)stopDate startTime:(NSString *)startTime stopTime:(NSString *)stopTime repeatModifier:(int)modifier room:(NSString *)room inLecture:(Lecture *)aLecture inContext:(NSManagedObjectContext *)moc
{
    DateBlock *aDateBlock = [DateBlock createDateBlockWithRoom:room startTime:startTime stopTime:stopTime startDate:startDate stopDate:stopDate repeatModifier:[NSNumber numberWithInt:modifier] lecture:aLecture inManagedContext:moc];
    [self addDatesToDateBlock:aDateBlock inContext:moc];
    return aDateBlock;
}

- (NSArray *)getSortedArrayForSet:(NSSet *)aSet byKey:(NSString *)aKey
{
    return [aSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:aKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
}
//Dierse Methode laed alle Veranstaltung zu einem Studiengang. Solange es nicht schon vorher geschehen ist.
- (void)getLecturesForCourse:(Course *)aCourse withCallback:(LecturesForCourseRequestCompleteBlock)callback
{
    if ([aCourse.lectures count] > 0) {
        callback(YES, [self getSortedArrayForSet:aCourse.lectures byKey:@"title"]);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSLog(@"adding lectures");
            BOOL *success = [self addLecturesToCourse:aCourse inContext:aCourse.managedObjectContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveDatabase];
                NSLog(@"saved DB");
                if (aCourse.lectures) {
                    callback(success, [self getSortedArrayForSet:aCourse.lectures byKey:@"title"]);
                    NSLog(@"callback send");
                } else {
                    
                }
            });
        });
    }
}
//Diese Methode laed immer alle Veranstaltungen neu. Selbst wenn es schon welche gibt. (interne verwendet fuer das updaten des Datenbestandes)
- (void)getLecturesForCourse:(Course *)aCourse inContext:(NSManagedObjectContext *)aContext withCallback:(LecturesForCourseRequestCompleteBlock)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"adding lectures");
        BOOL *success = [self addLecturesToCourse:aCourse inContext:aContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveDatabase];
            NSLog(@"saved DB");
            if (aCourse.lectures) {
                callback(success, [self getSortedArrayForSet:aCourse.lectures byKey:@"title"]);
                NSLog(@"callback send");
            } else {
                
            }
        });
    });
}

- (NSArray *)getCoursesForTerm:(Term *)aTerm
{
    NSFetchRequest *coursesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    coursesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"title != %@ AND semester.title LIKE %@", kUserCreatedCourse, aTerm.title];
    coursesFetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    return [self.document.managedObjectContext executeFetchRequest:coursesFetchRequest error:nil];
}
- (NSArray *)getLecturersForLecture:(Lecture *)aLecture
{
    if ([aLecture.lecturers count] > 0) {
        return [aLecture.lecturers array];
        //return [self getSortedArrayForSet:aLecture.lecturers byKey:@"title"];
    }
    return [NSArray array];
}

- (NSArray *)sortedDateArrayFromSet:(NSSet *)aSet byKey:(NSString *)aKey
{
    return [aSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:aKey ascending:YES]]];
}

- (NSArray *)getDateBlocksForLecture:(Lecture *)aLecture
{
    if ([aLecture.dateBlocks count] > 0) {
        return [self sortedDateArrayFromSet:aLecture.dateBlocks byKey:@"startDate"];
    }
    return [NSArray array];
}
- (NSArray *)getDatesForLecture:(Lecture *)aLecture
{
    if ([aLecture.dates count] > 0) {
        return [self sortedDateArrayFromSet:aLecture.dates byKey:@"date"];
    }
    return [NSArray array];
}
- (NSArray *)getDatesForDateBlock:(DateBlock *)aDateBlock
{
    if ([aDateBlock.dates count] > 0) {
        return [self sortedDateArrayFromSet:aDateBlock.dates byKey:@"date"];
    }
    return [NSArray array];
}

- (NSString *)getLocalizedWeekDayForDate:(NSDate *)aDate
{
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    return [weekday stringFromDate:aDate];
}

- (void)addDateBlocksToSchedule:(NSArray *)aDateBlockArray
{
    DateBlock *aTempDateBlock = [aDateBlockArray lastObject];
    [aTempDateBlock.lecture setActiveInSchedule:[NSNumber numberWithBool:YES]];
    for (DateBlock *aDateBlock in aDateBlockArray) {
        for (Date *aDate in aDateBlock.dates) {
            aDate.active = [NSNumber numberWithBool:YES];
        }
    }
    [self saveDatabase];
}
- (void)removeLectureFromSchedule:(Lecture *)aLecture
{
    for (Date *aDate in aLecture.dates) {
        aDate.active = [NSNumber numberWithBool:NO];
    }
    aLecture.activeInSchedule = [NSNumber numberWithBool:NO];
    [self saveDatabase];
}

- (BOOL)DateBlockInSchedule:(DateBlock *)aDateBlock
{
    for (Date *aDate in aDateBlock.dates) {
        if ([[aDate active] boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeDateBlocksFromSchedule:(NSArray *)aDateBlockArray
{
    Lecture *aLecture = [[aDateBlockArray lastObject] lecture];
    for (DateBlock *aDateBlock in aDateBlockArray) {
        for (Date *aDate in aDateBlock.dates) {
            aDate.active = [NSNumber numberWithBool:NO];
        }
    }
    BOOL *isActive = NO;
    for (Date *aDate in aLecture.dates) {
        if ([[aDate active] boolValue]) {
            isActive = YES;
        }
    }
    aLecture.activeInSchedule = [NSNumber numberWithBool:isActive];
    [self saveDatabase];
}

- (Eintrag *)getEintragForLecture:(Lecture *)aLecture
{
    if (aLecture.eintrag) {
        return aLecture.eintrag;
    }
    
    NSFetchRequest *eintragFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Eintrag"];
    eintragFetchRequest.predicate = [NSPredicate predicateWithFormat:@"titel LIKE %@ AND semester.name LIKE %@",aLecture.title, aLecture.course.semester.title];
    eintragFetchRequest.fetchLimit = 1;
    NSError *fetchingError = nil;
    NSArray *result = [self.document.managedObjectContext executeFetchRequest:eintragFetchRequest error:&fetchingError];
    if (fetchingError) {
        NSLog(@"%@",[fetchingError localizedDescription]);
    }
    if ([result count] > 0) {
        return [result lastObject];
    }
    return nil;
    
}
- (Eintrag *)copyLecture:(Lecture *)aLecture intoStudiengang:(Studiengang *)aStudiengang inSemester:(Semester *)aSemester
{
    if (!aSemester) {
        return nil;
    }
    Eintrag *anEintrag = [Eintrag CreateEintragWithTitle:aLecture.title art:aLecture.type isBestanden:NO isBenotet:YES cp:aLecture.cp note:nil inSemester:aSemester inStudiengang:aStudiengang inManagedContext:self.document.managedObjectContext];
    anEintrag.lecture = aLecture;
    return anEintrag;
}
- (BOOL)deleteEintragForLecture:(Lecture *)aLecture
{
    Eintrag *anEintrag = [self getEintragForLecture:aLecture];
    if (anEintrag) {
        [self.document.managedObjectContext deleteObject:anEintrag];

        [self deleteAllEmptyFutureSemestersAfterIndex:[[self getAllSemesters] indexOfObject:[self getCurrentSemester]]];
        [self saveDatabase];
        return YES;
    }
    return NO;
}

- (void)deleteLecture:(Lecture *)aLecture
{
    for (DateBlock *aDateBlock in aLecture.dateBlocks) {
        [self.document.managedObjectContext deleteObject:aDateBlock];
    }
    for (Date *aDate in aLecture.dates) {
        [self.document.managedObjectContext deleteObject:aDate];
    }
    for (Lecturer *aLecturer in aLecture.lecturers) {
        if (aLecturer.lectures.count > 1) {
            [aLecturer removeLecturesObject:aLecture];
        } else {
            [self.document.managedObjectContext deleteObject:aLecturer];
        }
    }
    [self deleteEintragForLecture:aLecture];
    [self.document.managedObjectContext deleteObject:aLecture];
    [self saveDatabase];
}

#pragma mark - Stundenplan

- (BOOL)Date:(NSDate*)date1 isOnSameDayAsDate:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}




@end
