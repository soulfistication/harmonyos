import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { ProgressStore } from '../model/ProgressStore'
import { SpeechService } from '../common/SpeechService'

const DOMAIN = 0x3101

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    SpeechService.init()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ProgressStore.init(this.context).then(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err) {
          hilog.error(DOMAIN, 'DeutschLingo', 'Failed to load content: %{public}s', JSON.stringify(err))
          return
        }
        hilog.info(DOMAIN, 'DeutschLingo', 'Content loaded')
      })
    }).catch((e: Error) => {
      hilog.error(DOMAIN, 'DeutschLingo', 'Progress init failed: %{public}s', JSON.stringify(e))
      windowStage.loadContent('pages/Index')
    })
  }

  onForeground(): void {
    ProgressStore.instance.regenerateHearts()
  }

  onWindowStageDestroy(): void {
    SpeechService.stop()
  }
}
