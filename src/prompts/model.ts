import Enquirer from 'enquirer'
const { Select, Input } = Enquirer as any
import { Provider } from '../providers'

export async function selectModel(provider: Provider): Promise<string> {
  const models = await provider.getModels()

  const choices = models.map((m) => ({ name: m, message: m }))

  // Allow custom model entry for all providers
  choices.push({ name: '__custom__', message: 'Custom model...' })

  const choice = await new Select({
    name: 'model',
    message: `Select model (${provider.label})`,
    choices
  }).run()

  if (choice === '__custom__') {
    const custom = await new Input({
      message: 'Enter custom model name'
    }).run()
    return custom
  }

  return choice
}
