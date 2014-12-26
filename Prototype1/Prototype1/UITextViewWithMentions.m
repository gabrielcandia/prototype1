//
//  UITextViewWithMentions.m
//  Prototype1
//
//  Created by Gabriel Candia on 15-12-14.
//  Copyright (c) 2014 Gabriel Candia. All rights reserved.
//

#import "UITextViewWithMentions.h"

@implementation UITextViewWithMentions
@synthesize  mentionsDictionaries;
@synthesize tableViewObjects;
@synthesize accessoryView;

static const CGFloat ROW_HEIGHT = 30;
static const CGFloat NUMBER_OF_ROW_PORTRAIT_IPHONE = 5;
static const CGFloat NUMBER_OF_ROW_LANDSCAPE_IPHONE = 3;
static const CGFloat NUMBER_OF_ROW_PORTRAIT_IPAD = 3;
static const CGFloat NUMBER_OF_ROW_LANDSCAPE_IPAD = 3;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


-(id)init {
    NSLog(@"Init");
    mentionsDictionaries = [[NSMutableDictionary alloc] init];
    accessoryView = [[UIView alloc] init];
    
    tableV = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0) style:UITableViewStylePlain];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.scrollEnabled = YES;
    //tableView.hidden = YES;
    
    accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    accessoryView.backgroundColor = [UIColor blueColor];
    [accessoryView addSubview:tableV];
    //[self configureInputAccessoryView];
    
    UIDevice *device = [UIDevice currentDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidChangeFrameNotification //UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];
    return self;
}

-(void)configureClassForTextView: (UITextView *)textView withSuperView: (UIView *)view {
    [textView setDelegate:self];
    textView.inputAccessoryView = accessoryView;
    textView.inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    superView = view;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize newKeyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if(newKeyboardSize.height != keyboardSize.height || newKeyboardSize.width != keyboardSize.height) {
        keyboardSize = newKeyboardSize;
        [self resizeTextView:auxTextView];
    }
}
- (void) orientationChange:(NSNotification *)note {
    [self configureInputAccessoryView];
    [self getRectForInputViewWithThisEntries:[tableViewObjects count] forTextView:auxTextView];
}

- (void)configureInputAccessoryView {
    // Autocomplete TableView Configuration
    /*CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if([self isPortrait]){ //iPhone Portrait
            accessFrame = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*NUMBER_OF_ROW_PORTRAIT_IPHONE);
        }
        else if([self isLandscape]){ //iPhone Landscape
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                accessFrame = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*NUMBER_OF_ROW_LANDSCAPE_IPHONE);
            }
            else {
                accessFrame = CGRectMake(0.0, 0.0, 0.0, 0.0);//screenHeight, ROW_HEIGHT*NUMBER_OF_ROW_LANDSCAPE_IPHONE);
            }
        }
    }
    else {
        
    }*/
    CGRect accessFrame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [accessoryView setFrame:accessFrame];
    [tableV setFrame:accessFrame];
    auxTextView.inputAccessoryView.hidden = TRUE;
    
}

-(void)getRectForInputViewWithThisEntries: (NSInteger)count forTextView: (UITextView *)textView{
    CGRect tableViewRect;
    CGRect viewRect;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if([self isPortrait]){ //iPhone Portrait
            count = (count > NUMBER_OF_ROW_PORTRAIT_IPHONE)? NUMBER_OF_ROW_PORTRAIT_IPHONE : count;
            viewRect = CGRectMake(0.0, (NUMBER_OF_ROW_PORTRAIT_IPHONE-count)*ROW_HEIGHT, screenWidth, ROW_HEIGHT*count);
            tableViewRect = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*count);
        }
        else if([self isLandscape]){ //iPhone Landscape
            count = (count > NUMBER_OF_ROW_LANDSCAPE_IPHONE)? NUMBER_OF_ROW_LANDSCAPE_IPHONE : count;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                viewRect = CGRectMake(0.0, (NUMBER_OF_ROW_LANDSCAPE_IPHONE-count)*ROW_HEIGHT, screenWidth, ROW_HEIGHT*count);
                tableViewRect = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*count);
            }
            else {
                viewRect = CGRectMake(0.0, (NUMBER_OF_ROW_LANDSCAPE_IPHONE-count)*ROW_HEIGHT, screenHeight, ROW_HEIGHT*count);
                tableViewRect = CGRectMake(0.0, 0.0, screenHeight, ROW_HEIGHT*count);
            }
        }
    }
    else {
        if([self isPortrait]){ //iPad Portrait
            
        }
        else if([self isLandscape]){ //iPad Landscape
            
        }
    }
    if(count == 0) {
        [self configureInputAccessoryView];
        textView.inputAccessoryView.hidden = TRUE;
    }
    else {
        if(viewRect.size.width != textView.inputAccessoryView.frame.size.width ||
           viewRect.size.height != textView.inputAccessoryView.frame.size.height) {
            tableV.frame = tableViewRect;
            accessoryView.frame = viewRect;
            /* iOS 8 > has a bug with the reloadInputViews, so if you call only the reloadinputview changing the frame size it gets on top of the keyboard, this way the inputAccessoryView is forced to reload */
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                textView.inputAccessoryView = nil;
                [textView reloadInputViews];
            }
            textView.inputAccessoryView = accessoryView;
            [textView reloadInputViews];

        }
        textView.inputAccessoryView.hidden = FALSE;
        //[self resizeTextView: textView];
    }
}

- (void)addMentionListWith: (NSMutableArray *)mentionList forCharacter: (NSString *)character {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSMutableArray *mentionListSorted = [[mentionList sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
    [mentionsDictionaries setObject:mentionListSorted forKey:character];
}

- (void)filtrateMentionsForTextView:(UITextView *)textView withWord:(NSString *)word withMentionCharacter: (NSString *)character {
    NSMutableArray *objectsList = [mentionsDictionaries objectForKey:character];
    if(objectsList != nil) {
        characterString = character;
        if(word.length > 0) {
            NSString *filter = [NSString stringWithFormat:@"self BEGINSWITH[cd] '%@'" ,word];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:filter];
            tableViewObjects = [[objectsList filteredArrayUsingPredicate:predicate] mutableCopy];
        }
        else {
            tableViewObjects = objectsList;
        }
        [self getRectForInputViewWithThisEntries:[tableViewObjects count] forTextView:textView];
    }
    else {
        textView.inputAccessoryView.hidden = TRUE;
    }
    [self resizeTextView:textView];
}
- (BOOL) isAlphaNumeric: (NSString *)string
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([string rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

- (BOOL)isPortrait {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return (orientation == 0 || orientation == UIDeviceOrientationPortrait
            || orientation == UIDeviceOrientationPortraitUpsideDown);
}

- (BOOL)isLandscape {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return (orientation == UIDeviceOrientationLandscapeLeft
            || orientation == UIDeviceOrientationLandscapeRight);
}

/******* TextField Methods BEGIN *******/
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSLog(@"shouldChangeTextInRange");
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else {
        NSInteger position = [textView selectedRange].location;
        NSString *resultedText = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSInteger aux = (text.length > 0)? text.length: -1;
        NSString *subString = [[NSString alloc] init];
        if(resultedText.length > (position + aux)) {
            subString = [resultedText substringToIndex:(position + aux)];
        }
        else {
            subString = resultedText;
        }
        tableViewObjects = [[NSMutableArray alloc] init];
        NSArray *wordList = [subString componentsSeparatedByString:@" "];
        NSString *lastWord = [wordList objectAtIndex:([wordList count]-1)];
        
        if(lastWord.length > 0) {
            NSString *firstCharacter = [lastWord substringToIndex:1];
            if(![self isAlphaNumeric:firstCharacter]) {
                [self filtrateMentionsForTextView:textView withWord:[lastWord substringFromIndex:1] withMentionCharacter:firstCharacter];
            }
            else {
                [self getRectForInputViewWithThisEntries:0 forTextView:textView];
            }
        }
        else {
            [self getRectForInputViewWithThisEntries:0 forTextView:textView];
        }
        [tableV reloadData];
        [self resizeTextView:textView];
        return true;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.inputAccessoryView.hidden = TRUE;
    auxTextView = textView;
    originalTextViewRect = textView.frame;
    [self resizeTextView:textView];

}

- (void)resizeTextView: (UITextView *)textView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    NSInteger count = [tableViewObjects count];
    NSInteger statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    NSInteger statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;
    
    CGFloat sizeObjects = 0;
    CGFloat height2;
    CGFloat width;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if([self isPortrait]){ //iPhone Portrait
            count = (count == 0)? NUMBER_OF_ROW_PORTRAIT_IPHONE : 0;
            sizeObjects = count * ROW_HEIGHT;
            height2 = screenHeight - keyboardSize.height - statusBarHeight + sizeObjects;
            width = screenWidth;
        }
        else if([self isLandscape]){ //iPhone Landscape
            count = (count == 0)? NUMBER_OF_ROW_LANDSCAPE_IPHONE : 0;
            sizeObjects = count * ROW_HEIGHT;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                height2 = screenHeight - keyboardSize.height - statusBarHeight + sizeObjects;
                width = screenWidth;
            }
            else {
                height2 = screenWidth - keyboardSize.width - statusBarWidth + sizeObjects;
                width = screenHeight;
                statusBarHeight = statusBarWidth;
            }
        }
    }
    else {
        if([self isPortrait]){ //iPad Portrait
            
        }
        else if([self isLandscape]){ //iPad Landscape
            
        }
    }
    
    CGRect newTextViewFrame = textView.frame;
    newTextViewFrame.size.width = width;
    newTextViewFrame.size.height = height2;
    newTextViewFrame.origin.y = statusBarHeight;
    newTextViewFrame.origin.x = 0;
    
    [textView setFrame:newTextViewFrame];
    [superView bringSubviewToFront:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
    auxTextView = nil;
    textView.frame = originalTextViewRect;
    [superView sendSubviewToBack:textView];
    tableViewObjects = [[NSMutableArray alloc] init];
    [tableV reloadData];
}

/******* TextField Methods END *******/
/******* TableView Methods BEGIN *******/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set the data for this cell:
    
    cell.textLabel.text = [tableViewObjects objectAtIndex:indexPath.row];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numbersOfRows: %lu",(unsigned long)[tableViewObjects count]);
    return [tableViewObjects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *subStringToCursor = [auxTextView.text substringToIndex:auxTextView.selectedRange.location];
    NSArray *splitArray = [subStringToCursor componentsSeparatedByString:characterString];
    NSString *stringWriting = [splitArray objectAtIndex:[splitArray count]-1];
    
    UITextPosition *beginning = auxTextView.beginningOfDocument;
    UITextPosition *start = [auxTextView positionFromPosition:beginning offset:(auxTextView.selectedRange.location - (stringWriting.length + 1))];
    UITextPosition *end = [auxTextView positionFromPosition:start offset:stringWriting.length+1];
    UITextRange *textRange = [auxTextView textRangeFromPosition:start toPosition:end];
    
    
    [auxTextView replaceRange:textRange withText:[NSString stringWithFormat:@"%@%@ ",characterString, [tableViewObjects objectAtIndex:[indexPath row]]]];
    auxTextView.inputAccessoryView.hidden = YES;
    tableViewObjects = [[NSMutableArray alloc] init];
    [tableV reloadData];
    [self resizeTextView:auxTextView];
    [self getRectForInputViewWithThisEntries:0 forTextView:auxTextView];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return ROW_HEIGHT;
}
/******* TableView Methods END *******/

@end
