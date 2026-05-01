import Enquirer from 'enquirer'
const { Select } = Enquirer as any
import { providers, Provider } from '../providers'

export async function selectProvider(): Promise<Provider> {
  const choice = await new Select({
    name: 'provider',
    message: 'Select LLM Provider',
    choices: Object.values(providers).map((p) => ({
      name: p.name,
      message: p.label
    }))
  }).run()

  return providers[choice]
}
