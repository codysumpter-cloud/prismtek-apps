//
//  LLMEngine.mm
//  LLMEngine
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include "LLMEngine.h"

#ifndef BEMORE_MLC_RUNTIME_LINKED
#define BEMORE_MLC_RUNTIME_LINKED 0
#endif

#if BEMORE_MLC_RUNTIME_LINKED

#include <os/proc.h>

#define TVM_USE_LIBBACKTRACE 0

#include <tvm/ffi/extra/module.h>
#include <tvm/ffi/function.h>
#include <tvm/ffi/optional.h>
#include <tvm/ffi/string.h>
#include <tvm/runtime/module.h>

using namespace tvm::runtime;
using tvm::ffi::Function;
using tvm::ffi::Module;
using tvm::ffi::Optional;
using tvm::ffi::String;
using tvm::ffi::TypedFunction;

@implementation JSONFFIEngine {
  // Internal c++ classes
  // internal module backed by JSON FFI
  Optional<Module> json_ffi_engine_;
  // member functions
  Function init_background_engine_func_;
  Function unload_func_;
  Function reload_func_;
  Function reset_func_;
  Function chat_completion_func_;
  Function abort_func_;
  Function run_background_loop_func_;
  Function run_background_stream_back_loop_func_;
  Function exit_background_loop_func_;
}

- (instancetype)init {
  if (self = [super init]) {
    // load chat module
    Function f_json_ffi_create = Function::GetGlobalRequired("mlc.json_ffi.CreateJSONFFIEngine");
    json_ffi_engine_ = f_json_ffi_create().cast<Module>();
    init_background_engine_func_ =
        json_ffi_engine_.value()->GetFunction("init_background_engine").value_or(Function(nullptr));
    reload_func_ = json_ffi_engine_.value()->GetFunction("reload").value_or(Function(nullptr));
    unload_func_ = json_ffi_engine_.value()->GetFunction("unload").value_or(Function(nullptr));
    reset_func_ = json_ffi_engine_.value()->GetFunction("reset").value_or(Function(nullptr));
    chat_completion_func_ =
        json_ffi_engine_.value()->GetFunction("chat_completion").value_or(Function(nullptr));
    abort_func_ = json_ffi_engine_.value()->GetFunction("abort").value_or(Function(nullptr));
    run_background_loop_func_ =
        json_ffi_engine_.value()->GetFunction("run_background_loop").value_or(Function(nullptr));
    run_background_stream_back_loop_func_ = json_ffi_engine_.value()
                                                ->GetFunction("run_background_stream_back_loop")
                                                .value_or(Function(nullptr));
    exit_background_loop_func_ =
        json_ffi_engine_.value()->GetFunction("exit_background_loop").value_or(Function(nullptr));

    TVM_FFI_ICHECK(init_background_engine_func_ != nullptr);
    TVM_FFI_ICHECK(reload_func_ != nullptr);
    TVM_FFI_ICHECK(unload_func_ != nullptr);
    TVM_FFI_ICHECK(reset_func_ != nullptr);
    TVM_FFI_ICHECK(chat_completion_func_ != nullptr);
    TVM_FFI_ICHECK(abort_func_ != nullptr);
    TVM_FFI_ICHECK(run_background_loop_func_ != nullptr);
    TVM_FFI_ICHECK(run_background_stream_back_loop_func_ != nullptr);
    TVM_FFI_ICHECK(exit_background_loop_func_ != nullptr);
  }
  return self;
}

- (void)initBackgroundEngine:(void (^)(NSString*))streamCallback {
  TypedFunction<void(String)> internal_stream_callback([streamCallback](String value) {
    streamCallback([NSString stringWithUTF8String:value.c_str()]);
  });
  int device_type = kDLMetal;
  int device_id = 0;
  init_background_engine_func_(device_type, device_id, internal_stream_callback);
}

- (void)reload:(NSString*)engineConfigJson {
  std::string engine_config = engineConfigJson.UTF8String;
  reload_func_(engine_config);
}

- (void)unload {
  unload_func_();
}

- (void)reset {
  reset_func_();
}

- (void)chatCompletion:(NSString*)requestJSON requestID:(NSString*)requestID {
  std::string request_json = requestJSON.UTF8String;
  std::string request_id = requestID.UTF8String;
  chat_completion_func_(request_json, request_id);
}

- (void)abort:(NSString*)requestID {
  std::string request_id = requestID.UTF8String;
  abort_func_(request_id);
}

- (void)runBackgroundLoop {
  run_background_loop_func_();
}

- (void)runBackgroundStreamBackLoop {
  run_background_stream_back_loop_func_();
}

- (void)exitBackgroundLoop {
  exit_background_loop_func_();
}

@end

#else

static NSString* BEMOREMLCStringFromJSONObject(id object) {
  if (![NSJSONSerialization isValidJSONObject:object]) {
    return @"[]";
  }

  NSError* error = nil;
  NSData* data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
  if (data == nil || error != nil) {
    NSLog(@"MLCSwift fallback failed to encode response JSON: %@", error.localizedDescription);
    return @"[]";
  }

  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"[]";
}

@implementation JSONFFIEngine {
  void (^streamCallback_)(NSString*);
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSLog(@"MLCSwift bridge compiled without the native MLC/TVM runtime; using unavailable-runtime fallback.");
  }
  return self;
}

- (void)initBackgroundEngine:(void (^)(NSString*))streamCallback {
  streamCallback_ = [streamCallback copy];
}

- (void)reload:(NSString*)engineConfigJson {
  NSLog(@"MLCSwift reload skipped because BEMORE_MLC_RUNTIME_LINKED is disabled. Config: %@", engineConfigJson);
}

- (void)unload {
}

- (void)reset {
}

- (void)chatCompletion:(NSString*)requestJSON requestID:(NSString*)requestID {
  if (streamCallback_ == nil) {
    NSLog(@"MLCSwift fallback received chatCompletion before initBackgroundEngine.");
    return;
  }

  NSString* responseID = requestID.length > 0 ? requestID : @"bemore-runtime-unavailable";
  NSNumber* created = @((NSInteger)[[NSDate date] timeIntervalSince1970]);
  NSString* message = @"The MLCSwift bridge is present, but this build does not link the native MLC/TVM runtime library. Keep this PR draft until a compatible model runtime is bundled and local token generation is verified.";

  NSDictionary* contentChunk = @{
    @"id": responseID,
    @"choices": @[
      @{
        @"index": @0,
        @"delta": @{
          @"role": @"assistant",
          @"content": message
        }
      }
    ],
    @"created": created,
    @"model": @"mlc-runtime-unavailable",
    @"system_fingerprint": @"bemore-mlc-runtime-unavailable",
    @"object": @"chat.completion.chunk"
  };

  NSDictionary* finalChunk = @{
    @"id": responseID,
    @"choices": @[],
    @"created": created,
    @"model": @"mlc-runtime-unavailable",
    @"system_fingerprint": @"bemore-mlc-runtime-unavailable",
    @"object": @"chat.completion.chunk",
    @"usage": @{
      @"prompt_tokens": @0,
      @"completion_tokens": @0,
      @"total_tokens": @0,
      @"extra": [NSNull null]
    }
  };

  streamCallback_(BEMOREMLCStringFromJSONObject(@[contentChunk, finalChunk]));
}

- (void)abort:(NSString*)requestID {
}

- (void)runBackgroundLoop {
}

- (void)runBackgroundStreamBackLoop {
}

- (void)exitBackgroundLoop {
  streamCallback_ = nil;
}

@end

#endif
