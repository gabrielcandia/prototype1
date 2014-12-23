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

static const CGFloat ROW_HEIGHT = 44;
static const CGFloat NUMBER_OF_ROW_PORTRAIT_IPHONE = 3;
static const CGFloat NUMBER_OF_ROW_LANDSCAPE_IPHONE = 1;
static const CGFloat NUMBER_OF_ROW_PORTRAIT_IPAD = 3;
static const CGFloat NUMBER_OF_ROW_LANDSCAPE_IPAD = 3;


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureInputAccessoryView)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    return self;
}

-(void)configureClassForTextView: (UITextView *)textView withSuperView: (UIView *)view {
    [textView setDelegate:self];
    textView.inputAccessoryView = self.accessoryView;
    superView = view;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)configureInputAccessoryView {
    // Autocomplete TableView Configuration
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGRect accessFrame;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPhone Portrait
            accessFrame = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*NUMBER_OF_ROW_PORTRAIT_IPHONE);
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPhone Landscape
            accessFrame = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*NUMBER_OF_ROW_LANDSCAPE_IPHONE);
        }
    }
    else {
        
    }
    accessoryView.frame = accessFrame;
    tableV.frame = accessFrame;
}

-(void)getRectForInputViewWithThisEntries: (NSInteger)count forTextView: (UITextView *)textView{
    CGRect tableViewRect;
    CGRect viewRect;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPhone Portrait
            count = (count > NUMBER_OF_ROW_PORTRAIT_IPHONE)? NUMBER_OF_ROW_PORTRAIT_IPHONE : count;
            viewRect = CGRectMake(0.0, (NUMBER_OF_ROW_PORTRAIT_IPHONE-count)*ROW_HEIGHT, screenWidth, ROW_HEIGHT*count);
            tableViewRect = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*count);
            NSLog(@"Frame, X:%f,Y:%f, Width: %f, Height: %f",viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPhone Landscape
            count = (count > NUMBER_OF_ROW_LANDSCAPE_IPHONE)? NUMBER_OF_ROW_LANDSCAPE_IPHONE : count;
            viewRect = CGRectMake(0.0, (NUMBER_OF_ROW_LANDSCAPE_IPHONE-count)*ROW_HEIGHT, screenWidth, ROW_HEIGHT*count);
            tableViewRect = CGRectMake(0.0, 0.0, screenWidth, ROW_HEIGHT*count);
            NSLog(@"Frame, X:%f,Y:%f, Width: %f, Height: %f",viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
        }
    }
    else {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPad Portrait
            
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPad Landscape
            
        }
    }
    tableV.frame = tableViewRect;
    textView.inputAccessoryView.frame = viewRect;
    if(count == 0) {
        textView.inputAccessoryView.hidden = TRUE;
    }
    else {
        textView.inputAccessoryView.hidden = FALSE;
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
}
- (BOOL) isAlphaNumeric: (NSString *)string
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([string rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

/******* TextField Methods BEGIN *******/
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return TRUE;
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
    [self performSelector :@selector(resizeTextView:) withObject:textView afterDelay:0.1];

}

- (void)resizeTextView: (UITextView *)textView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSInteger count = [tableViewObjects count];
    NSInteger statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPhone Portrait
            count = (count > NUMBER_OF_ROW_PORTRAIT_IPHONE)? 0 : (NUMBER_OF_ROW_PORTRAIT_IPHONE -count);
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPhone Landscape
            count = (count > NUMBER_OF_ROW_LANDSCAPE_IPHONE)? 0 : (NUMBER_OF_ROW_LANDSCAPE_IPHONE -count);
        }
    }
    else {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPad Portrait
            
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPad Landscape
            
        }
    }
    CGFloat sizeObjects = count * ROW_HEIGHT;
    
    CGRect newTextViewFrame = textView.frame;
    newTextViewFrame.size.height = screenHeight - keyboardSize.height - statusBarHeight + sizeObjects;
    newTextViewFrame.origin.y = statusBarHeight;
    newTextViewFrame.origin.x = 0;
    textView.frame = newTextViewFrame;
    [textView setFrame:newTextViewFrame];
    [[UIApplication sharedApplication].keyWindow addSubview:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    auxTextView = nil;
    textView.frame = originalTextViewRect;
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
    [self resizeTextView:auxTextView];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return ROW_HEIGHT;
}
/******* TableView Methods END *******/

@end
