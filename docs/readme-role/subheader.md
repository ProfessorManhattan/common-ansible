<div align="center">
  <h4 align="center">
    <a href="{{ link.home }}" title="Megabyte Labs homepage" target="_blank">
      <img src="{{ project.assets }}/svg/home-solid.svg" />
    </a>
    <a href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" title="{{ name }} role on Ansible Galaxy" target="_blank">
      <img height="50" src="{{ project.assets }}/svg/ansible-galaxy.svg" />
    </a>
    <a href="{{ repository.group.ansible_roles }}/{{ galaxy_info.role_name }}{{ repository.location.contributing }}" title="Learn about contributing" target="_blank">
      <img src="{{ project.assets }}/svg/contributing-solid.svg" />
    </a>
    <a href="{{ profile_link.patreon }}/{{ profile.patreon }}" title="Support us on Patreon" target="_blank">
      <img src="{{ project.assets }}/svg/support-solid.svg" />
    </a>
    <a href="{{ link.chat }}" title="Slack chat room" target="_blank">
      <img src="{{ project.assets }}/svg/chat-solid.svg" />
    </a>
    <a href="{{ profile_link.github }}/{{ profile.github }}/{{ github_prefix }}{{ galaxy_info.role_name }}" title="GitHub mirror" target="_blank">
      <img src="{{ project.assets }}/svg/github-solid.svg" />
    </a>
    <a href="{{ repository.group.ansible_roles }}/{{ galaxy_info.role_name }}" title="GitLab repository" target="_blank">
      <img src="{{ project.assets }}/svg/gitlab-solid.svg" />
    </a>
  </h4>
  <p align="center">
    <a href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Ansible Galaxy role: {{ profile.galaxy }}.{{ galaxy_info.role_name }}" src="https://img.shields.io/ansible/role/{{ ansible_galaxy_project_id }}?logo=ansible&style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.github }}/{{ profile.github }}/{{ github_prefix }}{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Version: {{ pkg.version }}" src="https://img.shields.io/badge/version-{{ pkg.version }}-blue.svg?cacheSeconds=2592000" />
    </a>
    <a href="{{ {{ profile_link.github }}/{{ profile.github }}/{{ github_prefix }}{{ galaxy_info.role_name }}/actions/Windows.yml" target="_blank">
      <img alt="Windows 10 build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/ansible-{{ galaxy_info.role_name }}/Windows/master?color=cyan&label=Windows%20build&logo=windows&style={{ badge_style }}">
    </a>
    <a href="{{ profile_link.github }}/{{ profile.github }}/{{ github_prefix }}{{ galaxy_info.role_name }}/actions/macOS.yml" target="_blank">
      <img alt="macOS build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/ansible-{{ role_name }}/macOS/master?label=macOS%20build&logo=apple&style={{ badge_style }}">
    </a>
    <a href="{{ repository.group.ansible_roles }}/{{ galaxy_info.role_name }}/commits/master" target="_blank">
      <img alt="Linux build status" src="{{ repository.group.ansible_roles }}/{{ role_name }}/badges/master/pipeline.svg">
    </a>
    <a href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank" title="Ansible Galaxy quality score (out of 5)">
      <img alt="Ansible Galaxy quality score" src="https://img.shields.io/ansible/quality/{{ ansible_galaxy_project_id }}?logo=ansible&style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.galaxy }}/{{ profile.galaxy }}/{{ galaxy_info.role_name }}" target="_blank">
      <img alt="Ansible Galaxy downloads" src="https://img.shields.io/ansible/role/d/53381?logo=ansible&style={{ badge_style }}">
    </a>
    <a href="{{ link.docs }}/ansible" target="_blank">
      <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg?logo=readthedocs&style={{ badge_style }}" />
    </a>
    <a href="{{ repository.group.ansible_roles }}/{{ galaxy_info.role_name }}{{ repository.location.license }}" target="_blank">
      <img alt="License: {{ license }}" src="https://img.shields.io/badge/license-{{ license }}-yellow.svg?style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.opencollective }}/{{ profile.opencollective }}" title="Support us on Open Collective" target="_blank">
      <img alt="Open Collective sponsors" src="https://img.shields.io/opencollective/sponsors/megabytelabs?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAElBMVEUAAACvzfmFsft4pfD////w+P9tuc5RAAAABHRSTlMAFBERkdVu1AAAAFxJREFUKM9jgAAXIGBAABYXMHBA4yNEXGBAAU2BMz4FIIYTNhtFgRjZPkagFAuyAhGgHAuKAlQBCBtZB4gzQALoDsN0Oobn0L2PEUCoQYgZyOjRQFiJA67IRrEbAJImNwFBySjCAAAAAElFTkSuQmCC&label=Open%20Collective%20sponsors&logo=opencollective&style={{ badge_style }}" />
    </a>
    <a href="{{ profile_link.github }}/{{ profile.github }}" title="Support us on GitHub" target="_blank">
      <img alt="GitHub sponsors" src="https://img.shields.io/github/sponsors/{{ profile.github }}?label=GitHub%20sponsors&logo=github&style={{ badge_style }}" />
    </a>
    <a href="{{ profile.github }}" target="_blank">
      <img alt="GitHub: Megabyte Labs" src="https://img.shields.io/github/followers/{{ profile.github }}?style=social" target="_blank" />
    </a>
    <a href="https://twitter.com/{{ profile.twitter }}" target="_blank">
      <img alt="Twitter: {{ profile.twitter }}" src="https://img.shields.io/twitter/url/https/twitter.com/{{ profile.twitter }}.svg?style=social&label=Follow%20%40{{ profile.twitter }}" />
    </a>
  </p>
</div>
