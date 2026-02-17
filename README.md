# Void Linux BSPWM Auto Install Dotfiles

Script ini digunakan untuk **menginstall dan mengkonfigurasi dotfiles BSPWM secara otomatis** di **Void Linux**.


## Cara Install

Clone repository:

```bash
git clone https://github.com/t4n-tech/bspwm.git
cd bspwm
```

```
install-intel  →  intel
install-amd    →  amd
```

---

## Struktur Project

```
config/        → Semua konfigurasi utama
fonts/         → Nerd Fonts
themes/        → GTK Themes
icons/         → Icon theme
other/         → Tambahan (pipewire, xorg config, dll)
install        → Script auto installer
```

---

## Default Keybind (sxhkd)

### Applications & Utilities

| Keybinding              | Fungsi                         |
| ----------------------- | ------------------------------ |
| `Super + Enter`         | Open **Alacritty**             |
| `Super + Shift + Enter` | Open **XFCE4 Terminal**        |
| `Super + d`             | Rofi App Launcher (drun)       |
| `Super + y`             | Rofi Window Switcher           |
| `Super + Shift + y`     | Rofi Monitor Menu              |
| `Super + e`             | Open **Thunar** (File Manager) |
| `Super + w`             | Open **Firefox**               |
| `Print`                 | Flameshot GUI                  |
| `Super + Shift + s`     | Flameshot GUI (Alternate)      |
| `Super + Shift + w`     | Open `nmtui` (WiFi Manager)    |
| `Super + n`             | Monitor Connect (HDMI)         |
| `Super + m`             | Monitor Disconnect (HDMI)      |
| `XF86AudioRaiseVolume`  | Volume Up                      |
| `XF86AudioLowerVolume`  | Volume Down                    |
| `XF86AudioMute`         | Mute Audio                     |
| `XF86AudioMicMute`      | Toggle Mic                     |
| `Super + Shift + a`     | Audio Output Switch            |
| `XF86MonBrightnessUp`   | Brightness Up                  |
| `XF86MonBrightnessDown` | Brightness Down                |
| `XF86PowerOff`          | Power Menu                     |
| `Super + p`             | Power Profiles Menu            |

---

### BSPWM Window Management

| Keybinding                            | Fungsi                              |
| ------------------------------------- | ----------------------------------- |
| `Super + Alt + r`                     | Reload BSPWM                        |
| `Super + q`                           | Close Focused Window                |
| `Super + f`                           | Toggle Fullscreen                   |
| `Super + Shift + f`                   | Set Tiled Mode                      |
| `Super + Space`                       | Toggle Floating                     |
| `Super + Shift + Space`               | Force Tiled (~floating)             |
| `Super + h / j / k / l`               | Move Focus (West/South/North/East)  |
| `Super + Shift + h / j / k / l`       | Swap Window (West/South/North/East) |
| `Super + Alt + h / j / k / l`         | Resize Window (Expand)              |
| `Super + Alt + Shift + h / j / k / l` | Resize Window (Shrink)              |

---

### Workspace Management

| Keybinding            | Fungsi                         |
| --------------------- | ------------------------------ |
| `Super + 1-6`         | Switch to Workspace 1–6        |
| `Super + 7-9`         | Switch to Workspace Desktop7–9 |
| `Super + Shift + 1-6` | Move Window to Workspace 1–6   |
| `Super + Tab`         | Next Workspace                 |
| `Super + Shift + Tab` | Previous Workspace             |

---

## Uninstall

Hapus konfigurasi:

```bash
rm -rf ~/.config/bspwm
rm -rf ~/.config/sxhkd
rm -rf ~/.config/polybar
rm -rf ~/.config/rofi
rm -rf ~/.config/picom
rm -rf ~/.config/dunst
```

---

#### Create By
@[Gh0sT4n](https://github.com/gh0st4n/)