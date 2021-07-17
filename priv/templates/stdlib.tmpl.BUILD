load(
    "@rules_crystal//:priv/rules/library.bzl",
    "CRYSTAL_LIBRARY_NO_REQUIRE_PREFIX",
    "crystal_library",
)

crystal_library(
    name = "stdlib",
    srcs = glob(["**/*.cr"]),
    extra_srcs = glob(
        ["**/*"],
        exclude = ["**/*.cr"],
    ),
    require_prefix = CRYSTAL_LIBRARY_NO_REQUIRE_PREFIX,
    visibility = ["//visibility:public"],
)
