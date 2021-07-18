"""Contains rules for building binaries & running tests."""

load(
    "//:priv/rules/common.bzl",
    "BINARY_LIBRARY_ATTRS",
    "CrystalLibraryInfo",
    "CrystalSourcesInfo",
    "depset_for_libraries",
)
load("//:priv/utils/sources.bzl", "root_sources")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "CPP_LINK_EXECUTABLE_ACTION_NAME")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

_CompileInfo = provider(fields = ["libs_depset", "default_info"])

_BINARY_ADDITIONAL_ATTRS = {
    "warnings": attr.string(
        default = "all",
        values = ["all", "error_all", "none"],
        doc = """The warnings that compilation should show. *error_all* is \
equivalent to *all*, but all warnings are now errors.""",
    ),
    "defines": attr.string_list(doc = "Defines to pass to the Crystal compiler."),
    "flags": attr.string_list(doc = "Flags to pass to the Crystal compiler."),
    "_cc_toolchain": attr.label(
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
}

_BINARY_ATTRS = dict(BINARY_LIBRARY_ATTRS, **_BINARY_ADDITIONAL_ATTRS)

def _root_sources_hidden_prefix(ctx, srcs, extra_srcs):
    return root_sources(ctx, srcs, extra_srcs, prefix = "_%s_srcs" % ctx.label.name)

def _merge_extra_srcs_and_deps_with_base(extra_srcs, deps, base):
    base_sources_info = base[CrystalSourcesInfo]
    base_srcs = list(base_sources_info.srcs)
    if base_sources_info.main_src_index != -1:
        base_srcs.pop(base_sources_info.main_src_index)

    return extra_srcs + base_srcs, deps + base_sources_info.deps

def _compile(ctx, root_info, compile_entry_points, deps):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    linker_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_EXECUTABLE_ACTION_NAME,
    )

    crystal_info = ctx.toolchains["@rules_crystal//:toolchain_type"].crystal_info

    libs_depset = depset_for_libraries(deps + [crystal_info.stdlib])
    libs = [dep[CrystalLibraryInfo] for dep in libs_depset.to_list()]

    args = ["build"]

    output = ctx.actions.declare_file(ctx.label.name)
    args.append("-o%s" % output.path)

    for define in ctx.attr.defines:
        args.append("-D%s" % define.path)

    if ctx.attr.warnings == "none":
        args.extend(["--warnings", "none"])
    elif ctx.attr.warnings == "error_all":
        args.append("--error-on-warnings")

    args.extend(ctx.attr.flags)
    args.extend([file.path for file in compile_entry_points])

    crystal_path = [lib.root for lib in libs]
    env = {"CRYSTAL_PATH": ":".join(crystal_path), "CC": linker_path}

    all_inputs = depset(
        direct = root_info.src_links + root_info.extra_src_links + [crystal_info.crystal],
        transitive = [depset(lib.files) for lib in libs],
    )

    ctx.actions.run(
        arguments = args,
        executable = crystal_info.crystal.path,
        inputs = all_inputs,
        outputs = [output],
        env = env,
    )

    return _CompileInfo(
        default_info = DefaultInfo(files = depset([output]), executable = output),
        libs_depset = libs_depset,
    )

def _crystal_binary_impl(ctx):
    if ctx.file.main not in ctx.files.srcs:
        fail("Main file %s must be in srcs" % ctx.file.main.short_path)

    main_src_index = ctx.files.srcs.index(ctx.file.main)

    extra_srcs = ctx.attr.extra_srcs
    deps = ctx.attr.deps

    if ctx.attr.based_on:
        extra_srcs, deps = _merge_extra_srcs_and_deps_with_base(
            extra_srcs,
            deps,
            ctx.attr.based_on,
        )

    root_info = _root_sources_hidden_prefix(ctx, ctx.attr.srcs, extra_srcs)
    compile_info = _compile(
        ctx,
        root_info = root_info,
        compile_entry_points = [root_info.src_links[main_src_index]],
        deps = deps,
    )

    return [
        compile_info.default_info,
        CrystalSourcesInfo(
            srcs = ctx.attr.srcs + extra_srcs,
            deps = deps,
            main_src_index = main_src_index,
        ),
    ]

def _crystal_test_impl(ctx):
    extra_srcs = ctx.attr.extra_srcs
    deps = ctx.attr.deps

    if ctx.attr.subject:
        extra_srcs, deps = _merge_extra_srcs_and_deps_with_base(
            extra_srcs,
            deps,
            ctx.attr.subject,
        )

    root_info = _root_sources_hidden_prefix(ctx, ctx.attr.srcs, extra_srcs)
    compile_info = _compile(
        ctx,
        root_info = root_info,
        compile_entry_points = root_info.src_links,
        deps = deps,
    )

    return [compile_info.default_info]

def _create_binary_rule(attrs = {}, **extra_kw):
    return rule(
        attrs = dict(_BINARY_ATTRS, **attrs),
        toolchains = [
            "@rules_crystal//:toolchain_type",
            "@bazel_tools//tools/cpp:toolchain_type",
        ],
        fragments = ["cpp"],
        incompatible_use_toolchain_transition = True,
        **extra_kw
    )

crystal_binary = _create_binary_rule(
    implementation = _crystal_binary_impl,
    executable = True,
    attrs = {
        "main": attr.label(
            allow_single_file = [".cr"],
            doc = "The main entry point for the program.",
            mandatory = True,
        ),
        "based_on": attr.label(
            providers = [CrystalSourcesInfo],
            doc = "A binary or library to re-use srcs and deps from.",
        ),
    },
)

crystal_test = _create_binary_rule(
    implementation = _crystal_test_impl,
    executable = True,
    test = True,
    attrs = {
        "subject": attr.label(
            providers = [CrystalSourcesInfo],
            doc = "A binary or library to re-use srcs and deps from.",
        ),
    },
)
