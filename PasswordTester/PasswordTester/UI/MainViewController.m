//
//  ViewController.m
//  PasswordTester
//
//  Created by Quentin Metzler on 21/07/13.
//  Copyright (c) 2013 Quentin Metzler. All rights reserved.
//

#import "MainViewController.h"
#import "PassCalculator.h"

#define kKeyboardAnimationDuration 0.3
#define kNavigationTitle @"Password Tester"
#define kPlaceHolder @"Your password here"

#define kCheckboxImagePath @"checkbox.png"
#define kCheckboxCheckedImagePath @"checkbox-checked.png"
#define kBlackKeyHoleImagePath @"blackKeyHole.jpeg"
#define kKeyImagePath @"key.png"
#define kGreenKeyHoleImagePath @"greenKeyHole.png"
#define kOrangeKeyHoleImagePath @"orangeKeyHole.png"
#define kRedKeyHoleImagePath @"redKeyHole.png"
#define kRedButton @"redButton.png"
#define kOrangeButton @"orangeButton.png"
#define kGreenButton @"greenButton.png"

#define kMinute 60
#define kHour kMinute * 60
#define kDay kHour * 24
#define kMonth kDay * 31
#define kYear kMonth * 120

#define kDangerText @"You are in danger"
#define kBetterText @"You can do better"
#define kSafeText @"You are safe"

#define kSecondText @"It will take ... seconds to crack your password"
#define kMinuteText @"It will take ... minutes to crack your password"
#define kHourText @"It will take ... hours to crack your password"
#define kDayText @"It will take ... days to crack your password"
#define kMonthText @"It will take ... months to crack your password"
#define kYearText @"It will take ... years to crack your password"
#define kCenturyText @"It will take ... centuries to crack your password"
#define kEternityText @"It will take ... eternity to crack your password"

@interface MainViewController ()
@property (nonatomic) Boolean keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) NSString *password;
@property (nonatomic) PassCalculator *passCalculator;
@property (nonatomic) UIColor *scoreColor;
@property (nonatomic) UIImage *scoreImage;
@property (nonatomic) NSArray *smallHoles;
@property (nonatomic) NSArray *middleHoles;
@property (nonatomic) NSArray *bigHoles;

@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UITextField *passwordText;
@property (nonatomic) IBOutlet UIImageView *lockImage;
@property (nonatomic) IBOutlet UIImageView *keyImage;
@property (nonatomic) IBOutlet UIScrollView *hiddenLabel;
@property (nonatomic) IBOutlet UIButton *checkButton;
@property (nonatomic) IBOutlet UILabel *dangerStateLabel;
@property (nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) IBOutlet UIButton *detailReportButton;

@property (nonatomic) IBOutlet UIImageView *smallhole1;
@property (nonatomic) IBOutlet UIImageView *smallHole2;
@property (nonatomic) IBOutlet UIImageView *smallHole3;
@property (nonatomic) IBOutlet UIImageView *smallHole4;
@property (nonatomic) IBOutlet UIImageView *smallHole5;
@property (nonatomic) IBOutlet UIImageView *smallHole6;
@property (nonatomic) IBOutlet UIImageView *smallHole7;
@property (nonatomic) IBOutlet UIImageView *middleHole1;
@property (nonatomic) IBOutlet UIImageView *middleHole2;
@property (nonatomic) IBOutlet UIImageView *middleHole3;
@property (nonatomic) IBOutlet UIImageView *middleHole4;
@property (nonatomic) IBOutlet UIImageView *middleHole5;
@property (nonatomic) IBOutlet UIImageView *bigHole1;
@property (nonatomic) IBOutlet UIImageView *bigHole2;
@property (nonatomic) IBOutlet UIImageView *bigHole3;
@property (nonatomic) IBOutlet UIImageView *bigHole4;
@property (nonatomic) IBOutlet UIImageView *bigHole5;

@end

@implementation MainViewController

@synthesize keyboardIsShown;

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = kNavigationTitle;
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entropyCalculated:)
                                                 name:kEntropyCalculated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSmallHoles:)
                                                 name:kUpdateSmallHoles
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMiddleHoles:)
                                                 name:kUpdateMiddleHoles
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBigHoles:)
                                                 name:kUpdateBigHoles
                                               object:nil];
    
    [self.checkButton setBackgroundImage:[UIImage imageNamed:kCheckboxImagePath]
                        forState:UIControlStateNormal];
    [self.checkButton setBackgroundImage:[UIImage imageNamed:kCheckboxCheckedImagePath]
                        forState:UIControlStateSelected];
    [self.checkButton addTarget:self action:@selector(toggleCheck:) forControlEvents: UIControlEventTouchUpInside];
    [self.keyImage setImage:[UIImage imageNamed:kKeyImagePath]];

    UITapGestureRecognizer *onKeyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKeyTap)];
    self.keyImage.userInteractionEnabled = YES;
    [self.keyImage addGestureRecognizer:onKeyTap];
    
    UITapGestureRecognizer *onViewTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:onViewTap];
    
    self.passwordText.secureTextEntry = self.checkButton.state == UIControlStateSelected;
    keyboardIsShown = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.passwordText resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kEntropyCalculated
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.passCalculator = [PassCalculator sharedInstance];
    [self.passwordText setPlaceholder:kPlaceHolder];
    self.smallHoles = [[NSArray alloc] initWithObjects:self.smallhole1, self.smallHole2, self.smallHole3, self.smallHole4, self.smallHole5, self.smallHole6, self.smallHole7, nil];
    self.middleHoles = [[NSArray alloc] initWithObjects:self.middleHole1, self.middleHole2, self.middleHole3, self.middleHole4, self.middleHole5, nil];
    self.bigHoles = [[NSArray alloc] initWithObjects:self.bigHole1, self.bigHole2, self.bigHole3, self.bigHole4, self.bigHole5, nil];
}

#pragma mark keyboardHandler

- (void)keyboardWillHide:(NSNotification *)n
{
    // resize the scrollView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += self.keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0)
                                                  animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }

    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    self.keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the scrollView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= self.keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
    
    [self.scrollView scrollRectToVisible:self.passwordText.frame animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard
{
    [self.passwordText resignFirstResponder];
}

#pragma mark onTouchEvent

- (void)onKeyTap
{
    [self performSegueWithIdentifier:@"InfoViewControllerSegue" sender:self];
}

- (IBAction)onDetailTouchDown:(id)sender
{
    [self performSegueWithIdentifier:@"DetailViewControllerSegue" sender:self];
}

- (IBAction)onTextTyped:(id)sender
{
    self.password = ((UITextField *)sender).text;
    [[NSNotificationCenter defaultCenter] postNotificationName:kPasswordChangedNotif object:self.password];
}

- (void)toggleCheck:(id)sender
{
    self.passwordText.secureTextEntry = !self.passwordText.secureTextEntry;
    [self.checkButton setSelected:self.passwordText.secureTextEntry];
}

#pragma mark onTextEdit

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = self.password;
}

#pragma mark entropy

- (void)entropyCalculated:(NSNotification *)n
{
    NSNumber *seconds = [n.userInfo objectForKey:@"seconds"];
    if ([self.password isEqualToString:@""])
    {
        [self clearAll];
        return;
    }
    [self scoreToCrack:seconds];
    [self displayTimeToCrack:seconds];
    [self showAll];
}

- (void)scoreToCrack:(NSNumber *)seconds
{
    if ([seconds longLongValue] < 0)
    {
        if (![self.scoreColor isEqual:[UIColor greenColor]])
        {
            self.scoreColor = [UIColor greenColor];
            self.scoreImage = [UIImage imageNamed:kGreenKeyHoleImagePath];
            [self updateAllHolesColor];
        }
        return;
    }
    else if ([seconds longLongValue] < pow(10, 4))
    {
        if (![self.scoreColor isEqual:[UIColor redColor]])
        {
            self.scoreColor = [UIColor redColor];
            self.scoreImage = [UIImage imageNamed:kRedKeyHoleImagePath];
            [self updateAllHolesColor];
        }
        return;
    }
    else if ([seconds longLongValue] < pow(10, 8))
    {
        if (![self.scoreColor isEqual:[UIColor orangeColor]])
        {
            self.scoreColor = [UIColor orangeColor];
            self.scoreImage = [UIImage imageNamed:kOrangeKeyHoleImagePath];
            [self updateAllHolesColor];
        }
        return;
    }
    
    if (![self.scoreColor isEqual:[UIColor greenColor]])
    {
        self.scoreColor = [UIColor greenColor];
        self.scoreImage = [UIImage imageNamed:kGreenKeyHoleImagePath];
        [self updateAllHolesColor];
    }
}

- (void)displayTimeToCrack:(NSNumber *)seconds
{
    if ([seconds longLongValue] < 0)
    {
        // eternity
        [self.timeLabel setText:kEternityText];
    }
    else if ([seconds longLongValue] < kMinute)
    {
        // seconds
        [self.timeLabel setText:kSecondText];
    }
    else if ([seconds longLongValue] < kHour)
    {
        // minutes
        [self.timeLabel setText:kMinuteText];
    }
    else if ([seconds longLongValue] < kDay)
    {
        // hours
        [self.timeLabel setText:kHourText];
    }
    else if ([seconds longLongValue] < kMonth)
    {
        // days
        [self.timeLabel setText:kDayText];
    }
    else if ([seconds longLongValue] < kYear)
    {
        // months
        [self.timeLabel setText:kMonthText];
    }
    else if ([seconds longLongValue] < kYear * 100)
    {
        // years
        [self.timeLabel setText:kYearText];
    }
    else
    {
        // centuries
        [self.timeLabel setText:kCenturyText];
    }
}

- (void)showAll
{
    [self.detailReportButton setHidden:NO];
    [self.dangerStateLabel setHidden:NO];
    [self.timeLabel setHidden:NO];
    
    if ([self.scoreColor isEqual:[UIColor redColor]])
    {
        [self.dangerStateLabel setText:kDangerText];
        [self.detailReportButton setBackgroundImage:[UIImage imageNamed:kRedButton] forState:UIControlStateNormal];
        [self.lockImage setImage:[UIImage imageNamed:kRedKeyHoleImagePath]];
    }
    else if ([self.scoreColor isEqual:[UIColor orangeColor]])
    {
        [self.dangerStateLabel setText:kBetterText];
        [self.detailReportButton setBackgroundImage:[UIImage imageNamed:kOrangeButton] forState:UIControlStateNormal];
        [self.lockImage setImage:[UIImage imageNamed:kOrangeKeyHoleImagePath]];
    }
    else
    {
        [self.dangerStateLabel setText:kSafeText];
        [self.detailReportButton setBackgroundImage:[UIImage imageNamed:kGreenButton] forState:UIControlStateNormal];
        [self.lockImage setImage:[UIImage imageNamed:kGreenKeyHoleImagePath]];
    }
    
    self.dangerStateLabel.textColor = self.scoreColor;
    self.timeLabel.textColor = self.scoreColor;
}

- (void)clearAll
{
    [self.detailReportButton setHidden:YES];
    [self.dangerStateLabel setHidden:YES];
    [self.timeLabel setHidden:YES];
    [self.lockImage setImage:[UIImage imageNamed:kBlackKeyHoleImagePath]];
    for (UIImageView *imageView in self.smallHoles)
    {
        [imageView setHidden:YES];
    }
    for (UIImageView *imageView in self.middleHoles)
    {
        [imageView setHidden:YES];
    }
    for (UIImageView *imageView in self.bigHoles)
    {
        [imageView setHidden:YES];
    }
}

- (void)updateAllHolesColor
{
    for (UIImageView *imageView in self.smallHoles)
    {
        [imageView setImage:self.scoreImage];
    }
    for (UIImageView *imageView in self.middleHoles)
    {
        [imageView setImage:self.scoreImage];
    }
    for (UIImageView *imageView in self.bigHoles)
    {
        [imageView setImage:self.scoreImage];
    }
}

- (void)updateSmallHoles:(NSNotification *)n
{
    [self updateHolesWithArray:self.smallHoles andNumber:self.passCalculator.lowerCase];
}

- (void)updateMiddleHoles:(NSNotification *)n
{
    [self updateHolesWithArray:self.middleHoles andNumber:self.passCalculator.upperCase];
}

- (void)updateBigHoles:(NSNotification *)n
{
    [self updateHolesWithArray:self.bigHoles andNumber:self.passCalculator.symbol];
}

- (void)updateHolesWithArray:(NSArray *)holes andNumber:(NSInteger)nbrSymbol
{
    int i = 0;
    for (i = 0; i < nbrSymbol && i < [holes count]; i++)
    {
        UIImageView *imView = holes[i];
        [imView setHidden:NO];
    }
    for (; i < [holes count]; i++)
    {
        UIImageView *imView = holes[i];
        [imView setHidden:YES];
    }
}

@end
