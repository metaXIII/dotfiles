# Installer drivers nvidia (Work for fedora 43)

```bash
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y && sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y && sudo dnf upgrade --refresh -y && sudo dnf install kmodtool akmods mokutil openssl -y && sudo kmodgenca -a && sudo mokutil --import /etc/pki/akmods/certs/public_key.der
```

*Choose a password*

**Carefull, password will be qwerty !!!**

```bash
sudo systemctl reboot
```

Enroll MOK key with password specified

reboot

```
sudo dnf install gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs.{i686,x86_64} libva-nvidia-driver.{i686,x86_64} xorg-x11-drv-nvidia-cuda
```

Wait a while, then : 
 ```bash
 modinfo -F version nvidia
 ```

Ensure modules are builts : 
```bash
sudo akmods --force && sudo dracut --force
```


## Load nvidia modules early

Make sure nvidia modules are load early : 

```bash
sudo nvim /etc/default/grub
```
see line containing GRUB_CMDLINE_LINUX
add at the end rd.driver.pre=nvidia nvidia-drm.modeset=1
to make it like :

`GRUB_CMDLINE_LINUX="rhgb quiet rd.driver.pre=nvidia nvidia-drm.modeset=1"`


```bash
sudo nano /etc/dracut.conf.d/nvidia.conf
```

```bash
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
```

reload grub config

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg && sudo dracut -f
```


## Bonus 
Do not forget to install flatpak apps for GE proton : 

```bash
flatpak install net.davidotek.pupgui2
```