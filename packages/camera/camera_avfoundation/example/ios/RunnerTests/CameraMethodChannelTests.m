// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface CameraMethodChannelTests : XCTestCase
@end

@implementation CameraMethodChannelTests

- (void)testCreate_ShouldCallResultOnMainThread {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];

  __block id resultValue;
  [camera createCameraOnSessionQueueWithCreateMethodCall:call
                                                  result:^(id _Nullable result) {
                                                    resultValue = result;
                                                    [expectation fulfill];
                                                  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultValue;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
