import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CourseUnit, Lesson, LessonResult } from '../model/Models'
import { Curriculum } from '../model/Curriculum'
import { startOfDay, startOfWeek } from '../common/Utils'

const PREF_NAME = 'deutschlingo'

@ObservedV2
export class ProgressStore {
  static readonly heartsMax: number = 5
  static readonly heartRegenMinutes: number = 20

  private static inst: ProgressStore | undefined = undefined
  private static ctx: common.UIAbilityContext | undefined = undefined
  private static prefs: preferences.Preferences | undefined = undefined

  @Trace ready: boolean = false
  @Trace hasOnboarded: boolean = false
  @Trace displayName: string = 'You'
  @Trace dailyGoal: number = 20
  @Trace prefersDarkMode: boolean = false
  @Trace xp: number = 0
  @Trace weeklyXP: number = 0
  @Trace gems: number = 50
  @Trace hearts: number = ProgressStore.heartsMax
  @Trace streak: number = 0
  @Trace longestStreak: number = 0
  @Trace lastActiveDay: number = 0
  @Trace lastHeartAt: number = Date.now()
  @Trace dailyXP: number = 0
  @Trace dailyXPDay: number = 0
  @Trace weeklyXPWeekStart: number = 0
  @Trace practicedToday: boolean = false
  @Trace completedLessonIDs: Array<string> = []
  @Trace lessonStarsJson: string = '{}'
  @Trace bump: number = 0

  static get instance(): ProgressStore {
    if (ProgressStore.inst === undefined) {
      ProgressStore.inst = new ProgressStore()
    }
    return ProgressStore.inst
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    ProgressStore.ctx = context
    ProgressStore.prefs = await preferences.getPreferences(context, PREF_NAME)
    await ProgressStore.instance.load()
  }

  get dark(): boolean {
    return this.prefersDarkMode
  }

  get dailyProgress(): number {
    if (this.dailyGoal <= 0) {
      return 0
    }
    return Math.min(1, this.dailyXP / this.dailyGoal)
  }

  get completedCount(): number {
    return this.completedLessonIDs.length
  }

  get totalLessons(): number {
    return Curriculum.allLessons().length
  }

  stars(lessonID: string): number {
    const map = this.starMap()
    const value = map[lessonID]
    return value !== undefined ? value : 0
  }

  isCompleted(id: string): boolean {
    return this.completedLessonIDs.indexOf(id) >= 0
  }

  isLessonUnlocked(id: string): boolean {
    return Curriculum.isUnlocked(id, this.completedLessonIDs)
  }

  completeOnboarding(name: string, goal: number): void {
    const trimmed = name.trim()
    this.displayName = trimmed.length === 0 ? 'You' : trimmed
    this.dailyGoal = goal
    this.hasOnboarded = true
    this.persist()
  }

  completeLesson(id: string, correct: number, total: number): LessonResult {
    this.regenerateHearts()
    const accuracy = total === 0 ? 1 : correct / total
    const earnedStars = accuracy >= 1 ? 3 : (accuracy >= 0.7 ? 2 : 1)
    const previous = this.stars(id)
    const firstClear = !this.isCompleted(id)
    if (firstClear) {
      this.completedLessonIDs = this.completedLessonIDs.concat([id])
    }
    const map = this.starMap()
    map[id] = Math.max(previous, earnedStars)
    this.lessonStarsJson = JSON.stringify(map)

    const lesson: Lesson | null = Curriculum.lesson(id)
    let gained = lesson !== null ? lesson.xpReward : 10
    if (earnedStars === 3) {
      gained += 5
    }
    if (!firstClear) {
      gained = Math.max(5, Math.floor(gained / 2))
    }
    this.addXP(gained)
    if (firstClear) {
      this.gems += 2
    }
    this.noteActivity()
    this.persist()
    return { xp: gained, stars: earnedStars, accuracy: accuracy, firstClear: firstClear }
  }

  missAnswer(): void {
    this.regenerateHearts()
    if (this.hearts > 0) {
      this.hearts -= 1
      this.lastHeartAt = Date.now()
      this.persist()
    }
  }

  refillHeartFromPractice(): void {
    this.regenerateHearts()
    this.hearts = Math.min(ProgressStore.heartsMax, this.hearts + 1)
    this.practicedToday = true
    this.addXP(5)
    this.noteActivity()
    this.persist()
  }

  regenerateHearts(): void {
    if (this.hearts >= ProgressStore.heartsMax) {
      return
    }
    const elapsed = Date.now() - this.lastHeartAt
    const gained = Math.floor(elapsed / (ProgressStore.heartRegenMinutes * 60 * 1000))
    if (gained > 0) {
      this.hearts = Math.min(ProgressStore.heartsMax, this.hearts + gained)
      this.lastHeartAt = this.lastHeartAt + gained * ProgressStore.heartRegenMinutes * 60 * 1000
      this.persist()
    }
  }

  nextHeartDate(): number {
    if (this.hearts >= ProgressStore.heartsMax) {
      return 0
    }
    return this.lastHeartAt + ProgressStore.heartRegenMinutes * 60 * 1000
  }

  buyHeartsIfPossible(): boolean {
    if (this.gems < 10 || this.hearts >= ProgressStore.heartsMax) {
      return false
    }
    this.gems -= 10
    this.hearts = ProgressStore.heartsMax
    this.persist()
    return true
  }

  toggleDarkMode(): void {
    this.setDarkMode(!this.prefersDarkMode)
  }

  setDarkMode(on: boolean): void {
    this.prefersDarkMode = on
    this.persist()
  }

  setDailyGoal(goal: number): void {
    this.dailyGoal = goal
    this.persist()
  }

  resetProgress(): void {
    this.xp = 0
    this.weeklyXP = 0
    this.gems = 50
    this.hearts = ProgressStore.heartsMax
    this.streak = 0
    this.longestStreak = 0
    this.lastActiveDay = 0
    this.lastHeartAt = Date.now()
    this.dailyXP = 0
    this.dailyXPDay = Date.now()
    this.practicedToday = false
    this.completedLessonIDs = []
    this.lessonStarsJson = '{}'
    this.persist()
  }

  unitComplete(unitId: string): boolean {
    const unit: CourseUnit | null = Curriculum.unitById(unitId)
    if (unit === null) {
      return false
    }
    for (let i = 0; i < unit.lessons.length; i++) {
      if (!this.isCompleted(unit.lessons[i].id)) {
        return false
      }
    }
    return true
  }

  hasThreeStar(): boolean {
    const map = this.starMap()
    const keys = Object.keys(map)
    for (let i = 0; i < keys.length; i++) {
      if (map[keys[i]] >= 3) {
        return true
      }
    }
    return false
  }

  private addXP(amount: number): void {
    this.rollDaysIfNeeded()
    this.xp += amount
    this.weeklyXP += amount
    this.dailyXP += amount
  }

  private noteActivity(): void {
    this.rollDaysIfNeeded()
    const today = startOfDay(Date.now())
    if (this.lastActiveDay > 0) {
      const last = startOfDay(this.lastActiveDay)
      if (last !== today) {
        const yesterday = today - 24 * 60 * 60 * 1000
        if (last === yesterday) {
          this.streak += 1
        } else {
          this.streak = 1
        }
      }
    } else {
      this.streak = Math.max(1, this.streak)
    }
    this.lastActiveDay = today
    this.longestStreak = Math.max(this.longestStreak, this.streak)
  }

  private rollDaysIfNeeded(): void {
    const today = startOfDay(Date.now())
    if (this.dailyXPDay > 0 && startOfDay(this.dailyXPDay) !== today) {
      this.dailyXP = 0
      this.practicedToday = false
    }
    this.dailyXPDay = today
    const weekStart = startOfWeek(Date.now())
    if (this.weeklyXPWeekStart > 0 && this.weeklyXPWeekStart !== weekStart) {
      this.weeklyXP = 0
    }
    this.weeklyXPWeekStart = weekStart
  }

  private starMap(): Record<string, number> {
    try {
      return JSON.parse(this.lessonStarsJson) as Record<string, number>
    } catch (_e) {
      return {}
    }
  }

  private async load(): Promise<void> {
    const p = ProgressStore.prefs
    if (p === undefined) {
      this.ready = true
      return
    }
    this.hasOnboarded = await p.get('hasOnboarded', false) as boolean
    this.displayName = await p.get('displayName', 'You') as string
    this.dailyGoal = await p.get('dailyGoal', 20) as number
    this.prefersDarkMode = await p.get('prefersDarkMode', false) as boolean
    this.xp = await p.get('xp', 0) as number
    this.weeklyXP = await p.get('weeklyXP', 0) as number
    this.gems = await p.get('gems', 50) as number
    this.hearts = await p.get('hearts', ProgressStore.heartsMax) as number
    this.streak = await p.get('streak', 0) as number
    this.longestStreak = await p.get('longestStreak', 0) as number
    this.lastActiveDay = await p.get('lastActiveDay', 0) as number
    this.lastHeartAt = await p.get('lastHeartAt', Date.now()) as number
    this.dailyXP = await p.get('dailyXP', 0) as number
    this.dailyXPDay = await p.get('dailyXPDay', 0) as number
    this.weeklyXPWeekStart = await p.get('weeklyXPWeekStart', 0) as number
    this.practicedToday = await p.get('practicedToday', false) as boolean
    const idsJson = await p.get('completedLessonIDs', '[]') as string
    try {
      this.completedLessonIDs = JSON.parse(idsJson) as Array<string>
    } catch (_e) {
      this.completedLessonIDs = []
    }
    this.lessonStarsJson = await p.get('lessonStarsJson', '{}') as string
    this.rollDaysIfNeeded()
    this.regenerateHearts()
    this.ready = true
  }

  private persist(): void {
    this.bump += 1
    const p = ProgressStore.prefs
    if (p === undefined) {
      return
    }
    p.put('hasOnboarded', this.hasOnboarded)
    p.put('displayName', this.displayName)
    p.put('dailyGoal', this.dailyGoal)
    p.put('prefersDarkMode', this.prefersDarkMode)
    p.put('xp', this.xp)
    p.put('weeklyXP', this.weeklyXP)
    p.put('gems', this.gems)
    p.put('hearts', this.hearts)
    p.put('streak', this.streak)
    p.put('longestStreak', this.longestStreak)
    p.put('lastActiveDay', this.lastActiveDay)
    p.put('lastHeartAt', this.lastHeartAt)
    p.put('dailyXP', this.dailyXP)
    p.put('dailyXPDay', this.dailyXPDay)
    p.put('weeklyXPWeekStart', this.weeklyXPWeekStart)
    p.put('practicedToday', this.practicedToday)
    p.put('completedLessonIDs', JSON.stringify(this.completedLessonIDs))
    p.put('lessonStarsJson', this.lessonStarsJson)
    p.flush()
  }
}
