//
//  UITextViewWithMentions.h
//  Prototype1
//
//  Created by Gabriel Candia on 15-12-14.
//  Copyright (c) 2014 Gabriel Candia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UITextViewWithMentions : NSObject <UITextViewDelegate, UITableViewDataSource,
            UITableViewDelegate>{
                NSMutableDictionary *mentionsDictionaries;
                UITableView *tableV;
                UIView *accessoryView;
                NSMutableArray *tableViewObjects;
                UITextView *auxTextView;
                UIView *superView;
                NSString *characterString;
                CGSize keyboardSize;
                CGRect originalTextViewRect;
}

@property (nonatomic, retain) NSMutableDictionary *mentionsDictionaries;
@property (nonatomic, retain) NSMutableArray *tableViewObjects;
@property (nonatomic, retain) UIView *accessoryView;

- (void)configureClassForTextView: (UITextView *)textView withSuperView: (UIView *)view;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)addMentionListWith: (NSMutableArray *)mentionList forCharacter: (NSString *)character;
- (void)filtrateMentionsForTextView:(UITextView *)textView withWord:(NSString *)word withMentionCharacter: (NSString *)character;
- (void)configureInputAccessoryView;
- (BOOL) isAlphaNumeric: (NSString *)string;
- (void)getRectForInputViewWithThisEntries: (NSInteger)count forTextView: (UITextView *)textView;
@end
