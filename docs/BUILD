load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

bzl_library(
    name = "rules_crystal",
    srcs = [
        "//:bzl_srcs",
        "@bazel_tools//tools:bzl_srcs",
    ],
)

stardoc(
    name = "docs",
    out = "rules_crystal.md",
    input = "//:index.bzl",
    deps = [":rules_crystal"],
)
