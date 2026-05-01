import os from 'os'

export interface SystemInfo {
  platform: string
  arch: string
  osName: string
}

export function detectSystem(): SystemInfo {
  const platform = os.platform()
  const arch = os.arch()

  let osName = 'Unknown'

  if (platform === 'darwin') {
    osName = `macOS ${os.release()}`
  } else if (platform === 'linux') {
    try {
      const release = require('fs').readFileSync('/etc/os-release', 'utf-8')
      const pretty = release.match(/^PRETTY_NAME="(.+)"$/m)
      osName = pretty ? pretty[1] : 'Linux'
    } catch {
      osName = 'Linux'
    }
  } else if (platform === 'win32') {
    osName = 'Windows'
  }

  return { platform, arch, osName }
}
