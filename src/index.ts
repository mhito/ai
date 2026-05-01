import fs from 'fs'
import path from 'path'
import Enquirer from 'enquirer'
const { Input, Select } = Enquirer as any
import {
  loadProviderConfig,
  saveConfig,
  ensureConfigPermissions,
  CONFIG_PATH,
  Config
} from './config/config'
import { detectSystem } from './system/detectSystem'
import { selectLanguage } from './prompts/language'
import { selectProvider } from './prompts/provider'
import { selectModel } from './prompts/model'

const INSTALL_DIR = path.resolve(__dirname, '..')

function clearConsole() {
  process.stdout.write(process.platform === 'win32' ? '\x1Bc' : '\x1B[2J\x1B[3J\x1B[H')
}

function printHeader() {
  console.log('')
  console.log('╔════════════════════════════════════════╗')
  console.log('║     AI (Terminal-AI) Installer         ║')
  console.log('╚════════════════════════════════════════╝')
  console.log('')
}

function printSuccess() {
  console.log('')
  console.log('╔════════════════════════════════════════╗')
  console.log('║   Installation Complete!               ║')
  console.log('╚════════════════════════════════════════╝')
  console.log('')
  console.log('Next steps:')
  console.log('  1. Run ai "your question" to generate commands')
  console.log('  2. Run aic "your question" for conversational queries')
  console.log('')
  console.log('Documentation: https://github.com/mhito/ai')
  console.log('')
}

function copyLanguagePrompts(language: string) {
  const configDir = path.join(require('os').homedir(), '.ai')
  fs.mkdirSync(configDir, { recursive: true })

  const aiPromptSrc = path.join(INSTALL_DIR, 'lang', `ai_${language}.md`)
  const aicPromptSrc = path.join(INSTALL_DIR, 'lang', `aic_${language}.md`)

  if (fs.existsSync(aiPromptSrc)) {
    fs.copyFileSync(aiPromptSrc, path.join(configDir, 'ai_prompt.txt'))
    console.log(`✓ AI prompt configured (${language})`)
  } else {
    console.log(`✗ AI prompt file not found for language: ${language}`)
  }

  if (fs.existsSync(aicPromptSrc)) {
    fs.copyFileSync(aicPromptSrc, path.join(configDir, 'aic_prompt.txt'))
    console.log(`✓ AIC prompt configured (${language})`)
  } else {
    console.log(`✗ AIC prompt file not found for language: ${language}`)
  }
}

async function main() {
  clearConsole()
  printHeader()

  const sys = detectSystem()
  console.log(`System: ${sys.osName} (${sys.arch})`)
  console.log('')

  // Language
  const language = await selectLanguage()
  console.log('')

  // Check existing INI config
  const hasExistingConfig = fs.existsSync(CONFIG_PATH)
  if (hasExistingConfig) {
    const reconfig = await new Select({
      name: 'reconfig',
      message: 'Existing configuration found. Do you want to reconfigure?',
      choices: [
        { name: 'n', message: 'No (keep existing)' },
        { name: 'y', message: 'Yes (reconfigure)' }
      ]
    }).run()

    if (reconfig === 'n') {
      console.log('')
      console.log('✓ Using existing configuration')
      console.log('')
      printSuccess()
      return
    }
    console.log('')
  }

  const provider = await selectProvider()
  console.log('')
  console.log(`🧠 ${provider.label} Configuration`)
  console.log('')

  // Load existing values for this specific provider from INI
  const existingProvider = loadProviderConfig(provider.name)

  // API Key
  let apiKey: string | undefined
  if (provider.requiresApiKey) {
    console.log('⚠️  Security Notice: Your API key will be stored in ~/.ai/config with 600 permissions')
    console.log('')

    if (existingProvider.apiKey) {
      const useExisting = await new Select({
        name: 'use_existing_key',
        message: 'Existing API key found for this provider. Use existing?',
        choices: [
          { name: 'y', message: 'Yes' },
          { name: 'n', message: 'No (enter new)' }
        ]
      }).run()

      if (useExisting === 'y') {
        apiKey = existingProvider.apiKey
      } else {
        apiKey = await new Input({ message: 'API Key' }).run()
      }
    } else {
      apiKey = await new Input({ message: 'API Key' }).run()
    }
    console.log('')
  }

  // Model
  const model = await selectModel(provider)
  console.log('')

  // Ollama-specific config
  let host: string | undefined
  let hasPrompt: string | undefined

  if (provider.name === 'ollama') {
    if (existingProvider.host) {
      const useExistingHost = await new Select({
        name: 'use_existing_host',
        message: `Existing Ollama host found: ${existingProvider.host}. Use existing?`,
        choices: [
          { name: 'y', message: 'Yes' },
          { name: 'n', message: 'No (enter new)' }
        ]
      }).run()

      if (useExistingHost === 'y') {
        host = existingProvider.host
      } else {
        host = await new Input({
          message: 'Ollama host',
          initial: 'http://localhost:11434'
        }).run()
      }
    } else {
      host = await new Input({
        message: 'Ollama host',
        initial: 'http://localhost:11434'
      }).run()
    }

    hasPrompt = await new Select({
      name: 'has_prompt',
      message: 'Does the model already have a system prompt?',
      choices: [
        { name: 'y', message: 'Yes' },
        { name: 'n', message: 'No' }
      ]
    }).run()
    console.log('')
  }

  // Build and save config in INI format
  const config: Config = {
    language,
    provider: provider.name,
    model,
    ...(apiKey && { apiKey }),
    ...(host && { host }),
    ...(hasPrompt && { hasPrompt })
  }

  saveConfig(config)
  ensureConfigPermissions()
  console.log(`✓ ${provider.label} configured`)

  if (provider.name === 'ollama') {
    console.log(`Note: Make sure Ollama is running at ${host}`)
  }

  console.log('')

  // Copy language prompts
  copyLanguagePrompts(language)
  console.log('')

  printSuccess()
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
