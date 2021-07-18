load("@rules_crystal//:index.bzl", "crystal_binary")

crystal_binary(
    name = "lucky_api",
    srcs = glob(
        [
            "config/*.cr",
            "db/**/*.cr",
            "src/**/*.cr",
        ],
    ),
    data = ["config/watch.yml"],
    # Workaround for the "empty directory" gotcha, see the top-level README.md.
    extra_srcs = glob([
        "db/**/.keep",
        "src/**/.keep",
    ]),
    main = "src/lucky_api.cr",
    deps = [
        "@shards//:lucky",
        "@shards//:lucky_env",
    ],
)

crystal_binary(
    name = "tasks",
    srcs = ["tasks.cr"] + glob([
        "tasks/**/*.cr",
        "spec/support/factories/**/*.cr",
    ]),
    based_on = ":lucky_api",
    extra_srcs = glob(["spec/support/factories/**/.keep"]),
    main = "tasks.cr",
    deps = ["@shards//:lucky_task"],
)

sh_library(
    name = "script_helpers",
    srcs = glob(["script/helpers/*_helpers"]),
)

sh_binary(
    name = "system_check",
    srcs = ["script/system_check"],
    data = [":tasks"],
    deps = [":script_helpers"],
)

sh_binary(
    name = "setup",
    srcs = ["script/setup"],
    data = [
        ":system_check",
        ":tasks",
    ],
    deps = [":script_helpers"],
)
