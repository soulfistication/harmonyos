import { AppTheme } from '../common/Theme'
import { CourseUnit, Lesson } from '../model/Models'
import { Curriculum } from '../model/Curriculum'
import { ProgressStore } from '../model/ProgressStore'
import { LessonSessionPage } from '../pages/LessonSessionPage'
import { GuidebookView, HeartsSheet } from './Sheets'
import { StatChip } from './Widgets'

@ComponentV2
export struct LearnPage {
  private store: ProgressStore = ProgressStore.instance
  @Local selectedLessonId: string = ''
  @Local showLesson: boolean = false
  @Local showGuide: boolean = false
  @Local showHearts: boolean = false
  @Local guideUnitId: string = ''
  private offsets: Array<number> = [0, -56, -86, -40, 20, 64, 86, 40]

  private selectedLesson(): Lesson | null {
    return Curriculum.lesson(this.selectedLessonId)
  }

  private guideUnit(): CourseUnit | null {
    return Curriculum.unitById(this.guideUnitId)
  }

  private tapLesson(lesson: Lesson): void {
    if (this.store.hearts === 0) {
      this.showHearts = true
    } else if (this.store.isLessonUnlocked(lesson.id)) {
      this.selectedLessonId = lesson.id
      this.showLesson = true
    }
  }

  @Builder
  lessonCover() {
    LessonSessionPage({
      lessonId: this.selectedLessonId,
      practiceMode: false,
      onClose: () => {
        this.showLesson = false
      }
    })
  }

  @Builder
  heartsBuilder() {
    HeartsSheet({
      onClose: () => {
        this.showHearts = false
      }
    })
  }

  @Builder
  guideBuilder() {
    if (this.guideUnit() !== null) {
      GuidebookView({
        unit: this.guideUnit() as CourseUnit,
        onClose: () => {
          this.showGuide = false
        }
      })
    }
  }

  build() {
    Column() {
      Row() {
        Row({ space: 6 }) {
          Text('🇩🇪')
          Text('German')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
        }
        .layoutWeight(1)
        Row({ space: 16 }) {
          StatChip({ icon: '🔥', value: `${this.store.streak}`, tint: AppTheme.streak })
          StatChip({ icon: '💎', value: `${this.store.gems}`, tint: AppTheme.blue })
          StatChip({ icon: '❤️', value: `${this.store.hearts}`, tint: AppTheme.heart })
            .onClick(() => {
              this.showHearts = true
            })
        }
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .width('100%')

      Scroll() {
        Column() {
          ForEach(Curriculum.units(), (unit: CourseUnit) => {
            this.unitHeader(unit)
            this.path(unit)
          }, (unit: CourseUnit) => unit.id)
        }
        .padding({ bottom: 40 })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
    .bindContentCover(this.showLesson, this.lessonCover())
    .bindSheet(this.showHearts, this.heartsBuilder(), {
      height: SheetSize.MEDIUM,
      dragBar: true,
      showClose: false,
      onDisappear: () => {
        this.showHearts = false
      }
    })
    .bindSheet(this.showGuide, this.guideBuilder(), {
      height: SheetSize.LARGE,
      dragBar: true,
      onDisappear: () => {
        this.showGuide = false
      }
    })
  }

  @Builder
  unitHeader(unit: CourseUnit) {
    Row() {
      Column({ space: 6 }) {
        Text(`UNIT ${unit.number}`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .letterSpacing(1)
          .fontColor('#D9FFFFFF')
        Text(unit.title.toUpperCase())
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(unit.subtitle)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6FFFFFF')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 4 }) {
        Text('📖')
          .fontSize(18)
        Text('GUIDE')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .padding(12)
      .border({ width: 2, color: '#8CFFFFFF', radius: 14 })
      .onClick(() => {
        this.guideUnitId = unit.id
        this.showGuide = true
      })
    }
    .padding(20)
    .backgroundColor(unit.color)
    .borderRadius(18)
    .margin({ left: 16, right: 16, top: 18, bottom: 8 })
    .shadow({ radius: 8, color: unit.color, offsetY: 4 })
    .width('100%')
  }

  @Builder
  path(unit: CourseUnit) {
    Column({ space: 22 }) {
      ForEach(unit.lessons, (lesson: Lesson, index: number) => {
        LessonNode({
          lesson: lesson,
          unitColor: unit.color,
          unlocked: this.store.isLessonUnlocked(lesson.id),
          completed: this.store.isCompleted(lesson.id),
          stars: this.store.stars(lesson.id),
          isCurrent: this.store.isLessonUnlocked(lesson.id) && !this.store.isCompleted(lesson.id),
          onTap: () => {
            this.tapLesson(lesson)
          }
        })
          .offset({ x: this.offsets[index % this.offsets.length] })
      }, (lesson: Lesson) => lesson.id)
    }
    .width('100%')
    .padding({ top: 18 })
  }
}

@ComponentV2
struct LessonNode {
  @Param @Require lesson: Lesson
  @Param unitColor: string = AppTheme.green
  @Param unlocked: boolean = false
  @Param completed: boolean = false
  @Param stars: number = 0
  @Param isCurrent: boolean = false
  @Event onTap: () => void = () => {
  }
  @Local pulse: boolean = false

  aboutToAppear(): void {
    if (this.isCurrent) {
      this.pulse = true
    }
  }

  private fillColor(): string {
    if (this.completed) {
      return AppTheme.gold
    }
    if (this.unlocked) {
      return this.unitColor
    }
    return AppTheme.lockedDark
  }

  private shadowColor(): string {
    if (this.completed) {
      return AppTheme.goldDark
    }
    if (this.unlocked) {
      return this.unitColor
    }
    return '#8C8C8C'
  }

  build() {
    Column({ space: 8 }) {
      Stack() {
        Circle()
          .width(74)
          .height(74)
          .fill(this.shadowColor())
          .offset({ y: 5 })
        Circle()
          .width(74)
          .height(74)
          .fill(this.fillColor())
        Circle()
          .width(62)
          .height(62)
          .fill(Color.Transparent)
          .border({ width: 4, color: this.unlocked ? '#59FFFFFF' : '#26FFFFFF' })
        Text(this.unlocked ? this.lesson.symbol : '🔒')
          .fontSize(24)
          .fontColor(Color.White)
      }
      .width(74)
      .height(80)
      .scale({ x: this.isCurrent && this.pulse ? 1.06 : 1, y: this.isCurrent && this.pulse ? 1.06 : 1 })
      .animation({
        duration: 900,
        iterations: -1,
        playMode: PlayMode.Alternate,
        curve: Curve.EaseInOut
      })
      .onClick(() => {
        this.onTap()
      })

      if (this.completed) {
        Row({ space: 2 }) {
          ForEach([1, 2, 3], (i: number) => {
            Text(i <= this.stars ? '★' : '☆')
              .fontSize(11)
              .fontColor(i <= this.stars ? AppTheme.gold : AppTheme.lockedDark)
          }, (i: number) => `s-${this.lesson.id}-${i}`)
        }
      } else if (this.isCurrent) {
        Text('START')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.unitColor)
      } else {
        Text(this.unlocked ? this.lesson.title : 'Locked')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
      }
    }
  }
}
