-- Find unexpected setuid binaries on disk
--
-- false positives:
--   * new software
--
-- tags: persistent seldom
-- platform: posix
SELECT
  GROUP_CONCAT(path) AS paths,
  gid,
  uid,
  mode,
  type,
  size,
  data,
  sha256
FROM
  (
    SELECT
      file.path,
      file.gid,
      file.uid,
      file.inode,
      file.mode,
      file.type,
      file.size,
      magic.data,
      hash.sha256
    FROM
      file
      LEFT JOIN hash ON file.path = hash.path
      LEFT JOIN magic ON file.path = magic.path
    WHERE
      file.directory IN (
        '/bin',
        '/etc',
        '/opt/google-cloud-sdk/bin',
        '/opt/homebrew/bin',
        '/opt/homebrew/sbin',
        '/sbin',
        '/tmp',
        '/usr/bin',
        '/usr/lib',
        '/usr/lib/jvm/default/bin',
        '/usr/lib64',
        '/usr/libexec',
        '/usr/local/bin',
        '/usr/local/lib',
        '/usr/local/lib64',
        '/usr/local/libexec',
        '/usr/local/sbin',
        '/usr/sbin',
        '/var/lib',
        '/var/tmp'
      )
      AND type = 'regular'
      AND mode NOT LIKE '0%'
      AND mode NOT LIKE '1%'
      AND mode NOT LIKE '2%'
      AND NOT (
        mode LIKE '4%11'
        AND uid = 0
        AND gid = 0
        AND file.path IN (
          '/bin/bwrap',
          '/bin/cdda2wav',
          '/bin/cdrecord',
          '/bin/chfn',
          '/bin/chsh',
          '/bin/grub2-set-bootflag',
          '/bin/icedax',
          '/bin/mount.nfs',
          '/bin/mount.nfs4',
          '/bin/readcd',
          '/bin/readom',
          '/bin/rscsi',
          '/bin/staprun',
          '/bin/sudo',
          '/bin/sudoedit',
          '/bin/umount.nfs',
          '/bin/umount.nfs4',
          '/bin/wodim',
          '/usr/local/libexec/ssh-keysign',
          '/sbin/cdda2wav',
          '/sbin/cdrecord',
          '/sbin/chfn',
          '/sbin/chsh',
          '/sbin/icedax',
          '/sbin/mount.nfs',
          '/sbin/mount.nfs4',
          '/sbin/readcd',
          '/sbin/readom',
          '/sbin/rscsi',
          '/bin/userhelper',
          '/usr/bin/userhelper',
          '/sbin/sudo',
          '/sbin/sudoedit',
          '/sbin/umount.nfs',
          '/sbin/umount.nfs4',
          '/sbin/userhelper',
          '/sbin/wodim',
          '/usr/bin/bwrap',
          '/usr/bin/cdda2wav',
          '/usr/bin/cdrecord',
          '/usr/bin/chfn',
          '/usr/bin/chsh',
          '/usr/bin/grub2-set-bootflag',
          '/usr/bin/icedax',
          '/usr/bin/mount.nfs',
          '/usr/bin/mount.nfs4',
          '/usr/bin/readcd',
          '/usr/bin/readom',
          '/usr/bin/rscsi',
          '/usr/bin/staprun',
          '/usr/bin/sudo',
          '/usr/bin/sudoedit',
          '/usr/bin/umount.nfs',
          '/usr/bin/umount.nfs4',
          '/usr/bin/wodim',
          '/usr/libexec/security_authtrampoline',
          '/usr/libexec/xf86-video-intel-backlight-helper',
          '/usr/sbin/cdda2wav',
          '/usr/sbin/cdrecord',
          '/usr/sbin/chfn',
          '/usr/sbin/chsh',
          '/usr/sbin/icedax',
          '/usr/sbin/mount.nfs',
          '/usr/sbin/mount.nfs4',
          '/usr/sbin/readcd',
          '/usr/sbin/readom',
          '/usr/sbin/rscsi',
          '/usr/sbin/sudo',
          '/usr/sbin/sudoedit',
          '/usr/sbin/umount.nfs',
          '/usr/sbin/umount.nfs4',
          '/usr/sbin/userhelper',
          '/usr/sbin/wodim'
        )
      )
      AND NOT (
        mode LIKE '4%55'
        AND uid = 0
        AND gid = 0
        AND file.path IN (
          '/bin/at',
          '/bin/atq',
          '/bin/screen',
          '/bin/screen-5.0.0',
          '/sbin/screen',
          '/sbin/screen-5.0.0',
          '/usr/bin/screen',
          '/usr/bin/screen-5.0.0',
          '/usr/sbin/screen',
          '/usr/sbin/screen-5.0.0',
          '/bin/atrm',
          '/bin/bwrap',
          '/bin/chage',
          '/bin/chfn',
          '/bin/chsh',
          '/bin/crontab',
          '/bin/doas',
          '/bin/expiry',
          '/bin/firejail',
          '/bin/fusermount',
          '/bin/fusermount-glusterfs',
          '/bin/fusermount3',
          '/bin/gpasswd',
          '/sbin/fusermount-glusterfs',
          '/usr/sbin/fusermount-glusterfs',
          '/bin/grub2-set-bootflag',
          '/bin/keybase-redirector',
          '/bin/ksu',
          '/bin/mount',
          '/bin/mount.nfs',
          '/bin/mount.nfs4',
          '/bin/mullvad-exclude',
          '/bin/ndisc6',
          '/bin/newgidmap',
          '/bin/newgrp',
          '/bin/newuidmap',
          '/bin/ntfs-3g',
          '/bin/nvidia-modprobe',
          '/bin/pam_timestamp_check',
          '/bin/passwd',
          '/bin/pkexec',
          '/bin/ps',
          '/sbin/atq',
          '/sbin/atrm',
          '/sbin/at',
          '/usr/sbin/atq',
          '/usr/sbin/atrm',
          '/usr/sbin/at',
          '/bin/rdisc6',
          '/bin/rltraceroute6',
          '/bin/schroot',
          '/bin/sg',
          '/bin/su',
          '/bin/sudo',
          '/sbin/vmware-user',
          '/sbin/vmware-user-suid-wrapper',
          '/usr/sbin/vmware-user',
          '/usr/sbin/vmware-user-suid-wrapper',
          '/bin/sudoedit',
          '/bin/suexec',
          '/bin/ubuntu-core-launcher',
          '/bin/umount',
          '/bin/umount.nfs',
          '/bin/umount.nfs4',
          '/bin/unix_chkpwd',
          '/bin/vmware-user',
          '/bin/vmware-user-suid-wrapper',
          '/sbin/chage',
          '/sbin/chfn',
          '/sbin/chsh',
          '/sbin/crontab',
          '/sbin/doas',
          '/sbin/expiry',
          '/sbin/firejail',
          '/sbin/fusermount',
          '/sbin/fusermount3',
          '/sbin/gpasswd',
          '/sbin/grub2-set-bootflag',
          '/sbin/ksu',
          '/sbin/mount',
          '/sbin/mount.cifs',
          '/sbin/mount.nfs',
          '/sbin/mount.nfs4',
          '/sbin/mount.ntfs',
          '/sbin/mount.ntfs-3g',
          '/sbin/mount.smb3',
          '/sbin/mullvad-exclude',
          '/sbin/ndisc6',
          '/sbin/newgrp',
          '/sbin/nvidia-modprobe',
          '/sbin/pam_timestamp_check',
          '/sbin/passwd',
          '/sbin/pkexec',
          '/sbin/rdisc6',
          '/sbin/rltraceroute6',
          '/sbin/sg',
          '/sbin/su',
          '/sbin/sudo',
          '/sbin/sudoedit',
          '/sbin/suexec',
          '/sbin/umount',
          '/sbin/umount.nfs',
          '/sbin/umount.nfs4',
          '/sbin/unix_chkpwd',
          '/sbin/usernetctl',
          '/usr/bin/at',
          '/usr/bin/atq',
          '/usr/bin/atrm',
          '/usr/bin/batch',
          '/usr/bin/bwrap',
          '/usr/bin/chage',
          '/usr/bin/chfn',
          '/usr/bin/chsh',
          '/usr/bin/crontab',
          '/usr/bin/doas',
          '/usr/bin/expiry',
          '/usr/bin/firejail',
          '/usr/bin/fusermount',
          '/usr/bin/fusermount-glusterfs',
          '/usr/bin/fusermount3',
          '/usr/bin/gpasswd',
          '/usr/bin/grub2-set-bootflag',
          '/usr/bin/keybase-redirector',
          '/usr/bin/ksu',
          '/usr/bin/login',
          '/usr/bin/mount',
          '/usr/bin/mount.nfs',
          '/usr/bin/mount.nfs4',
          '/usr/bin/mullvad-exclude',
          '/usr/bin/ndisc6',
          '/usr/bin/newgidmap',
          '/usr/bin/newgrp',
          '/usr/bin/newuidmap',
          '/usr/bin/ntfs-3g',
          '/usr/bin/nvidia-modprobe',
          '/usr/bin/pam_timestamp_check',
          '/usr/bin/passwd',
          '/usr/bin/pkexec',
          '/usr/bin/quota',
          '/usr/bin/rdisc6',
          '/usr/bin/rltraceroute6',
          '/usr/bin/schroot',
          '/usr/bin/sg',
          '/usr/bin/su',
          '/usr/bin/sudo',
          '/usr/bin/sudoedit',
          '/usr/bin/suexec',
          '/usr/bin/top',
          '/usr/bin/ubuntu-core-launcher',
          '/usr/bin/umount',
          '/usr/bin/umount.nfs',
          '/usr/bin/umount.nfs4',
          '/usr/bin/unix_chkpwd',
          '/usr/bin/vmware-user',
          '/usr/bin/vmware-user-suid-wrapper',
          '/usr/lib/mail-dotlock',
          '/usr/lib/xf86-video-intel-backlight-helper',
          '/usr/lib/Xorg.wrap',
          '/usr/lib64/mail-dotlock',
          '/usr/lib64/xf86-video-intel-backlight-helper',
          '/usr/lib64/Xorg.wrap',
          '/usr/libexec/authopen',
          '/usr/libexec/libgtop_server2',
          '/usr/libexec/polkit-agent-helper-1',
          '/usr/libexec/qemu-bridge-helper',
          '/usr/libexec/spice-client-glib-usb-acl-helper',
          '/usr/libexec/Xorg.wrap',
          '/usr/local/bin/doas',
          '/usr/sbin/chage',
          '/usr/sbin/chfn',
          '/usr/sbin/chsh',
          '/usr/sbin/crontab',
          '/usr/sbin/doas',
          '/usr/sbin/expiry',
          '/usr/sbin/firejail',
          '/usr/sbin/fusermount',
          '/usr/sbin/fusermount3',
          '/usr/sbin/gpasswd',
          '/usr/sbin/grub2-set-bootflag',
          '/usr/sbin/ksu',
          '/usr/sbin/mount',
          '/usr/sbin/mount.cifs',
          '/usr/sbin/mount.nfs',
          '/usr/sbin/mount.nfs4',
          '/usr/sbin/mount.ntfs',
          '/usr/sbin/mount.ntfs-3g',
          '/usr/sbin/mount.smb3',
          '/usr/sbin/mullvad-exclude',
          '/usr/sbin/ndisc6',
          '/usr/sbin/newgrp',
          '/usr/sbin/nvidia-modprobe',
          '/usr/sbin/pam_timestamp_check',
          '/usr/sbin/passwd',
          '/usr/sbin/pkexec',
          '/usr/sbin/rdisc6',
          '/usr/sbin/rltraceroute6',
          '/usr/sbin/sg',
          '/usr/sbin/su',
          '/usr/sbin/sudo',
          '/usr/sbin/sudoedit',
          '/usr/sbin/suexec',
          '/usr/sbin/traceroute',
          '/usr/sbin/traceroute6',
          '/usr/sbin/umount',
          '/usr/sbin/umount.nfs',
          '/usr/sbin/umount.nfs4',
          '/usr/sbin/unix_chkpwd',
          '/usr/sbin/usernetctl'
        )
      )
      AND NOT (
        mode = '4754'
        AND uid = 0
        AND gid = 30
        AND file.path IN ('/usr/sbin/pppd', '/sbin/pppd')
      )
      AND NOT (
        mode = '6755'
        AND uid = 0
        AND gid IN (0,8)
        AND file.path IN (
          '/bin/light',
          '/bin/man',
          '/bin/mandb',
          '/bin/mount.cifs',
          '/bin/mount.smb3',
          '/bin/procmail',
          '/bin/unix_chkpwd',
          '/sbin/mandb',
          '/sbin/mount.cifs',
          '/sbin/mount.smb3',
          '/sbin/unix_chkpwd',
          '/usr/bin/light',
          '/usr/bin/mandb',
          '/usr/bin/mount.cifs',
          '/usr/bin/mount.smb3',
          '/usr/bin/procmail',
          '/usr/bin/unix_chkpwd',
          '/usr/lib/xtest',
          '/usr/lib64/xtest',
          '/usr/sbin/mandb',
          '/usr/sbin/mount.cifs',
          '/usr/sbin/mount.smb3',
          '/usr/sbin/unix_chkpwd',
          '/bin/procmail',
          '/usr/bin/procmail'
        )
      )
      AND NOT (
        mode = '4110'
        AND uid = 0
        AND gid = 156
        AND file.path IN ('/bin/staprun', '/usr/bin/staprun', '/sbin/staprun', '/usr/sbin/staprun')
      )
  )
GROUP BY
  inode
