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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init {
    NSLog(@"Init");
    mentionsDictionaries = [[NSMutableDictionary alloc] init];
    accessoryView = [[UIView alloc] init];
    [self configureInputAccessoryView];
    return self;
}
-(void)configureClassForTextView: (UITextView *)textView withSuperView: (UIView *)view {
    [textView setDelegate:self];
    textView.inputAccessoryView = self.accessoryView;
    superView = view;
}

/*-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)configureInputAccessoryView {
    // Autocomplete TableView Configuration
    tableV = [[UITableView alloc] initWithFrame:
              CGRectMake(0.0, 0.0, 320.0, 132.0) style:UITableViewStylePlain];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.scrollEnabled = YES;
    //tableView.hidden = YES;
    
    CGRect accessFrame = CGRectMake(0.0, 0.0, 320.0, 132.0);
    accessoryView = [[UIView alloc] initWithFrame:accessFrame];
    accessoryView.backgroundColor = [UIColor blueColor];
    [accessoryView addSubview:tableV];
}

-(void)getRectForInputViewWithThisEntries: (NSInteger)count forTextView: (UITextView *)textView{
    CGRect tableViewRect;
    CGRect viewRect;
    double rowHeight = 44.0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    count = (count > 3)? 3 : count;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait){ //iPhone Portrait
            viewRect = CGRectMake(0.0, (3-count)*rowHeight, 320.0, rowHeight*count);
            tableViewRect = CGRectMake(0.0, 0.0, 320.0, rowHeight*count);
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){ //iPhone Landscape
            viewRect = CGRectMake(0.0, 0.0, 480.0, rowHeight);
            tableViewRect = CGRectMake(0.0, 0.0, 480.0, rowHeight);
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
    textView.inputAccessoryView.hidden = FALSE;
}

- (void)addMentionListWith: (NSMutableArray *)mentionList forCharacter: (NSString *)character {
    [mentionsDictionaries setObject:mentionList forKey:character];
}

- (void)filtrateMentionsForTextView:(UITextView *)textView withWord:(NSString *)word withMentionCharacter: (NSString *)character {
    NSMutableArray *objectsList = [mentionsDictionaries objectForKey:character];
    if(objectsList != nil) {
        characterString = character;
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        if(word.length > 0) {
            NSString *filter = [NSString stringWithFormat:@"self BEGINSWITH[cd] '%@'" ,word];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:filter];
            tableViewObjects = [[[objectsList filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
        }
        else {
            tableViewObjects = [[objectsList sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.inputAccessoryView.hidden = TRUE;
    auxTextView = textView;
    NSLog(@"textViewDidBeginEditing");
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    auxTextView = nil;
    return false;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSLog(@"shouldChangeTextInRange");
    //NSString *deletedText = [textView.text  substringWithRange:range];
    //NSString *textWithoutRange = [textView.text stringByReplacingCharactersInRange:range withString:@""];
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
        /*if([firstCharacter isEqualToString:@"\n"] && ![lastWord isEqualToString:@"\n"]) {
            firstCharacter = [lastWord substringWithRange:NSMakeRange(1, 1)];
        }*/
        if(![self isAlphaNumeric:firstCharacter]) {
            [self filtrateMentionsForTextView:textView withWord:[lastWord substringFromIndex:1] withMentionCharacter:firstCharacter];
        }
        else {
            textView.inputAccessoryView.hidden = TRUE;
        }
    }
    else {
        textView.inputAccessoryView.hidden = TRUE;
    }
    [tableV reloadData];
    return true;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
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
    NSLog(@"numbersOfRows: %d",[tableViewObjects count]);
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
}
/******* TableView Methods END *******/

@end
