//
//  StudiumsplanerViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudiumsplanerViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic)BOOL shouldRefresh;
@property (nonatomic, strong)UIScrollView *scrollViewWithSelectedEintrag;

@end
