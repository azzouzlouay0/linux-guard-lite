# 🛡️ Linux Guard Lite

**A modular Linux administration toolkit built with Bash.**

Linux Guard Lite is a command-line application designed to simplify essential Linux administration tasks through a single interactive menu.

Developed as a collaborative academic project by three students, it combines nine Linux administration modules.

## Features

| Module | Description |
|---|---|
| 1. File Management | Create, list, and delete files and directories |
| 2. User Management | Manage users and groups |
| 3. Permissions Management | View, modify, and check file permissions |
| 4. Compression | Compress and extract archives |
| 5. Backup & Restore | Back up and restore files |
| 6. Cron Scheduling | Schedule recurring tasks |
| 7. AT Scheduling | Schedule one-time tasks |
| 8. Network Configuration | Inspect network settings and connectivity |
| 9. System Administration | Monitor system resources and services |

## Getting Started

**Requirements:** Ubuntu Linux, Bash, Git, and the command-line packages listed in `REQUIREMENTS.md`.

```bash
git clone https://github.com/YOUR_USERNAME/linux-guard-lite.git
cd linux-guard-lite
bash main.sh
```

Replace `YOUR_USERNAME` with your GitHub username.

## Architecture

```text
linux-guard-lite/
├── main.sh
├── modules/
│   ├── files.sh
│   ├── users.sh
│   ├── permissions.sh
│   ├── compression.sh
│   ├── backup.sh
│   ├── cron.sh
│   ├── at.sh
│   ├── network.sh
│   └── administration.sh
├── README.md
└── REQUIREMENTS.md
```

The main menu uses a Bash function to launch each module independently.

## Team

| Member | Responsibilities |
|---|---|
| Louay | Files, users, permissions |
| Adem | Compression, backups, cron |
| Saddem | AT, networking, system administration |

## Project Objectives

- Apply Linux administration concepts through Bash scripting.
- Build a modular, interactive CLI.
- Practice Git and GitHub collaboration.
- Automate common system administration tasks.

**Note:** This project is intended for educational use. Test administrative operations in a controlled Ubuntu environment.
