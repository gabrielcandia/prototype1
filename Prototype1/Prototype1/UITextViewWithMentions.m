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
    tableViewObjects = [[NSArray alloc] init];
    mentionsDictionaries = [[NSMutableDictionary alloc] init];
    accessoryView = [[UIView alloc] init];
    [self configureInputAccessoryView];
    /*for(NSString *keys in mentionsDictionaries) {
        NSLog(@"%@",keys);
        NSArray *objectsArray = [mentionsDictionaries objectForKey:keys];
        
    }*/
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureInputAccessoryView {
    // Autocomplete TableView Configuration
    tableV = [[UITableView alloc] initWithFrame:
              CGRectMake(0.0, 0.0, 320.0, 120.0) style:UITableViewStylePlain];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.scrollEnabled = YES;
    //tableView.hidden = YES;
    
    CGRect accessFrame = CGRectMake(0.0, 0.0, 320.0, 120.0);
    accessoryView = [[UIView alloc] initWithFrame:accessFrame];
    accessoryView.backgroundColor = [UIColor blueColor];
    [accessoryView addSubview:tableV];
    self.inputAccessoryView.hidden = TRUE;
}

- (void)addMentionListWith: (NSArray *)mentionList forCharacter: (NSString *)character {
    [mentionsDictionaries setObject:mentionList forKey:character];
}

- (void)filtrateMentionsForWord: (NSString *)word withMentionCharacter: (NSString *)character {
    NSArray *objectsList = [mentionsDictionaries objectForKey:character];
    if(objectsList != nil) {
        if(word.length > 0) {
            NSString *filter = [NSString stringWithFormat:@"self BEGINSWITH[cd] '%@'" ,word];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:filter];
            tableViewObjects = [objectsList filteredArrayUsingPredicate:predicate];
        }
        else {
            tableViewObjects = objectsList;
        }
        self.inputAccessoryView.hidden = FALSE;
        [tableV reloadData];
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
    NSLog(@"textViewDidBeginEditing");
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
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
    NSInteger aux = (text.length > 0)? text.length: text.length;
    NSString *subString = [[NSString alloc] init];
    if(resultedText.length > (position + aux)) {
        subString = [resultedText substringToIndex:(position + aux)];
    }
    else {
        subString = resultedText;
    }
    NSArray *wordList = [subString componentsSeparatedByString:@" "];
    NSString *lastWord = [wordList objectAtIndex:([wordList count]-1)];
    if(lastWord.length > 0) {
        NSString *firstCharacter = [lastWord substringToIndex:1];
        if(![self isAlphaNumeric:firstCharacter] && ![firstCharacter isEqualToString:@"\n"]) {
            [self filtrateMentionsForWord:[lastWord substringFromIndex:1] withMentionCharacter:firstCharacter];
        }
    }

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
}
/******* TableView Methods END *******/

@end
