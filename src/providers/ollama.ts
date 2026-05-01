import { execSync } from 'child_process'
import { Provider } from './index'

export const ollama: Provider = {
  name: 'ollama',
  label: 'Ollama (local)',

  async getModels(): Promise<string[]> {
    try {
      const output = execSync('ollama list', { encoding: 'utf-8' })
      return output
        .split('\n')
        .slice(1)
        .map((line) => line.trim().split(/\s+/)[0])
        .filter(Boolean)
    } catch {
      return ['deepseek-r1:7b', 'llama3.2', 'mistral', 'qwen2.5', 'phi4', 'gemma2', 'codellama']
    }
  },

  requiresApiKey: false
}
