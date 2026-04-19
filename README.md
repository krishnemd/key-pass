# KeyPass - Simple Password Manager

Lightning-fast password manager for macOS with menu bar integration and CLI access.

## ⚡ Quick Start

**Install (one-time):**
```bash
./install.sh
source ~/.zshrc
```

**Use from terminal:**
```bash
kp 1              # Copy password #1 instantly
kp github         # Search & copy
kp add            # Add password
kp list           # List all
```

**Or use menu bar (with SwiftBar):**
- Click 🔐 icon → Click password → Done!

---

## 🎯 Two Ways to Use

### Option 1: Terminal (Power Users) ⚡

**Quick copy by number:**
```bash
$ kp list
1. GitHub
2. Netflix
3. AWS

$ kp 1            # ✓ Copied GitHub - instant!
```

**Search and copy:**
```bash
$ kp netflix      # ✓ Copied Netflix
$ kp aws          # ✓ Copied AWS
```

**Manage passwords:**
```bash
$ kp add          # Add new password
$ kp delete       # Delete password
```

---

### Option 2: Menu Bar (Everyone) 🖱️

**Setup (one-time):**
```bash
brew install swiftbar
cp keypass-menubar.1m.sh ~/.swiftbar-plugins/
open -a SwiftBar
```

**Use:**
1. Click 🔐 icon in menu bar
2. Select category → Click password name → Copied!
3. Paste anywhere

**Menu features:**
- 📂 Category organization (Work, Personal, Finance, etc.)
- ➕ Add Password (dialog with category)
- 🗑️ Delete Password (dialog)
- 🔓 Unlock Vault (dialog)
- 🎨 Color-coded categories
- No terminal needed!

---

## ✨ Features

**Speed:**
- ⚡ Instant copy by number: `kp 1`
- 🎯 Smart search: `kp git` finds "GitHub"
- 📋 Auto-copy to clipboard
- ⏱️ Auto-clear in 30s

**Security:**
- 🔐 AES-256-CBC encryption
- 🔒 PBKDF2 (100,000 iterations)
- 💾 100% local (no network)
- 🚫 Zero dependencies

**Convenience:**
- 💨 Master password cached (5 min)
- 🖱️ Menu bar integration
- ⌨️ Terminal access
- 📱 macOS notifications

---

## 📖 Usage Examples

**Terminal workflow:**
```bash
# See your passwords with numbers
kp list

# Copy by number (fastest!)
kp 1

# Or search
kp github
kp netflix

# Add new
kp add
```

**Menu bar workflow:**
```
Click 🔐 → Click "GitHub" → Paste (Cmd+V)
```

---

## 🔒 Security Details

- **Encryption:** AES-256-CBC with PBKDF2 (100,000 iterations)
- **Storage:** `~/Library/Application Support/KeyPass/vault.enc`
- **Permissions:** 600 (owner-only read/write)
- **Master password:** Cached securely for 5 minutes
- **Clipboard:** Auto-clears after 30 seconds
- **Network:** Zero - completely offline

---

## 🎁 Distribution

**Share with friends:**

**Just the CLI:**
```bash
# Send them 'keypass' file
chmod +x keypass
./keypass add
```

**Complete package:**
```bash
# Zip everything
zip -r keypass.zip keypass install.sh keypass-menubar.1m.sh README.md

# They unzip and install
./install.sh
```

**With menu bar:**
```bash
# They need SwiftBar
brew install swiftbar
cp keypass-menubar.1m.sh ~/.swiftbar-plugins/
```

---

## 🔧 Advanced

**Backup vault:**
```bash
cp ~/Library/Application\ Support/KeyPass/vault.enc ~/backup/
```

**Change master password:**
```bash
# Start fresh (deletes all passwords)
rm -rf ~/Library/Application\ Support/KeyPass/
kp add  # Set new master password
```

**Uninstall:**
```bash
# Remove from PATH
nano ~/.zshrc  # Delete keypass export lines

# Remove vault
rm -rf ~/Library/Application\ Support/KeyPass/

# Remove menu bar plugin
rm ~/.swiftbar-plugins/keypass-menubar.1m.sh
```

---

---

## 📋 Vault Data Format

**SwiftBar (v2.0):** Supports categories
```
category|name|password
Work|GitHub|ghp_abc123
Personal|Netflix|pass123
```

**CLI (current):** No categories yet
```
name|password
GitHub|ghp_abc123
Netflix|pass123
```

**Note:** Old format passwords appear under "Uncategorized" in SwiftBar menu. Both formats work together seamlessly.

---

## ⚠️ Important

- **Master Password:** If forgotten, passwords are UNRECOVERABLE
- **Backup:** Regularly backup `vault.enc` file  
- **Use case:** Personal password manager - simple, fast, secure

---

## 📁 Project Structure

```
key-pass/
├── keypass                    # Main CLI tool
├── keypass-menubar.1m.sh      # SwiftBar menu bar plugin
├── install.sh                 # PATH installer
└── README.md                  # This file
```

**Storage:**
```
~/Library/Application Support/KeyPass/
├── vault.enc                  # Encrypted password vault
└── .master                    # Cached master password (temp)
```

---

## 🛠️ Technical Details

**Built with:**
- Pure bash shell script
- `openssl` for encryption (AES-256-CBC)
- `pbcopy/pbpaste` for clipboard
- `osascript` for dialogs (menu bar)
- SwiftBar for menu bar integration

**Requirements:**
- macOS (any recent version)
- No external dependencies!

**Encryption:**
```bash
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000
```

---

## 🎯 Design Philosophy

- **Zero dependencies** - Works on any Mac out of the box
- **Fast first** - Optimized for daily use, not edge cases
- **Local only** - No cloud, no network, no tracking
- **Simple** - Easy to understand, modify, share
- **Secure enough** - AES-256 for personal use

---

## 📝 License

MIT License - Do whatever you want with it!

---

**Made with ❤️ for fast, simple password management**
- `openssl` - AES-256 encryption (built into macOS)
- `pbcopy` - Clipboard access (built into macOS)
- No external dependencies!

**Files:**
- `keypass` - Main script (fast CLI)
- `keypass.sh` - Full interactive version (menu-based)
- `install.sh` - PATH installer
- `SETUP.md` - Detailed usage guide

**Requirements:**
- macOS (any recent version)
- bash, openssl, pbcopy (all pre-installed)

## 📝 License

Free to use, modify, and share!

## Security

- **Encryption:** AES-256-CBC with password-based key derivation (PBKDF2, 100K iterations)
- **File permissions:** Vault file is 600 (owner read/write only)
- **Master password:** Never stored, required each run
- **Clipboard:** Auto-clears after 30 seconds
- **Storage:** `~/Library/Application Support/KeyPass/vault.enc`

## Distribution

### Share with Friends (Simple Binary)

Since this is a shell script, just share the file:

```bash
# Send keypass.sh to friends
# They run it with:
chmod +x keypass.sh
./keypass.sh
```

**Requirements:** macOS (any version with bash and openssl - all have it!)

### Create Alias (Optional)

Run the installer to add `keypass` to your PATH:

```bash
./install.sh
source ~/.zshrc
```

Then just run `keypass` or `kp` from anywhere!

## Technical Details

**Built with:**
- `bash` - Shell script
- `openssl` - AES-256 encryption (built into macOS)
- `pbcopy` - Clipboard access (built into macOS)
- No external dependencies!

**Why shell script?**
- Works on any Mac without installation
- No Rust/Python/etc compilation needed
- Uses proven crypto (OpenSSL)
- Easy to audit (simple bash code)
- Zero network requirements

## Important Notes

⚠️ **Master Password:** If you forget it, your passwords are unrecoverable  
⚠️ **Backup:** Copy `~/Library/Application Support/KeyPass/vault.enc` to backup encrypted passwords  
⚠️ **Security:** This is for personal use - not enterprise-grade but solid for individual password management

## License

Free to use, modify, and share!



