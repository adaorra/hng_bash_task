# hng_bash_task
## Overview

This bash script `create_users.sh` automates the process of creating users and assigning them to their various groups. It reads a text file known as `users.txt` that has the users and their groups and further ensures the passwords of the users are secured.

## Details of Script

- **Script Name**: `create_users.sh`
- **Script Language**: Bash

## Usage 
 
- First clone the repo
- Create a text file `users.txt`
- Add users to the text file using this format `users;group`

### Example Text File

```
adaorra;admin,dev
vera;sudo
```

## To run the script 
- Use the command  `sudo bash create_users.sh <users.txt>`

The above command runs the script and reads the text file and creates the users and adds them to their respective groups

### Execution of Script

1. **Create Directories and Files**: Ensures the secure and log directories and files exist.
2. **Check Text File**: Validates and reads the text file adding reads users and groups in it.
3. **Run with Sudo Privileges**: Ensures the script is run with sudo privileges.
4. **User Account Creation**: 
   - Verifies if the user already exists.
   - Generates a secure password for users.
   - Adds the user and sets their secure password.
   - Creates the user's home directory.
     
5. **Group Management**: 
   - Checks if the group exists.
   - Adds the user to the group, creates the group if it doesn't exist.
     
## Confirmation:

To verify the user logs run this command: 
```
sudo cat /var/log/user_management.log
```
To verify the passwords generated, run this command:
```
sudo cat /var/secure/user_passwords.csv
```

## Logging

The script logs all activities to the `/var/log/user_management.log`.

## Conclusion

This script provides a seamless and  secure method to create users and add them to their respective groups while creating a secure password.
