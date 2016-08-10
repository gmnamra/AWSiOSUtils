/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "FirstViewController.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "AWSUtils.h"

@interface FirstViewController ()
{
    int32_t m_state;
    NSUInteger  m_taskId;
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;

@property (copy, nonatomic) AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler;
@property (copy, nonatomic) AWSS3TransferUtilityProgressBlock progressBlock;
@property (copy, nonatomic) UIImage* testImage;
@property (copy, nonatomic) NSMutableData* testData;
@property (weak, nonatomic) AWSTask* awsTask;
@property (nonatomic, strong) NSString* bucketName;
@property (nonatomic) float progressFraction;
@property (nonatomic) NSInteger taskStatus;
@property (nonatomic) NSUInteger taskId;

@property (copy, nonatomic) simpleCB markSuspend;
@property (copy, nonatomic) simpleCB markResume;


@end

NSUInteger currentUploader;
AWSS3TransferUtilityUploadTask* currentUploadTask;

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   // [_controlButton setTitle:@" Suspend " forState:UIControlStateNormal];

    self.taskStatus = -1;
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSURL* url = [NSBundle URLForResource:@"Untitled"
                        withExtension:@"jpg"
                        subdirectory:nil
                        inBundleWithURL:[bundle bundleURL]];
                        
    self.testImage = [UIImage imageWithContentsOfFile:[url relativePath]];
    UIImage *scaledImage = [UIImage imageWithCGImage:[self.testImage CGImage]
                        scale:(self.testImage.scale * 0.1)
                  orientation:(self.testImage.imageOrientation)];
    
    self.testImage = scaledImage;
    
    self.progressView.progress = 0;
    self.statusLabel.text = @"Ready";
    currentUploader = 0;
    
    __weak FirstViewController *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf postReminder];
            if (error) {
                weakSelf.statusLabel.text = @"Failed to Upload";
            } else {
                weakSelf.statusLabel.text = @"Successfully Uploaded";
                weakSelf.progressView.progress = 1.0;
                weakSelf.taskStatus = -1;
              
            }
        });
    };

    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress.fractionCompleted;
        });
    };
    
    self.markResume = ^{
        weakSelf.taskStatus = 1;
        [[weakSelf controlButton] setTitle:@" Suspend " forState:UIControlStateSelected];
        [weakSelf statusLabel].text = @"Suspend";
    };
    
    self.markSuspend = ^{
        weakSelf.taskStatus = 0;
        [[weakSelf controlButton] setTitle:@" Resume " forState:UIControlStateSelected];
        [weakSelf statusLabel].text = @"Resume";
    };
    

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask * _Nonnull uploadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable uploadProgressBlockReference, AWSS3TransferUtilityUploadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        currentUploader = (unsigned long)uploadTask.taskIdentifier;
        currentUploadTask = uploadTask;
        
        NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);
        
        *uploadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.completionHandler;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Uploading...";
        });
    } downloadTask:nil];
}

- (IBAction)start:(id)sender {
   
    if ([self taskStatus] < 0) // start
    {
        self.statusLabel.text = @"Creating a test file...";
        _testData = [NSMutableData dataWithLength:1000000];
       [self uploadData:_testData];
    }
}


- (IBAction)suspend:(id)sender {

   __weak FirstViewController *weakSelf = self;
    
    switch (self.taskStatus)
    {
        case 0:
        {
            [AWSUtils resumeTransferUtilityTask:_taskId :[weakSelf markResume]];
            break;
        }
        case 1:
        {
            [AWSUtils suspendTransferUtilityTask:_taskId :[weakSelf markSuspend]];
            break;
        }
    }
}

- (void)uploadData:(NSData *)testData {
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = self.progressBlock;
    [expression setValue:@"AES256" forRequestHeader:@"x-amz-server-side-encryption"];
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility uploadData:testData
                          bucket:S3BucketName
                             key:S3UploadKeyName
                     contentType:@"image/jpeg"
                      expression:expression
                completionHander:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
        }
        if (task.result ) {
            
            self.taskId = [[task result] taskIdentifier];
            self.taskStatus  = 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%d", self.taskStatus);
                self.statusLabel.text = @"Uploading...";
            });
        }

        return nil;
    }];
}

@end
