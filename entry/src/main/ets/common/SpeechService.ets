import { BusinessError } from '@kit.BasicServicesKit'
import { textToSpeech } from '@kit.CoreSpeechKit'

export class SpeechService {
  private static engine: textToSpeech.TextToSpeechEngine | null = null
  private static creating: boolean = false

  static init(): void {
    if (SpeechService.engine !== null || SpeechService.creating) {
      return
    }
    SpeechService.creating = true
    const params: textToSpeech.CreateEngineParams = {
      language: 'de-DE',
      person: 0,
      online: 1
    }
    textToSpeech.createEngine(params, (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
      SpeechService.creating = false
      if (err) {
        console.error(`TTS init failed: ${err.code}`)
        return
      }
      SpeechService.engine = engine
    })
  }

  static speak(text: string): void {
    const trimmed = text.trim()
    if (trimmed.length === 0) {
      return
    }
    if (SpeechService.engine === null) {
      SpeechService.init()
      return
    }
    try {
      SpeechService.engine.stop()
      const speakParams: textToSpeech.SpeakParams = {
        requestId: `dl-${Date.now()}`
      }
      SpeechService.engine.speak(trimmed, speakParams)
    } catch (e) {
      console.error(`TTS speak failed: ${JSON.stringify(e)}`)
    }
  }

  static stop(): void {
    if (SpeechService.engine !== null) {
      try {
        SpeechService.engine.stop()
      } catch (_e) {
      }
    }
  }
}
