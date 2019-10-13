//
//  ViewController.h
//  festivalApp
//
//  Created by Beyar on 2018-08-24.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *recipientInputContent;
@property (weak) IBOutlet NSTextField *timesInputContent;
@property (weak) IBOutlet NSTextField *bodyInputContent;
@property (weak) IBOutlet NSButton *deliverSubmitButton;
@property (strong) IBOutlet NSTextField *stats;
@end

// Static names
NSString *app = @"Messages.app";
NSString *appDir = @"/Applications";
NSString *appProcess = @"com.apple.iChat";
