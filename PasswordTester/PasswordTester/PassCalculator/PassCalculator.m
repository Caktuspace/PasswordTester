//
//  PassCalculator.m
//  PasswordTester
//
//  Created by Quentin Metzler on 21/07/13.
//  Copyright (c) 2013 Quentin Metzler. All rights reserved.
//

#import "PassCalculator.h"

#define kSingleGuess 0.010
#define kNumAttackers 100
#define kSecondPerGuess kSingleGuess / kNumAttackers


@interface PassCalculator ()
@property (nonatomic) NSString *currentPassword;
@end

@implementation PassCalculator
@synthesize currentPassword, number, lowerCase, upperCase, symbol, space, length;

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    
    if (self != NULL)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordChanged:) name:kPasswordChangedNotif object:nil];
        [self resetCalcul];
    }
    
    return self;
}

- (void)destroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPasswordChangedNotif object:nil];
}

- (void)resetCalcul
{
    self.currentPassword = @"";
    self.number = 0;
    self.lowerCase = 0;
    self.upperCase = 0;
    self.symbol = 0;
    self.space = 0;
}

- (void)passwordChanged:(NSNotification *)notification
{
    NSString *newPassword = [notification object];
    if ([newPassword isEqualToString:@""])
    {
        [self resetCalcul];
    }
    else
    {
        if ([newPassword length] < [self.currentPassword length])
        {
            [self updateCountWithCharacter:[self.currentPassword characterAtIndex:[self.currentPassword length] - 1] andOperation:-1];
        }
        else
        {
            [self updateCountWithCharacter:[newPassword characterAtIndex:[newPassword length] - 1] andOperation:1];
        }
        self.currentPassword = newPassword;
    }
    self.length = [self.currentPassword length];
    [self calculEntropy];
}

- (void)updateCountWithCharacter:(char)character andOperation:(NSInteger)op
{
    if (islower(character))
    {
        self.lowerCase += op;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSmallHoles object:self];
    }
    else if (isupper(character))
    {
        self.upperCase += op;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMiddleHoles object:self];
    }
    else if (isnumber(character))
    {
        self.number += op;
    }
    else if (isspace(character))
    {
        self.space += op;
    }
    else
    {
        self.symbol += op;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateBigHoles object:self];
    }
}

- (void)calculEntropy
{
    NSNumber *entropy;
    NSInteger penality = 0;
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSInteger numberPossibleSymbol = 0;
    
    numberPossibleSymbol += self.lowerCase > 0 ? 26 : 0;
    penality += self.lowerCase > 0 ? 0 : 10;
    numberPossibleSymbol += self.upperCase > 0 ? 26 : 0;
    penality += self.upperCase > 0 ? 0 : 10;
    numberPossibleSymbol += self.number > 0 ? 10 : 0;
    penality += self.number > 0 ? 0 : 8;
    numberPossibleSymbol += self.symbol > 0 ? 35 : 0;
    penality += self.symbol > 0 ? 0 : 10;
    penality += self.length > 6 ? 0 : 10;
    entropy = [NSNumber numberWithDouble:[self.currentPassword length] * log2(numberPossibleSymbol) - penality];
    [userInfo setObject:[self secondWithEntropy:entropy] forKey:@"seconds"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEntropyCalculated object:self userInfo:userInfo];
}

- (NSNumber *)secondWithEntropy:(NSNumber *)entropy
{
    return [NSNumber numberWithLongLong:0.5 * pow(2, [entropy doubleValue]) * kSecondPerGuess];
}

@end
