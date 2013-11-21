//
//  HomeScreenEsseCell.h
//  eStudent
//
//  Created by Nicolas Autzen on 28.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>

//Die Klasse für das Essen-Feld.
@interface HomeScreenEssenCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *essenFunktionLabel;
@property (weak, nonatomic) IBOutlet UILabel *essensTypLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitiyIndicator;

@end
