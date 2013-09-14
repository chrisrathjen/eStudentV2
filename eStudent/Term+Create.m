//
//  Term+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Term+Create.h"

@implementation Term (Create)

+ (Term *)createTermWithTitle:(NSString *)title
                    termStart:(NSDate *)termStart
                      termEnd:(NSDate *)termEnd
                 lectureStart:(NSDate *)lectureStart
                   lectureEnd:(NSDate *)lectureEnd
             inManagedContext:(NSManagedObjectContext *)context

{
    Term *aTerm = [NSEntityDescription insertNewObjectForEntityForName:@"Term" inManagedObjectContext:context];
    aTerm.title = [Term convertTermTitleWithString:title];
    aTerm.termStart = termStart;
    aTerm.termEnd = termEnd;
    aTerm.lectureStart = lectureStart;
    aTerm.lectureEnd = lectureEnd;
    
    return aTerm;
}

+ (NSString *)convertTermTitleWithString:(NSString *)title
{
    if ([title hasPrefix:@"WiSe2"]) {
        title = [title stringByReplacingOccurrencesOfString:@"_20" withString:@"/"];
        title = [title stringByReplacingOccurrencesOfString:@"WiSe" withString:@"WiSe "];
    } else if ([title hasPrefix:@"SoSe"]){
        title = [title stringByReplacingOccurrencesOfString:@"SoSe" withString:@"SoSe "];
    }
    return title;
}

@end
