import Enquirer from 'enquirer'
const { Select } = Enquirer as any

export async function selectLanguage(): Promise<'en' | 'es'> {
  const choice = await new Select({
    name: 'language',
    message: 'Select your preferred language / Selecciona tu idioma preferido',
    choices: [
      { name: 'en', message: 'English' },
      { name: 'es', message: 'Español' }
    ]
  }).run()

  return choice
}
