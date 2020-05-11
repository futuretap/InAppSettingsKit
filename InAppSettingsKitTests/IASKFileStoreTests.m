//
//  IASKFileStoreTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <XCTest/XCTest.h>
#import "IASKSettingsStoreFile.h"

@interface IASKFileStoreTests : XCTestCase
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
    XCTAssertEqual(fileStore.filePath, @"/Users/Karl", @"FilePath not stored");
}

- (void) testFileStoreCreatesFileOnSynchronize {
    NSString* tempDir = NSTemporaryDirectory();
    NSString* tempFilePath = [tempDir stringByAppendingPathComponent:@"IASKFileStoreTests.settings"];
    
    IASKSettingsStoreFile* fileStore = [[IASKSettingsStoreFile alloc] initWithPath:tempFilePath];
    XCTAssertTrue([fileStore synchronize], @"Failed to save file");
    
    NSFileManager* fm = [NSFileManager new];
    XCTAssertTrue([fm fileExistsAtPath:tempFilePath], @"Failed to create file");
    
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
}

@end
