//
//  MusicWasmObjCTests.m
//  WasmHost
//
//  Created by L7Studio on 12/2/25.
//

#import "MusicWasmObjCTests.h"
@import AsyncWasmObjC;
@import MusicWasmProtobuf;
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
    XCTestExpectation *getConfigureExpectation = [self expectationWithDescription:@"get version"];
    [self->_sut performSelector:@selector(versionWithCompletionHandler:)
                           args: @[]
                          clazz:EngineVersion.class
              completionHandler:^(EngineVersion* _Nullable version, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(version);
        [getConfigureExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}
-(void)setMusicOptions {
    MusicOptions *opts = [[MusicOptions alloc] init];
    opts.provider = @"youtube";
    self->_sut.copts = @{@"music": [opts data]};
}

-(void)testSearch {
    [self setMusicOptions];
    XCTestExpectation *exp = [self expectationWithDescription:@"search with keyword"];
    NSArray *args = [NSArray arrayWithObjects:@"i known", @"all", @"", nil];
    [self->_sut performSelector:@selector(searchWithKeyword:scope:continuation:completionHandler:)
                           args: args
                          clazz:MusicListTracks.class
              completionHandler:^(MusicListTracks* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.itemsArray.count, 0);
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
                           args: args
                          clazz:MusicListSuggestions.class
              completionHandler:^(MusicListSuggestions* _Nullable ret, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ret);
        XCTAssertNotEqual(ret.suggestionsArray.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        
    }];
}
@end
