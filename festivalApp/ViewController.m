//
//  ViewController.m
//  festivalApp
//
//  Created by Beyar on 2018-08-24.
//

#import "ViewController.h"

@implementation ViewController
@synthesize recipientInputContent, timesInputContent, bodyInputContent, stats;

- (void)viewDidAppear {}
- (void)viewDidLoad {
    [super viewDidLoad];
//    Disabling resizing
    self.preferredContentSize = self.view.frame.size;
//    Disabling the NSFocusRingType
    [recipientInputContent setFocusRingType:NSFocusRingTypeNone];
    [timesInputContent setFocusRingType:NSFocusRingTypeNone];
    [bodyInputContent setFocusRingType:NSFocusRingTypeNone];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    stats.stringValue = @"Status";
}

// https:developer.apple.com/design/human-interface-guidelines/macos/visual-design/color
// https:developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib?language=occ
// Changing background color to the selected one
- (void)awakeFromNib {
    self.view.window.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"background.png"]];
}

// Prompts the user to accept Festival to control Messages
- (NSString *)allowanceForSystemIntegrityProtection:(NSString *)statusCode {
    NSAppleEventDescriptor *appProcessIdentifier;
    appProcessIdentifier = [NSAppleEventDescriptor descriptorWithBundleIdentifier:appProcess];
//    OSStatus shows result code of a function
//    https://developer.apple.com/documentation/coreservices/aedesc?language=objc
    OSStatus permissions = 0;
    if (@available(macOS 10.14, *)) {
        permissions = AEDeterminePermissionToAutomateTarget(appProcessIdentifier.aeDesc, typeWildCard, typeWildCard, TRUE);
    }
    switch (permissions) {
        case -1743:
            return @"Permissions required";
            break;
    }
    return @"Permissions success";
}

// https://developer.apple.com/documentation/appkit/nsworkspace?language=objc
// IB = Interface builder
// Launching iMessage
- (IBAction)openclick:(id)sender {
    stats.stringValue = @"Launching Messages";
    [ [NSWorkspace sharedWorkspace] openFile:[NSString stringWithFormat:@"%@/%@",appDir ,app] /* withApplication:@"Messages" */];
}

// Closing iMessage
- (IBAction)closeclick:(id)sender {
    stats.stringValue = @"Closing Messages";
    NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:appProcess];
    if (applications.count) {
        [(NSRunningApplication *)applications[0] terminate];
    }
}

// Retrieveing the first input data
- (IBAction)recipientInputField:(NSTextField *)sender {
    NSString *recipientContent = [NSString stringWithFormat:@"%@", recipientInputContent.stringValue];
//    Checks if input is empty
    if ([recipientContent isEqualTo:@""]) {
        stats.stringValue = @"Input required";
//    Returns a zero if NaN (Not a Number)
    } else if ([recipientContent intValue] != 0) {
        stats.stringValue = @"Not a contact";
    } else {
        NSLog(@"Recipient button %@", recipientContent);
        stats.stringValue = @"Input approved";
    }
}

// Retrieving the second input data
- (IBAction)timesInputField:(NSTextField *)sender {
    NSString *timesContent = [NSString stringWithFormat:@"%@", timesInputContent.stringValue];
//    Checks if input is empty
    if ([timesContent isEqualTo:@""]) {
        stats.stringValue = @"Input required";
//        Returns a zero if NaN (Not a Number)
    } else if ([timesContent intValue] == 0) {
        stats.stringValue = @"Not a number";
    } else {
        stats.stringValue = @"Input approved";
    }
}

// Function to automate task for Messages
- (void)deliveryLoad {
//    Data from input field
    NSString *recipient = [NSString stringWithFormat:@"%@", recipientInputContent.stringValue];
    NSInteger timesInt = [[NSString stringWithFormat:@"%@", timesInputContent.stringValue] integerValue];
    NSString *body = [NSString stringWithFormat:@"%@", bodyInputContent.stringValue];
    NSInteger from = 1;
//    The command for AppleScript
    NSString *stage = [NSString stringWithFormat:@"tell application \"Messages\" to send \"%@\" to buddy \"%@\"", body, recipient];
//    Error collector
//    https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html
    NSDictionary *error = NULL;
    NSAppleScript *initTaskFromSource = [[NSAppleScript alloc] initWithSource:stage];
//    Starting with one test case to see if there is any errors or if the delivery task should continue
    [initTaskFromSource executeAndReturnError:&error];
    from +=1 ;
//    -1728 error code means contact unknown
    if ([[error objectForKey:NSAppleScriptErrorNumber] integerValue] == -1728) {
        stats.stringValue = [NSString stringWithFormat:@"Unknown contact"];
    } else {
//        Keeps commanding Messages until end of loop reached
        for(; from <= timesInt; from++) {
            [initTaskFromSource executeAndReturnError:&error];
            stats.stringValue = [NSString stringWithFormat:@"%ld of %ld delivered", (long)from, (long)timesInt];
        }
    }
}

// Handles the deliver button and script for delivering messages
- (IBAction)middleclick:(id)sender {
//    https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html
    NSDictionary *error = NULL;
//    Request permission to automatate
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        self->stats.stringValue = [self allowanceForSystemIntegrityProtection: [error objectForKey:NSAppleScriptErrorNumber]];
    });
//    Runs the deliveryLoad function
    [self deliveryLoad];
};

@end
