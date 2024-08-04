# How to verify SSH login.

## How to verify SSH login to user containrs

This is a semi-automatic test.

```
[Example]

$ sh utils/run-test-ssh-login-scripts.sh work/list.users
```
1. Run the script above.
   It shows the script template to test SSH login to containers.
   Please copy and paste them for the test.
1. the file `work/list.users` was automatically generated when you ran "make" at the first time.
   This file format is "user-name password" per line
   where this password is a 16 chars random string.
