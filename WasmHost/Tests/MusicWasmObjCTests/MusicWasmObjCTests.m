//
//  MusicWasmObjCTests.m
//  WasmHost
//
//  Created by L7Studio on 12/2/25.
//

#import "MusicWasmObjCTests.h"
@import AsyncWasmObjC;
@import WasmObjCProtobuf;
@import MusicWasm;
@implementation MusicWasmObjCTests {
    AsyncWasmEngine *_sut;
}
- (void)setUp {
    [super setUp];
    NSURL *file = [SWIFTPM_MODULE_BUNDLE URLForResource:@"music" withExtension:@"wasm"];
    NSError * error = nil;
    self->_sut = [[MusicWasmEngine alloc] initWithFile:file error:&error];

}

-(void)testGetVersion {
    [self waitForEngineStarted];
    XCTestExpectation *exp = [self expectationWithDescription:@"get version"];
    [self->_sut performSelector:@selector(versionWithCompletionHandler:)
                           args: @[]
                          clazz:WAEngineVersion.class
              completionHandler:^(WAEngineVersion* _Nullable version, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(version);
        NSLog(@"found version: %@", [version debugDescription]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}
-(void)waitForEngineStarted {
    XCTestExpectation *exp = [self expectationWithDescription:@"success start"];
    [self->_sut startWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:60];
}
-(void)setMusicOptions {
    [self waitForEngineStarted];
    WAMusicOptions *opts = [[WAMusicOptions alloc] init];
    opts.provider = @"youtube";
    self->_sut.copts = @{@"music": [opts data]};
}

-(void)testSearch {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"search with keyword"];
  
    NSArray *args = [NSArray arrayWithObjects:@"i known", @"all", @"", nil];
    [self->_sut performSelector:@selector(searchWithKeyword:scope:continuation:completionHandler:)
                           args:args
                          clazz:WAMusicListTracks.class
              completionHandler:^(WAMusicListTracks* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.itemsArray.count, 0);
        NSLog(@"found %lu results", (unsigned long)ret.itemsArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        
    }];
}
-(void)testSuggestion {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"suggestion with query"];
    NSArray *args = [NSArray arrayWithObjects:@"i known", nil];
    [self->_sut performSelector:@selector(suggestionWithKeyword:completionHandler:)
                           args:args
                          clazz:WAMusicListSuggestions.class
              completionHandler:^(WAMusicListSuggestions* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.suggestionsArray.count, 0);
        NSLog(@"found %lu suggestions", (unsigned long)ret.suggestionsArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        
    }];
}
-(void)testGetTrending {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"get discover"];
    NSArray *args = [NSArray arrayWithObjects:@"1", @"", nil];
    [self->_sut performSelector:@selector(getDiscoverWithCategory:continuation:completionHandler:)
                           args:args
                          clazz:WAMusicListTracks.class
              completionHandler:^(WAMusicListTracks* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.itemsArray.count, 0);
        NSLog(@"found %lu tracks", (unsigned long)ret.itemsArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        
    }];
}
-(void)testGetMusicOptions {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"get music options"];
    [self->_sut performSelector:@selector(optionsWithCompletionHandler:)
                           args:@[]
                          clazz:WAMusicListOptions.class
              completionHandler:^(WAMusicListOptions* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.providersArray_Count, 0);
        NSLog(@"found %lu provider", (unsigned long)ret.providersArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:200 handler:^(NSError *error) {
        
    }];
}
-(void)testGetDetails {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"get details track"];
    NSArray *args = [NSArray arrayWithObjects:@"kPa7bsKwL-c", nil];
    [self->_sut performSelector:@selector(detailsWithVideoId:completionHandler:)
                           args:args
                          clazz:WAMusicTrackDetails.class
              completionHandler:^(WAMusicTrackDetails* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssert([ret.id_p isEqualToString:@"kPa7bsKwL-c"]);
        XCTAssertNotEqual(ret.formatsArray.count, 0);
        NSLog(@"found %lu formats", (unsigned long)ret.formatsArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:200 handler:^(NSError *error) {
        
    }];
}
-(void)testGetMixPlaylistDetails {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"get mixed playlist"];
    NSArray *args = [NSArray arrayWithObjects:@"RDEMp7_432lokhimq4eaoILwZA", @"", nil];
    [self->_sut performSelector:@selector(trackWithPlaylistId:continuation:completionHandler:)
                           args:args
                          clazz:WAMusicListTracks.class
              completionHandler:^(WAMusicListTracks* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.itemsArray.count, 0);
        NSLog(@"found %lu tracks", (unsigned long)ret.itemsArray_Count);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:200 handler:^(NSError *error) {
        
    }];
}
@end
