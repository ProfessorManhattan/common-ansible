<div align="center">
  <h4 align="center">
    <a href="{{ website.homepage }}" title="Megabyte Labs homepage" target="_blank">
      <img alt="Homepage" src="{{ repository.project.assets }}/svg/home-solid.svg" />
    </a>
    <a href="{{ repository.github }}{{ repository.location.contributing.github }}" title="Learn about contributing" target="_blank">
      <img alt="Contributing" src="{{ repository.project.assets }}/svg/contributing-solid.svg" />
    </a>
    <a href="{{ profile.patreon }}" title="Support us on Patreon" target="_blank">
      <img alt="Patreon" src="{{ repository.project.assets }}/svg/support-solid.svg" />
    </a>
    <a href="{{ chat_url }}" title="Slack chat room" target="_blank">
      <img alt="Slack" src="{{ repository.project.assets }}/svg/chat-solid.svg" />
    </a>
    <a href="{{ repository.github }}" title="GitHub mirror" target="_blank">
      <img alt="GitHub" src="{{ repository.project.assets }}/svg/github-solid.svg" />
    </a>
    <a href="{{ repository.gitlab }}" title="GitLab repository" target="_blank">
      <img alt="GitLab" src="{{ repository.project.assets }}/svg/gitlab-solid.svg" />
    </a>
  </h4>
  <p align="center">
    <a alt="Version: {{ pkg.version }}" href="{{ repository.github }}" target="_blank">
      <img alt="Version: {{ pkg.version }}" src="https://img.shields.io/badge/version-{{ pkg.version }}-blue.svg?cacheSeconds=2592000" />
    </a>
    <a title="Windows 11 build status on GitHub" href="{{ repository.github }}/actions/Windows.yml" target="_blank">
      <img alt="Windows 11 build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/{{ slug }}/Windows/master?color=cyan&label=Windows%20build&logo=windows&style={{ badge_style }}">
    </a>
    <a title="macOS build status on GitHub" href="{{ repository.github }}/actions/macOS.yml" target="_blank">
      <img alt="macOS build status" src="https://img.shields.io/github/workflow/status/{{ profile.github }}/{{ slug }}/macOS/master?label=macOS%20build&logo=apple&style={{ badge_style }}">
    </a>
    <a title="Linux build status on GitLab" href="{{ repository.gitlab }}{{ repository.location.commits.gitlab }}" target="_blank">
      <img alt="Linux build status" src="{{ repository.gitlab }}/badges/master/pipeline.svg">
    </a>
    <a title="Documentation" href="{{ website.documentation }}/ansible" target="_blank">
      <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg?logo=readthedocs&style={{ badge_style }}" />
    </a>
    <a title="View license agreement" href="{{ repository.github }}/blob/master/LICENSE" target="_blank">
      <img alt="License: {{ license }}" src="https://img.shields.io/badge/license-{{ license }}-yellow.svg?style={{ badge_style }}" />
    </a>
    <a title="Support us on Open Collective" href="{{ profile.opencollective }}" target="_blank">
      <img alt="Open Collective sponsors" src="https://img.shields.io/opencollective/sponsors/megabytelabs?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAElBMVEUAAACvzfmFsft4pfD////w+P9tuc5RAAAABHRSTlMAFBERkdVu1AAAAFxJREFUKM9jgAAXIGBAABYXMHBA4yNEXGBAAU2BMz4FIIYTNhtFgRjZPkagFAuyAhGgHAuKAlQBCBtZB4gzQALoDsN0Oobn0L2PEUCoQYgZyOjRQFiJA67IRrEbAJImNwFBySjCAAAAAElFTkSuQmCC&label=Open%20Collective%20sponsors&logo=opencollective&style={{ badge_style }}" />
    </a>
    <a title="Support us on GitHub" href="{{ profile_link.github }}/{{ profile.github }}" target="_blank">
      <img alt="GitHub sponsors" src="https://img.shields.io/github/sponsors/{{ profile.github }}?label=GitHub%20sponsors&logo=github&style={{ badge_style }}" />
    </a>
    <a title="Follow us on GitHub" href="{{ profile_link.github }}/{{ profile.github }}" target="_blank">
      <img alt="GitHub: {{ profile.github }}" src="https://img.shields.io/github/followers/{{ profile.github }}?style=social" target="_blank" />
    </a>
    <a title="Follow us on Twitter" href="https://twitter.com/{{ profile.twitter }}" target="_blank">
      <img alt="Twitter: {{ profile.twitter }}" src="https://img.shields.io/twitter/url/https/twitter.com/{{ profile.twitter }}.svg?style=social&label=Follow%20%40{{ profile.twitter }}" />
    </a>
  </p>
</div>
