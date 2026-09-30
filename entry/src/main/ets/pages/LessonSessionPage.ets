import { AppTheme } from '../common/Theme'
import { Haptics } from '../common/Utils'
import { Exercise, Lesson, LessonResult } from '../model/Models'
import { Curriculum } from '../model/Curriculum'
import { ProgressStore } from '../model/ProgressStore'
import { ExerciseHost } from '../components/ExerciseViews'
import { ConfettiView, DuoButton, MascotOwl } from '../components/Widgets'
import { HeartsSheet } from '../components/Sheets'

@ComponentV2
export struct LessonSessionPage {
  @Param lessonId: string = ''
  @Param practiceMode: boolean = false
  @Event onClose: () => void = () => {
  }
  private store: ProgressStore = ProgressStore.instance
  @Local queue: Array<Exercise> = []
  @Local index: number = 0
  @Local correctCount: number = 0
  @Local answered: number = 0
  @Local retriedIDs: Array<string> = []
  @Local feedback: string = 'none'
  @Local finished: boolean = false
  @Local resultXp: number = 0
  @Local resultStars: number = 0
  @Local resultAccuracy: number = 0
  @Local showOutOfHearts: boolean = false
  @Local didSetup: boolean = false

  aboutToAppear(): void {
    if (this.didSetup) {
      return
    }
    const lesson = Curriculum.lesson(this.lessonId)
    if (this.practiceMode) {
      this.queue = this.makePracticeQueue()
    } else if (lesson !== null) {
      this.queue = lesson.exercises.slice()
    }
    this.didSetup = true
  }

  aboutToDisappear(): void {
    this.didSetup = false
    this.finished = false
    this.feedback = 'none'
    this.index = 0
  }

  private currentLesson(): Lesson | null {
    if (this.practiceMode) {
      return {
        id: this.lessonId,
        title: 'Practice',
        symbol: '💪',
        xpReward: 5,
        exercises: this.queue
      }
    }
    return Curriculum.lesson(this.lessonId)
  }

  private makePracticeQueue(): Array<Exercise> {
    const completed = Curriculum.allLessons().filter((l: Lesson) => this.store.isCompleted(l.id))
    const pool: Array<Exercise> = []
    const source = completed.length === 0 ? [Curriculum.units()[0].lessons[0]] : completed
    for (let i = 0; i < source.length; i++) {
      const ex = source[i].exercises
      for (let j = 0; j < ex.length; j++) {
        pool.push(ex[j])
      }
    }
    const shuffled: Array<Exercise> = pool.slice()
    shuffled.sort((_a: Exercise, _b: Exercise) => Math.random() - 0.5)
    return shuffled.slice(0, Math.min(8, shuffled.length))
  }

  private progress(): number {
    if (this.queue.length === 0) {
      return 1
    }
    return this.index / this.queue.length
  }

  private current(): Exercise | null {
    if (this.index >= 0 && this.index < this.queue.length) {
      return this.queue[this.index]
    }
    return null
  }

  private handle(kind: string, answer: string): void {
    if (kind === 'correct') {
      this.feedback = 'correct'
      this.correctCount += 1
      this.answered += 1
      Haptics.success()
      return
    }
    if (kind === 'wrong') {
      this.feedback = 'wrong'
      this.answered += 1
      if (!this.practiceMode) {
        this.store.missAnswer()
      }
      Haptics.error()
      const current = this.current()
      if (!this.practiceMode && current !== null && this.retriedIDs.indexOf(current.id) < 0) {
        this.retriedIDs = this.retriedIDs.concat([current.id])
        this.queue = this.queue.concat([current])
      }
      if (!this.practiceMode && this.store.hearts === 0) {
        this.showOutOfHearts = true
      }
      return
    }
    if (kind === 'miss') {
      if (!this.practiceMode) {
        this.store.missAnswer()
      }
      Haptics.error()
      if (!this.practiceMode && this.store.hearts === 0) {
        this.showOutOfHearts = true
      }
      return
    }
    if (kind === 'continue') {
      this.feedback = 'none'
      if (this.index + 1 >= this.queue.length) {
        this.finish()
      } else {
        this.index += 1
      }
    }
  }

  private finish(): void {
    const lesson = this.currentLesson()
    if (this.practiceMode) {
      this.store.refillHeartFromPractice()
      this.resultXp = 5
      this.resultStars = 3
      this.resultAccuracy = this.answered === 0 ? 1 : this.correctCount / this.answered
      this.finished = true
      return
    }
    if (lesson !== null) {
      const result: LessonResult = this.store.completeLesson(lesson.id, this.correctCount, Math.max(this.answered, 1))
      this.resultXp = result.xp
      this.resultStars = result.stars
      this.resultAccuracy = result.accuracy
    }
    this.finished = true
  }

  build() {
    Stack() {
      Column() {
        if (this.finished) {
          this.completeView()
        } else if (this.current() !== null) {
          this.header()
          ExerciseHost({
            exerciseId: (this.current() as Exercise).id,
            kind: (this.current() as Exercise).kind,
            mc: (this.current() as Exercise).mc,
            bank: (this.current() as Exercise).bank,
            blank: (this.current() as Exercise).blank,
            match: (this.current() as Exercise).match,
            feedback: this.feedback,
            onResolved: (k: string, a: string) => {
              this.handle(k, a)
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppTheme.background(this.store.dark))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
    .bindSheet(this.showOutOfHearts, this.heartsBuilder(), {
      height: SheetSize.MEDIUM,
      dragBar: true,
      onDisappear: () => {
        this.showOutOfHearts = false
        if (this.store.hearts === 0) {
          this.onClose()
        }
      }
    })
  }

  @Builder
  heartsBuilder() {
    HeartsSheet({
      onClose: () => {
        this.showOutOfHearts = false
        if (this.store.hearts === 0) {
          this.onClose()
        }
      }
    })
  }

  @Builder
  header() {
    Row({ space: 12 }) {
      Text('✕')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.muted())
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.onClose()
        })
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(16)
          .backgroundColor(AppTheme.locked)
          .borderRadius(8)
        Row()
          .width(`${this.progress() * 100}%`)
          .height(16)
          .backgroundColor(this.practiceMode ? AppTheme.blue : AppTheme.green)
          .borderRadius(8)
      }
      .layoutWeight(1)
      .height(16)

      if (!this.practiceMode) {
        Row({ space: 4 }) {
          Text('❤️')
          Text(`${this.store.hearts}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.heart)
        }
      }
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .width('100%')
  }

  @Builder
  completeView() {
    Stack() {
      if (!this.practiceMode) {
        ConfettiView()
          .opacity(0.9)
      }
      Column({ space: 18 }) {
        Blank()
        MascotOwl({ mood: this.practiceMode ? 'happy' : 'cheer', size: this.practiceMode ? 140 : 150 })
        Text(this.practiceMode ? 'Nice review' : (this.resultStars === 3 ? 'Perfect!' : 'Lesson complete'))
          .fontSize(this.practiceMode ? 32 : 34)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(this.store.dark))
        Text(this.practiceMode ? `+${this.resultXp} XP  ·  +1 heart` :
          (this.currentLesson() !== null ? (this.currentLesson() as Lesson).title : ''))
          .fontSize(this.practiceMode ? 16 : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
        if (!this.practiceMode) {
          Row({ space: 6 }) {
            ForEach([1, 2, 3], (i: number) => {
              Text(i <= this.resultStars ? '★' : '☆')
                .fontSize(28)
                .fontColor(i <= this.resultStars ? AppTheme.gold : AppTheme.lockedDark)
            }, (i: number) => `star-${i}`)
          }
          Row({ space: 12 }) {
            this.resultChip('⚡', `+${this.resultXp} XP`, AppTheme.gold)
            this.resultChip('🎯', `${Math.round(this.resultAccuracy * 100)}%`, AppTheme.blue)
          }
          .padding({ top: 8 })
        }
        Blank()
        DuoButton({
          title: this.practiceMode ? 'Done' : 'Continue',
          onTap: () => {
            this.onClose()
          }
        })
          .padding({ left: 24, right: 24, bottom: 28 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  resultChip(icon: string, text: string, color: string) {
    Row({ space: 6 }) {
      Text(icon)
      Text(text)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(`#26${color.substring(1)}`)
    .borderRadius(20)
  }
}
