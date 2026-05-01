import { ollama } from './ollama'
import { openai } from './openai'
import { deepseek } from './deepseek'
import { moonshot } from './moonshot'
import { groq } from './groq'

export interface Provider {
  name: string
  label: string
  getModels(): Promise<string[]>
  requiresApiKey?: boolean
}

export const providers: Record<string, Provider> = {
  ollama,
  openai,
  deepseek,
  moonshot,
  groq
}
