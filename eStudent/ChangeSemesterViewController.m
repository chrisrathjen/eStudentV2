//
//  ChangeSemesterViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 14.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "ChangeSemesterViewController.h"
#import "CoreDataDataManager.h"
#import "StudiengaengeViewController.h"

@interface ChangeSemesterViewController ()
{
    NSArray *_semester;
}

@end

@implementation ChangeSemesterViewController

@synthesize pViewController = _pViewController;
@synthesize chosenTerm = _chosenTerm;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _semester = [[CoreDataDataManager sharedInstance] getAllTermsFromCoreData].copy;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _semester.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SemesterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Term *term = (Term *)[_semester objectAtIndex:indexPath.row];
    cell.textLabel.text = term.title;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    if ([term isEqual:_chosenTerm])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Term *term = [_semester objectAtIndex:indexPath.row];
    ((StudiengaengeViewController *)_pViewController).chosenSemester = term;
    [((StudiengaengeViewController *)_pViewController) loadCoursesforTerm:term];
}

@end
