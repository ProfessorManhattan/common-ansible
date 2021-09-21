<div align="center">
  <h4 align="center">
    <a href="{{ link.home }}" title="{{ organization }} homepage" target="_blank">
      <img alt="Homepage" src="https://img.shields.io/website?down_color=%23FF4136&down_message=Down&label=Homepage&logo=home-assistant&logoColor=white&up_color=%232ECC40&up_message=Up&url=https%3A%2F%2Fmegabyte.space&style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" title="{{ name }} role on Ansible Galaxy" target="_blank">
      <img alt="Ansible Galaxy" src="https://img.shields.io/badge/Ansible-Galaxy-000000?logo=ansible&logoColor=white&style={{ badge_style }}" />
    </a>
    <a href="{{ repository.github }}{{ repository.location.contributing.github }}" title="Learn about contributing" target="_blank">
      <img alt="Contributing" src="https://img.shields.io/badge/Contributing-Guide-0074D9?logo=github-sponsors&logoColor=white&style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.patreon }}/{{ profile.patreon }}" title="Support us on Patreon" target="_blank">
      <img alt="Patreon" src="https://img.shields.io/badge/Patreon-Support-052d49?logo=patreon&logoColor=white&style={{ badge_style }}" />
    </a>
    <a href="{{ link.chat }}" title="Slack chat room" target="_blank">
      <img alt="Slack" src="https://img.shields.io/badge/Slack-Chat-e01e5a?logo=slack&logoColor=white&style={{ badge_style }}" />
    </a>
    <a href="{{ repository.github }}" title="GitHub mirror" target="_blank">
      <img alt="GitHub" src="https://img.shields.io/badge/Mirror-GitHub-333333?logo=github&style={{ badge_style }}" />
    </a>
    <a href="{{ repository.gitlab }}" title="GitLab repository" target="_blank">
      <img alt="GitLab" src="https://img.shields.io/badge/Repo-GitLab-fc6d26?logo=gitlab&style={{ badge_style }}" />
    </a>
  </h4>
  <p align="center">
    <a title="Ansible Galaxy role: {{ profile.galaxy }}.{{ galaxy_info.role_name }}" href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Ansible Galaxy role: {{ profile.galaxy }}.{{ galaxy_info.role_name }}" src="https://img.shields.io/ansible/role/{{ ansible_galaxy_project_id }}?logo=ansible&style={{ badge_style }}" />
    </a>
    <a title="Version: {{ pkg.version }}" href="{{ repository.github }}" target="_blank">
      <img alt="Version: {{ pkg.version }}" src="https://img.shields.io/badge/version-{{ pkg.version }}-blue.svg?cacheSeconds=2592000" />
    </a>
    <a title="Windows 11 build status on GitHub" href="{{ {{ repository.github }}/actions/Windows.yml" target="_blank">
      <img alt="Windows 11 build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/{{ repository.prefix.github }}{{ galaxy_info.role_name }}/Windows/master?color=cyan&label=Windows%20build&logo=windows&style={{ badge_style }}">
    </a>
    <a title="macOS build status on GitHub" href="{{ repository.github }}/actions/macOS.yml" target="_blank">
      <img alt="macOS build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/{{ repository.prefix.github }}{{ galaxy_info.role_name }}/macOS/master?label=macOS%20build&logo=apple&style={{ badge_style }}">
    </a>
    <a title="Linux build status on GitLab" href="{{ repository.gitlab }}{{ repository.location.commits.gitlab }}" target="_blank">
      <img alt="Linux build status" src="https://img.shields.io/badge/dynamic/json?color=ffdc00&label=Linux&query=%24%5B0%5D.status&url=https%3A%2F%2Fgitlab.com%2Fapi%2Fv4%2Fprojects%2F{{ encoded_gitlab_path }}%2Fpipelines&style={{ badge_style }}">
    </a>
    <a title="Ansible Galaxy quality score (out of 5)" href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Ansible Galaxy quality score" src="https://img.shields.io/ansible/quality/{{ ansible_galaxy_project_id }}?logo=ansible&style={{ badge_style }}" />
    </a>
    <a title="Ansible Galaxy download count" href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Ansible Galaxy download count" src="https://img.shields.io/ansible/role/d/53381?logo=ansible&style={{ badge_style }}">
    </a>
    <a title="Documentation" href="{{ link.docs }}/{{ group }}" target="_blank">
      <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg?logo=readthedocs&style={{ badge_style }}" />
    </a>
    <a title="License: {{ license }}" href="{{ repository.github }}{{ repository.location.license.github }}" target="_blank">
      <img alt="License: {{ license }}" src="https://img.shields.io/badge/license-{{ license }}-yellow.svg?style={{ badge_style }}" />
    </a>
    <a title="Support us on Open Collective" href="{{ profile_link.opencollective }}/{{ profile.opencollective }}" target="_blank">
      <img alt="Open Collective sponsors" src="https://img.shields.io/opencollective/sponsors/megabytelabs?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAElBMVEUAAACvzfmFsft4pfD////w+P9tuc5RAAAABHRSTlMAFBERkdVu1AAAAFxJREFUKM9jgAAXIGBAABYXMHBA4yNEXGBAAU2BMz4FIIYTNhtFgRjZPkagFAuyAhGgHAuKAlQBCBtZB4gzQALoDsN0Oobn0L2PEUCoQYgZyOjRQFiJA67IRrEbAJImNwFBySjCAAAAAElFTkSuQmCC&label=Open%20Collective%20sponsors&logo=opencollective&style={{ badge_style }}" />
    </a>
    <a title="Support us on GitHub" href="{{ profile_link.github }}/{{ profile.github }}" target="_blank">
      <img alt="GitHub sponsors" src="https://img.shields.io/github/sponsors/{{ profile.github }}?label=GitHub%20sponsors&logo=github&style={{ badge_style }}" />
    </a>
    <a title="Follow us on GitHub" href="{{ profile_link.github }}/{{ profile.github }}" target="_blank">
      <img alt="GitHub: Megabyte Labs" src="https://img.shields.io/github/followers/{{ profile.github }}?style=social" target="_blank" />
    </a>
    <a title="Follow us on Twitter" href="https://twitter.com/{{ profile.twitter }}" target="_blank">
      <img alt="Twitter: {{ profile.twitter }}" src="https://img.shields.io/twitter/url/https/twitter.com/{{ profile.twitter }}.svg?style=social&label=Follow%20%40{{ profile.twitter }}" />
    </a>
  </p>
</div>
