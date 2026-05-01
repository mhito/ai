import { Provider } from './index'

export const moonshot: Provider = {
  name: 'moonshot',
  label: 'Moonshot/Kimi (API)',

  async getModels(): Promise<string[]> {
    return ['kimi-k2.6', 'kimi-k2.5', 'moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k']
  },

  requiresApiKey: true
}
