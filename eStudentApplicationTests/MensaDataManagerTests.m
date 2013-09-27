//
//  MensaDataManagerTests.m
//  eStudent
//
//  Created by Christian Rathjen on 26/3/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "MensaDataManagerTests.h"

@interface MensaDataManagerTests()
{
    ESMensaDataManager *testMensaDataManager;
}

@end

@implementation MensaDataManagerTests

- (void)setUp
{
    [super setUp];
    testMensaDataManager = [[ESMensaDataManager alloc] init];
}

- (void)testDataManagerCreation
{
    STAssertNotNil(testMensaDataManager, @"DatenManager wird nicht korrekt erstellt");
}

- (void)testGetWeek
{
    NSNumber *weekOfTheYear = [testMensaDataManager getWeek];
    if (weekOfTheYear <= [NSNumber numberWithInt:52] && weekOfTheYear >= [NSNumber numberWithInt:1]) {
        STAssertNotNil(weekOfTheYear, @"Wrong ouput format");
    }
}

- (void)testCorrectMensaIsSetForGettingTheMenu
{
    [testMensaDataManager getMenuDataForMensa:@"testMensa"];
    STAssertEquals(testMensaDataManager.currentMensa, @"testMensa", @"Der MensaDataManager akzeptiert die übergebene Mensa nicht korrekt");
}

@end
