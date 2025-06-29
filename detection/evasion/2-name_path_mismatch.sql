-- Processes that have an unrelated name in the process tree than the program on disk.
--
-- false positives:
--   * new software, particularly those using interpreted languages
--
-- references:
--   * https://attack.mitre.org/techniques/T1036/004/ (Masquerade Task or Service)
--
-- tags: persistent process
SELECT
  SUBSTR(
    COALESCE(
      -- TODO: Fix to not require filename!
      REGEX_MATCH (f.filename, '(.*?)\W', 1),
      f.filename
    ),
    0,
    6
  ) AS short_filename,
  COALESCE(REGEX_MATCH (p0.path, '.*/(.*)', 1), p0.path) AS basename,
  COALESCE(
    REGEX_MATCH (p0.path, '.*/([a-zA-Z]+)', 1),
    p0.path
  ) AS base_letters,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    COALESCE(REGEX_MATCH (p0.path, '.*/(.*)', 1), p0.path),
    ',',
    p0.name
  ) AS exception_key,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.cgroup_path AS p0_cgroup,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256,
  -- Grandparent
  p1.parent AS p2_pid,
  p2.name AS p2_name,
  p2.path AS p2_path,
  p2.cmdline AS p2_cmd,
  p2_hash.sha256 AS p2_sha256
FROM
  processes p0
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
WHERE
  p0.path != ''
  AND NOT p0.name == basename
  AND NOT (
    LENGTH(basename) > 1
    AND basename == short_filename
  )
  AND NOT (
    LENGTH(p0.name) > 2
    AND INSTR(LOWER(basename), LOWER(p0.name)) > 0
  )
  AND NOT (
    LENGTH(short_filename) > 2
    AND INSTR(LOWER(p0.name), LOWER(short_filename)) > 0
  ) -- Extremely common and unpredictable process name setters
  AND NOT base_letters IN (
    'bash',
    'busybox',
    'dash',
    'electron',
    'firefox',
    'gjs',
    'librewolf',
    'node',
    'perl',
    'python',
    'ruby',
    'systemd',
    'thunderbird',
    'vim'
  )
  AND NOT exception_key IN (
    '0,newgrp,sg',
    '0,systemd-executor,(sd-pam)',
    '0,udevadm,(udev-worker)',
    '0,udevadm,systemd-udevd',
    '112,systemd-executor,(sd-pam)',
    '120,systemd-executor,(sd-pam)',
    '128,systemd-executor,(sd-pam)',
    '42,systemd-executor,(sd-pam)',
    '500,busybox,sh',
    '500,chainctl,docker-credenti',
    '500,coreutils,tail',
    '500,docker,code',
    '500,gjs-console,daemon.js',
    '500,gjs-console,gnome-character',
    '500,libgvc6-config-update,dot',
    '500,mate-session,x-session-manag',
    '500,nc.openbsd,nc',
    '500,netcat,nc',
    '500,plugin-container,MainThread',
    '500,pyrogenesis,main',
    '500,rootlesskit,exe',
    '500,rootlessport,exe',
    '500,systemd-executor,(sd-pam)',
    '500,udevadm,(udev-worker)',
    '500,udevadm,systemd-udevd',
    '500,vim.basic,vi',
    '500,vim.nox,vi',
    '500,vim.tiny,vi',
    '500,x86_64-linux-gnu-as,as'
  )
  AND NOT exception_key LIKE '%,systemd,(sd-pam)'
  AND NOT (
    p0.path LIKE '/usr/lib/%/panel/wrapper-2.0'
    AND exception_key LIKE '500,wrapper-2.0,panel-%'
  )
  AND NOT p0.path IN ('/usr/lib/systemd/systemd')
  AND NOT p0_cgroup LIKE '/system.slice/docker-%'
GROUP by
  exception_key
