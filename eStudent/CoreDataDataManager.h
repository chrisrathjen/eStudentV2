//
//  CoreDataDataManager.h
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Eintrag+Create.h"
#import "Kriterium+Create.h"
#import "Semester+Create.h"
#import "Studiengang+Create.h"
#import "Lecture+Create.h"
#import "Date+Create.h"
#import "DateBlock+Create.h"
#import "Term+Create.h"
#import "Lecturer+Create.h"
#import "Course+Create.h"  

typedef void (^LecturesForCourseRequestCompleteBlock) (BOOL wasSuccessful, NSArray *lectures);

@interface CoreDataDataManager : NSObject
@property (nonatomic, strong) UIManagedDocument *document;
+(CoreDataDataManager *)sharedInstance;

- (void)saveDatabase;

//Create ManagedObjects
- (Semester *)createSemesterWithName:(NSString *)name;

- (void)addEintragToDatabase:(Eintrag *)einEintrag;

- (Eintrag *)createEintragWithTitle:(NSString *)title
                                art:(NSString *)art
                        isBestanden:(BOOL)bestanden
                          isBenotet:(BOOL)benotet
                                 cp:(NSNumber *)cp
                               note:(NSNumber *)note
                         inSemester:(Semester *)semester
                      inStudiengang:(Studiengang *)studiengang;

- (Kriterium *)createKriteriumWithName:(NSString *)name
                            isErledigt:(BOOL)erledigt
                                  date:(NSDate *)date
                            forEintrag:(Eintrag *)eintrag;

- (Studiengang *)createStudiengangWithName:(NSString *)name
                                 abschluss:(NSString *)abschluss
                                        cp:(NSNumber *)cp
                            erstesFachsemester:(Semester *)semester;

//Delete ManagedObject
- (void)deleteSemester:(Semester *)semester;
- (void)deleteEintrag:(Eintrag *)eintrag;
- (void)deleteStudiengang:(Studiengang *)studiengang;
- (void)deleteKriterium:(Kriterium *)kriterium;
//List ManagedObjects
- (NSArray *)getAllSemesters;
- (Semester *)getCurrentSemester;
- (Semester *)getSemesterForTerm:(Term *)term;
- (NSArray *)getAllStudiengaenge;
- (Studiengang *)getStudiengangForName:(NSString *)name abschluss:(NSString *)abschluss;
- (NSArray *)getSortedKriterienForEintrag:(Eintrag *)anEintrag;
- (Kriterium *)getKriteriumForCalendarItemIdentifier:(NSString *)identifier;
- (NSArray *)getAllSemestersWithCoursesInStudiengang:(Studiengang *)aStudiengang;
- (NSArray *)getAllEntriesForStudiengang:(Studiengang *)aStudiengang;
- (NSArray *)getAllOpenEntriesForStudiengang:(Studiengang *)aStudiengang;
- (NSArray *)getAllPastEntriesForStudiengang:(Studiengang *)aStudiengang;

//Transfermethoden

- (Eintrag *)createEintragFromLecture:(Lecture *)aLecture inStudiengang:(Studiengang *)aStudiengang forSemester:(Semester *)aSemester;



//Vorlesungsverzeichnis

- (void)updateSemesters;
- (Term *)currentTerm;
- (NSArray *)getAllTermsFromCoreData;
- (void)getLecturesForCourse:(Course *)aCourse withCallback:(LecturesForCourseRequestCompleteBlock)callback;
- (NSArray *)getCoursesForTerm:(Term *)aTerm;
- (NSArray *)getLecturersForLecture:(Lecture *)aLecture;
- (NSArray *)getDateBlocksForLecture:(Lecture *)aLecture;
- (NSArray *)getDatesForLecture:(Lecture *)aLecture;
- (NSArray *)getDatesForDateBlock:(DateBlock *)aDateBlock;
- (void)addLecturerToLecture:(Lecture *)aLecture fromArray:(NSArray *)anArray;

//Stundenplan
- (NSArray *)getAllActiveLectures;
- (NSArray *)getAllActiveDatesForDate:(NSDate *)aDate;
- (NSDate *)dateWithString:(NSString *)dateString; //(zB 21.10.2012)
- (NSString *)getLocalizedWeekDayForDate:(NSDate *)aDate;
- (void)addDateBlocksToSchedule:(NSArray *)aDateBlockArray;
- (void)removeLectureFromSchedule:(Lecture *)aLecture;
- (BOOL)DateBlockInSchedule:(DateBlock *)aDateBlock;
- (void)removeDateBlocksFromSchedule:(NSArray *)aDateBlockArray;
- (Eintrag *)getEintragForLecture:(Lecture *)aLecture;
- (Eintrag *)copyLecture:(Lecture *)aLecture intoStudiengang:(Studiengang *)aStudiengang inSemester:(Semester *)aSemester;
- (BOOL)deleteEintragForLecture:(Lecture *)aLecture;
- (Lecture *)createLectureWithTitle:(NSString *)aTitle type:(NSString *)aType cp:(NSNumber *)cp vak:(NSString *)vak inTerm:(Term *)aTerm;
//- (NSArray *)getAllActiveLecturesAndEintrage;

//compare two semesters
- (NSComparisonResult)compareSemester:(Semester *)s1 withSemester:(Semester *)s2;
- (NSComparisonResult)compareTerm:(Term *)term withSemester:(Semester *)semester;

//delete future semesters that are empty
- (void)deleteAllEmptyFutureSemestersAfterIndex:(int)index;


//OverviewLists
//Array(je Semester) von Arrays(je Studiengang) von Arrays mit Entries. Entries sind alphabetisch sortiert
// [[[Kurs1,kurs2,kurs3],['Kurse eines Studiengangs']],['Je ein Array pro Studiengang der in aktuellen Semester vorhanden ist'],[]]

- (NSArray *)getAllEntriesForOverview;
- (NSArray *)getAllOpenEntriesForOverview;
- (NSArray *)getAllPastEntriesForOverview;



//[{Studiengang}, {die einzelnen infos in einem Dict}] Die keys fuer das Studiengang bezogene Dict koennen in den Konstanten nachgeschaut werden
- (NSArray *)getStatistics;

//Reminders
- (NSArray *)getAllKriteriumsWithLinkedReminder;

@end
