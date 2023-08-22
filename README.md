
# KDE Plasma automatic colorscheme switcher
**Seamlessly transition between KDE Plasma colorschemes at your chosen times (automated with bash and systemd)**


Made with bash scripts and systemd, this tool is easy to configure and install.

## - Why systemd over cron?

While cron has its merits, it falls short in handling scheduled tasks during specific scenarios, such as system shutdowns or restarts. Systemd, on the other hand, offers a more robust solution for these cases. Additionally, I encountered issues with both cron and anacron functioning locally. Rather than delving deeper into these issues, I opted for the straightforward nature of systemd and bash, especially since I didn't require cron or anacron for other tasks at the time, and a reliable automatic theme switcher was a must for me.

## How to install it?

1. First, configure the tool by running:
   ```bash
   ./configure.sh
   ```

2. Deploy it with:
   ```bash
   sudo ./deploy.sh
   ```

## To uninstall

1. Simply run:
    ```bash
    sudo ./remove.sh
    ```

## To reinstall

1. Run:
   ```bash
   ./configure.sh
   ```

2. Then:
   ```bash
   ./deploy.sh
   ```

## Tested on:

- Fedora 38 with KDE

## Dependencies:

- `whiptail`
