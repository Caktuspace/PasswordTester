//
//  DetailViewController.m
//  PasswordTester
//
//  Created by Quentin Metzler on 21/07/13.
//  Copyright (c) 2013 Quentin Metzler. All rights reserved.
//

#import "DetailViewController.h"
#import "PassCalculator.h"

#define kGreenCheckPath @"greenCheck.jpg"
#define kRedCrossPath @"redCross.jpg"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *lowerImage;
@property (strong, nonatomic) IBOutlet UIImageView *upperImage;
@property (strong, nonatomic) IBOutlet UIImageView *numberImage;
@property (strong, nonatomic) IBOutlet UIImageView *symbolImage;
@property (strong, nonatomic) IBOutlet UIImageView *spaceImage;
@property (strong, nonatomic) IBOutlet UIImageView *lengthImage;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    PassCalculator *passCalculator = [PassCalculator sharedInstance];
    
    passCalculator.lowerCase > 0 ? [self.lowerImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.lowerImage setImage:[UIImage imageNamed:kRedCrossPath]];
    passCalculator.upperCase > 0 ? [self.upperImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.upperImage setImage:[UIImage imageNamed:kRedCrossPath]];
    passCalculator.number > 0 ? [self.numberImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.numberImage setImage:[UIImage imageNamed:kRedCrossPath]];
    passCalculator.symbol > 0 ? [self.symbolImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.symbolImage setImage:[UIImage imageNamed:kRedCrossPath]];
    passCalculator.space == 0 ? [self.spaceImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.spaceImage setImage:[UIImage imageNamed:kRedCrossPath]];
    passCalculator.length > 6 ? [self.lengthImage setImage:[UIImage imageNamed:kGreenCheckPath]] : [self.lengthImage setImage:[UIImage imageNamed:kRedCrossPath]];
}

@end
