import { AppTheme } from '../common/Theme'
import { ProgressStore } from '../model/ProgressStore'
import { DuoButton, MascotOwl } from '../components/Widgets'

@ComponentV2
export struct OnboardingPage {
  private store: ProgressStore = ProgressStore.instance
  @Local page: number = 0
  @Local name: string = ''
  @Local goal: number = 20
  private swiper: SwiperController = new SwiperController()

  private continue(): void {
    if (this.page < 2) {
      this.page += 1
      this.swiper.changeIndex(this.page, true)
    } else {
      this.store.completeOnboarding(this.name, this.goal)
    }
  }

  @Builder
  goalRow(value: number, title: string, subtitle: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(`${value} XP · ${subtitle}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.muted())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.goal === value) {
        Text('✓')
          .fontSize(22)
          .fontColor(AppTheme.green)
      }
    }
    .padding(16)
    .backgroundColor(AppTheme.card(this.store.dark))
    .borderRadius(16)
    .border({ width: 2, color: this.goal === value ? AppTheme.green : AppTheme.divider(this.store.dark) })
    .onClick(() => {
      this.goal = value
    })
  }

  build() {
    Column() {
      Swiper(this.swiper) {
        Column({ space: 24 }) {
          Blank()
          MascotOwl({ mood: 'cheer', size: 180 })
          Text("Hallo! I'm Otto.")
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
          Text("I'll help you learn German with short lessons, streaks, and a little friendly pressure.")
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.muted())
            .textAlign(TextAlign.Center)
            .padding({ left: 28, right: 28 })
          Blank()
        }
        .width('100%')
        .height('100%')

        Column({ space: 20 }) {
          Blank()
          Text('Set a daily goal')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
          Text('A little every day beats a lot once a week.')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.muted())
          Column({ space: 12 }) {
            this.goalRow(10, 'Casual', '5 minutes')
            this.goalRow(20, 'Regular', '10 minutes')
            this.goalRow(30, 'Serious', '15 minutes')
          }
          .padding({ left: 24, right: 24 })
          .width('100%')
          Blank()
        }
        .width('100%')
        .height('100%')

        Column({ space: 20 }) {
          Blank()
          MascotOwl({ mood: 'idle', size: 120 })
          Text('What should I call you?')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
          TextInput({ placeholder: 'Your name', text: this.name })
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
            .placeholderColor(AppTheme.muted())
            .backgroundColor(AppTheme.surface(this.store.dark))
            .borderRadius(16)
            .border({ width: 2, color: AppTheme.divider(this.store.dark) })
            .padding(16)
            .margin({ left: 24, right: 24 })
            .onChange((value: string) => {
              this.name = value
            })
          Blank()
        }
        .width('100%')
        .height('100%')
      }
      .index(this.page)
      .loop(false)
      .indicator(false)
      .disableSwipe(true)
      .layoutWeight(1)
      .onChange((index: number) => {
        this.page = index
      })

      Row({ space: 8 }) {
        ForEach([0, 1, 2], (i: number) => {
          Row()
            .width(i === this.page ? 22 : 8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(i === this.page ? AppTheme.green : AppTheme.locked)
        }, (i: number) => `dot-${i}`)
      }
      .padding({ bottom: 16 })

      DuoButton({
        title: this.page === 2 ? 'Start learning' : 'Continue',
        onTap: () => {
          this.continue()
        }
      })
        .padding({ left: 24, right: 24, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
  }
}
