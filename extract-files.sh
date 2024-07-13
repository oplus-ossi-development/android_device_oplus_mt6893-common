#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

export DEVICE=mt6893-common
export VENDOR=oplus

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}"/../../..

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup {
    case "$1" in
        vendor/lib*/hw/vendor.mediatek.hardware.pq@2.15-impl.so)
            "$PATCHELF" --replace-needed libutils.so libutils-v32.so "$2"
            ;;
	vendor/bin/hw/android.hardware.media.c2@1.2-mediatek|vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
            "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib/libcodec2_mtk_c2store.so|\
        vendor/lib64/libcodec2_mtk_c2store.so)
            "${PATCHELF}" --replace-needed "libcodec2_soft_common.so" "libcodec2_soft_common-mtk.so" "${2}"
            ;;
        vendor/bin/mtk_agpsd)
           "$PATCHELF" --replace-needed libcrypto.so libcrypto-v32.so "$2"
           "$PATCHELF" --replace-needed libssl.so libssl-v32.so "${2}"
            ;;
        vendor/lib*/libkeystore-engine-wifi-hidl.so)
            "$PATCHELF" --replace-needed android.system.keystore2-V1-ndk_platform.so android.system.keystore2-V1-ndk.so "$2"
            ;;
	vendor/lib64/libmtkcam_featurepolicy.so)
            # evaluateCaptureConfiguration()
            sed -i "s/\x34\xE8\x87\x40\xB9/\x34\x28\x02\x80\x52/" "$2"
            ;;
        vendor/bin/hw/android.hardware.thermal@2.0-service.mtk)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.wifi@1.0-service-lazy)
            "${PATCHELF}" --replace-needed "libwifi-hal.so" "libwifi-hal-mtk.so" "${2}"
            ;;
        lib64/libem_support_jni.so)
            "${PATCHELF}" --add-needed "libjni_shim.so" "${2}"
            ;;
        vendor/lib64/hw/sensors.mt6893.so)
            "${PATCHELF}" --add-needed "libsensors_shim.so" "${2}"
            ;;
        vendor/bin/mnld)
            ;&
        vendor/lib64/libaalservice.so)
            "${PATCHELF}" --replace-needed "libsensorndkbridge.so" "libsensorndkbridge-v30.so" "${2}"
            ;;
	system_ext/lib64/libsource.so)
            grep -q libshim_ui.so "$2" || "$PATCHELF" --add-needed libshim_ui.so "$2"
            ;;
    esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper for device
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

bash "${MY_DIR}/setup-makefiles.sh"
