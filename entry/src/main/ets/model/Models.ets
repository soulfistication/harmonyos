export enum PromptLanguage {
  ENGLISH = 'english',
  GERMAN = 'german'
}

export interface VocabEntry {
  german: string
  english: string
  hint: string
}

export interface MultipleChoice {
  id: string
  prompt: string
  promptLanguage: PromptLanguage
  options: Array<string>
  correctIndex: number
  speakText: string
  tip: string
}

export interface WordBank {
  id: string
  prompt: string
  tokens: Array<string>
  correct: Array<string>
  speakText: string
}

export interface FillBlank {
  id: string
  before: string
  after: string
  translation: string
  options: Array<string>
  correctIndex: number
  speakText: string
}

export interface MatchPairs {
  id: string
  pairs: Array<VocabEntry>
}

export type ExerciseKind = 'multipleChoice' | 'listenChoose' | 'wordBank' | 'fillBlank' | 'matchPairs'

export interface Exercise {
  kind: ExerciseKind
  id: string
  mc: MultipleChoice | null
  bank: WordBank | null
  blank: FillBlank | null
  match: MatchPairs | null
}

export interface Lesson {
  id: string
  title: string
  symbol: string
  xpReward: number
  exercises: Array<Exercise>
}

export interface CourseUnit {
  id: string
  number: number
  title: string
  germanTitle: string
  subtitle: string
  symbol: string
  color: string
  lessons: Array<Lesson>
  vocab: Array<VocabEntry>
}

export interface LessonResult {
  xp: number
  stars: number
  accuracy: number
  firstClear: boolean
}

export interface LeagueEntry {
  id: string
  name: string
  xp: number
  isUser: boolean
}

export function vocab(german: string, english: string, hint: string = ''): VocabEntry {
  return { german: german, english: english, hint: hint }
}

export function speakTextOf(exercise: Exercise): string {
  if (exercise.mc !== null) {
    return exercise.mc.speakText
  }
  if (exercise.bank !== null) {
    return exercise.bank.speakText
  }
  if (exercise.blank !== null) {
    return exercise.blank.speakText
  }
  return ''
}

export function leagueEntries(userName: string, weeklyXP: number): Array<LeagueEntry> {
  const rows: Array<LeagueEntry> = [
    { id: 'mara', name: 'Mara', xp: 240, isUser: false },
    { id: 'jonas', name: 'Jonas', xp: 190, isUser: false },
    { id: 'sofia', name: 'Sofia', xp: 155, isUser: false },
    { id: 'lukas', name: 'Lukas', xp: 120, isUser: false },
    { id: 'nina', name: 'Nina', xp: 95, isUser: false },
    { id: 'ben', name: 'Ben', xp: 70, isUser: false },
    { id: 'emma', name: 'Emma', xp: 45, isUser: false },
    { id: 'user', name: userName, xp: weeklyXP, isUser: true }
  ]
  return rows.sort((a: LeagueEntry, b: LeagueEntry) => b.xp - a.xp)
}
