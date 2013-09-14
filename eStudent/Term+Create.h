//
//  Term+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Term.h"

@interface Term (Create)

+ (Term *)createTermWithTitle:(NSString *)title
                    termStart:(NSDate *)termStart
                      termEnd:(NSDate *)termEnd
                 lectureStart:(NSDate *)lectureStart
                   lectureEnd:(NSDate *)lectureEnd
             inManagedContext:(NSManagedObjectContext *)context;
+ (NSString *)convertTermTitleWithString:(NSString *)title;
@end
