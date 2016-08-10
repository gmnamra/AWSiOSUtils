# AWSiOSUtils
small utilities for AWSiOSSDK ( v2 )


# S3TransferUtilityTest
Demonstrates how to add Cognito IdentityPool and suspend and resume functionality to AWS S3 Transfer Utility Sample.
It is a modified version of the AWS's S3 Transfer Utility Sample code for use of Amazon S3 PreSigned URL Builder 
to download / upload files in background. 

AWSUtils.{h,m} are the utility functionalities. 
AppDelegate.{h,m}, Constants.{h,m}, FirstViewController.{h,m},SecondViewController.{h,m} replace files in S3 Transfer Utility Sample. 

##How to Use:
1. Build S3 Transfer Utility Sample code and run using your AWS S3 credentials. 
2. Copy the 8 files ( 6 replacing files and 2 new files )
3. Put your S3 and IdentityPool credentials in Constants.m. 
4. Build


###AWS services used

* [Amazon S3](http://aws.amazon.com/s3/)
* [Amazon Cognito Identity](http://aws.amazon.com/cognito/)


###AWS resources
At the AWS GitHub repo, you can check out the [SDK source code](https://github.com/aws/aws-sdk-ios).
For more information, see  [AWS Mobile SDK for iOS Developer Guide](http://docs.aws.amazon.com/mobile/sdkforios/developerguide/).
The [samples](https://github.com/awslabs/aws-sdk-ios-samples) included with the SDK for iOS are standalone projects that are already set up for you. You can also integrate the SDK for iOS with your own existing project.



