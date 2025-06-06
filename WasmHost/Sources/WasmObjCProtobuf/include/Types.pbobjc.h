// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// clang-format off
// source: types.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30007
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30007 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class WATypesBytes;
@class WATypesFormat;
@class WATypesFormat_Audio;
@class WATypesFormat_Image;
@class WATypesFormat_Video;
@class WATypesPoint;
@class WATypesPointer;
@class WATypesSize;
@class WATypesValidator;
@class WATypesValidator_Double;
@class WATypesValidator_Int;
@class WATypesValidator_Media;
@class WATypesValidator_String;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - WATypesTypesRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
GPB_FINAL @interface WATypesTypesRoot : GPBRootObject
@end

#pragma mark - WATypesImage

typedef GPB_ENUM(WATypesImage_FieldNumber) {
  WATypesImage_FieldNumber_Id_p = 1,
  WATypesImage_FieldNumber_URL = 2,
  WATypesImage_FieldNumber_Data_p = 3,
  WATypesImage_FieldNumber_Metadata = 4,
};

GPB_FINAL @interface WATypesImage : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;
/** Test to see if @c id_p has been set. */
@property(nonatomic, readwrite) BOOL hasId_p;

@property(nonatomic, readwrite, copy, null_resettable) NSString *URL;
/** Test to see if @c URL has been set. */
@property(nonatomic, readwrite) BOOL hasURL;

/** base64 data */
@property(nonatomic, readwrite, strong, null_resettable) WATypesBytes *data_p;
/** Test to see if @c data_p has been set. */
@property(nonatomic, readwrite) BOOL hasData_p;

/** blur, mime */
@property(nonatomic, readwrite, strong, null_resettable) GPBStruct *metadata;
/** Test to see if @c metadata has been set. */
@property(nonatomic, readwrite) BOOL hasMetadata;

@end

#pragma mark - WATypesBytes

typedef GPB_ENUM(WATypesBytes_FieldNumber) {
  WATypesBytes_FieldNumber_Raw = 1,
  WATypesBytes_FieldNumber_Ptr = 2,
};

typedef GPB_ENUM(WATypesBytes_Data_OneOfCase) {
  WATypesBytes_Data_OneOfCase_GPBUnsetOneOfCase = 0,
  WATypesBytes_Data_OneOfCase_Raw = 1,
  WATypesBytes_Data_OneOfCase_Ptr = 2,
};

GPB_FINAL @interface WATypesBytes : GPBMessage

@property(nonatomic, readonly) WATypesBytes_Data_OneOfCase dataOneOfCase;

@property(nonatomic, readwrite, copy, null_resettable) NSData *raw;

@property(nonatomic, readwrite, strong, null_resettable) WATypesPointer *ptr;

@end

/**
 * Clears whatever value was set for the oneof 'data'.
 **/
void WATypesBytes_ClearDataOneOfCase(WATypesBytes *message);

#pragma mark - WATypesPointer

typedef GPB_ENUM(WATypesPointer_FieldNumber) {
  WATypesPointer_FieldNumber_Ptr = 1,
  WATypesPointer_FieldNumber_Len = 2,
};

GPB_FINAL @interface WATypesPointer : GPBMessage

@property(nonatomic, readwrite) uint32_t ptr;

@property(nonatomic, readwrite) uint32_t len;

@end

#pragma mark - WATypesString

typedef GPB_ENUM(WATypesString_FieldNumber) {
  WATypesString_FieldNumber_Raw = 1,
  WATypesString_FieldNumber_Ptr = 2,
};

typedef GPB_ENUM(WATypesString_Data_OneOfCase) {
  WATypesString_Data_OneOfCase_GPBUnsetOneOfCase = 0,
  WATypesString_Data_OneOfCase_Raw = 1,
  WATypesString_Data_OneOfCase_Ptr = 2,
};

GPB_FINAL @interface WATypesString : GPBMessage

@property(nonatomic, readonly) WATypesString_Data_OneOfCase dataOneOfCase;

@property(nonatomic, readwrite, copy, null_resettable) NSString *raw;

@property(nonatomic, readwrite, strong, null_resettable) WATypesPointer *ptr;

@end

/**
 * Clears whatever value was set for the oneof 'data'.
 **/
void WATypesString_ClearDataOneOfCase(WATypesString *message);

#pragma mark - WATypesVoid

GPB_FINAL @interface WATypesVoid : GPBMessage

@end

#pragma mark - WATypesError

typedef GPB_ENUM(WATypesError_FieldNumber) {
  WATypesError_FieldNumber_Code = 1,
  WATypesError_FieldNumber_Reason = 2,
};

GPB_FINAL @interface WATypesError : GPBMessage

@property(nonatomic, readwrite) int32_t code;

@property(nonatomic, readwrite, copy, null_resettable) NSString *reason;

@end

#pragma mark - WATypesWAFuture

typedef GPB_ENUM(WATypesWAFuture_FieldNumber) {
  WATypesWAFuture_FieldNumber_Data_p = 1,
  WATypesWAFuture_FieldNumber_Len = 2,
  WATypesWAFuture_FieldNumber_Callback = 3,
  WATypesWAFuture_FieldNumber_Context = 4,
  WATypesWAFuture_FieldNumber_ContextLen = 5,
  WATypesWAFuture_FieldNumber_Index = 6,
};

GPB_FINAL @interface WATypesWAFuture : GPBMessage

@property(nonatomic, readwrite) uint32_t data_p;

@property(nonatomic, readwrite) uint32_t len;

@property(nonatomic, readwrite) uint32_t callback;

@property(nonatomic, readwrite) uint32_t context;

@property(nonatomic, readwrite) uint32_t contextLen;

@property(nonatomic, readwrite) uint32_t index;

@end

#pragma mark - WATypesWAString

typedef GPB_ENUM(WATypesWAString_FieldNumber) {
  WATypesWAString_FieldNumber_Ptr = 1,
  WATypesWAString_FieldNumber_Len = 2,
};

GPB_FINAL @interface WATypesWAString : GPBMessage

@property(nonatomic, readwrite) uint32_t ptr;

@property(nonatomic, readwrite) uint32_t len;

@end

#pragma mark - WATypesField

typedef GPB_ENUM(WATypesField_FieldNumber) {
  WATypesField_FieldNumber_Type = 1,
  WATypesField_FieldNumber_Value = 2,
};

GPB_FINAL @interface WATypesField : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *type;

@property(nonatomic, readwrite, copy, null_resettable) NSString *value;

@end

#pragma mark - WATypesEntry

typedef GPB_ENUM(WATypesEntry_FieldNumber) {
  WATypesEntry_FieldNumber_Id_p = 1,
  WATypesEntry_FieldNumber_Name = 2,
  WATypesEntry_FieldNumber_Desc = 3,
};

GPB_FINAL @interface WATypesEntry : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;

@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@property(nonatomic, readwrite, copy, null_resettable) NSString *desc;

@end

#pragma mark - WATypesRect

typedef GPB_ENUM(WATypesRect_FieldNumber) {
  WATypesRect_FieldNumber_Origin = 1,
  WATypesRect_FieldNumber_Size = 2,
};

GPB_FINAL @interface WATypesRect : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) WATypesPoint *origin;
/** Test to see if @c origin has been set. */
@property(nonatomic, readwrite) BOOL hasOrigin;

@property(nonatomic, readwrite, strong, null_resettable) WATypesSize *size;
/** Test to see if @c size has been set. */
@property(nonatomic, readwrite) BOOL hasSize;

@end

#pragma mark - WATypesPoint

typedef GPB_ENUM(WATypesPoint_FieldNumber) {
  WATypesPoint_FieldNumber_X = 1,
  WATypesPoint_FieldNumber_Y = 2,
};

GPB_FINAL @interface WATypesPoint : GPBMessage

@property(nonatomic, readwrite) double x;

@property(nonatomic, readwrite) double y;

@end

#pragma mark - WATypesSize

typedef GPB_ENUM(WATypesSize_FieldNumber) {
  WATypesSize_FieldNumber_Width = 1,
  WATypesSize_FieldNumber_Height = 2,
};

GPB_FINAL @interface WATypesSize : GPBMessage

@property(nonatomic, readwrite) double width;

@property(nonatomic, readwrite) double height;

@end

#pragma mark - WATypesArgument

typedef GPB_ENUM(WATypesArgument_FieldNumber) {
  WATypesArgument_FieldNumber_Name = 1,
  WATypesArgument_FieldNumber_Desc = 2,
  WATypesArgument_FieldNumber_Validator = 3,
};

GPB_FINAL @interface WATypesArgument : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@property(nonatomic, readwrite, copy, null_resettable) NSString *desc;
/** Test to see if @c desc has been set. */
@property(nonatomic, readwrite) BOOL hasDesc;

@property(nonatomic, readwrite, strong, null_resettable) WATypesValidator *validator;
/** Test to see if @c validator has been set. */
@property(nonatomic, readwrite) BOOL hasValidator;

@end

#pragma mark - WATypesValidator

typedef GPB_ENUM(WATypesValidator_FieldNumber) {
  WATypesValidator_FieldNumber_Required = 1,
  WATypesValidator_FieldNumber_Media = 2,
  WATypesValidator_FieldNumber_Int_p = 3,
  WATypesValidator_FieldNumber_Double_p = 4,
  WATypesValidator_FieldNumber_String = 5,
};

typedef GPB_ENUM(WATypesValidator_Data_OneOfCase) {
  WATypesValidator_Data_OneOfCase_GPBUnsetOneOfCase = 0,
  WATypesValidator_Data_OneOfCase_Media = 2,
  WATypesValidator_Data_OneOfCase_Int_p = 3,
  WATypesValidator_Data_OneOfCase_Double_p = 4,
  WATypesValidator_Data_OneOfCase_String = 5,
};

GPB_FINAL @interface WATypesValidator : GPBMessage

@property(nonatomic, readwrite) BOOL required;

@property(nonatomic, readonly) WATypesValidator_Data_OneOfCase dataOneOfCase;

@property(nonatomic, readwrite, strong, null_resettable) WATypesValidator_Media *media;

@property(nonatomic, readwrite, strong, null_resettable) WATypesValidator_Int *int_p;

@property(nonatomic, readwrite, strong, null_resettable) WATypesValidator_Double *double_p;

@property(nonatomic, readwrite, strong, null_resettable) WATypesValidator_String *string;

@end

/**
 * Clears whatever value was set for the oneof 'data'.
 **/
void WATypesValidator_ClearDataOneOfCase(WATypesValidator *message);

#pragma mark - WATypesValidator_Int

typedef GPB_ENUM(WATypesValidator_Int_FieldNumber) {
  WATypesValidator_Int_FieldNumber_Min = 1,
  WATypesValidator_Int_FieldNumber_Max = 2,
  WATypesValidator_Int_FieldNumber_Default_p = 3,
};

GPB_FINAL @interface WATypesValidator_Int : GPBMessage

@property(nonatomic, readwrite) int32_t min;
@property(nonatomic, readwrite) BOOL hasMin;

@property(nonatomic, readwrite) int32_t max;
@property(nonatomic, readwrite) BOOL hasMax;

@property(nonatomic, readwrite) int32_t default_p;
@property(nonatomic, readwrite) BOOL hasDefault_p;

@end

#pragma mark - WATypesValidator_Double

typedef GPB_ENUM(WATypesValidator_Double_FieldNumber) {
  WATypesValidator_Double_FieldNumber_Min = 1,
  WATypesValidator_Double_FieldNumber_Max = 2,
  WATypesValidator_Double_FieldNumber_Default_p = 3,
};

GPB_FINAL @interface WATypesValidator_Double : GPBMessage

@property(nonatomic, readwrite) double min;
@property(nonatomic, readwrite) BOOL hasMin;

@property(nonatomic, readwrite) double max;
@property(nonatomic, readwrite) BOOL hasMax;

@property(nonatomic, readwrite) double default_p;
@property(nonatomic, readwrite) BOOL hasDefault_p;

@end

#pragma mark - WATypesValidator_String

typedef GPB_ENUM(WATypesValidator_String_FieldNumber) {
  WATypesValidator_String_FieldNumber_Min = 1,
  WATypesValidator_String_FieldNumber_Max = 2,
  WATypesValidator_String_FieldNumber_Default_p = 3,
  WATypesValidator_String_FieldNumber_Prefix = 4,
  WATypesValidator_String_FieldNumber_Suffix = 5,
  WATypesValidator_String_FieldNumber_Regex = 6,
};

GPB_FINAL @interface WATypesValidator_String : GPBMessage

@property(nonatomic, readwrite) uint32_t min;
@property(nonatomic, readwrite) BOOL hasMin;

@property(nonatomic, readwrite) uint32_t max;
@property(nonatomic, readwrite) BOOL hasMax;

@property(nonatomic, readwrite, copy, null_resettable) NSString *default_p;
/** Test to see if @c default_p has been set. */
@property(nonatomic, readwrite) BOOL hasDefault_p;

@property(nonatomic, readwrite, copy, null_resettable) NSString *prefix;
/** Test to see if @c prefix has been set. */
@property(nonatomic, readwrite) BOOL hasPrefix;

@property(nonatomic, readwrite, copy, null_resettable) NSString *suffix;
/** Test to see if @c suffix has been set. */
@property(nonatomic, readwrite) BOOL hasSuffix;

@property(nonatomic, readwrite, copy, null_resettable) NSString *regex;
/** Test to see if @c regex has been set. */
@property(nonatomic, readwrite) BOOL hasRegex;

@end

#pragma mark - WATypesValidator_Media

typedef GPB_ENUM(WATypesValidator_Media_FieldNumber) {
  WATypesValidator_Media_FieldNumber_Mime = 1,
  WATypesValidator_Media_FieldNumber_FileSize = 2,
  WATypesValidator_Media_FieldNumber_Dpi = 3,
  WATypesValidator_Media_FieldNumber_Resolution = 4,
  WATypesValidator_Media_FieldNumber_FormatsArray = 6,
};

GPB_FINAL @interface WATypesValidator_Media : GPBMessage

/** regex pattern */
@property(nonatomic, readwrite, copy, null_resettable) NSString *mime;

/** maximum file size in bytes */
@property(nonatomic, readwrite) uint64_t fileSize;
@property(nonatomic, readwrite) BOOL hasFileSize;

@property(nonatomic, readwrite) uint32_t dpi;
@property(nonatomic, readwrite) BOOL hasDpi;

@property(nonatomic, readwrite, strong, null_resettable) WATypesSize *resolution;
/** Test to see if @c resolution has been set. */
@property(nonatomic, readwrite) BOOL hasResolution;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<WATypesFormat*> *formatsArray;
/** The number of items in @c formatsArray without causing the container to be created. */
@property(nonatomic, readonly) NSUInteger formatsArray_Count;

@end

#pragma mark - WATypesFormat

typedef GPB_ENUM(WATypesFormat_FieldNumber) {
  WATypesFormat_FieldNumber_Audio = 1,
  WATypesFormat_FieldNumber_Video = 2,
  WATypesFormat_FieldNumber_Image = 3,
};

GPB_FINAL @interface WATypesFormat : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) WATypesFormat_Audio *audio;
/** Test to see if @c audio has been set. */
@property(nonatomic, readwrite) BOOL hasAudio;

@property(nonatomic, readwrite, strong, null_resettable) WATypesFormat_Video *video;
/** Test to see if @c video has been set. */
@property(nonatomic, readwrite) BOOL hasVideo;

@property(nonatomic, readwrite, strong, null_resettable) WATypesFormat_Image *image;
/** Test to see if @c image has been set. */
@property(nonatomic, readwrite) BOOL hasImage;

@end

#pragma mark - WATypesFormat_Audio

typedef GPB_ENUM(WATypesFormat_Audio_FieldNumber) {
  WATypesFormat_Audio_FieldNumber_Format = 1,
  WATypesFormat_Audio_FieldNumber_SampleRate = 2,
  WATypesFormat_Audio_FieldNumber_BitDepth = 3,
  WATypesFormat_Audio_FieldNumber_Channels = 4,
  WATypesFormat_Audio_FieldNumber_Duration = 5,
};

GPB_FINAL @interface WATypesFormat_Audio : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *format;

@property(nonatomic, readwrite) double sampleRate;
@property(nonatomic, readwrite) BOOL hasSampleRate;

@property(nonatomic, readwrite) uint32_t bitDepth;
@property(nonatomic, readwrite) BOOL hasBitDepth;

@property(nonatomic, readwrite) uint32_t channels;
@property(nonatomic, readwrite) BOOL hasChannels;

@property(nonatomic, readwrite) double duration;
@property(nonatomic, readwrite) BOOL hasDuration;

@end

#pragma mark - WATypesFormat_Video

typedef GPB_ENUM(WATypesFormat_Video_FieldNumber) {
  WATypesFormat_Video_FieldNumber_Duration = 5,
};

GPB_FINAL @interface WATypesFormat_Video : GPBMessage

@property(nonatomic, readwrite) double duration;
@property(nonatomic, readwrite) BOOL hasDuration;

@end

#pragma mark - WATypesFormat_Image

GPB_FINAL @interface WATypesFormat_Image : GPBMessage

@end

#pragma mark - WATypesListStrings

typedef GPB_ENUM(WATypesListStrings_FieldNumber) {
  WATypesListStrings_FieldNumber_ValuesArray = 1,
};

GPB_FINAL @interface WATypesListStrings : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *valuesArray;
/** The number of items in @c valuesArray without causing the container to be created. */
@property(nonatomic, readonly) NSUInteger valuesArray_Count;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

// clang-format on
