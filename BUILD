exports_files(
    ["index.bzl"],
    visibility = ["//docs:__subpackages__"],
)

filegroup(
    name = "bzl_srcs",
    srcs = ["index.bzl"] + glob(["priv/**/*.bzl"]),
    visibility = ["//docs:__subpackages__"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)
