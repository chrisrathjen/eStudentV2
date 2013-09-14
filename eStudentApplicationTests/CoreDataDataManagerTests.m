//
//  CoreDataDataManagerTests.m
//  eStudent
//
//  Created by Christian Rathjen on 26/3/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "CoreDataDataManagerTests.h"

@interface CoreDataDataManagerTests()
{
    CoreDataDataManager *sharedDataManager;
}

@end

@implementation CoreDataDataManagerTests

- (void)setUp
{
    [super setUp];
    sharedDataManager = [CoreDataDataManager sharedInstance];
}

- (void)testDataManagerInit
{
    STAssertNotNil(sharedDataManager.document, @"There should be a Document Object");
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[sharedDataManager.document.fileURL path]], @"DatabaseFile exists on Disk");
}

- (void)testSemester
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"test"];
    STAssertEqualObjects(testSemester.name, @"test", @"TestSemester hat falschen titel");
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager saveDatabase];
    STAssertFalse([testSemester isInserted], @"TestSemester ist nach dem löschen noch im MOC");
}

- (void)testCreateStudiengang
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"test"];
    NSInteger preTestCreateStudiengangsCount = [[sharedDataManager getAllStudiengaenge] count];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    STAssertEqualObjects(testStudiengang.name, @"testName", @"TestStudiengang hat den Falschen Titel");
    NSInteger postCreateStudiengangsCount = [[sharedDataManager getAllStudiengaenge] count];
    
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager saveDatabase];
    STAssertFalse([testStudiengang isInserted], @"TestStudiengang ist nach dem löschen noch im MOC");
    NSInteger postTestDeletionStudiengangCount = [[sharedDataManager getAllStudiengaenge] count];
    
    STAssertTrue(preTestCreateStudiengangsCount < postCreateStudiengangsCount, @"Nach dem Anlegen eines neuen Studiengangs gibt es nicht mehr Studiengaenge in der DB");
    STAssertTrue(postCreateStudiengangsCount > postTestDeletionStudiengangCount, @"Nach dem Löschen eines Studiengangs gibt es nicht weniger Studiengänge in der DB");
}

- (void)testCreateEintrag
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"WiSe 2014/15"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    Eintrag *testEintrag = [sharedDataManager createEintragWithTitle:@"testTitle" art:@"testArt" isBestanden:YES isBenotet:YES cp:[NSNumber numberWithInt:6] note:[NSNumber numberWithInt:2] inSemester:testSemester inStudiengang:testStudiengang];
    STAssertEqualObjects(testEintrag.semester, testSemester, @"Semester des Eintrags nicht gesetzt");
    STAssertEqualObjects(testEintrag.studiengang, testStudiengang, @"Studiengang des Eintrags falsch gesetzt");
    STAssertEqualObjects(testEintrag.titel, @"testTitle", @"testEintrag hat nicht den korrekten Titel");
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager deleteEintrag:testEintrag];
    [sharedDataManager saveDatabase];
    STAssertFalse([testEintrag isInserted], @"TestEintrag ist nach dem löschen noch im MOC");
    
}

- (void)testCreateKriterium
{
    Kriterium *testKriterium = [sharedDataManager createKriteriumWithName:@"testName" isErledigt:YES date:[NSDate distantFuture] forEintrag:nil];
    STAssertEqualObjects(testKriterium.name, @"testName", @"TestKriterium nicht korrekt erstellt");
    STAssertTrue([testKriterium.erledigt boolValue], @"TestKriterium nicht korrekt erstellt");
    [sharedDataManager deleteKriterium:testKriterium];
    [sharedDataManager saveDatabase];
    STAssertFalse([testKriterium isInserted], @"TestKriterium ist nach dem löschen noch im MOC");
}

- (void)testGetCurrentSemester
{
    Semester *testSemester = [sharedDataManager getCurrentSemester];
    STAssertNotNil(testSemester, @"Kein Semester returned");
}

- (void)testKriteriumSort
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"test"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    Eintrag *testEintrag = [sharedDataManager createEintragWithTitle:@"testTitle" art:@"testArt" isBestanden:YES isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];
    Kriterium *distandTestKriterium = [sharedDataManager createKriteriumWithName:@"distantKriterium" isErledigt:NO date:[NSDate distantFuture] forEintrag:testEintrag];
    Kriterium *urgentTestKriterium = [sharedDataManager createKriteriumWithName:@"urgentTestKriterium" isErledigt:NO date:[NSDate dateWithTimeIntervalSinceNow:7200] forEintrag:testEintrag];
    Kriterium *noDateKriterium = [sharedDataManager createKriteriumWithName:@"noDateKriterium" isErledigt:NO date:nil forEintrag:testEintrag];
    
    NSArray *sortedKriterien = [sharedDataManager getSortedKriterienForEintrag:testEintrag];
    STAssertEqualObjects(urgentTestKriterium, [sortedKriterien objectAtIndex:0], @"Das dringendere Kriterium ist nicht oben in der Liste");
    
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager deleteEintrag:testEintrag];
    [sharedDataManager deleteKriterium:urgentTestKriterium];
    [sharedDataManager deleteKriterium:distandTestKriterium];
    [sharedDataManager deleteKriterium:noDateKriterium];
}

- (void)testCreateTwoSemesterWithTheSameName
{
    Semester *firstSemester = [sharedDataManager createSemesterWithName:@"Test"];
    [sharedDataManager saveDatabase];
    Semester *secondSemester = [sharedDataManager createSemesterWithName:@"Test"];
    [sharedDataManager saveDatabase];
    STAssertTrue([firstSemester isEqual:secondSemester], @"Es wurden 2 verschieden Objekte mit dem selben namen erstellt");
    [sharedDataManager deleteSemester:firstSemester];
    [sharedDataManager deleteSemester:secondSemester];
    [sharedDataManager saveDatabase];
}

- (void)testFindStudiengangWithNameAndAbschluss
{
    NSString *testName = @"testName";
    NSString *testAbschluss = @"testAbschluss";
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"test"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:testName abschluss:testAbschluss cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    [sharedDataManager saveDatabase];
    STAssertTrue([[sharedDataManager getStudiengangForName:testName abschluss:testAbschluss] isEqual:testStudiengang], @"Es wurde nicht das selbe Semester zurückgegeben");
    
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager saveDatabase];
}

- (void)testGetAllEntriesForOverview
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"SoSe 1921"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    Eintrag *testEintrag = [sharedDataManager createEintragWithTitle:@"testTitle" art:@"testArt" isBestanden:YES isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];

    NSArray *overviewArray = [sharedDataManager getAllEntriesForOverview];
    BOOL success = NO;

    //NSLog(@"Es gibt %d Semester", [overviewArray count]);
    for (NSArray *semesterArray in overviewArray) {
        //NSLog(@"Dieses Semester enthält Kurse aus %d studiengaengen", [semesterArray count]);
        for (NSArray *studiengangArray in semesterArray) {
            //Eintrag *infoEintrag = [studiengangArray lastObject];
            //NSLog(@"In diesem Studiengang(%@) und Semester(%@) gibt es %d Kurse", infoEintrag.studiengang.name,infoEintrag.semester.name ,[studiengangArray count]);
            for (Eintrag *anEintrag in studiengangArray) {
                //NSLog(@"%@", anEintrag.titel);
                if ([anEintrag isEqual:testEintrag]) {
                    success = YES;
                }
            }
        }
    }
    
    STAssertTrue(success, @"testEintrag nicht im Overview Array vorhanden");
    
    [sharedDataManager deleteEintrag:testEintrag];
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager saveDatabase]; 
}

- (void)testGetAllOpenEntriesForOverview
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"SoSe 1921"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    Eintrag *testEintragOpen = [sharedDataManager createEintragWithTitle:@"testTitle" art:@"testArt" isBestanden:NO isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];
    Eintrag *testEintragPast = [sharedDataManager createEintragWithTitle:@"testTitlePast" art:@"testArt" isBestanden:YES isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];
    
    NSArray *overviewArray = [sharedDataManager getAllOpenEntriesForOverview];
    BOOL success = NO;
    
    //NSLog(@"Es gibt %d Semester", [overviewArray count]);
    for (NSArray *semesterArray in overviewArray) {
        //NSLog(@"Dieses Semester enthält Kurse aus %d studiengaengen", [semesterArray count]);
        for (NSArray *studiengangArray in semesterArray) {
            //Eintrag *infoEintrag = [studiengangArray lastObject];
            //NSLog(@"In diesem Studiengang(%@) und Semester(%@) gibt es %d Kurse", infoEintrag.studiengang.name,infoEintrag.semester.name ,[studiengangArray count]);
            for (Eintrag *anEintrag in studiengangArray) {
                //NSLog(@"%@", anEintrag.titel);
                if ([anEintrag isEqual:testEintragOpen]) {
                    success = YES;
                }
                if ([anEintrag isEqual:testEintragPast]) {
                    STFail(@"Der bestanden kurs sollte hier nicht enthalten sein!");
                }
            }
        }
    }
    STAssertTrue(success, @"testEintrag nicht im Overview Array vorhanden");
    [sharedDataManager deleteEintrag:testEintragOpen];
    [sharedDataManager deleteEintrag:testEintragPast];
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager saveDatabase];
}

- (void)testGetAllPastEntriesForOverview
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"SoSe 1921"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
    Eintrag *testEintragOpen = [sharedDataManager createEintragWithTitle:@"testTitle" art:@"testArt" isBestanden:NO isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];
    Eintrag *testEintragPast = [sharedDataManager createEintragWithTitle:@"testTitlePast" art:@"testArt" isBestanden:YES isBenotet:NO cp:[NSNumber numberWithInt:0] note:[NSNumber numberWithInt:0] inSemester:testSemester inStudiengang:testStudiengang];
    
    NSArray *overviewArray = [sharedDataManager getAllPastEntriesForOverview];
    BOOL success = NO;
    
    //NSLog(@"Es gibt %d Semester", [overviewArray count]);
    for (NSArray *semesterArray in overviewArray) {
        //NSLog(@"Dieses Semester enthält Kurse aus %d studiengaengen", [semesterArray count]);
        for (NSArray *studiengangArray in semesterArray) {
            //Eintrag *infoEintrag = [studiengangArray lastObject];
            //NSLog(@"In diesem Studiengang(%@) und Semester(%@) gibt es %d Kurse", infoEintrag.studiengang.name,infoEintrag.semester.name ,[studiengangArray count]);
            for (Eintrag *anEintrag in studiengangArray) {
                //NSLog(@"%@", anEintrag.titel);
                if ([anEintrag isEqual:testEintragPast]) {
                    success = YES;
                }
                if ([anEintrag isEqual:testEintragOpen]) {
                    STFail(@"Der offene kurs sollte hier nicht enthalten sein!");
                }
            }
        }
    }
    STAssertTrue(success, @"testEintrag nicht im Overview Array vorhanden");
    [sharedDataManager deleteEintrag:testEintragOpen];
    [sharedDataManager deleteEintrag:testEintragPast];
    [sharedDataManager deleteStudiengang:testStudiengang];
    [sharedDataManager deleteSemester:testSemester];
    [sharedDataManager saveDatabase];
}


- (void)testCurrentTerm
{
    Term *aTerm = [sharedDataManager currentTerm];
    STAssertNotNil(aTerm, @"There should always be a Term Objekt");
}

- (void)testDateWithString
{
    NSDate *aDate = [sharedDataManager dateWithString:@"20.07.1989"];
    STAssertNotNil(aDate, @"The Method should accept the Format of the Test Input and return a DateObject");
}

- (void)testAdd_RemoveDateBlocksToSchedule
{
    Lecture *aLecture = [Lecture createLectureWithTitle:@"test" vak:@"test" cp:Nil type:nil activeInSchedule:NO inCourse:nil inManagedContext:sharedDataManager.document.managedObjectContext];
    DateBlock *testDateBlock = [DateBlock createDateBlockWithRoom:@"test" startTime:@"test" stopTime:@"test" startDate:nil stopDate:nil repeatModifier:nil lecture:aLecture inManagedContext:sharedDataManager.document.managedObjectContext];
    Date *testDate = [Date createDateWithDateBlock:testDateBlock date:nil startTime:nil stopTime:nil active:NO forLecture:aLecture inManagedContext:sharedDataManager.document.managedObjectContext];
    STAssertFalse([testDate.active boolValue], @"TestDate should be inactive");
    STAssertFalse([aLecture.activeInSchedule boolValue], @"aLecture should not be in Schedule");
    [sharedDataManager addDateBlocksToSchedule:[NSArray arrayWithObject:testDateBlock]];
    STAssertTrue([testDate.active boolValue], @"TestDate should now be active");
    STAssertTrue([aLecture.activeInSchedule boolValue], @"aLecture should be in Schedule");
    [sharedDataManager removeDateBlocksFromSchedule:[NSArray arrayWithObject:testDateBlock]];
    STAssertFalse([testDate.active boolValue], @"TestDate should be inactive");
    STAssertFalse([aLecture.activeInSchedule boolValue], @"aLecture should not be in Schedule");
    [sharedDataManager.document.managedObjectContext deleteObject:testDate];
    [sharedDataManager.document.managedObjectContext deleteObject:testDateBlock];
    [sharedDataManager.document.managedObjectContext deleteObject:aLecture];
}

- (void)testGetAllActiveLectures
{
    int oldLectureCount = [[sharedDataManager getAllActiveLectures] count];
    Lecture *aLecture = [Lecture createLectureWithTitle:@"test" vak:@"test" cp:Nil type:nil activeInSchedule:YES inCourse:nil inManagedContext:sharedDataManager.document.managedObjectContext];
    int newLectureCount = [[sharedDataManager getAllActiveLectures] count];
    [sharedDataManager.document.managedObjectContext deleteObject:aLecture];
    STAssertTrue(oldLectureCount == newLectureCount - 1, @"There should be exactly one more active Lecture returned from the Database");
}


- (void)testLectureEintragConnection
{
    Semester *testSemester = [sharedDataManager createSemesterWithName:@"SoSe 1921"];
    Studiengang *testStudiengang = [sharedDataManager createStudiengangWithName:@"testName" abschluss:@"testAbschlluss" cp:[NSNumber numberWithInt:180] erstesFachsemester:testSemester];
     Lecture *aLecture = [Lecture createLectureWithTitle:@"test12" vak:@"test12" cp:Nil type:nil activeInSchedule:NO inCourse:nil inManagedContext:sharedDataManager.document.managedObjectContext];
    Eintrag *anEintrag = [sharedDataManager copyLecture:aLecture intoStudiengang:testStudiengang inSemester:testSemester];
    STAssertTrue([aLecture.title isEqualToString:anEintrag.titel], @"copied Object should have same title");
    STAssertNotNil(aLecture.eintrag, @"Copied Eintrag should be connected to source Lecture Object");
    
    [sharedDataManager.document.managedObjectContext deleteObject:aLecture];
    [sharedDataManager.document.managedObjectContext deleteObject:testSemester];
    [sharedDataManager.document.managedObjectContext deleteObject:testStudiengang];
    [sharedDataManager.document.managedObjectContext deleteObject:anEintrag];
}

- (void)testAddLecturer
{
    Lecturer *oldLecturer = [Lecturer createLecturerWithTitle:@"test" inManagedContext:sharedDataManager.document.managedObjectContext];
    Lecture *aLecture = [Lecture createLectureWithTitle:@"test" vak:@"test" cp:nil type:nil activeInSchedule:NO inCourse:nil inManagedContext:sharedDataManager.document.managedObjectContext];
    [oldLecturer addLectures:[NSSet setWithObject:aLecture]];
    STAssertTrue([aLecture.lecturers containsObject:oldLecturer], @"Old Lecturer should be added to Lecture");
    
    
    [sharedDataManager addLecturerToLecture:aLecture fromArray:[NSArray arrayWithObject:@"test2"]];
    STAssertFalse([aLecture.lecturers containsObject:oldLecturer], @"Old Lecturer should be removen");
    Lecturer *newLecturer = [aLecture.lecturers lastObject];
    STAssertEquals(@"test2", newLecturer.title,@"test");
    
    [sharedDataManager.document.managedObjectContext deleteObject:aLecture];
    [sharedDataManager.document.managedObjectContext deleteObject:oldLecturer];
    [sharedDataManager.document.managedObjectContext deleteObject:newLecturer];
}

@end
