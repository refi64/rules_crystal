load("@rules_crystal//:index.bzl", "crystal_binary", "crystal_test")

crystal_binary(
    name = "kemal_demo",
    srcs = glob(["src/**/*.cr"]),
    main = "src/kemal_demo.cr",
    deps = ["@shards//:kemal"],
)

crystal_test(
    name = "spec",
    srcs = glob(["spec/**/*.cr"]),
    subject = ":kemal_demo",
    deps = ["@shards//:spec-kemal"],
)
