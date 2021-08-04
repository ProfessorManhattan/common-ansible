## Example Playbook

With the dependencies installed, all you have to do is add the role to your main playbook. The role handles the `become` behavior so you can simply add the role to your playbook without having to worry about commands that should not be run as root:

```lang-yml
- hosts: all
  roles:
    - professormanhattan.{{ role_name }}
```

If you are incorporating this role into a pre-existing playbook, then it might be prudent to copy the requirements in `requirements.txt` and `requirements.yml` to their corresponding files in the root of your playbook.
