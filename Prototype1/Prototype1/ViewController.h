//
//  ViewController.h
//  Prototype1
//
//  Created by Gabriel Candia on 15-12-14.
//  Copyright (c) 2014 Gabriel Candia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextViewWithMentions.h"


@interface ViewController : UIViewController {
    UITextViewWithMentions *textViewWM;
}
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextView *textView2;
@property (strong, nonatomic) IBOutlet UITextView *textView3;


@end

