load("@rules_crystal//:index.bzl", "crystal_binary", "crystal_test")

crystal_binary(
    name = "basic",
    srcs = glob(["src/**/*.cr"]),
    main = "src/basic.cr",
)

crystal_test(
    name = "spec",
    srcs = glob(["spec/**/*.cr"]),
    subject = ":basic",
)
