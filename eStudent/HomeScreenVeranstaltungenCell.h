//
//  HomeScreenVeranstaltungenCell.h
//  eStudent
//
//  Created by Nicolas Autzen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>

//Die Klasse für das Veranstaltungen-Feld.
@interface HomeScreenVeranstaltungenCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *veranstaltungenFunktionLabel;
@property (weak, nonatomic) IBOutlet UILabel *veranstaltungsTitelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *veranstaltungsImage;


@end
