# Void Linux BSPWM Auto Install Dotfiles

Script ini digunakan untuk **menginstall dan mengkonfigurasi dotfiles BSPWM secara otomatis** di **Void Linux**.

Konfigurasi sudah termasuk:

* BSPWM
* SXHKD
* Polybar
* Picom
* Dunst
* Rofi
* Alacritty
* GTK Themes (Everforest & TokyoNight)
* Nerd Fonts(FiraCode, IosevkaTearm, JetbrainsMono & NerdFontsSymbolsOnly)
* Pipewire Helper Scripts

## 🚀 Cara Install

Clone repository:

```bash
git clone https://github.com/t4n-tech/bspwm.git
cd bspwm
chmod +x install
./install
```

Script akan otomatis:

1. Update system
2. Install dependency yang dibutuhkan
3. Copy dotfiles ke `~/.config`
4. Install fonts ke `~/.local/share/fonts`
5. Copy themes ke `~/.themes`
6. Copy icons ke `~/.icons`
7. Set permission script
8. Enable service jika diperlukan

---

## 📁 Struktur Project

```
config/        → Semua konfigurasi utama
fonts/         → Nerd Fonts
themes/        → GTK Themes
icons/         → Icon theme
other/         → Tambahan (pipewire, xorg config, dll)
install        → Script auto installer
```

---

## 🛠 Package yang Diinstall

Script akan menginstall package berikut menggunakan `xbps-install`:

```bash
# Core Package
xorg bspwm sxhkd rofi picom polybar alacritty dmenu feh
network-manager-applet Thunar gvfs gvfs-mtp thunar-archive-plugin
thunar-media-tags-plugin brightnessctl xss-lock xfce4-terminal
playerctl lm_sensors htop btop fastfetch firefox chromium flameshot 
galculator geany timeshift lxappearance papirus-icon-theme 
gtk-engine-murrine arc-theme font-awesome nerd-fonts
dejavu-fonts-ttf noto-fonts-ttf noto-fonts-cjk fontconfig
betterlockscreen i3lock-color xrdb

# PipeWire Package
pipewire wireplumber libspa-bluetooth alsa-pipewire
libjack-pipewire pavucontrol pamixer

# Service Package
dbus elogind NetworkManager lightdm rtkit polkit
```

---

## 🎨 Themes

Tersedia 2 theme utama:

### Everforest Dark

### TokyoNight Storm

Kamu bisa mengganti theme melalui:

```bash
lxappearance
```

---

## 🔤 Fonts

Termasuk:

* FiraCode Nerd Font
* IosevkaTerm Nerd Font
* JetBrainsMono Nerd Font
* Symbols Nerd Font

Setelah install, refresh cache:

```bash
fc-cache -fv
```

---

## ⚙ Default Keybind (sxhkd)

| Key                 | Fungsi        |
| ------------------- | ------------- |
| `Super + Enter`     | Buka Terminal |
| `Super + d`         | Rofi Launcher |
| `Super + alt + r`   | Reload BSPWM  |
| `Super +  q`        | Close Window  |

---

## 🔊 Audio

Menggunakan:

* PipeWire
* WirePlumber

Helper script tersedia di:

```
~/.config/other/pipewire/
```

---

## 🖼 Wallpaper

Wallpaper tersedia di:

```
~/.config/bspwm/wallpaper/
```

Bisa diganti manual atau via script.

---

## ❗ Troubleshooting

Jika BSPWM tidak muncul:

```bash
echo "exec bspwm" > ~/.xinitrc
startx
```

Jika polybar tidak muncul:

```bash
~/.config/polybar/launch.sh
```

---

## 🧹 Uninstall

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

## 🧠 Tips

* Gunakan `startx` jika tanpa display manager
* Gunakan LightDM untuk login GUI
* Backup dotfiles lama sebelum install

---
---
---
#### Create By
@[Gh0sT4n](https://github.com/gh0st4n/)