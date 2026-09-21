import { vibrator } from '@kit.SensorServiceKit'

export class Haptics {
  static light(): void {
    Haptics.pulse(12)
  }

  static medium(): void {
    Haptics.pulse(24)
  }

  static success(): void {
    Haptics.pulse(18)
  }

  static error(): void {
    Haptics.pulse(40)
  }

  private static pulse(duration: number): void {
    try {
      const option: vibrator.VibrateTime = { type: 'time', duration: duration }
      const attr: vibrator.VibrateAttribute = { id: 0, usage: 'touch' }
      vibrator.startVibration(option, attr).catch(() => {
      })
    } catch (_e) {
    }
  }
}

export function startOfDay(ms: number): number {
  const d = new Date(ms)
  d.setHours(0, 0, 0, 0)
  return d.getTime()
}

export function startOfWeek(ms: number): number {
  const d = new Date(startOfDay(ms))
  const day = d.getDay()
  const diff = day === 0 ? -6 : 1 - day
  d.setDate(d.getDate() + diff)
  return d.getTime()
}

export function formatTime(ms: number): string {
  const d = new Date(ms)
  let h = d.getHours()
  const m = d.getMinutes()
  const am = h < 12
  const h12 = h % 12 === 0 ? 12 : h % 12
  const mm = m < 10 ? `0${m}` : `${m}`
  return `${h12}:${mm} ${am ? 'AM' : 'PM'}`
}

export function shuffleCopy<T>(items: Array<T>): Array<T> {
  const copy: Array<T> = items.slice()
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    const tmp = copy[i]
    copy[i] = copy[j]
    copy[j] = tmp
  }
  return copy
}

export function makeId(): string {
  return `${Date.now()}-${Math.floor(Math.random() * 1000000)}`
}
