//
//  Constants_ES.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( IS_WIDESCREEN )
#define IS_IOS_7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] ==NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kDEBUG 0

// USER DEFAULT KEYS

#define kDEFAULTS_MENSA_TO_SHOW             @"defaultMensaToShow"
#define kDEFAULTS_MENSANAME_TO_SHOW         @"defaultMensaNameToShow"

#define kDEFAULTS_DEFAULT_MENSA             @"defaultMensa"
#define kDEFAULTS_DEFAULT_FOOD_TYPE         @"foodType"
#define kDEFAULTS_MENSA_NAME                @"mensaName"
#define kDEFAULTS_ENTRY_TYPES               @"eintragsArten"
#define kDEFAULTS_COURSE_OF_STUDY           @"Studiengang"

#define kFILTERED_FOOD_TYPES                @"filteredFoodTypes"

#define kMENSA_UNI                          @"UNI"
#define kMENSA_GW2                          @"GW2"
#define kMENSA_AIR                          @"AIR"
#define kMENSA_BHV                          @"BHV"
#define kMENSA_HSB                          @"HSB"
#define kMENSA_WER                          @"WER"

#define kURI_UNI_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/uniessen.php"
#define kURI_GW2_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/gw2essen.php"
#define kURI_AIR_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/airessen.php"
#define kURI_BHV_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/bhvessen.php"
#define kURI_HSB_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/hsbessen.php"
#define kURI_WER_MENSA                      @"http://www.studentenwerk.bremen.de/files/main_info/essen/plaene/weressen.php"

// Keys für die Attribute eines Studiengangs
#define kDEFAULTS_COURSE_OF_STUDY_NAME          @"StudiengangName"
#define kDEFAULTS_COURSE_OF_STUDY_DEGREE        @"StudiengangAbschluss"
#define kDEFAULTS_COURSE_OF_STUDY_FIST_SEMESTER @"StudiengangErstesSemester"
#define kDEFAULTS_COURSE_OF_STUDY_CP            @"StudiengangCP"

// Reminders
#define kDefaultReminderCalenderTitle       @"kDefaultReminderCalender"

//Studiengänge
#define kDEFAULTS_BACHELOR                  @"Bachelor"
#define kDEFAULTS_MASTER                    @"Master"
#define kDEFAULTS_DIPLOM                    NSLocalizedString(@"Diplom", @"Diplom")
#define kDEFAULTS_MAGISTER                  NSLocalizedString(@"Magister", @"Magister")
#define kDEFAULTS_STAATSEXAMEN              NSLocalizedString(@"Staatsexamen", @"Staatsexamen")
//Vorlesungsverzeichnis
#define kUserCreatedCourse                  @"User Created Course"
#define kAllSemestersJSONURL                @"http://chrisrathjen.de/eStudent/vorlesungen/allSemesters.json"
#define kAllSemesterKey                     @"semesters"
#define kAllSemestersUpdateKey              @"updateString"
#define kSemesterURL                        @"url"
#define kSemesterTitle                      @"title"
#define kTermTitle                          @"name"
#define kTermStart                          @"SemesterStart"
#define kTermEnd                            @"SemesterEnd"
#define kLectureStart                       @"LectureStart"
#define kLectureEnd                         @"LectureEnd"
#define kTermFiles                          @"files"
#define kTermFileName                       @"titel"
#define kTermFileURL                        @"fileURL"
#define kLectureTitle                       @"name"
#define kLectureVAK                         @"vak"
#define kLectureType                        @"type"
#define kLectureCP                          @"cp"
#define kLectureDates                       @"dates"
#define kLectureLecturers                   @"lecturers"
#define kDateBlockDay                       @"day"
#define kDateBlockRoom                      @"room"
#define kDateBlockRepeat                    @"repeat"
#define kDateBlockFirstDate                 @"firstdate"
#define kDateBlockLastDate                  @"lastdate"
#define kDateBlockStartTime                 @"starttime"
#define kDateBlockStopTime                  @"stoptime"
#define kDateBlockType                      @"type"
#define kLastSemesterDataSync               @"lastSemesterSync"
#define kDateDay                            @"day"
#define kDateMonth                         @"month"
#define kDateYear                           @"year"
#define kTimeIntervalTwoWeek                -1209600.0
#define kTimeIntervalFourWeek               -2419200.0
//MensaDataManager
#define kMensaDataURL                       @"http://chrisrathjen.de/mensa.php?file="
#define kMensaDataFromat                    @".json"
//CampusInfo
#define kGenerellCampusInformationURL       @"http://chrisrathjen.de/campus.php?file=CampusInfo.json"
#define kLastCampusPOIRefresh               @"lastPoiRequestDate"
#define kTimeIntervalOneWeek                -604800.0
#define kSavedPoiDataFileName               @"campusPois.array"
//StatisticKeys
#define kAchievedCP                         @"achievedCP" //Erreichte Cp
#define kOpenCP                             @"openCP" //Geplante Cp(ohne bestandene Cp)
#define kCPNeededToCompletion               @"cpsNeededToFinish" // Noch einzutragene CP

#define kLastSemesterIndexWithAchievedEintraege   @"lastsemesterIndexWithachievedEintrag" 
#define kLastSemesterIndexForAnyEintraege     @"lastsemesterIndex"
#define kCurrentSemesterIndex               @"currentSemesterIndex"

#define kAvarageMark                        @"avarageMark"
#define kBestMark                           @"bestMark"
#define kWorstMark                          @"worstMark"
#define kAvarageCPPerSemester               @"avarageCPPerSemester"

#define kStudiengangName                    @"studiengangName"
#define kStudiengangAbschluss               @"studiengangAbschluss"
#define kStudiengangCP                      @"studiengangCP"


//Colors
#define kCUSTOM_BLUE_COLOR                  [UIColor colorWithRed:.25 green:.51 blue:.77 alpha:1.0]
#define kCUSTOM_BACKGROUND_PATTERN_COLOR    [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise_lines"]]
#define kCUSTOM_SETTINGS_BACKGROUND_COLOR   [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_background"]]

//Fonts
#define kCUSTOM_HEADER_LABEL_FONT           [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]

//Filter fuer die Anzeige der Uebersicht im Studiumsplaner
#define kEINTRAEGE_FILTER                   @"eintraegeFilter"

#define kALL_EINTRAEGE_FILTER               1
#define kPAST_EINTRAEGE_FILTER              2
#define kOPEN_EINTRAEGE_FILTER              3



