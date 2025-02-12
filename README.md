Some handy automation scripts for the daily life

# Integrations used

## 1Password CLI

- [op](https://developer.1password.com/docs/cli/)

Most of the secrets are stored in 1Password, so the `op` tool must be installed and configured

### 1Password CLI environment variables

- `OP_SERVICE_ACCOUNT_TOKEN` - the token for the service account that has access to the vault. If not set, touchID, Apple Watch confirmation or password will be required
- `OP_VAULT` - the name of the vault where the secrets are stored

# add-ssh-keys

[vroom-vroom.fish](add-ssh-keys/vroom-vroom.fish) is a fish script that adds ssh keys to the ssh-agent in a batch mode. It wraps `ssh-add` command using custom SSH_ASKPASS_PATH script [ssh_1pass.sh](add-ssh-keys/ssh_1pass.sh).

It is useful when you have multiple password protected ssh keys and you don't want to add them manually every time you restart your computer

Usage example:

```fish
source ~/git/agraqqa/scripts/add-ssh-keys/vroom-vroom.fish
```

# moon-phase

[moon-phase.bash](moon-phase.bash) is a bash script that returns the current moon phase as an emoji.

Useful for the terminal prompt customization in order to get sure that it is an appropriate time to run complex commands 🐺 🌝

Example:

```bash
🌓 ~/git/agraqqa/scripts/ > ./dump_database.sh # Half moon is the best time to do that
```
