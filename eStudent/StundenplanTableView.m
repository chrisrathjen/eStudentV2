//
//  StundenplanTableView.m
//  eStudent
//
//  Created by Nicolas Autzen on 26.08.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "StundenplanTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "DateBlock.h"
#import "Lecture.h"
#import "CoreDataDataManager.h"
#import "Date.h"
#import "VeranstaltungenViewController.h"

@interface StundenplanTableView ()
{
    UIView *_noDatesTodayView;
    NSIndexPath *_indexPathToSetOrEditNote;
    UITextView *_noteTextView;
}

- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;
- (BOOL)dateIsNow:(Date *)date;

@end

@implementation StundenplanTableView

@synthesize dates = _dates;

- (id)initWithFrame:(CGRect)frame DateArray:(NSArray *)dates
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dates = dates;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        
        _noDatesTodayView = [[UIView alloc] initWithFrame:frame];
        UIImageView *noDatesToday = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-lecture-today"]];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.text = NSLocalizedString(@"Keine Veranstaltungen.", @"Keine Veranstaltungen.");
        
        CGRect _frame = noDatesToday.frame;
        _frame.origin.x = (_noDatesTodayView.frame.size.width / 2.0) - (_frame.size.width / 2.0);
        _frame.origin.y = (_noDatesTodayView.frame.size.height / 2.0) - (_frame.size.height/1.5);
        noDatesToday.frame = _frame;
        [_noDatesTodayView addSubview:noDatesToday];
        
        textView.frame = CGRectMake(40.0, _frame.origin.y + _frame.size.height + 10.0, 240.0, 100.0);
        textView.scrollEnabled = NO;
        textView.editable = NO;
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        textView.textColor = [UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1.0];
        textView.backgroundColor = [UIColor clearColor];
        [_noDatesTodayView addSubview:textView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DateArray Setter ueberschreiben

-(void) setDates:(NSArray *)dates
{
    _dates = dates;
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dates.count == 0)
    {
        self.backgroundView = _noDatesTodayView;
    }
    else
    {
        self.backgroundView = nil;
    }
    if (_indexPathToSetOrEditNote)
    {
        return _dates.count+1;
    }
    return _dates.count;
}

- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StundenplanCell";
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[cell.contentView.subviews lastObject] removeFromSuperview];

    Date *date;
    if (_indexPathToSetOrEditNote)
    {
        if (indexPath.row < _indexPathToSetOrEditNote.row)
        {
            date = [_dates objectAtIndex:indexPath.row];
        }
        else if (indexPath.row > _indexPathToSetOrEditNote.row)
        {
            date = [_dates objectAtIndex:indexPath.row-1];
        }
        else
        {
            date = [_dates objectAtIndex:indexPath.row-1];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10.0, -10.0, 300.0, 73.0)];
            view.backgroundColor = [UIColor colorWithRed:.85 green:.95 blue:.99 alpha:1.0]; //Die Hintergrundfarbe eines Notizzettels
            view.opaque = YES;
            
            UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 280.0, 21.0)];
            noteLabel.backgroundColor = [UIColor clearColor];
            if (date.note.length > 0)
            {
                noteLabel.text = NSLocalizedString(@"Notiz bearbeiten", @"Notiz bearbeiten");
            }
            else
            {
                noteLabel.text = NSLocalizedString(@"Notiz hinzufügen", @"Notiz hinzufügen");
            }
            noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
            noteLabel.textColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
            [view addSubview:noteLabel];
            
            CGRect frame = noteLabel.frame;
            frame.origin.y += frame.size.height;
            frame.size.height = 35.0;
            _noteTextView = [[UITextView alloc] initWithFrame:frame];
            _noteTextView.backgroundColor = [UIColor clearColor];
            _noteTextView.text = date.note;
            _noteTextView.returnKeyType = UIReturnKeyDone;
            _noteTextView.delegate = self;
            [view addSubview:_noteTextView];
            
            //view.layer.cornerRadius = 5.0;
            view.layer.shadowRadius = 1.5;
            view.layer.shadowOffset = CGSizeMake(0, .5);
            view.layer.shadowOpacity = .4;
            view.layer.shouldRasterize = YES; //wichtig für die Performance
            view.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
            [cell.contentView addSubview:view];
            return cell;
        }
    }
    else
    {
        date = [_dates objectAtIndex:indexPath.row];
    }
        
    float paddingTop = 2.5;
    if (indexPath.row == 0)
    {
        paddingTop = 5.0;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10.0, paddingTop, 300.0, 50.0)];
    view.opaque = YES;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 280.0, 40.0)];
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@", date.startTime, date.stopTime];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    timeLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:timeLabel];
    
    CGRect frame = timeLabel.frame;
    frame.origin.y = frame.size.height + frame.origin.y - 5.0;
    frame.origin.x += 10.0;
    frame.size.width = 260.0;
    UILabel *lectureTitle = [[UILabel alloc] initWithFrame:frame];
    lectureTitle.text = date.dateBlock.lecture.title;
    lectureTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
    lectureTitle.backgroundColor = [UIColor clearColor];
    lectureTitle.numberOfLines = 0;
    lectureTitle.lineBreakMode = NSLineBreakByWordWrapping;
    frame.size.height = [lectureTitle.text sizeWithFont:lectureTitle.font constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
    lectureTitle.frame = frame;
    frame.origin.y = frame.size.height + frame.origin.y + 10.0;
    frame.size.height = 21.0;
    [view addSubview:lectureTitle];
    
    UILabel *roomLabel = [[UILabel alloc] initWithFrame:frame];
    roomLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    roomLabel.backgroundColor = [UIColor clearColor];
    //roomLabel.textColor = [UIColor grayColor];
    roomLabel.text = [NSString stringWithFormat:@"%@", date.dateBlock.room];
    roomLabel.numberOfLines = 0;
    roomLabel.lineBreakMode = NSLineBreakByWordWrapping;
    frame = roomLabel.frame;
    frame.size.height = [roomLabel.text sizeWithFont:roomLabel.font constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
    roomLabel.frame = frame;
    [view addSubview:roomLabel];
    
    BOOL dateIsNow = [self dateIsNow:date];
    if (dateIsNow)
    {
        view.backgroundColor = [UIColor colorWithRed:.47 green:.74 blue:.96 alpha:1.0];
        roomLabel.textColor = [UIColor darkGrayColor];
        
    }
    else
    {
        view.backgroundColor = [UIColor whiteColor];
        roomLabel.textColor = [UIColor grayColor];
    }
    
    if (date.note)
    {
        frame.origin.y += frame.size.height + 10.0;
        frame.size.height = 1.0;
        UIView *lineView = [[UIView alloc] initWithFrame:frame];
        lineView.backgroundColor = kCUSTOM_BLUE_COLOR;
        [view addSubview:lineView];
        
        frame = roomLabel.frame;
        frame.origin.y += frame.size.height + 15.0;
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:frame];
        noteLabel.text = [NSString stringWithFormat:@"%@", date.note];
        noteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noteLabel.numberOfLines = 0;
        if (dateIsNow)
        {
            noteLabel.textColor = [UIColor colorWithRed:.17 green:.345 blue:.52 alpha:1.0];
        }
        else
        {
            noteLabel.textColor = kCUSTOM_BLUE_COLOR;
        }
        frame = noteLabel.frame;
        frame.size.height = [noteLabel.text sizeWithFont:noteLabel.font constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
        noteLabel.frame = frame;
        [view addSubview:noteLabel];
        
        UIImageView *tapIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]];
        frame = tapIndicator.frame;
        frame.origin.x = view.frame.size.width/2.0 - frame.size.width/2.0;
        frame.origin.y = noteLabel.frame.size.height + noteLabel.frame.origin.y + 5.0;
        tapIndicator.frame = frame;
        if (_indexPathToSetOrEditNote && _indexPathToSetOrEditNote.row-1 == indexPath.row)
        {
            tapIndicator.image = [UIImage imageNamed:@"tapIndicator_u"];
        }
        else
        {
            tapIndicator.image = [UIImage imageNamed:@"tapIndicator"];
        }
        [view addSubview:tapIndicator];
        frame = roomLabel.frame;
        frame = view.frame;
        frame.size.height = tapIndicator.frame.size.height + tapIndicator.frame.origin.y + 5.0;
    }
    else
    {
        UIImageView *tapIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]];
        frame = tapIndicator.frame;
        frame.origin.x = view.frame.size.width/2.0 - frame.size.width/2.0;
        frame.origin.y = roomLabel.frame.size.height + roomLabel.frame.origin.y + 5.0;
        tapIndicator.frame = frame;
        if (_indexPathToSetOrEditNote && _indexPathToSetOrEditNote.row-1 == indexPath.row)
        {
            tapIndicator.image = [UIImage imageNamed:@"tapIndicator_u"];
        }
        else
        {
            tapIndicator.image = [UIImage imageNamed:@"tapIndicator"];
        }
        [view addSubview:tapIndicator];
        frame = roomLabel.frame;
        frame = view.frame;
        frame.size.height = tapIndicator.frame.size.height + tapIndicator.frame.origin.y + 7.0;
    }
    
    
    view.frame = frame;
    view.layer.cornerRadius = 5.0;
    view.layer.shadowRadius = 1.5;
    view.layer.shadowOffset = CGSizeMake(0, .5);
    view.layer.shadowOpacity = .4;
    view.layer.shouldRasterize = YES; //wichtig für die Performance
    view.layer.rasterizationScale = [UIScreen mainScreen].scale == 2.0 ? 2.0 : 1.0; //wichtig für das Aussehen der rasterisierten Views
    
    [cell.contentView addSubview:view];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Date *date;
    if (_indexPathToSetOrEditNote)
    {
        if (indexPath.row < _indexPathToSetOrEditNote.row)
        {
            date = [_dates objectAtIndex:indexPath.row];
        }
        else if ([_indexPathToSetOrEditNote isEqual:indexPath])
        {
            return 70.0;
        }
        else
        {
            date = [_dates objectAtIndex:indexPath.row-1];
        }
    }
    else
    {
        date = [_dates objectAtIndex:indexPath.row];
    }
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 280.0, 40.0)];
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@", date.startTime, date.stopTime];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    
    CGRect frame = timeLabel.frame;
    frame.origin.y = frame.size.height + frame.origin.y - 5.0;
    frame.origin.x += 10.0;
    frame.size.width = 260.0;
    UILabel *lectureTitle = [[UILabel alloc] initWithFrame:frame];
    lectureTitle.text = date.dateBlock.lecture.title;
    lectureTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
    lectureTitle.numberOfLines = 0;
    lectureTitle.lineBreakMode = NSLineBreakByWordWrapping;
    frame.size.height = [lectureTitle.text sizeWithFont:lectureTitle.font constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
    lectureTitle.frame = frame;
    frame.origin.y = frame.size.height + frame.origin.y + 10.0;
    frame.size.height = 21.0;
    
    UILabel *roomLabel = [[UILabel alloc] initWithFrame:frame];
    roomLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    roomLabel.text = [NSString stringWithFormat:@"%@", date.dateBlock.room];
    roomLabel.numberOfLines = 0;
    roomLabel.lineBreakMode = NSLineBreakByWordWrapping;
    frame = roomLabel.frame;
    frame.size.height = [roomLabel.text sizeWithFont:roomLabel.font constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
    roomLabel.frame = frame;
    
    float paddingBottom = 0.0;
    if (indexPath.row == 0 || indexPath.row == _dates.count-1)
    {
        paddingBottom = 2.5;
    }
    
    if (date.note)
    {
        frame.origin.y += frame.size.height + 15.0;
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:frame];
        noteLabel.text = [NSString stringWithFormat:@"%@", date.note]; //hier dann date.note eintragen
        noteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noteLabel.numberOfLines = 0;
        frame = noteLabel.frame;
        frame.size.height = [noteLabel.text sizeWithFont:noteLabel.font constrainedToSize:CGSizeMake(260.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
        
        return frame.size.height + frame.origin.y + 10.0 + paddingBottom + [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]].frame.size.height + 7.5;
    }
    
    return roomLabel.frame.size.height + roomLabel.frame.origin.y + 10.0 + paddingBottom + [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapIndicator"]].frame.size.height + 7.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:_indexPathToSetOrEditNote]) //Wenn der Nutzer auf die Notiz selbst tippt soll nichts passieren
    {
        return;
    }
    if (_indexPathToSetOrEditNote) //Die Notiz-Zelle wird angezeigt wird und soll wieder eingefahren werden
    {
        ((VeranstaltungenViewController *)[[[self superview] nextResponder] nextResponder]).horizontalScrollingDisabled = NO;
        [_noteTextView resignFirstResponder];
        NSIndexPath *tmp = [NSIndexPath indexPathForRow:_indexPathToSetOrEditNote.row-1 inSection:0];
        Date *date = [_dates objectAtIndex:tmp.row];
        if (_noteTextView.text.length > 0)
        {
            date.note = _noteTextView.text;
        }
        else
        {
            date.note = nil;
        }
        [[CoreDataDataManager sharedInstance] saveDatabase];
        _indexPathToSetOrEditNote = nil;
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tmp.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:tmp] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self scrollToRowAtIndexPath:tmp atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self endUpdates];
    }
    else //Die Notizzelle wird nicht angezeigt und soll ausgefahren werden
    {
        ((VeranstaltungenViewController *)[[[self superview] nextResponder] nextResponder]).horizontalScrollingDisabled = YES;
        _indexPathToSetOrEditNote = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [self beginUpdates];
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:_indexPathToSetOrEditNote] withRowAnimation:UITableViewRowAnimationTop];
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [_noteTextView becomeFirstResponder];
    }
}

#pragma mark - Eine ganze Woche auf einmal wechseln, statt nur einen Tag

- (void)setDatesForWeekBack:(NSArray *)dates
{
    _dates = dates;
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)setDatesForWeekFurther:(NSArray *)dates
{
    _dates = dates;
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - NotificationCenter

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height-20.0, 0.0);
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"])
    {
        ((VeranstaltungenViewController *)[[[self superview] nextResponder] nextResponder]).horizontalScrollingDisabled = NO;
        [textView resignFirstResponder];
        NSIndexPath *tmp = [NSIndexPath indexPathForRow:_indexPathToSetOrEditNote.row-1 inSection:0];
        Date *date = [_dates objectAtIndex:tmp.row];
        if (_noteTextView.text.length > 0)
        {
            date.note = _noteTextView.text;
        }
        else
        {
            date.note = nil;
        }
        [[CoreDataDataManager sharedInstance] saveDatabase];
        _indexPathToSetOrEditNote = nil;
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tmp.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:tmp] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self scrollToRowAtIndexPath:tmp atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self endUpdates];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_indexPathToSetOrEditNote && ![_noteTextView isFirstResponder])
    {
        [_noteTextView becomeFirstResponder];
    }
}

#pragma mark - Ist ein Termin jetzt in diesem Moment?

- (BOOL)dateIsNow:(Date *)date
{
    NSDateComponents *componentsOfDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date.date];
    NSDateComponents *componentsOfToday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
    if ([componentsOfDate day] == [componentsOfToday day] && [componentsOfDate month] == [componentsOfToday month] && [componentsOfDate year] == [componentsOfToday year]) //Ist der uebergebene Termin heute?
    {
        NSString *currentTime = [NSString stringWithFormat:@"%i:%i", [componentsOfToday hour], [componentsOfToday minute]]; //Erstellt einen Uhrzeit-String vom aktuellen Datum im 'HH:mm' Format
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSDate *formattedCurrentDate = [dateFormatter dateFromString:date.startTime];
        NSDate *dateFromString = [dateFormatter dateFromString:currentTime];
        if(![formattedCurrentDate isEqual:dateFromString])
        {
            if ([[formattedCurrentDate earlierDate:dateFromString] isEqual:formattedCurrentDate]) //Die Startzeit des Termins ist frueher.
            {
                formattedCurrentDate = [dateFormatter dateFromString:date.stopTime];
                if(![formattedCurrentDate isEqual:dateFromString])
                {
                    return [[formattedCurrentDate earlierDate:dateFromString] isEqual:dateFromString];
                }
            }
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}

@end
