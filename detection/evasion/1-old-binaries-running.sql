-- Alert on programs running that are unusually old
--
-- false positive:
--   * legimitely ancient programs. For instance, printer drivers.
--
-- references:
--   * https://attack.mitre.org/techniques/T1070/006/ (Indicator Removal on Host: Timestomp)
--
-- tags: transient process state
SELECT
  p.path,
  p.cmdline,
  p.cwd,
  p.pid,
  p.name,
  f.mtime,
  f.ctime,
  p.cgroup_path,
  ((strftime('%s', 'now') - f.ctime) / 86400) AS ctime_age_days,
  ((strftime('%s', 'now') - f.mtime) / 86400) AS mtime_age_days,
  ((strftime('%s', 'now') - f.btime) / 86400) AS btime_age_days,
  h.sha256,
  f.uid,
  m.data,
  f.gid
FROM
  processes p
  LEFT JOIN file f ON p.path = f.path
  LEFT JOIN hash h ON p.path = h.path
  LEFT JOIN magic m ON p.path = m.path
WHERE
  (
    ctime_age_days > 1460
    OR mtime_age_days > 1460
  )
  -- Jan 1st, 1980 (the source of many false positives)
  AND f.mtime > 315561600
  AND f.path NOT LIKE '/home/%/idea-IU-223.8214.52/%'
  AND f.directory NOT LIKE '/Applications/%.app/Contents/Frameworks/%/Resources'
  AND f.directory NOT LIKE '/Applications/%.app/Contents/MacOS'
  AND f.directory NOT LIKE '/opt/homebrew/Cellar/%/bin'
  AND f.path NOT IN (
    '/Applications/Gitter.app/Contents/Library/LoginItems/GitterHelperApp.app/Contents/MacOS/GitterHelperApp',
    '/Applications/Pandora.app/Contents/Frameworks/Electron Framework.framework/Versions/A/Resources/crashpad_handler',
    '/Applications/Skitch.app/Contents/Library/LoginItems/J8RPQ294UB.com.skitch.SkitchHelper.app/Contents/MacOS/J8RPQ294UB.com.skitch.SkitchHelper',
    '/Applications/Vimari.app/Contents/PlugIns/Vimari Extension.appex/Contents/MacOS/Vimari Extension',
    '/Library/Apple/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/Resources/usbmuxd',
    '/Library/Application Support/EPSON/Scanner/ScannerMonitor/Epson Scanner Monitor.app/Contents/MacOS/Epson Scanner Monitor',
    '/Library/Application Support/LogiFacecam.bundle/Contents/MacOS/LogiFacecamService',
    '/Library/Application Support/Logitech/com.logitech.vc.LogiVCCoreService/LogiVCCoreService.app/Contents/MacOS/LogiVCCoreService',
    '/Library/Application Support/Razer/RzUpdater.app/Contents/MacOS/RzUpdater',
    '/Library/Java/JavaVirtualMachines/jdk-17.0.2.jdk/Contents/Home/bin/java',
    '/Volumes/CANON_IJ/Setup.app/Contents/MacOS/Setup',
    '/opt/IRCCloud/chrome-sandbox',
    '/opt/IRCCloud/irccloud',
    '/snap/brackets/138/opt/brackets/Brackets-node',
    '/snap/brackets/138/opt/brackets/Brackets',
    '/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/Resources/usbmuxd',
    '/usr/bin/dbus-broker-launch',
    '/usr/bin/espeak',
    '/usr/bin/i3blocks',
    '/usr/bin/i3lock',
    '/usr/bin/mono-sgen',
    '/usr/bin/pavucontrol',
    '/usr/bin/sshfs',
    '/usr/bin/unpigz',
    '/usr/bin/xbindkeys',
    '/usr/bin/xclip',
    '/usr/bin/xsel',
    '/usr/bin/xsettingsd',
    '/usr/bin/xss-lock',
    '/usr/libexec/dconf-service',
    '/usr/local/bin/dive'
  )
  AND f.path NOT LIKE '/Library/Printers/%'
  AND p.name NOT IN (
    'Android File Transfer Agent',
    'BluejeansHelper',
    'buildkitd',
    'dlv',
    'Flycut',
    'gitstatusd-darwin-arm64',
    'gitstatusd-linu',
    'J8RPQ294UB.com.skitch.SkitchHelper',
    'kail',
    'Pandora Helper',
    'Pandora',
    'SetupWizard',
    'Vimari Extension'
  )
  AND f.path NOT LIKE '/private/var/folders/%/T/AppTranslocation/%/d/Skitch.app/Contents/MacOS/Skitch'
  AND f.path NOT LIKE '/private/var/folders/%/T/AppTranslocation/%/d/Spectacle.app/Contents/MacOS/Spectacle'
  AND f.path NOT LIKE '/snap/surfshark/%/usr/bin/gjs-console'
  AND f.filename NOT LIKE 'protoc-%'
  AND p.cgroup_path NOT LIKE '/system.slice/docker-%'
  AND p.cgroup_path NOT LIKE '/user.slice/user-%.slice/user@%.service/user.slice/nerdctl-%'
  AND p.cgroup_path NOT LIKE '/user.slice/user-%.slice/user@%.service/user.slice/podman-%'
GROUP BY
  p.pid,
  p.path
