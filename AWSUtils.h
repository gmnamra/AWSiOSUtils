//
//  AWSUtils.h
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

typedef void(^ClientResponseBlock)(id results, NSError* error);
typedef void(^CompletionWithError)(NSError* error);
typedef void (^simpleCB)(void);
typedef void (^taskCB)(NSUInteger taskid);

@interface AWSUtils : NSObject

+ (NSMutableDictionary*) allUploadsTaskIdentifiers;
+ (void) onTransferUtilityTask:(taskCB) onATask;
+ (void) resumeTransferUtilityTask:(NSUInteger) taskId :(simpleCB) afterResume;
+ (void) suspendTransferUtilityTask:(NSUInteger) taskId :(simpleCB) afterSuspend;
+ (void) infoForTransferUtilityTask:(NSUInteger) taskId;
+ (void) resumeAll:(NSMutableDictionary*) tasks;
+ (void) printTransferUtilityTasks;
+ (void) resumeAllTransferUtilityTasks:(simpleCB)afterResume;
+ (BOOL) isTaskSuspended:(NSUInteger) taskId;
+ (BOOL) isTaskCompleted:(NSUInteger) taskId;



@end
