//
//  UITextViewWithMentions.h
//  Prototype1
//
//  Created by Gabriel Candia on 15-12-14.
//  Copyright (c) 2014 Gabriel Candia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextViewWithMentions : UITextView <UITextViewDelegate, UITableViewDataSource,
            UITableViewDelegate>{
                NSMutableDictionary *mentionsDictionaries;
                UITableView *tableV;
                UIView *accessoryView;
                NSArray *tableViewObjects;
}

@property (nonatomic, retain) NSMutableDictionary *mentionsDictionaries;
@property (nonatomic, retain) NSArray *tableViewObjects;
@property (nonatomic, retain) UIView *accessoryView;

- (void)addMentionListWith: (NSArray *)mentionList forCharacter: (NSString *)character;
- (void)filtrateMentionsForWord: (NSString *)word withMentionCharacter: (NSString *)character;
- (void)configureInputAccessoryView;
- (BOOL) isAlphaNumeric: (NSString *)string;

@end
