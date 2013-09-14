//
//  ESNetworkManager.m
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "ESNetworkManager.h"

@interface ESNetworkManager() <NSURLConnectionDataDelegate, ESNetworkManagerDelegate>
@property (nonatomic, strong) NSMutableData *dataStorage;
@property (nonatomic, assign) BOOL expanding;
@property (nonatomic, strong) NSURL *iCloudURL;//private iCloud URL
@property (nonatomic, strong) NSMetadataQuery *iCloudQuery;
@end

@implementation ESNetworkManager
@synthesize dataStorage, delegate, iCloudQuery, iCloudURL;

- (void)getDataFromNetwork:(NSURL *)remoteURL
{
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:remoteURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (aConnection) {
        self.dataStorage = [NSMutableData data];
    } else {
        NSLog(@"Connection failed befor it startet :-(");
    }
}

#pragma mark - iCloud Sharing
    //Hier wird ein Array zunächst serialisiert auf das lokale Dateisystem geschrieben. Danach wird eine Kopie in die Cloud geladen. Dies Kopie wird dann für 24h veröffendlicht
- (void)shareArrayWithICloud:(NSArray *)array
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//get Any old Queue which is not the main thread
        NSString *name = @"timeTableExport4";
        NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:name];
        NSURL *localURL = [NSURL URLWithString:[localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"local URL:%@",localURL);
        BOOL writesuccess =YES;
        writesuccess = [array writeToFile:localPath atomically:YES];
        self.iCloudURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]  URLByAppendingPathComponent:name isDirectory:NO];
        NSLog(@"private iCloud URL:%@", self.iCloudURL);
        NSError *error = nil;
        [[[NSFileManager alloc]init] setUbiquitous:YES itemAtURL:localURL destinationURL:self.iCloudURL error:&error];
        NSLog(@"%@, %@, %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoverySuggestion]);
        NSNumber *inCloud =nil;
        [iCloudURL getResourceValue:&inCloud forKey:NSURLIsUbiquitousItemKey error:nil];
        if ([inCloud boolValue]) {
            NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:86400]; // Create a Date 24h from now
            NSError *sharingError;
            NSURL *sharedICloudURL = [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:iCloudURL expirationDate:&expirationDate error:&sharingError];
            NSLog(@"publicURL:%@", sharedICloudURL);
            NSString *longURLString = [NSString stringWithFormat:@"%@", sharedICloudURL];
            NSString* newText = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)longURLString,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
            dispatch_async(dispatch_get_main_queue(), ^{
                ESNetworkManager *urlShortner = [[ESNetworkManager alloc] init];
                [urlShortner setDelegate:self];
                [urlShortner getDataFromNetwork:[NSURL URLWithString:[NSString stringWithFormat:@"http://is.gd/create.php?format=json&url=%@", newText]]];
            });
        }
    });
}

- (void)importSharedArray:(NSString *)code
{
    ESNetworkManager *urlExpander = [[ESNetworkManager alloc]init];
    [urlExpander setDelegate:self];
    self.expanding = YES;
    [urlExpander getDataFromNetwork:[NSURL URLWithString:[NSString stringWithFormat:@"http://is.gd/forward.php?format=json&shorturl=%@", code]]];
    
}
#pragma mark - URL shortning

- (void)dataFromRemoteURL:(NSData *)remoteData
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:remoteData options:kNilOptions error:nil];
    if (self.expanding) {
        NSString *landingPageURL = [[dict objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
        NSRange pRange = [landingPageURL rangeOfString:@"?p"];
        NSRange tRange = [landingPageURL rangeOfString:@"&t="];
        pRange.length = (tRange.location - 1) - (pRange.location);
        pRange.location += 1;
        NSString *pString = [[landingPageURL substringWithRange:pRange] stringByReplacingOccurrencesOfString:@"=" withString:@""];
        NSString *tString = [landingPageURL substringFromIndex:(tRange.location + tRange.length)];
        NSString *downloadURL = [NSString stringWithFormat:@"https://%@-ubiquityws.icloud.com/ws/file/%@",pString, tString];
        NSArray *array = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:downloadURL]];
        [self.delegate sharedArrayForCode:array];
    }else {
        NSString *code = [[dict objectForKey:@"shorturl"] stringByReplacingOccurrencesOfString:@"http://is.gd/" withString:@""];
        [self.delegate codeForSharedURL:code];
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self.delegate requestFailedWithError:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.dataStorage) {
        [self.dataStorage appendData:data];
    } else {
        self.dataStorage = [self.dataStorage initWithData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.delegate dataFromRemoteURL:self.dataStorage];
    [self setDataStorage:nil];
}

- (void)dealloc
{
    [self.iCloudQuery stopQuery];
}
@end
