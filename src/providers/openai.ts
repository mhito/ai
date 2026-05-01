import { Provider } from './index'

export const openai: Provider = {
  name: 'openai',
  label: 'OpenAI (API)',

  async getModels(): Promise<string[]> {
    return ['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo', 'gpt-3.5-turbo']
  },

  requiresApiKey: true
}
