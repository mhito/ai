import { Provider } from './index'

export const groq: Provider = {
  name: 'groq',
  label: 'Groq (API)',

  async getModels(): Promise<string[]> {
    return [
      'openai/gpt-oss-120b',
      'openai/gpt-oss-20b',
      'qwen/qwen3-32b',
      'moonshotai/kimi-k2-instruct',
      'llama-3.3-70b-versatile',
      'llama-3.1-70b-versatile',
      'llama-3.1-8b-instant',
      'meta-llama/llama-4-scout-17b-16e-instruct',
      'mixtral-8x7b-32768',
      'gemma-7b-it'
    ]
  },

  requiresApiKey: true
}
