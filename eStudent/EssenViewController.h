//
//  EssenViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESMensaDataManager.h"

//Diese Klasse ist für das Laden sämtlicher Speisen aus den Speiseplan-Informationen verantwortlich und das erzeugen des
//dazugehörigen User Interfaces verantwortlich.
@interface EssenViewController : UIViewController <UIScrollViewDelegate, ESMensaDataManagerDelegate, UIActionSheetDelegate>

@end
