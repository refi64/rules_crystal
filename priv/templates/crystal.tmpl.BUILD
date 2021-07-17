load("@rules_crystal//:priv/rules/toolchain.bzl", "crystal_toolchain")

crystal_toolchain(
    name = "crystal",
    crystal = "//:bin/crystal",
    shards = "//:bin/shards",
    stdlib = "//share/crystal/src:stdlib",
)

toolchain(
    name = "crystal_toolchain",
    toolchain = ":crystal",
    toolchain_type = "@rules_crystal//:toolchain_type",
    visibility = ["//visibility:public"],
)
