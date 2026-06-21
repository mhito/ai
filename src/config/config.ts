import fs from 'fs'
import path from 'path'
import os from 'os'

export const CONFIG_PATH = path.join(os.homedir(), '.ai', 'config')

export interface Config {
  language: string
  provider: string
  model: string
  apiKey?: string
  host?: string
  hasPrompt?: string
}

interface IniSection {
  [key: string]: string
}

function parseIni(content: string): { global: IniSection; sections: { [name: string]: IniSection } } {
  const global: IniSection = {}
  const sections: { [name: string]: IniSection } = {}
  let currentSection: string | null = null

  for (const line of content.split('\n')) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#') || trimmed.startsWith(';')) continue

    const sectionMatch = trimmed.match(/^\[(.+)\]$/)
    if (sectionMatch) {
      currentSection = sectionMatch[1]
      continue
    }

    const kvMatch = trimmed.match(/^([^=]+)=(.*)$/)
    if (!kvMatch) continue

    const key = kvMatch[1].trim()
    const value = kvMatch[2].trim()

    if (currentSection) {
      if (!sections[currentSection]) sections[currentSection] = {}
      sections[currentSection][key] = value
    } else {
      global[key] = value
    }
  }

  return { global, sections }
}

function serializeIni(global: IniSection, sections: { [name: string]: IniSection }): string {
  const lines: string[] = []

  for (const [key, value] of Object.entries(global)) {
    lines.push(`${key}=${value}`)
  }

  if (lines.length > 0) lines.push('')

  for (const [name, kv] of Object.entries(sections)) {
    lines.push(`[${name}]`)
    for (const [key, value] of Object.entries(kv)) {
      lines.push(`${key}=${value}`)
    }
    lines.push('')
  }

  return lines.join('\n')
}

export function loadProviderConfig(providerName: string): { apiKey?: string; host?: string; model?: string; hasPrompt?: string } {
  if (!fs.existsSync(CONFIG_PATH)) return {}

  const content = fs.readFileSync(CONFIG_PATH, 'utf-8')
  const { global, sections } = parseIni(content)
  const section = sections[providerName]

  if (!section) return {}

  return {
    apiKey: section['api_key'],
    host: section['host'],
    model: section['model'],
    hasPrompt: section['has_prompt']
  }
}

export function saveConfig(config: Config): void {
  const configDir = path.dirname(CONFIG_PATH)
  fs.mkdirSync(configDir, { recursive: true })

  let global: IniSection = {}
  const sections: { [name: string]: IniSection } = {}

  if (fs.existsSync(CONFIG_PATH)) {
    const existing = parseIni(fs.readFileSync(CONFIG_PATH, 'utf-8'))
    global = existing.global
    for (const [name, kv] of Object.entries(existing.sections)) {
      sections[name] = { ...kv }
    }
  }

  global['provider'] = config.provider

  if (!sections[config.provider]) sections[config.provider] = {}
  sections[config.provider]['model'] = config.model

  if (config.apiKey) {
    sections[config.provider]['api_key'] = config.apiKey
  }
  if (config.host) {
    sections[config.provider]['host'] = config.host
  }
  if (config.hasPrompt) {
    sections[config.provider]['has_prompt'] = config.hasPrompt
  }

  fs.writeFileSync(CONFIG_PATH, serializeIni(global, sections))
}

export function ensureConfigPermissions(): void {
  if (process.platform !== 'win32' && fs.existsSync(CONFIG_PATH)) {
    fs.chmodSync(CONFIG_PATH, 0o600)
  }
}
