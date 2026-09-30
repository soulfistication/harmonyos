import { AppTheme } from '../common/Theme'
import { formatTime } from '../common/Utils'
import { CourseUnit, VocabEntry } from '../model/Models'
import { ProgressStore } from '../model/ProgressStore'
import { DuoButton, SpeakButton } from './Widgets'

@ComponentV2
export struct HeartsSheet {
  @Event onClose: () => void = () => {
  }
  private store: ProgressStore = ProgressStore.instance

  aboutToAppear(): void {
    this.store.regenerateHearts()
  }

  build() {
    Column({ space: 18 }) {
      Text('❤️')
        .fontSize(48)
      Text(this.store.hearts === 0 ? "You're out of hearts" : 'Hearts')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(this.store.dark))
      Text(`You have ${this.store.hearts} of ${ProgressStore.heartsMax}. Missed answers cost a heart. They refill every ${ProgressStore.heartRegenMinutes} minutes, or refill now with gems.`)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.muted())
        .textAlign(TextAlign.Center)
        .padding({ left: 16, right: 16 })

      if (this.store.nextHeartDate() > 0) {
        Text(`Next heart at ${formatTime(this.store.nextHeartDate())}`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.muted())
      }

      DuoButton({
        title: 'Refill for 10 gems',
        color: AppTheme.blue,
        shadow: AppTheme.blueDark,
        enabled: this.store.gems >= 10 && this.store.hearts < ProgressStore.heartsMax,
        onTap: () => {
          this.store.buyHeartsIfPossible()
          this.onClose()
        }
      })

      Text('Practice instead')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.blue)
        .onClick(() => {
          this.onClose()
        })

      Blank()
    }
    .padding(24)
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
  }
}

@ComponentV2
export struct GuidebookView {
  @Param @Require unit: CourseUnit
  @Event onClose: () => void = () => {
  }
  private store: ProgressStore = ProgressStore.instance

  build() {
    Column() {
      Row() {
        Text(this.unit.germanTitle)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(this.store.dark))
          .layoutWeight(1)
        Text('Done')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.blue)
          .onClick(() => {
            this.onClose()
          })
      }
      .padding({ left: 20, right: 20, top: 20, bottom: 12 })
      .width('100%')

      List() {
        ForEach(this.unit.vocab, (entry: VocabEntry) => {
          ListItem() {
            Row({ space: 12 }) {
              SpeakButton({ text: entry.german })
              Column({ space: 2 }) {
                Text(entry.german)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppTheme.text(this.store.dark))
                Text(entry.english)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.muted())
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              if (entry.hint.length > 0) {
                Text(entry.hint)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.muted())
              }
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .width('100%')
          }
        }, (entry: VocabEntry) => entry.german)
      }
      .divider({ strokeWidth: 1, color: AppTheme.divider(this.store.dark) })
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(AppTheme.background(this.store.dark))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
  }
}
