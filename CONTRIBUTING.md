# Contributing

## Set up `git` hooks

The repo includes some handy `git` hooks under `.scripts/`:

* `pre-commit` Runs the `format --check-formatted` task.
* `post-commit` Runs a customised `credo` check.

We strongly recommend that you set up these git hooks on your machine by:
```sh
# sh
# in the project root, run:
ln -sf ../../.scripts/pre-commit .git/hooks/pre-commit
ln -sf ../../.scripts/post-commit .git/hooks/post-commit

# Yeah you read that right! Two folders up is necessary.
# See: https://stackoverflow.com/questions/4592838/symbolic-link-to-a-hook-in-git#4594681
```

> **Note that our CI will fail your PR if you dont run `mix format` in the project
> root.**

## Styling

We follow
[lexmag/elixir-style-guide](https://github.com/lexmag/elixir-style-guide) and
[rrrene/elixir-style-guide](https://github.com/rrrene/elixir-style-guide) (both
overlap a lot).

Our commit messages (at least on [`develop`][dev]) are [formatted as described
here][commit-format].

Please set up [our super nice commit message template][our-template] to
supercharge :zap::zap: your commit messages!

```sh
# sh
# in the project root, run:

git config commit.template .git_commit_msg.txt
```

To make this your commit template globally, just add the `--global` flag!

Have fun commiting new changes! :rainbow:

[dev]: https://github.com/aviabird/snitch/tree/develop
[commit-format]: https://chris.beams.io/posts/git-commit/
[our-template]: https://github.com/aviabird/snitch/blob/develop/.git_commit_msg.txt

