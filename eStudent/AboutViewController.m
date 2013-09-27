//
//  AboutViewController.m
//  eStudent
//
//  Created by Georg Scharsich on 22.09.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
{
    __weak IBOutlet UITextView *_textview;
}

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kCUSTOM_SETTINGS_BACKGROUND_COLOR;
    self.navigationItem.title = NSLocalizedString(@"Über", @"Über");
    _textview.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
    _textview.textColor = [UIColor whiteColor];
    //_textview.tintColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
