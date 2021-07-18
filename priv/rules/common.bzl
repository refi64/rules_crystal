"""Contains some common attributes shared between rules."""

CrystalSourcesInfo = provider(
    doc = """
A provider that contains information about the original source files used by a Crystal
binary or library.
""",
    fields = {
        "srcs": "A list of the target's direct source files (Target instances)",
        "deps": "A list of all the target's dependencies",
        "main_src_index": """\
The index into the srcs list of the main source file of a binary (-1 for a library)""",
    },
)

CrystalLibraryInfo = provider(
    doc = """
A provider that contains information about a Crystal library.
""",
    fields = {
        "name": "A string representing library's name",
        "root": "A string representing filesystem root that should be added to the" +
                " Crystal search path",
        "files": "A list of Files this library holds",
        "deps": "A depset of all this library's dependencies",
    },
)

BINARY_LIBRARY_ATTRS = {
    "srcs": attr.label_list(
        allow_files = [".cr", ".ecr"],
        doc = "Source files this target contains.",
    ),
    "extra_srcs": attr.label_list(
        allow_files = True,
        doc = "Non-Crystal source files that this target needs during compilation.",
    ),
    "deps": attr.label_list(
        providers = [CrystalLibraryInfo],
        doc = "Crystal libraries that this target depends on.",
    ),
    "data": attr.label_list(
        allow_files = True,
        doc = """Files needed by this rule at runtime. Equivalent to `cc_binary`'s \
and `cc_library`'s *data*.""",
    ),
}

def get_libraries_for_targets(targets):
    """Returns a list of all the CrystalLibraryInfo instances in the given targets."""
    return [t[CrystalLibraryInfo] for t in targets]

def depset_for_libraries(lib_targets):
    """Returns a depset for the given library targets."""
    return depset(
        lib_targets,
        transitive = [lib.deps for lib in get_libraries_for_targets(lib_targets)],
    )

def merge_runfiles(ctx, deps):
    runfiles = ctx.runfiles(files = ctx.files.data)
    for dep in deps:
        runfiles = runfiles.merge(dep[DefaultInfo].default_runfiles)
    return runfiles
