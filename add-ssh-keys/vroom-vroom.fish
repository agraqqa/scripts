#!/opt/homebrew/bin/fish

# fish shell script to batch ssh-add keys to ssh-agent
# Requires 1Password cli `op` to get the keys paths and keys passwords
# Requires OP_VAULT environment variable to be set to the name of the vault in 1Password
# Single key in 1Password must be an item same name as the key file, it's password must be set in the `password` field

set SCRIPT_NAME (basename (status filename))

# Path to the custom ssh-askpass script
set SSH_ASKPASS_CUSTOM_SCRIPT_NAME ssh_1pass.sh
set SCRIPT_PATH (dirname (status filename))
set SSH_ASKPASS_CUSTORM_SCRIPT "$SCRIPT_PATH/$SSH_ASKPASS_CUSTOM_SCRIPT_NAME"

# Path to the 1Password item, must be a secret reference
set KEYS_ITEM "op://$OP_VAULT/ssh_keys_list/keys"

# Reset ssh-agent before adding the keys
set RESET_AGENT true

# Check if SSH_ASKPASS_CUSTORM_SCRIPT exists
if test ! -f $SSH_ASKPASS_CUSTORM_SCRIPT
    echo "$SCRIPT_NAME: Error: $SSH_ASKPASS_CUSTOM_SCRIPT script not found $SSH_ASKPASS_CUSTORM_SCRIPT"
    exit 1
end

# Check if OP_VAULT environment variable is set
if test -z $OP_VAULT
    echo "$SCRIPT_NAME: Error: OP_VAULT environment variable is not set"
    exit 1
end

# Check if 1Password cli `op` is installed
if test ! -f (which op)
    echo "$SCRIPT_NAME: 1Password 1️⃣🔑 cli is not installed"
    exit 1
end

# Check connection to the 1Password by getting the user (service account) info
printf "$SCRIPT_NAME: Connecting to 1Password...\n" 
op user get --me | grep -E 'Name:|Type:'
if test $status -ne 0
    echo "$SCRIPT_NAME: Error: Could not authenticate to 1Password"
    exit 1
end
printf "$SCRIPT_NAME: ...done\n"

# Get the list of keys from 1Password
# Must be a space separated list of absolute paths to the keys
set keys (op read $KEYS_ITEM | string split ' ')
if test $status -ne 0
    echo "$SCRIPT_NAME: Error getting the list of keys from 1Password"
    exit 1
end

if $RESET_AGENT
    echo "$SCRIPT_NAME: Resetting the agent..."
    ssh-add -D
    if test $status -ne 0
        echo "$SCRIPT_NAME: Error resetting the agent"
        exit 1
    end
end

set keys_added 0
for key in $keys
    if test -f $key
        printf "$SCRIPT_NAME: Adding %s to the agent...\n" $key
        set --export TMPL420KEY $key
        DISPLAY=1 SSH_ASKPASS="$SSH_ASKPASS_CUSTORM_SCRIPT" ssh-add $key < /dev/null
        if test $status -ne 0
            printf "$SCRIPT_NAME: Error adding %s key to the agent\n" $key
            exit 1
        end
        set keys_added (math $keys_added + 1)
    else
        printf "$SCRIPT_NAME: Warning: key file %s not found\n" $key
    end
end
set --erase TMPL420KEY

if test $keys_added -eq 0
    echo "$SCRIPT_NAME: Error: No keys were added"
    exit 1
end

printf "$SCRIPT_NAME: %s keys are locked and loaded. Have a nice crawling!" $keys_added
