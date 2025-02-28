// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// clang-format off
// source: engine.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30007
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30007 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

#import <stdatomic.h>

#import "Engine.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#pragma mark - Objective-C Class declarations
// Forward declarations of Objective-C classes that we can use as
// static values in struct initializers.
// We don't use [Foo class] because it is not a static value.
GPBObjCClassDeclaration(EngineError);
GPBObjCClassDeclaration(EngineVersion);
GPBObjCClassDeclaration(EngineVoid);

#pragma mark - EngineRoot

@implementation EngineRoot

// No extensions in the file and no imports or none of the imports (direct or
// indirect) defined extensions, so no need to generate +extensionRegistry.

@end

static GPBFileDescription EngineRoot_FileDescription = {
  .package = "asyncify.engine",
  .prefix = "Engine",
  .syntax = GPBFileSyntaxProto3
};

#pragma mark - Enum EngineCallID

GPBEnumDescriptor *EngineCallID_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    static const char *valueNames =
        "CallIdUnspecified\000CallIdGetVersion\000CallI"
        "dInitialize\000";
    static const int32_t values[] = {
        EngineCallID_CallIdUnspecified,
        EngineCallID_CallIdGetVersion,
        EngineCallID_CallIdInitialize,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(EngineCallID)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:EngineCallID_IsValidValue
                                            flags:GPBEnumDescriptorInitializationFlag_None];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL EngineCallID_IsValidValue(int32_t value__) {
  switch (value__) {
    case EngineCallID_CallIdUnspecified:
    case EngineCallID_CallIdGetVersion:
    case EngineCallID_CallIdInitialize:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - EngineVersion

@implementation EngineVersion

@dynamic id_p;
@dynamic name;
@dynamic hasEtag, etag;
@dynamic hasSha, sha;
@dynamic hasURL, URL;
@dynamic hasNext, next;
@dynamic hasReleaseDate, releaseDate;

typedef struct EngineVersion__storage_ {
  uint32_t _has_storage_[1];
  NSString *id_p;
  NSString *name;
  NSString *etag;
  NSString *sha;
  NSString *URL;
  EngineVersion *next;
  NSString *releaseDate;
} EngineVersion__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, id_p),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "name",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_Name,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, name),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "etag",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_Etag,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, etag),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sha",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_Sha,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, sha),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "URL",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_URL,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, URL),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "next",
        .dataTypeSpecific.clazz = GPBObjCClass(EngineVersion),
        .number = EngineVersion_FieldNumber_Next,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, next),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "releaseDate",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineVersion_FieldNumber_ReleaseDate,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(EngineVersion__storage_, releaseDate),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:GPBObjCClass(EngineVersion)
                                   messageName:@"Version"
                               fileDescription:&EngineRoot_FileDescription
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(EngineVersion__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown | GPBDescriptorInitializationFlag_ClosedEnumSupportKnown)];
    #if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
      static const char *extraTextFormatInfo =
        "\001\005!!!\000";
      [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
    #endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - EngineVoid

@implementation EngineVoid


typedef struct EngineVoid__storage_ {
  uint32_t _has_storage_[1];
} EngineVoid__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:GPBObjCClass(EngineVoid)
                                   messageName:@"Void"
                               fileDescription:&EngineRoot_FileDescription
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(EngineVoid__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown | GPBDescriptorInitializationFlag_ClosedEnumSupportKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - EngineError

@implementation EngineError

@dynamic code;
@dynamic reason;

typedef struct EngineError__storage_ {
  uint32_t _has_storage_[1];
  int32_t code;
  NSString *reason;
} EngineError__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "code",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineError_FieldNumber_Code,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(EngineError__storage_, code),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "reason",
        .dataTypeSpecific.clazz = Nil,
        .number = EngineError_FieldNumber_Reason,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(EngineError__storage_, reason),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:GPBObjCClass(EngineError)
                                   messageName:@"Error"
                               fileDescription:&EngineRoot_FileDescription
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(EngineError__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown | GPBDescriptorInitializationFlag_ClosedEnumSupportKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

// clang-format on
