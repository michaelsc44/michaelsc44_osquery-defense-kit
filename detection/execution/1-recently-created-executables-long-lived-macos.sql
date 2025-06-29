-- Long-running programs who were started around when they were written to disk
--
-- false-positives:
--   * many
--
-- tags: transient process state
-- platform: darwin
SELECT
  f.ctime,
  f.btime,
  f.mtime,
  p0.start_time,
  s.authority AS s_auth,
  s.identifier AS s_id,
  REPLACE(f.directory, u.directory, '~') AS dir,
  COALESCE(
    REGEX_MATCH (
      REPLACE(f.directory, u.directory, '~'),
      '(~/.*?/.*?/.*?/)',
      1
    ),
    REPLACE(f.directory, u.directory, '~')
  ) AS top3_dir,
  REPLACE(f.path, u.directory, '~') AS homepath,
  p0.start_time - f.btime AS start_birth_delta,
  -- Child
  p0.pid AS p0_pid,
  p0.start_time AS p0_start,
  p0.path AS p0_path,
  s.authority AS p0_sauth,
  s.identifier AS p0_sid,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.start_time AS p1_start,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256,
  -- Grandparent
  p1.parent AS p2_pid,
  p2.name AS p2_name,
  p2.start_time AS p2_start,
  p2.path AS p2_path,
  p2.cmdline AS p2_cmd,
  p2_hash.sha256 AS p2_sha256
FROM
  processes p0
  LEFT JOIN signature s ON p0.path = s.path
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN users u ON f.uid = u.uid
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
WHERE
  p0.pid IN (
    SELECT
      pid
    FROM
      processes
    WHERE
      start_time > 0
      AND start_time > (strftime('%s', 'now') - 86400)
      AND pid > 0
      AND path != ""
      AND NOT path LIKE '/Applications/%'
      AND NOT path LIKE '/bin/%'
      AND NOT path LIKE '/Library/Apple/%'
      AND NOT path LIKE '/Library/Elastic/Agent/data/%/components/%'
      AND NOT path LIKE '/nix/store/%'
      AND NOT path LIKE '/opt/%'
      AND NOT path LIKE '/System/%'
      AND NOT path LIKE '/usr/bin/%'
      AND NOT path LIKE '/usr/libexec/%'
      AND NOT path LIKE '/usr/local/kolide-k2/bin/%'
      AND NOT path LIKE '/usr/sbin/%'
      AND NOT path LIKE '%/bin/cargo'
  )
  -- Processes that started around when they were last modified on disk
  AND start_birth_delta BETWEEN -900 AND 900
  -- Exceptions for no-privileged execution
  AND NOT (
    p0.euid > 499
    AND (
      top3_dir IN (
        '/Library/Application Support/EcammLive',
        '/Library/Developer/Xcode/',
        '/usr/local/kolide-k2/Kolide.app/Contents/MacOS',
        '~/.local/share/bob/',
        '~/.local/share/nvim/',
        '~/.cache/selenium/chromedriver/',
        '~/.terraform.d/plugin-cache/registry.terraform.io/',
        '~/.vscode/extensions/ms-vscode.cpptools-1.15.4-darwin-arm64/',
        '~/homebrew/Library/Homebrew/',
        '~/Library/Application Support/BraveSoftware/',
        '~/Library/Application Support/com.elgato.StreamDeck/',
        '~/Library/Application Support/duckly/',
        '~/Library/Application Support/Figma/',
        '~/Library/Application Support/Foxit Software/',
        '~/Library/Application Support/JetBrains/',
        '~/Library/Application Support/OpenLens',
        '~/Library/Application Support/sourcegraph-sp/',
        '~/Library/Application Support/Steam/',
        '~/Library/Application Support/WebEx Folder/',
        '~/Library/Application Support/Zed/',
        '~/Library/Application Support/Zwift',
        '~/Library/Application Support/Zwift/',
        '~/Library/Caches/com.mimestream.Mimestream/',
        '~/Library/Caches/com.sempliva.Tiles/',
        '~/Library/Caches/company.thebrowser.Browser/',
        '~/Library/Caches/JetBrains/',
        '~/Library/Caches/org.gpgtools.updater/',
        '~/Library/Caches/snyk/',
        '~/projects/go/src/'
      )
      OR dir IN (
        '/usr/local/aws-cli',
        '/usr/local/kolide-k2/Kolide.app/Contents/MacOS',
        '~/.local/bin',
        '~/.local/share/gh/extensions/gh-sbom',
        '~/.magefile',
        '~/bin',
        '~/code/bin',
        '~/go/bin',
        '~/gohome/bin',
        '~/Library/Application Support/cloud-code/installer/google-cloud-sdk/bin',
        '~/Library/Application Support/dev.warp.Warp-Stable',
        '~/Library/Application Support/snyk-ls',
        '~/Library/Application Support/zoom.us/Plugins/aomhost.app/Contents/MacOS',
        '~/melange',
        '~/projects/go/bin',
        '~/repos/bincapz/out'
      )
      OR dir LIKE '~/%.vscode/extensions/%'
      OR dir LIKE '~/%/go/bin'
      OR dir LIKE '~/%/node_modules/%bin'
      OR dir LIKE '~/.rustup/toolchains/%'
      OR dir LIKE '~/.vscode-insiders/extensions/%'
      OR dir LIKE '~/Applications/%.app/%'
      OR dir LIKE '~/dev/%'
      OR dir LIKE '~/Documents/GH/%'
      OR dir LIKE '~/Downloads/%.app/Contents/MacOS'
      OR dir LIKE '~/git/%'
      OR f.path LIKE '%go-build%'
      OR homepath LIKE '~/%/cloud_sql_proxy'
      OR homepath LIKE '~/%/gopls'
      OR homepath LIKE '~/%/pkg/%.test'
      OR homepath LIKE '~/%/src/%.test'
      OR homepath LIKE '~/%/terraform-provider-%'
      OR homepath LIKE '~/chainguard-dev/%'
      OR homepath LIKE '~/repos/%'
      OR homepath LIKE '~/github/%'
      OR homepath LIKE '~/go/%/bin'
      OR homepath LIKE '~/go/src/%'
      OR homepath LIKE '~/Parallels/%/WinAppHelper'
      OR homepath LIKE '~/src/%'
      OR f.path LIKE '/private/tmp/%/Creative Cloud Installer.app/Contents/MacOS/Install'
      OR f.path LIKE '/private/tmp/go-%'
      OR f.path LIKE '/private/tmp/nix-build-%'
      OR f.path LIKE '/private/var/db/com.apple.xpc.roleaccountd.staging/%'
      OR f.path LIKE '/private/var/folders/%/bin/%'
      OR f.path LIKE '/private/var/folders/%/d/Wrapper/%.app/%'
      OR f.path LIKE '/private/var/folders/%/GoLand/%'
      OR f.path LIKE '/private/var/folders/%/T/download/ARMDCHammer'
      OR f.path LIKE '/private/var/folders/%/T/pulumi-go.%'
    )
  )
  AND NOT s.authority IN (
    'Apple iPhone OS Application Signing',
    'Apple Mac OS Application Signing',
    'Developer ID Application: Adobe Inc. (JQ525L2MZD)',
    'Developer ID Application: AMZN Mobile LLC (94KV3E626L)',
    'Developer ID Application: Autodesk (XXKJ396S2Y)',
    'Developer ID Application: Azul Systems, Inc. (TDTHCUPYFR)',
    'Developer ID Application: Bitdefender SRL (GUNFMW623Y)',
    'Developer ID Application: Brave Software, Inc. (KL8N8XSYF4)',
    'Developer ID Application: Brother Industries, LTD. (5HCL85FLGW)',
    'Developer ID Application: Bryan Jones (49EYHPJ4Q3)',
    'Developer ID Application: Canon Inc. (XE2XNRRXZ5)',
    'Developer ID Application: Cisco (DE8Y96K9QP)',
    'Developer ID Application: CodeWeavers Inc. (9C6B7X7Z8E)',
    'Developer ID Application: Corsair Memory, Inc. (Y93VXCB8Q5)',
    'Developer ID Application: Denver Technologies, Inc (2BBY89MBSN)',
    'Developer ID Application: Docker Inc (9BNSXJN65R)',
    'Developer ID Application: Dropbox, Inc. (G7HH3F8CAK)',
    'Developer ID Application: Eclipse Foundation, Inc. (JCDTMS22B4)',
    'Developer ID Application: Elasticsearch, Inc (2BT3HPN62Z)',
    'Developer ID Application: Emmanouil Konstantinidis (3YP8SXP3BF)',
    'Developer ID Application: EnterpriseDB Corporation (26QKX55P9K)',
    'Developer ID Application: Fumihiko Takayama (G43BCU2T37)',
    'Developer ID Application: Galvanix (5BRAQAFB8B)',
    'Developer ID Application: Garmin International (72ES32VZUA)',
    'Developer ID Application: General Arcade (Pte. Ltd.) (S8JLSG5ES7)',
    'Developer ID Application: GEORGE NACHMAN (H7V7XYVQ7D)',
    'Developer ID Application: GitHub (VEKTX9H2N7)',
    'Developer ID Application: Google LLC (EQHXZ8M8AV)',
    'Developer ID Application: GPGTools GmbH (PKV8ZPD836)',
    'Developer ID Application: Hashicorp, Inc. (D38WU7D763)',
    'Developer ID Application: JetBrains s.r.o. (2ZEFAR8TH3)',
    'Developer ID Application: Kandji, Inc. (P3FGV63VK7)',
    'Developer ID Application: Keybase, Inc. (99229SGT5K)',
    'Developer ID Application: Kolide Inc (YZ3EM74M78)',
    'Developer ID Application: Kolide, Inc (X98UFR7HA3)',
    'Developer ID Application: Logitech Inc. (QED4VVPZWA)',
    'Developer ID Application: Michael Jones (YD6LEYT6WZ)',
    'Developer ID Application: Microsoft Corporation (UBF8T346G9)',
    'Developer ID Application: Mojang AB (HR992ZEAE6)',
    'Developer ID Application: Objective Development Software GmbH (MLZF7K7B5R)',
    'Developer ID Application: Objective-See, LLC (VBG97UB4TA)',
    'Developer ID Application: Opal Camera Inc (97Z3HJWCRT)',
    'Developer ID Application: OPENVPN TECHNOLOGIES, INC. (ACV7L3WCD8)',
    'Developer ID Application: OSQUERY A Series of LF Projects, LLC (3522FA9PXF)',
    'Developer ID Application: Parallels International GmbH (4C6364ACXT)',
    'Developer ID Application: Rapid7 LLC (UL6CGN7MAL)',
    'Developer ID Application: RescueTime, Inc (FSY4RB8H39)',
    'Developer ID Application: Seiko Epson Corporation (TXAEAV5RN4)',
    'Developer ID Application: SteelSeries (6WGL6CHFH2)',
    'Developer ID Application: Sublime HQ Pty Ltd (Z6D26JE4Y4)',
    'Developer ID Application: SUSE LLC (2Q6FHJR3H3)',
    'Developer ID Application: Tailscale Inc. (W5364U7YZB)',
    'Developer ID Application: The Browser Company of New York Inc. (S6N382Y83G)',
    'Developer ID Application: VMware, Inc. (EG7KH642X6)',
    'Developer ID Application: Wesley FURLONG (P4A6FU9KZ3)',
    'Developer ID Application: Wizards of OBS LLC (2MMRE5MTB8)',
    'Developer ID Application: Yubico Limited (LQA3CS5MM7)',
    'Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3)',
    'Developer ID Application: Zwift, Inc (C2GM8Y9VFM)',
    'Software Signing'
  )
  AND NOT (
    s.identifier = "com.apple.print.PrinterProxy"
    AND p0.path LIKE "/Users/%/Library/Printers/%/Contents/MacOS/PrinterProxy"
    AND p0.uid > 499
  )
  -- Local developer testing
  AND NOT (
    homepath LIKE '~/%'
    AND p0.uid > 499
    AND f.ctime = f.mtime
    AND f.uid = p0.uid
    AND p0.cmdline LIKE './%'
    AND p0.path NOT LIKE '%Library%'
    AND p0.path NOT LIKE '%/.%'
    AND p0.path NOT LIKE '%Cache%'
  )
  AND NOT p1.name IN ('makepkg', 'make')
  -- Arc
  AND NOT (
    p0.path LIKE '/Users/%/Library/Caches/%/org.sparkle-project.Sparkle/Launcher/%'
    AND s.identifier = 'org.sparkle-project.Sparkle.Updater'
    AND s.authority != ''
    AND p0.uid > 499
  )
  AND NOT (
    p0.path = '/Library/PrivilegedHelperTools/com.macpaw.CleanMyMac4.Agent'
    AND s_auth = 'Developer ID Application: MacPaw Inc. (S8EX82NJP6)'
  )
GROUP BY
  p0.pid
