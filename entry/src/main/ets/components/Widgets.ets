import { AppTheme } from '../common/Theme'
import { Haptics } from '../common/Utils'
import { SpeechService } from '../common/SpeechService'
import { ProgressStore } from '../model/ProgressStore'

@ComponentV2
export struct DuoButton {
  @Param title: string = ''
  @Param color: string = AppTheme.green
  @Param shadow: string = AppTheme.greenDark
  @Param enabled: boolean = true
  @Event onTap: () => void = () => {
  }

  build() {
    Column() {
      Text(this.title.toUpperCase())
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.enabled ? Color.White : AppTheme.muted())
        .letterSpacing(0.6)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .backgroundColor(this.enabled ? this.color : AppTheme.locked)
        .borderRadius(16)
        .offset({ y: this.enabled ? -4 : 0 })
    }
    .width('100%')
    .backgroundColor(this.enabled ? this.shadow : AppTheme.lockedDark)
    .borderRadius(16)
    .onClick(() => {
      if (this.enabled) {
        Haptics.medium()
        this.onTap()
      }
    })
  }
}

@ComponentV2
export struct StatChip {
  @Param icon: string = ''
  @Param value: string = ''
  @Param tint: string = AppTheme.green

  build() {
    Row({ space: 6 }) {
      Text(this.icon)
        .fontSize(16)
      Text(this.value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(ProgressStore.instance.dark))
    }
    .padding({ left: 4, right: 4 })
  }
}

@ComponentV2
export struct SpeakButton {
  @Param text: string = ''
  @Param large: boolean = false

  build() {
    Text('🔊')
      .fontSize(this.large ? 28 : 18)
      .textAlign(TextAlign.Center)
      .width(this.large ? 72 : 44)
      .height(this.large ? 72 : 44)
      .backgroundColor(AppTheme.blue)
      .borderRadius(this.large ? 18 : 12)
      .shadow({ radius: 0, color: AppTheme.blueDark, offsetY: 3 })
      .onClick(() => {
        SpeechService.speak(this.text)
        Haptics.light()
      })
  }
}

@ComponentV2
export struct MascotOwl {
  @Param mood: string = 'idle'
  @Param size: number = 160

  build() {
    Stack() {
      Ellipse()
        .width(this.size * 0.92)
        .height(this.size)
        .fill(AppTheme.green)
        .shadow({ radius: 10, color: '#5958A700', offsetY: 8 })
        .offset({ y: this.size * 0.04 })

      Ellipse()
        .width(this.size * 0.52)
        .height(this.size * 0.48)
        .fill('#F2FFFFFF')
        .offset({ y: this.size * 0.18 })

      Ellipse()
        .width(this.size * 0.78)
        .height(this.size * 0.52)
        .fill(Color.White)
        .offset({ y: -this.size * 0.16 })

      Row({ space: this.size * 0.08 }) {
        this.eye()
        this.eye()
      }
      .offset({ y: -this.size * 0.18 })
      .scale({
        x: this.mood === 'cheer' ? 1.08 : (this.mood === 'sad' ? 0.85 : 1),
        y: this.mood === 'cheer' ? 1.08 : (this.mood === 'sad' ? 0.85 : 1)
      })

      Text('▼')
        .fontSize(this.size * 0.16)
        .fontColor(AppTheme.gold)
        .offset({ y: -this.size * 0.02 })

      if (this.mood === 'cheer') {
        Text('✦')
          .fontSize(this.size * 0.18)
          .fontColor(AppTheme.gold)
          .offset({ y: -this.size * 0.52 })
      }
    }
    .width(this.size)
    .height(this.size)
  }

  @Builder
  eye() {
    Stack() {
      Circle()
        .width(this.size * 0.22)
        .height(this.size * 0.22)
        .fill('#3C3C3C')
      Circle()
        .width(this.size * 0.08)
        .height(this.size * 0.08)
        .fill(Color.White)
        .offset({ x: -this.size * 0.04, y: -this.size * 0.04 })
    }
    .width(this.size * 0.22)
    .height(this.size * 0.22)
  }
}

@ComponentV2
export struct ConfettiView {
  private colors: Array<string> = [AppTheme.green, AppTheme.gold, AppTheme.blue, AppTheme.heart, AppTheme.purple]
  @Local seeds: Array<number> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]

  build() {
    Stack() {
      ForEach(this.seeds, (i: number) => {
        Rect()
          .width(6 + (i % 5))
          .height(10 + (i % 4))
          .radius(2)
          .fill(this.colors[i % this.colors.length])
          .position({ x: (i * 37) % 360, y: (i * 53) % 200 })
          .opacity(0.9)
          .animation({
            duration: 2800 + i * 40,
            iterations: -1,
            curve: Curve.Linear,
            playMode: PlayMode.Normal
          })
          .translate({ y: 640 })
      }, (i: number) => `c-${i}`)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }
}

@ComponentV2
export struct FeedbackFooter {
  @Param canCheck: boolean = false
  @Param feedback: string = 'none'
  @Param correctAnswer: string = ''
  @Param tip: string = ''
  @Event onCheck: () => void = () => {
  }
  @Event onContinue: () => void = () => {
  }

  private isCorrect(): boolean {
    return this.feedback === 'correct'
  }

  build() {
    Column({ space: 12 }) {
      if (this.feedback !== 'none') {
        Row() {
          Column({ space: 4 }) {
            Text(this.isCorrect() ? 'Nice!' : 'Correct answer:')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
            if (!this.isCorrect()) {
              Text(this.correctAnswer)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            } else if (this.tip.length > 0) {
              Text(this.tip)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.isCorrect() ? '✓' : '✕')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .fontColor(this.isCorrect() ? AppTheme.greenDark : AppTheme.heartDark)

        DuoButton({
          title: 'Continue',
          color: this.isCorrect() ? AppTheme.green : AppTheme.heart,
          shadow: this.isCorrect() ? AppTheme.greenDark : AppTheme.heartDark,
          onTap: () => {
            this.onContinue()
          }
        })
      } else {
        DuoButton({
          title: 'Check',
          enabled: this.canCheck,
          onTap: () => {
            this.onCheck()
          }
        })
      }
    }
    .padding(20)
    .width('100%')
    .backgroundColor(this.feedback === 'none' ? Color.Transparent :
      (this.isCorrect() ? '#1F58CC02' : '#1FFF4B4B'))
  }
}
