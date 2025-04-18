# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'login' 2>/dev/null | grep -q '^installed'; then

var_account_disable_post_pw_expiration='35'

# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/default/useradd"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^INACTIVE")

# shellcheck disable=SC2059
printf -v formatted_output "%s=%s" "$stripped_key" "$var_account_disable_post_pw_expiration"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^INACTIVE\\>" "/etc/default/useradd"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^INACTIVE\\>.*/$escaped_formatted_output/gi" "/etc/default/useradd"
else
    if [[ -s "/etc/default/useradd" ]] && [[ -n "$(tail -c 1 -- "/etc/default/useradd" || true)" ]]; then
        LC_ALL=C sed -i --follow-symlinks '$a'\\ "/etc/default/useradd"
    fi
    
    printf '%s\n' "$formatted_output" >> "/etc/default/useradd"
fi

# Apply the inactivity policy to existing accounts
while IFS=: read -r username _; do
    # Skip system accounts (UID < 1000), special accounts, and the admin account "msuarladmin"
    if id -u "$username" &>/dev/null && [[ $(id -u "$username") -ge 1000 ]] && [[ "$username" != "msuarladmin" ]]; then
        chage --inactive "$var_account_disable_post_pw_expiration" "$username"
    fi
done < <(awk -F: '{print $1}' /etc/passwd)

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi