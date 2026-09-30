import { AppTheme } from '../common/Theme'
import { ProgressStore } from '../model/ProgressStore'
import { OnboardingPage } from './OnboardingPage'
import { LearnPage } from './LearnPage'
import { LeaguePage, PracticePage, ProfilePage } from './MorePages'

@Entry
@ComponentV2
struct Index {
  store: ProgressStore = ProgressStore.instance
  @Local tabIndex: number = 0

  aboutToAppear(): void {
    this.store.regenerateHearts()
  }

  @Builder
  tabItem(title: string, icon: string, index: number) {
    Column({ space: 2 }) {
      Text(icon)
        .fontSize(20)
      Text(title)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.tabIndex === index ? AppTheme.green : AppTheme.muted())
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      if (!this.store.ready) {
        Column({ space: 12 }) {
          Text('🦉')
            .fontSize(48)
          Text('DeutschLingo')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(this.store.dark))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (!this.store.hasOnboarded) {
        OnboardingPage()
      } else {
        Tabs({ barPosition: BarPosition.End, index: this.tabIndex }) {
          TabContent() {
            LearnPage()
          }
          .tabBar(this.tabItem('Learn', '🗺️', 0))

          TabContent() {
            PracticePage()
          }
          .tabBar(this.tabItem('Practice', '💪', 1))

          TabContent() {
            LeaguePage()
          }
          .tabBar(this.tabItem('League', '🛡️', 2))

          TabContent() {
            ProfilePage()
          }
          .tabBar(this.tabItem('Profile', '🙂', 3))
        }
        .barMode(BarMode.Fixed)
        .barBackgroundColor(AppTheme.card(this.store.dark))
        .onChange((index: number) => {
          this.tabIndex = index
          this.store.regenerateHearts()
        })
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.background(this.store.dark))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
