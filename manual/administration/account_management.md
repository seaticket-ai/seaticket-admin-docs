# Account management


## Add a new admin account

Ensure the container is running, then enter this command:

```bash
docker exec -it seaqa-web /scripts/reset-admin.sh
```

Enter the username and password according to the prompts. You now have a new admin account.

## Forgot admin account or password?

Simply create a new admin account as described above, and then use this new account to reset the password for the old admin account.
