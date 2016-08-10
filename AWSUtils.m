//
//  AWSUtils.h
//

#import <Foundation/Foundation.h>
#import "AWSUtils.h"

@implementation AWSUtils

+ (void) printTransferUtilityTasks
{
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
        for (AWSS3TransferUtilityUploadTask* ut in [task result])
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL completed = [task isCompleted];
                NSLog(@"************   Id: %lul   Complete:%@ ", [ut taskIdentifier], completed ? @"Yes" : @"No");
                
            });
        }
        return task;
    }];
}


+ (void) onTransferUtilityTask :(taskCB) onInComplete
{
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
        for (AWSS3TransferUtilityUploadTask* ut in [task result])
        {

           dispatch_async(dispatch_get_main_queue(), ^{
            if(![task isCompleted] && onInComplete)
               onInComplete ([ut taskIdentifier]);
           });
        }
        return task;
    }];
}

+ (NSMutableDictionary*) allUploadsTaskIdentifiers
{
    __block NSMutableDictionary *tasks = [NSMutableDictionary new];
    taskCB onTask = ^(NSUInteger taskid){
        [tasks setObject:@"TaskId" forKey:[NSString stringWithFormat:@"%lu", taskid]];
    };
    [AWSUtils onTransferUtilityTask: onTask];
    return tasks;
}



+ (void) resumeTransferUtilityTask:(NSUInteger) taskId :(simpleCB)afterResume
{

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
    for (AWSS3TransferUtilityUploadTask* ut in [task result])
    {
        if (taskId == [ut taskIdentifier])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ut resume];
                if (afterResume)
                    afterResume();
            });
        }
    }
    return task;
    }];
}


+ (void) suspendTransferUtilityTask:(NSUInteger) taskId :(simpleCB)afterSuspend
{
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
        for (AWSS3TransferUtilityUploadTask* ut in [task result])
        {
            if (taskId == [ut taskIdentifier])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ut suspend];
                    if (afterSuspend)
                        afterSuspend();
                });
            }
        }
        return task;
    }];
}


+ (void) infoForTransferUtilityTask:(NSUInteger) taskId
{
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
        for (AWSS3TransferUtilityUploadTask* ut in [task result])
        {
            BOOL completed = [task isCompleted];
            if (taskId == [ut taskIdentifier])
            {
                NSLog(@"Id: %lul   Complete:%@ ", taskId, completed ? @"Yes" : @"No");
            }
        }
        return task;
    }];
}

+ (void) resumeAll:(NSMutableDictionary*) tasks
{
    NSArray* values = tasks.allValues;
    for (NSString *vstr in values)
    {
        NSNumber *number = [NSNumber numberWithLongLong: vstr.longLongValue];
        NSUInteger value = number.unsignedIntegerValue;
        [AWSUtils resumeTransferUtilityTask:value :nil];
    }
}



+ (void) resumeAllTransferUtilityTasks:(simpleCB)afterResume
{
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility getUploadTasks] continueWithBlock:^id _Nullable(AWSTask<NSArray<AWSS3TransferUtilityUploadTask *> *> * _Nonnull task) {
        for (AWSS3TransferUtilityUploadTask* ut in [task result])
        {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(![task isCompleted])
                    {
                        [ut resume];
                        if (afterResume)
                            afterResume();
                    }
                });
        }
        return task;
    }];
}




@end