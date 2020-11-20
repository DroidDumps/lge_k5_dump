#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:11613420:65723eb189af7ade89877b24e9a7b53aaf72af88; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:10861800:393e600021d9361a184228f4cb756675361a027d EMMC:/dev/block/bootdevice/by-name/recovery 65723eb189af7ade89877b24e9a7b53aaf72af88 11613420 393e600021d9361a184228f4cb756675361a027d:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
