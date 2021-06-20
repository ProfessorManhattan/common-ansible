## Dependencies

Most of our roles rely on [Ansible Galaxy]({{ profile_link.galaxy }}) collections. Some of our projects are also dependent on other roles and collections that are published on Ansible Galaxy. Before you run this role, you will need to install the collection and role dependencies, as well as the Python requirements, by running:

```
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml
```

### Galaxy Roles

Although most of our roles do not have dependencies, there are some cases where another role has to be installed before the logic can continue. At the beginning of the play, the Ansible Galaxy role dependencies listed in `meta/main.yml` will run. These dependencies are configured to only run once per playbook. If you include more than one of our roles in your playbook that have dependencies in common then the dependency installation will be skipped after the first run. Some of our roles also utilize helper roles which help keep our [main playbook]({{ repository.playbooks }}) DRY.

The `requirements.yml` file contains a full list of the dependencies required by this role (i.e. `meta/main.yml` dependencies, helper roles, and collections). For your convenience, the full list of the dependencies along with quick descriptions is below:

{{ role_dependencies }}
