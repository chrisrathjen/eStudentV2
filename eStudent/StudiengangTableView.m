//
//  StudiengangTableView.m
//  eStudent
//
//  Created by Nicolas Autzen on 11.05.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "StudiengangTableView.h"
#import "StatistikCell.h"

@interface StudiengangTableView ()
{
    NSDictionary *_studiengang;
}

- (NSString *)gradeRange:(float)grade;

@end

@implementation StudiengangTableView

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)studiengang
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self)
    {
        _studiengang = studiengang;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.backgroundView = nil;
        self.backgroundColor = kCUSTOM_BACKGROUND_PATTERN_COLOR;
        UINib *nib = [UINib nibWithNibName:@"StatistikCell_" bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:@"StatCell"];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"Creditpunkte", @"Creditpunkte");
            break;
        case 1:
            return NSLocalizedString(@"Noten", @"Noten");
        case 2:
            return NSLocalizedString(@"Zeit", @"Zeit");
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 3;
        case 1:
            return 3;
        case 2:
            return 2;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatistikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatCell"];
    
    switch (indexPath.section)
    {
        case 0: //Creditpunkte
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Erreicht", @"Erreicht");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ CP", [_studiengang objectForKey:kAchievedCP]];
                int erreicht = [[_studiengang objectForKey:kAchievedCP] intValue];
                if (erreicht > 0)
                {
                    int aktuellesSemester = [[_studiengang objectForKey:kCurrentSemesterIndex] intValue];
                    int semester = [[_studiengang objectForKey:kLastSemesterIndexWithAchievedEintraege] intValue];
                    if (semester > aktuellesSemester)
                    {
                        cell.detailDetailTextLabel.text = [NSString stringWithFormat:@"%@ %i. %@", NSLocalizedString(@"bis einschließlich des", @"bis einschließlich des"), semester, NSLocalizedString(@"Semesters", @"Semesters")];
                    }
                    else
                    {
                        cell.detailDetailTextLabel.text = NSLocalizedString(@"inkl. des aktuellen Semesters", @"inkl. des aktuellen Semesters");
                    }
                }
                else
                {
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Geplant", @"Geplant");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ CP", [_studiengang objectForKey:kOpenCP]];
                int geplant = [[_studiengang objectForKey:kOpenCP] intValue];
                if (geplant > 0)
                {
                    int aktuellesSemester = [[_studiengang objectForKey:kCurrentSemesterIndex] intValue];
                    int semester = [[_studiengang objectForKey:kLastSemesterIndexForAnyEintraege] intValue];
                    if (semester > aktuellesSemester)
                    {
                        cell.detailDetailTextLabel.text = [NSString stringWithFormat:@"%@ %i. %@", NSLocalizedString(@"bis einschließlich des", @"bis einschließlich des"), semester, NSLocalizedString(@"Semesters", @"Semesters")];
                    }
                    else
                    {
                        cell.detailDetailTextLabel.text = NSLocalizedString(@"inkl. des aktuellen Semesters", @"inkl. des aktuellen Semesters");
                    }
                    
                }
                else
                {
                    cell.detailDetailTextLabel.text = @"";
                }
                
                
            }
            else
            {
                int ausstehend = [[_studiengang objectForKey:kCPNeededToCompletion] intValue];
                ausstehend  = ausstehend >= 0 ? ausstehend : 0;
                cell.textLabel.text = NSLocalizedString(@"Ausstehend", @"Ausstehend");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i %@ %i CP", ausstehend, NSLocalizedString(@"von", @"von"), [[_studiengang objectForKey:kStudiengangCP] intValue]];
                if (ausstehend > 0)
                {
                    int nochzuplanen = ausstehend - [[_studiengang objectForKey:kOpenCP] intValue];
                    if (nochzuplanen > 0)
                    {
                        cell.detailDetailTextLabel.text = [NSString stringWithFormat:@"%@ %i CP %@", NSLocalizedString(@"noch", @"noch"), nochzuplanen, NSLocalizedString(@"zu planen", @"zu planen")];
                    }
                    else
                    {
                        cell.detailDetailTextLabel.text = NSLocalizedString(@"ausreichend CP geplant", @"ausreichend CP geplant");
                    }
                }
                else
                {
                    cell.detailDetailTextLabel.text = NSLocalizedString(@"ausreichend CP erworben", @"ausreichend CP erworben");
                }
            }
            break;
        case 1: //Noten
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Durchschnitt", @"Durchschnitt");
                id averageMark = [_studiengang objectForKey:kAvarageMark];
                if ([averageMark floatValue] > 0.0)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[NSString stringWithFormat:@"%.2f", [[_studiengang objectForKey:kAvarageMark] floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","]];
                    cell.detailDetailTextLabel.text = [self gradeRange:[averageMark floatValue]];
                }
                else
                {
                    cell.detailTextLabel.text = @"--";
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Beste Note", @"Beste Note");
                id bestMark = [_studiengang objectForKey:kBestMark];
                if (bestMark)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[NSString stringWithFormat:@"%.1f", [[_studiengang objectForKey:kBestMark] floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","]];
                    cell.detailDetailTextLabel.text = [self gradeRange:[bestMark floatValue]];
                }
                else
                {
                    cell.detailTextLabel.text = @"--";
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Schlechteste Note", @"Schlechteste Note");
                id worstMark = [_studiengang objectForKey:kWorstMark];
                if (worstMark)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[NSString stringWithFormat:@"%.1f", [[_studiengang objectForKey:kWorstMark] floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","]];
                    cell.detailDetailTextLabel.text = [self gradeRange:[worstMark floatValue]];
                }
                else
                {
                    cell.detailTextLabel.text = @"--";
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            break;
        case 2: //Zeit
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Punkte/Semester", @"Punkte/Semester");
                float schnitt = [[_studiengang objectForKey:kAvarageCPPerSemester] floatValue];
                if (schnitt > 0.0)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ CP", [[[_studiengang objectForKey:kAvarageCPPerSemester] stringValue] stringByReplacingOccurrencesOfString:@"." withString:@","]];
                    if ([[_studiengang objectForKey:kCurrentSemesterIndex] intValue] == 1)
                    {
                        cell.detailDetailTextLabel.text = NSLocalizedString(@"erstes Semester", @"erstes Semester");
                    }
                    else
                    {
                        cell.detailDetailTextLabel.text = NSLocalizedString(@"erstes bis einschließlich aktuelles Semester", @"erstes bis einschließlich aktuelles Semester");
                    }
                }
                else
                {
                    cell.detailTextLabel.text = @"--";
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Studiendauer", @"Studiendauer");
                
                float averageCP = [[_studiengang objectForKey:kAvarageCPPerSemester] floatValue];
                if (averageCP > 0.0)
                {
                    float studiendauer = [[_studiengang objectForKey:kStudiengangCP] floatValue] / averageCP;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Semester", (int)ceil(studiendauer)];
                    cell.detailDetailTextLabel.text = NSLocalizedString(@"nach bisherigem Schnitt", @"nach bisherigem Schnitt");
                }
                else
                {
                    cell.detailTextLabel.text = @"--";
                    cell.detailDetailTextLabel.text = @"";
                }
            }
            break;
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.opaque = YES;
    return cell;
}

- (NSString *)gradeRange:(float)grade
{
    NSString *gradeRange;
    if (grade)
    {
        if (grade >= 1.0 && grade <= 1.24)
        {
            gradeRange = [NSString stringWithFormat:@"1,0 < %@ < 1,25", NSLocalizedString(@"Ausgezeichnet", @"Ausgezeichnet")];
        }
        else if (grade >= 1.25 && grade <= 1.54)
        {
            gradeRange = [NSString stringWithFormat:@"1,25 < %@ < 1,54", NSLocalizedString(@"Sehr gut", @"Sehr gut")];
        }
        else if (grade >= 1.55 && grade < 2.54)
        {
            gradeRange = [NSString stringWithFormat:@"1,55 < %@ < 2,54", NSLocalizedString(@"Gut", @"Gut")];
        }
        else if (grade >= 2.54 && grade < 3.54)
        {
            gradeRange = [NSString stringWithFormat:@"2,54 < %@ < 3,54", NSLocalizedString(@"Befriedigend", @"Befriedigend")];
        }
        else if (grade >= 3.54 && grade <= 4.04)
        {
            gradeRange = [NSString stringWithFormat:@"3,54 < %@ < 4,04", NSLocalizedString(@"Ausreichend", @"Ausreichend")];
        }
        else
        {
            gradeRange = [NSString stringWithFormat:@"4,05 < %@", NSLocalizedString(@"Nicht bestanden", @"Nicht bestanden")];
        }
    }
    return gradeRange;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(20.0, 0.0, 200.0, 40.0);
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    UIImageView *headerImageView;
    frame.size.width -= 30.0;
    frame.size.height -= 10.0;
    frame.origin.x += 25.0;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:frame];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    switch (section)
    {
        case 0: //Creditpunkte
            headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"108-badge"]];
            headerLabel.text = NSLocalizedString(@"Creditpunkte", @"Creditpunkte");
            break;
        case 1: //Noten
            headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"85-trophy"]];
            headerLabel.text = NSLocalizedString(@"Noten", @"Noten");
            break;
        case 2: //Zeit
            headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"78-stopwatch"]];
            headerLabel.text = NSLocalizedString(@"Zeit", @"Zeit");
            break;
        default:
            break;
    }
    [headerView addSubview:headerLabel];
    [headerView addSubview:headerImageView];
    frame = headerImageView.frame;
    frame.origin.x += 15.0;
    headerImageView.frame = frame;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

@end
