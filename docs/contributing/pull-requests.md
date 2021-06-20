## Pull Requests

All pull requests should be associated with issues. Although not strictly required, the pull requests should be made to [the GitLab repository issues board]({{ repository.group.ansible_roles }}/{{ galaxy_info.role_name }}{{ repository.location.issues }}) instead of the [GitHub mirror repository]({{ profile_link.github }}/{{ profile.github }}/{{ github_prefix }}{{ galaxy_info.role_name }}). This is because we use GitLab as our primary repository and mirror the changes to GitHub for the community.

### How to Commit Code

Instead of using `git commit`, we prefer that you use `task commit`. You will understand why when you try it but basically it streamlines the commit process and helps us generate better `CHANGELOG.md` files.

### Pre-Commit Hook

Even if you decide not to use `task commit`, you will see that `git commit` behaves differently since the pre-commit hook is installed when `npm i` during various build steps. This pre-commit hook is there to test your code before committing. If you need to bypass the pre-commit hook, then you will have to add the `--no-verify` tag at the end of your `git commit` command (e.g. `git commit -m "Commit" --no-verify`).
