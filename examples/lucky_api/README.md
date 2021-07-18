# Lucky API example with rules_crystal

## Basics of using Lucky with rules_crystal

- `start_server.cr` was removed and inlined into `lucky_api.cr`. The reason is that
  `crystal_binary` takes a *single* main argument, so having the actual driver code in
  that file is required for `based_on` / `subject` to work.

- `lucky dev` does not go through Bazel and should not be used.

- `scripts/setup` had `shards` commands, touching `.env`, and `lucky dev` referneces
  removed. Bazel will ensure shards are downloaded before the app can be started, and
  `dev` does properly not work here (as described above).

- The process runner checks were removed from `script/system_check`.

- In each of these scripts, all commands *must* go through the custom `tasks` binary
  defined in BUILD instead of using `lucky` directly. In other words, `lucky` was replaced
  with `./tasks`,

- The tasks and all the scripts are run via `bazel run`, see BUILD for their target
  definitions.

## Unrelated removals

Some functionality was removed, just to make the demo a bit smaller so that the
rules_crystal usage is more clearly highlighted. In particular, the following was removed:

- All query- and email-related files and dependencies
- `Procfile`s
- Several items in `config`
- `base_serializer`
