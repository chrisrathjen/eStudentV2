//
//  UebersichtViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 14.04.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UebersichtViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic)BOOL shouldRefresh;
@property (nonatomic, strong)UIScrollView *scrollViewWithSelectedEintrag;

- (void)loadViews;

@end
