"""Contains rules for setting up a Crystal installation and workspace."""

load("//:priv/releases.bzl", "LATEST_RELEASE", "RELEASES")

_CPU_X86 = "i686"
_CPU_X64 = "x86_64"

_BAZEL_CPUS = {
    _CPU_X86: "x86_32",
    _CPU_X64: "x86_64",
}

_RELEASES_URL = "https://github.com/crystal-lang/crystal/releases/download"

_CRYSTAL_BUILD_TEMPLATE = Label("//:priv/templates/crystal.tmpl.BUILD")
_CRYSTAL_STDLIB_BUILD_TEMPLATE = Label("//:priv/templates/stdlib.tmpl.BUILD")

def _uname_cpu(repository_ctx):
    result = repository_ctx.execute(["uname", "-m"], quiet = True)
    if result.return_code != 0:
        repository_ctx.fail("Failed to run uname -m")

    cpu = result.stdout.strip()
    if cpu == "x86_64":
        return _CPU_X64
    elif cpu == "i386" or cpu == "i686":
        return _CPU_X86
    else:
        repository_ctx.fail("Unknown host CPU: %s", cpu)
        return ""

def _crystal_repositories_impl(repository_ctx):
    version = repository_ctx.attr.version
    if version == "latest":
        version = LATEST_RELEASE
    elif version not in RELEASES:
        repository_ctx.fail("Unknown Crystal version: %s" % version)

    base_url = "%s/%s" % (_RELEASES_URL, version)
    release = RELEASES[version]

    # XXX: We always assume a subrelease of 1 (are there even any others?).
    subrel = 1
    prefix = "crystal-%s-%s" % (version, subrel)

    # XXX: We also assume Linux at the moment, because I haven't tested these
    # rules on Macs.
    cpu = _uname_cpu(repository_ctx)

    # The TVA wouldn't like this...
    variant = "linux-%s" % cpu
    url = "%s/%s-%s.tar.gz" % (base_url, prefix, variant)
    sha256 = release[variant]

    repository_ctx.download_and_extract(
        url = url,
        sha256 = sha256,
        stripPrefix = prefix,
    )

    repository_ctx.template("BUILD", _CRYSTAL_BUILD_TEMPLATE)
    repository_ctx.template(
        "share/crystal/src/BUILD",
        _CRYSTAL_STDLIB_BUILD_TEMPLATE,
    )

_crystal_repositories = repository_rule(
    implementation = _crystal_repositories_impl,
    attrs = {
        "version": attr.string(default = "latest"),
    },
)

def crystal_repositories(
        name = "crystal",
        version = "latest",
        register_toolchains = True):
    """Downloads and installs Crystal into a new workspace.

    This rule downloads Crystal and Shards into a new workspace.

    Args:
        name: The workspace name.
        version: The version of Crystal to install. Use *latest* to download
            the latest version these rules support.
        register_toolchains: Whether or not to register the toolchain. If set
            to `False`, the user can register it themselves using the target
            `@WORKSPACE_NAME//:crystal_toolchain`.
    """

    _crystal_repositories(name = name, version = version)
    if register_toolchains:
        native.register_toolchains("@%s//:crystal_toolchain" % name)
