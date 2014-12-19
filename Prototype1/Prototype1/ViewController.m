//
//  ViewController.m
//  Prototype1
//
//  Created by Gabriel Candia on 15-12-14.
//  Copyright (c) 2014 Gabriel Candia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    textViewWM = [[UITextViewWithMentions alloc] init];
    [textViewWM addMentionListWith:[NSMutableArray arrayWithObjects:@"Mark", @"Matt", @"Matthew",@"John",@"Marcus",@"Michael",@"Robert", nil] forCharacter:@"@"];
    [textViewWM addMentionListWith:[NSMutableArray arrayWithObjects:@"Marcela",@"Daniela",@"Macarena",@"Dorothy", nil] forCharacter:@"&"];
    [textViewWM configureClassForTextView:self.textView withSuperView:self.view];
    [textViewWM configureClassForTextView:self.textView2 withSuperView:self.view];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
