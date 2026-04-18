#!/bin/bash
#
# KeyPass - Password Manager for SwiftBar
# Displays encrypted passwords in macOS menu bar with category organization
#
# <xbar.title>KeyPass Password Manager</xbar.title>
# <xbar.version>v2.0</xbar.version>
# <xbar.author>KeyPass</xbar.author>
# <xbar.desc>Quick password manager in menu bar with categories</xbar.desc>

#==============================================================================
# CONFIGURATION
#==============================================================================

VAULT_DIR="$HOME/Library/Application Support/KeyPass"
VAULT_FILE="$VAULT_DIR/vault.enc"
MASTER_PASS_FILE="$VAULT_DIR/.master"

#==============================================================================
# ACTION: ADD PASSWORD
#==============================================================================
if [ "$1" = "add" ]; then
    # Check if unlocked, if not prompt for master password
    if [ ! -f "$MASTER_PASS_FILE" ]; then
        MASTER_PASS=$(osascript -e 'Tell application "System Events" to display dialog "Enter master password:" default answer "" with title "KeyPass - Unlock Vault" with hidden answer' -e 'text returned of result' 2>/dev/null)
        
        if [ -z "$MASTER_PASS" ]; then
            exit 0
        fi
        
        # If vault exists, verify password
        if [ -f "$VAULT_FILE" ]; then
            if ! openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
                -in "$VAULT_FILE" -out /tmp/keypass_verify.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
                osascript -e 'display alert "Wrong Password" message "Incorrect master password"'
                rm -f /tmp/keypass_verify.tmp
                exit 1
            fi
            rm -f /tmp/keypass_verify.tmp
        fi
        
        # Cache master password
        echo "$MASTER_PASS" > "$MASTER_PASS_FILE"
        chmod 600 "$MASTER_PASS_FILE"
    else
        MASTER_PASS=$(cat "$MASTER_PASS_FILE")
    fi
    
    # Get category via dialog
    category=$(osascript -e 'Tell application "System Events" to display dialog "Category (e.g., Work, Personal, Finance):" default answer "Personal" with title "KeyPass - Add Password"' -e 'text returned of result' 2>/dev/null)
    
    if [ -z "$category" ]; then
        exit 0
    fi
    
    # Get password name via dialog
    name=$(osascript -e 'Tell application "System Events" to display dialog "Password name (e.g., GitHub, Netflix):" default answer "" with title "KeyPass - Add Password"' -e 'text returned of result' 2>/dev/null)
    
    if [ -z "$name" ]; then
        exit 0
    fi
    
    # Get password via dialog (hidden input)
    password=$(osascript -e 'Tell application "System Events" to display dialog "Enter password for '"$name"':" default answer "" with title "KeyPass - Add Password" with hidden answer' -e 'text returned of result' 2>/dev/null)
    
    if [ -z "$password" ]; then
        exit 0
    fi
    
    # Create vault dir if needed
    mkdir -p "$VAULT_DIR"
    chmod 700 "$VAULT_DIR"
    
    # Decrypt existing vault
    if [ -f "$VAULT_FILE" ]; then
        if ! openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
            -in "$VAULT_FILE" -out /tmp/keypass_add.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
            osascript -e 'display alert "Error" message "Failed to unlock vault"'
            exit 1
        fi
    else
        touch /tmp/keypass_add.tmp
    fi
    
    # Check if name exists in this category
    if grep -q "^$category|$name|" /tmp/keypass_add.tmp 2>/dev/null; then
        result=$(osascript -e 'Tell application "System Events" to display dialog "Password '"'$name'"' already exists in '"'$category'"'. Overwrite?" buttons {"Cancel", "Overwrite"} default button "Cancel" with title "KeyPass"' -e 'button returned of result' 2>/dev/null)
        
        if [ "$result" != "Overwrite" ]; then
            rm -f /tmp/keypass_add.tmp
            exit 0
        fi
        
        # Remove old entry
        grep -v "^$category|$name|" /tmp/keypass_add.tmp > /tmp/keypass_add.tmp.new 2>/dev/null || true
        mv /tmp/keypass_add.tmp.new /tmp/keypass_add.tmp
    fi
    
    # Add new entry (format: category|name|password)
    echo "$category|$name|$password" >> /tmp/keypass_add.tmp
    
    # Encrypt vault
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
        -in /tmp/keypass_add.tmp -out "$VAULT_FILE" -pass pass:"$MASTER_PASS" 2>/dev/null
    chmod 600 "$VAULT_FILE"
 ==============================================================================
# ACTION: DELETE PASSWORD
#==============================================================================

    rm -f /tmp/keypass_add.tmp
    
    osascript -e "display notification \"Password saved successfully\" with title \"KeyPass\" subtitle \"$name\""
    
    exit 0
fi

# Handle deleting password via dialog
if [ "$1" = "delete" ]; then
    if [ ! -f "$MASTER_PASS_FILE" ]; then
        MASTER_PASS=$(osascript -e 'Tell application "System Events" to display dialog "Enter master password:" default answer "" with title "KeyPass - Unlock Vault" with hidden answer' -e 'text returned of result' 2>/dev/null)
        
        if [ -z "$MASTER_PASS" ]; then
            exit 0
        fi
        
        if [ -f "$VAULT_FILE" ]; then
            if ! openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
                -in "$VAULT_FILE" -out /tmp/keypass_verify.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
                osascript -e 'display alert "Wrong Password" message "Incorrect master password"'
                rm -f /tmp/keypass_verify.tmp
                exit 1
            fi
            rm -f /tmp/keypass_verify.tmp
        fi
        
        echo "$MASTER_PASS" > "$MASTER_PASS_FILE"
        chmod 600 "$MASTER_PASS_FILE"
    else
        MASTER_PASS=$(cat "$MASTER_PASS_FILE")
    fi
    
    if ! openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
        -in "$VAULT_FILE" -out /tmp/keypass_del.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
        osascript -e 'display alert "Error" message "Failed to unlock vault"'
        exit 1
    fi
    
    if [ ! -s /tmp/keypass_del.tmp ]; then
        osascript -e 'display alert "No Passwords" message "Vault is empty - nothing to delete"'
        rm -f /tmp/keypass_del.tmp
        exit 0
    fi
    
    # Build list of passwords for dialog
    password_list=""
    while IFS='|' read -r col1 col2 col3; do
        if [ -z "$col3" ]; then
            display_name="$col1"
        else
            display_name="$col1 / $col2"
        fi
        
        if [ -z "$password_list" ]; then
            password_list="\"$display_name\""
        else
            password_list="$password_list, \"$display_name\""
        fi
    done < /tmp/keypass_del.tmp
    
    selected=$(osascript -e 'Tell application "System Events" to choose from list {'"$password_list"'} with prompt "Select password to delete:" with title "KeyPass - Delete Password"' 2>/dev/null)
    
    if [ "$selected" = "false" ] || [ -z "$selected" ]; then
        rm -f /tmp/keypass_del.tmp
        exit 0
    fi
    
    result=$(osascript -e 'Tell application "System Events" to display dialog "Delete password '"'$selected'"'?" buttons {"Cancel", "Delete"} default button "Cancel" with title "KeyPass - Confirm Delete"' -e 'button returned of result' 2>/dev/null)
    
    if [ "$result" != "Delete" ]; then
        rm -f /tmp/keypass_del.tmp
        exit 0
    fi
    
    # Remove the entry (handle both formats)
    if [[ "$selected" == *" / "* ]]; then
        category=$(echo "$selected" | cut -d'/' -f1 | sed 's/ *$//')
        name=$(echo "$selected" | cut -d'/' -f2 | sed 's/^ *//')
        grep -v "^$category|$name|" /tmp/keypass_del.tmp > /tmp/keypass_del.tmp.new 2>/dev/null || true
    else
        grep -v "^$selected|" /tmp/keypass_del.tmp > /tmp/keypass_del.tmp.new 2>/dev/null || true
    fi
    mv /tmp/keypass_del.tmp.new /tmp/keypass_del.tmp
    
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
        -in /tmp/keypass_del.tmp -out "$VAULT_FILE" -pass pass:"$MASTER_PASS" 2>/dev/null
    chmod 600 "$VAULT_FILE"
    
    rm -f /tmp/keypass_del.tmp
    
    osascript -e "display notification \"Password deleted successfully\" with title \"KeyPass\" subtitle \"$selected\""
    
 ==============================================================================
# ACTION: UNLOCK VAULT
#==============================================================================

fi

# Handle unlocking vault
if [ "$1" = "unlock" ]; then
    MASTER_PASS=$(osascript -e 'Tell application "System Events" to display dialog "Enter master password:" default answer "" with title "KeyPass - Unlock Vault" with hidden answer' -e 'text returned of result' 2>/dev/null)
    
    if [ -z "$MASTER_PASS" ]; then
        exit 0
    fi
    
    if [ -f "$VAULT_FILE" ]; then
        if ! openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
            -in "$VAULT_FILE" -out /tmp/keypass_unlock.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
            osascript -e 'display alert "Wrong Password" message "Incorrect master password. Please try again."'
            rm -f /tmp/keypass_unlock.tmp
            exit 1
        fi
        rm -f /tmp/keypass_unlock.tmp
    fi
    
    echo "$MASTER_PASS" > "$MASTER_PASS_FILE"
    chmod 600 "$MASTER_PASS_FILE"
 ==============================================================================
# ACTION: COPY PASSWORD
#==============================================================================

    osascript -e 'display notification "Vault unlocked (auto-locks in 5 minutes)" with title "KeyPass"'
    
    exit 0
fi

# Handle copying password by line number
if [ "$1" = "copy" ] && [ -n "$2" ]; then
    if [ -f "$MASTER_PASS_FILE" ]; then
        MASTER_PASS=$(cat "$MASTER_PASS_FILE")
        
        if openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
            -in "$VAULT_FILE" -out /tmp/keypass_copy.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
            
            # Get entry by line number
            entry=$(sed -n "${2}p" /tmp/keypass_copy.tmp)
            
            if [ -n "$entry" ]; then
                col1=$(echo "$entry" | cut -d'|' -f1)
                col2=$(echo "$entry" | cut -d'|' -f2)
                col3=$(echo "$entry" | cut -d'|' -f3)
                
                if [ -z "$col3" ]; then
                    # Old format: name|password
                    display_name="$col1"
                    password="$col2"
                else
                    # New format: category|name|password
                    display_name="$col2"
                    password="$col3"
                fi
                
                echo -n "$password" | pbcopy
                
                osascript -e "display notification \"Password copied to clipboard (clears in 30s)\" with title \"KeyPass\" subtitle \"$display_name\""
                
                # Clear clipboard after 30 seconds
                (
                    sleep 30
                    current=$(pbpaste)
                    if [ "$current" = "$password" ]; then
                        echo -n "" | pbcopy
                        osascript -e "display notification \"Clipboard cleared\" with title \"KeyPass\""
                    fi
                ) &
            fi
            
 ==============================================================================
# MENU BAR DISPLAY
#==============================================================================

#           rm -f /tmp/keypass_copy.tmp
        fi
    fi
    exit 0
fi

# Menu bar icon
echo "🔐"
echo "---"

# Check if vault exists
if [ ! -f "$VAULT_FILE" ]; then
    echo "No passwords yet | color=gray"
    echo "---"
    echo "➕ Add Password | bash='$0' param1=add terminal=false refresh=true"
    exit 0
fi

# Check for master password cache
if [ -f "$MASTER_PASS_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$MASTER_PASS_FILE"))) -lt 300 ]; then
    MASTER_PASS=$(cat "$MASTER_PASS_FILE")
    
    if openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
        -in "$VAULT_FILE" -out /tmp/keypass_menu.tmp -pass pass:"$MASTER_PASS" 2>/dev/null; then
        
        if [ -s /tmp/keypass_menu.tmp ]; then
            # First pass: collect unique categories and prepare data
            > /tmp/keypass_categories.tmp
            line_num=0
            
            while IFS='|' read -r col1 col2 col3; do
                ((line_num++))
                
                # Support both formats: category|name|password and name|password
                if [ -z "$col3" ]; then
                    # Old format: name|password (assign to "Uncategorized")
                    category="Uncategorized"
                    name="$col1"
                else
                    # New format: category|name|password
                    category="$col1"
                    name="$col2"
                fi
                
                # Store: category|name|line_number
                echo "$category|$name|$line_num" >> /tmp/keypass_categories.tmp
            done < /tmp/keypass_menu.tmp
            
            # Get unique sorted categories
            cat /tmp/keypass_categories.tmp | cut -d'|' -f1 | sort -u > /tmp/keypass_cats_unique.tmp
            
            # Display each category and its passwords
            while IFS= read -r category; do
                # Display category header with color
                echo "$category | color=#0066cc"
                
                # Display passwords in this category (sorted by name)
                grep "^$category|" /tmp/keypass_categories.tmp | sort -t'|' -k2 | while IFS='|' read -r cat name line_id; do
                    echo "--$name | bash='$0' param1=copy param2=$line_id terminal=false refresh=false"
                done
            done < /tmp/keypass_cats_unique.tmp
            
            rm -f /tmp/keypass_categories.tmp /tmp/keypass_cats_unique.tmp
        else
            echo "No passwords yet | color=gray"
        fi
        
        rm -f /tmp/keypass_menu.tmp
    else
        echo "Unlock Vault | bash='$0' param1=unlock terminal=false refresh=true"
    fi
else
    echo "🔒 Locked | color=red"
    echo "Unlock Vault | bash='$0' param1=unlock terminal=false refresh=true"
fi

echo "---"
echo "➕ Add Password | bash='$0' param1=add terminal=false refresh=true"
echo "🗑️ Delete Password | bash='$0' param1=delete terminal=false refresh=true"
