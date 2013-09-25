//
//  IASKFileStoreTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "IASKSettingsStoreFile.h"

@interface IASKFileStoreTests : SenTestCase
@end


@implementation IASKFileStoreTests
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

-(void)testFileStoreStoresPath {
    IASKSettingsStoreFile* fileStore = [[IASKSettingsStoreFile alloc] initWithPath:@"/Users/Karl"];
    STAssertEquals(fileStore.filePath, @"/Users/Karl", @"FilePath not stored");
}

- (void) testFileStoreCreatesFileOnSynchronize {
    NSString* tempDir = NSTemporaryDirectory();
    NSString* tempFilePath = [tempDir stringByAppendingPathComponent:@"IASKFileStoreTests.settings"];
    
    IASKSettingsStoreFile* fileStore = [[IASKSettingsStoreFile alloc] initWithPath:tempFilePath];
    STAssertTrue([fileStore synchronize], @"Failed to save file");
    
    NSFileManager* fm = [NSFileManager new];
    STAssertTrue([fm fileExistsAtPath:tempFilePath], @"Failed to create file");
    
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
}

@end
