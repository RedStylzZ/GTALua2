//NativeInvoker.cpp
#include "stdafx.h"

static NativeManagerContext g_context;

static UINT64 g_hash;

void(*scrNativeCallContext::SetVectorResults)(scrNativeCallContext*) = nullptr;

void nativeInit(UINT64 hash) {
	g_context.Reset();
	g_hash = hash;
}

void nativePush64(UINT64 value) {
	g_context.Push(value);
}

uint64_t * nativeCall() {

	auto function = Hooking::GetNativeHandler(g_hash);

	if (function != 0) {

		static void* exceptionAddress;

		try {
			function(&g_context);
			scrNativeCallContext::SetVectorResults(&g_context);
		}
		catch (const std::exception &e) {
			printf(ERROR_EXECUTING_NATIVE, e.what(), g_hash, exceptionAddress);
		}
	}

	return reinterpret_cast<uint64_t*>(g_context.GetResultPointer());
}

