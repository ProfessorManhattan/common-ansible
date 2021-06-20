<div align="center">
  <h4 align="center">
    <a href="{{ website.homepage }}" title="Megabyte Labs homepage" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/home-solid.svg" />
    </a>
    <a href="{{ repository.playbooks }}/-/blob/master/CONTRIBUTING.md" title="Learn about contributing" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/contributing-solid.svg" />
    </a>
    <a href="{{ profile.patreon }}" title="Support us on Patreon" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/support-solid.svg" />
    </a>
    <a href="{{ chat_url }}" title="Slack chat room" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/chat-solid.svg" />
    </a>
    <a href="{{ profile.github }}/InstallDoctor" title="GitHub mirror" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/github-solid.svg" />
    </a>
    <a href="{{ repository.playbooks }}" title="GitLab repository" target="_blank">
      <img src="https://gitlab.com/megabyte-labs/assets/-/raw/master/svg/gitlab-solid.svg" />
    </a>
  </h4>
  <p align="center">
    <a href="{{ repository.playbooks }}" target="_blank">
      <img alt="Version: {{ pkg.version }}" src="https://img.shields.io/badge/version-{{ pkg.version }}-blue.svg?cacheSeconds=2592000" />
    </a>
    <a href="{{ profile.github }}/InstallDoctor/actions/Windows.yml" target="_blank">
      <img alt="Windows 10 build status" src="https://img.shields.io/github/workflow/status/ProfessorManhattan/InstallDoctor/Windows/master?color=cyan&label=Windows%20build&logo=windows&style={{ badge_style }}">
    </a>
    <a href="{{ profile.github }}/InstallDoctor/actions/macOS.yml" target="_blank">
      <img alt="macOS build status" src="https://img.shields.io/github/workflow/status/ProfessorManhattan/InstallDoctor/macOS/master?label=macOS%20build&logo=apple&style={{ badge_style }}">
    </a>
    <a href="{{ repository.playbooks }}/commits/master" target="_blank">
      <img alt="Linux build status" src="{{ repository.group.ansible_roles }}/{{ role_name }}/badges/master/pipeline.svg">
    </a>
    <a href="{{ website.documentation }}/ansible" target="_blank">
      <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg?logo=readthedocs&style={{ badge_style }}" />
    </a>
    <a href="{{ repository.playbooks }}/-/raw/master/LICENSE" target="_blank">
      <img alt="License: {{ license }}" src="https://img.shields.io/badge/license-{{ license }}-yellow.svg?style={{ badge_style }}" />
    </a>
    <a href="{{ profile.opencollective }}" title="Support us on Open Collective" target="_blank">
      <img alt="Open Collective sponsors" src="https://img.shields.io/opencollective/sponsors/megabytelabs?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAElBMVEUAAACvzfmFsft4pfD////w+P9tuc5RAAAABHRSTlMAFBERkdVu1AAAAFxJREFUKM9jgAAXIGBAABYXMHBA4yNEXGBAAU2BMz4FIIYTNhtFgRjZPkagFAuyAhGgHAuKAlQBCBtZB4gzQALoDsN0Oobn0L2PEUCoQYgZyOjRQFiJA67IRrEbAJImNwFBySjCAAAAAElFTkSuQmCC&label=Open%20Collective%20sponsors&logo=opencollective&style={{ badge_style }}" />
    </a>
    <a href="{{ profile.github }}" title="Support us on GitHub" target="_blank">
      <img alt="GitHub sponsors" src="https://img.shields.io/github/sponsors/ProfessorManhattan?label=GitHub%20sponsors&logo=github&style={{ badge_style }}" />
    </a>
    <a href="{{ profile.github }}" target="_blank">
      <img alt="GitHub: ProfessorManhattan" src="https://img.shields.io/github/followers/ProfessorManhattan?style=social" target="_blank" />
    </a>
    <a href="https://twitter.com/{{ profile.twitter }}" target="_blank">
      <img alt="Twitter: {{ profile.twitter }}" src="https://img.shields.io/twitter/url/https/twitter.com/{{ profile.twitter }}.svg?style=social&label=Follow%20%40{{ profile.twitter }}" />
    </a>
  </p>
</div>
