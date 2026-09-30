import { AppTheme } from '../common/Theme'
import { LeagueEntry, leagueEntries } from '../model/Models'
import { ProgressStore } from '../model/ProgressStore'
import { LessonSessionPage } from './LessonSessionPage'
import { DuoButton, MascotOwl } from '../components/Widgets'

@ComponentV2
export struct PracticePage {
  private store: ProgressStore = ProgressStore.instance
  @Local showSession: boolean = false

  build() {
    Column({ space: 24 }) {
      Blank()
      MascotOwl({ mood: 'idle', size: 140 })
      Text('Practice')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(this.store.dark))
      Text("Review what you've learned. Finish a round to earn XP and refill a heart.")
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.muted())
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })

      Column({ space: 10 }) {
        Text('Daily goal')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
          .width('100%')
          .textAlign(TextAlign.Start)
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(14)
            .backgroundColor(AppTheme.locked)
            .borderRadius(8)
          Row()
            .width(`${this.store.dailyProgress * 100}%`)
            .height(14)
            .backgroundColor(AppTheme.gold)
            .borderRadius(8)
        }
        .width('100%')
        .height(14)
        Text(`${this.store.dailyXP} / ${this.store.dailyGoal} XP`)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(this.store.dark))
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .padding(20)
      .backgroundColor(AppTheme.card(this.store.dark))
      .borderRadius(18)
      .border({ width: 2, color: AppTheme.divider(this.store.dark) })
      .margin({ left: 24, right: 24 })
      .width('100%')

      Blank()
      DuoButton({
        title: 'Start practice',
        onTap: () => {
          this.showSession = true
        }
      })
        .padding({ left: 24, right: 24, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
    .bindContentCover(this.showSession, this.sessionCover())
  }

  @Builder
  sessionCover() {
    LessonSessionPage({
      lessonId: 'practice',
      practiceMode: true,
      onClose: () => {
        this.showSession = false
      }
    })
  }
}

@ComponentV2
export struct LeaguePage {
  private store: ProgressStore = ProgressStore.instance

  private rows(): Array<LeagueEntry> {
    return leagueEntries(this.store.displayName, this.store.weeklyXP)
  }

  build() {
    Column() {
      Text('League')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(this.store.dark))
        .padding({ left: 20, top: 16, bottom: 8 })
        .width('100%')

      List() {
        ListItem() {
          Column({ space: 8 }) {
            Text('🛡️')
              .fontSize(40)
            Text('Emerald League')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.text(this.store.dark))
            Text('Weekly XP resets every Monday')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.muted())
          }
          .width('100%')
          .padding({ top: 8, bottom: 16 })
        }

        ForEach(this.rows(), (entry: LeagueEntry, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Text(`${index + 1}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(index < 3 ? AppTheme.gold : AppTheme.muted())
                .width(28)
                .textAlign(TextAlign.Center)
              Stack() {
                Circle()
                  .width(40)
                  .height(40)
                  .fill(entry.isUser ? AppTheme.green : '#401CB0F6')
                Text(entry.name.substring(0, 1))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(entry.isUser ? Color.White : AppTheme.text(this.store.dark))
              }
              .width(40)
              .height(40)
              Text(entry.name)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.text(this.store.dark))
                .layoutWeight(1)
              Text(`${entry.xp} XP`)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.muted())
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(entry.isUser ? '#1F58CC02' : AppTheme.card(this.store.dark))
            .borderRadius(12)
            .width('100%')
          }
        }, (entry: LeagueEntry) => entry.id)
      }
      .divider({ strokeWidth: 8, color: Color.Transparent })
      .padding({ left: 12, right: 12 })
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
  }
}

@ComponentV2
export struct ProfilePage {
  private store: ProgressStore = ProgressStore.instance
  @Local confirmReset: boolean = false

  @Builder
  stat(title: string, value: string, icon: string, tint: string) {
    Row() {
      Text(icon)
        .fontSize(18)
        .fontColor(tint)
        .width(28)
      Text(title)
        .fontSize(16)
        .fontColor(AppTheme.text(this.store.dark))
        .layoutWeight(1)
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.muted())
    }
    .padding({ top: 10, bottom: 10 })
    .width('100%')
  }

  @Builder
  achievement(title: string, subtitle: string, unlocked: boolean) {
    Row({ space: 12 }) {
      Text(unlocked ? '🏅' : '🔒')
        .fontSize(18)
        .width(28)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(this.store.dark))
        Text(subtitle)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.muted())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .padding({ top: 8, bottom: 8 })
    .width('100%')
    .opacity(unlocked ? 1 : 0.55)
  }

  build() {
    Scroll() {
      Column({ space: 4 }) {
        Text('Profile')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(this.store.dark))
          .width('100%')
          .padding({ bottom: 8 })

        Row({ space: 16 }) {
          MascotOwl({ mood: 'idle', size: 72 })
          Column({ space: 4 }) {
            Text(this.store.displayName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.text(this.store.dark))
            Text('Learning German')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.muted())
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ top: 6, bottom: 16 })
        .width('100%')

        Text('Stats')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
          .width('100%')
          .padding({ top: 8 })
        this.stat('Total XP', `${this.store.xp}`, '⚡', AppTheme.gold)
        this.stat('Streak', `${this.store.streak} days`, '🔥', AppTheme.streak)
        this.stat('Longest streak', `${this.store.longestStreak} days`, '👑', AppTheme.purple)
        this.stat('Lessons', `${this.store.completedCount} / ${this.store.totalLessons}`, '✅', AppTheme.green)
        this.stat('Gems', `${this.store.gems}`, '💎', AppTheme.blue)

        Text('Achievements')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
          .width('100%')
          .padding({ top: 16 })
        this.achievement('First step', 'Finish your first lesson', this.store.completedCount >= 1)
        this.achievement('On fire', 'Reach a 3-day streak', this.store.longestStreak >= 3)
        this.achievement('Dedicated', 'Reach a 7-day streak', this.store.longestStreak >= 7)
        this.achievement('Scholar', 'Earn 100 XP', this.store.xp >= 100)
        this.achievement('Hallo!', 'Complete Unit 1', this.store.unitComplete('greetings'))
        this.achievement('Perfectionist', 'Get 3 stars on any lesson', this.store.hasThreeStar())

        Text('Settings')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
          .width('100%')
          .padding({ top: 16 })

        Row() {
          Text('Dark mode')
            .fontSize(16)
            .fontColor(AppTheme.text(this.store.dark))
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.store.prefersDarkMode })
            .selectedColor(AppTheme.green)
            .onChange((on: boolean) => {
              this.store.setDarkMode(on)
            })
        }
        .padding({ top: 10, bottom: 10 })
        .width('100%')

        Text('Daily goal')
          .fontSize(16)
          .fontColor(AppTheme.text(this.store.dark))
          .width('100%')
          .padding({ top: 8 })
        Row({ space: 8 }) {
          ForEach([10, 20, 30], (g: number) => {
            Text(`${g} XP`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.store.dailyGoal === g ? Color.White : AppTheme.text(this.store.dark))
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.store.dailyGoal === g ? AppTheme.green : AppTheme.surface(this.store.dark))
              .borderRadius(12)
              .onClick(() => {
                this.store.setDailyGoal(g)
              })
          }, (g: number) => `goal-${g}`)
        }
        .width('100%')
        .padding({ bottom: 12 })

        Text('Reset progress')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.heart)
          .padding({ top: 12, bottom: 24 })
          .onClick(() => {
            this.confirmReset = true
          })
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 32 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
    .scrollBar(BarState.Off)
    .bindSheet(this.confirmReset, this.resetSheet(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: true,
      onDisappear: () => {
        this.confirmReset = false
      }
    })
  }

  @Builder
  resetSheet() {
    Column({ space: 16 }) {
      Text('Reset all progress?')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(this.store.dark))
      Text('This clears XP, streaks, hearts, and completed lessons.')
        .fontSize(14)
        .fontColor(AppTheme.muted())
        .textAlign(TextAlign.Center)
      DuoButton({
        title: 'Reset',
        color: AppTheme.heart,
        shadow: AppTheme.heartDark,
        onTap: () => {
          this.store.resetProgress()
          this.confirmReset = false
        }
      })
      Text('Cancel')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.blue)
        .onClick(() => {
          this.confirmReset = false
        })
    }
    .padding(24)
    .width('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
  }
}
