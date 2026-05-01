import { Provider } from './index'

export const deepseek: Provider = {
  name: 'deepseek',
  label: 'DeepSeek (API)',

  async getModels(): Promise<string[]> {
    return ['deepseek-v4-flash', 'deepseek-v4-pro']
  },

  requiresApiKey: true
}
