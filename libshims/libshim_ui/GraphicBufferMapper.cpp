/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdint.h>
#include <ui/GraphicBufferMapper.h>
#include <ui/Rect.h>
#include <utils/Errors.h>

using android::Rect;
using android::status_t;

extern "C" {
status_t _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPvPiS9_(
        void* thisptr, buffer_handle_t handle, uint32_t usage, const Rect& bounds, void** vaddr,
        int32_t* /*outBytesPerPixel*/, int32_t* /*outBytesPerStride*/) {
    auto* gpm = static_cast<android::GraphicBufferMapper*>(thisptr);
    return gpm->lock(handle, usage, bounds, vaddr);
}
}
