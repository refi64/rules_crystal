load("@rules_crystal//:index.bzl", "crystal_binary")

crystal_binary(
    name = "write_version",
    srcs = ["generator/write_version.cr"],
    main = "generator/write_version.cr",
)

genrule(
    name = "version",
    srcs = [],
    outs = ["src/generated/version.cr"],
    cmd = "./$(location :write_version) \"$@\" Generated 0.1",
    tools = [":write_version"],
)

crystal_binary(
    name = "generated",
    srcs = glob(
        ["src/**/*.cr"],
        # We need to exclude the in-tree symlink we created for language servers to work.
        exclude = ["src/generated/version.cr"],
    ) + [
        # This is where we add the target with our generated source for Bazel.
        ":version",
    ],
    main = "src/generated.cr",
)
