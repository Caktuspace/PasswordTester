//
//  PassCalculator.h
//  PasswordTester
//
//  Created by Quentin Metzler on 21/07/13.
//  Copyright (c) 2013 Quentin Metzler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPasswordChangedNotif @"com.quentinator.passwordChangedNotif"
#define kEntropyCalculated @"com.quentinator.entropyCalculated"
#define kUpdateSmallHoles @"com.quentinator.updateSmallHoles"
#define kUpdateMiddleHoles @"com.quentinator.updateMiddleHoles"
#define kUpdateBigHoles @"com.quentinator.updateBigHoles"

@interface PassCalculator : NSObject

@property (nonatomic) NSInteger number;
@property (nonatomic) NSInteger lowerCase;
@property (nonatomic) NSInteger upperCase;
@property (nonatomic) NSInteger symbol;
@property (nonatomic) NSInteger space;
@property (nonatomic) NSInteger length;

+ (id)sharedInstance;

@end
