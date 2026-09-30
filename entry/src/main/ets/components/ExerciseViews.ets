import { AppTheme } from '../common/Theme'
import { Haptics, makeId, shuffleCopy } from '../common/Utils'
import { SpeechService } from '../common/SpeechService'
import { FillBlank, MatchPairs, MultipleChoice, PromptLanguage, VocabEntry, WordBank } from '../model/Models'
import { ProgressStore } from '../model/ProgressStore'
import { DuoButton, FeedbackFooter, SpeakButton } from './Widgets'

export interface BankToken {
  id: string
  text: string
}

@ComponentV2
export struct MultipleChoiceView {
  @Param @Require item: MultipleChoice
  @Param listening: boolean = false
  @Param feedback: string = 'none'
  @Event onResolved: (kind: string, answer: string) => void = (_k: string, _a: string) => {
  }
  @Local selected: number = -1

  aboutToAppear(): void {
    this.selected = -1
    if (this.listening && this.item.speakText.length > 0) {
      setTimeout(() => {
        SpeechService.speak(this.item.speakText)
      }, 350)
    }
  }

  private locked(): boolean {
    return this.feedback !== 'none'
  }

  private heading(): string {
    if (this.listening) {
      return 'Tap what you hear'
    }
    return this.item.promptLanguage === PromptLanguage.GERMAN ? 'What does this mean?' : 'Translate this'
  }

  private optionBorder(i: number): string {
    const dark = ProgressStore.instance.dark
    if (this.locked() && i === this.item.correctIndex) {
      return AppTheme.green
    }
    if (this.locked() && this.selected === i) {
      return AppTheme.heart
    }
    if (this.selected === i) {
      return AppTheme.blue
    }
    return AppTheme.divider(dark)
  }

  private optionFill(i: number): string {
    const dark = ProgressStore.instance.dark
    if (this.locked() && i === this.item.correctIndex) {
      return '#1F58CC02'
    }
    if (this.locked() && this.selected === i && i !== this.item.correctIndex) {
      return '#1FFF4B4B'
    }
    if (this.selected === i) {
      return '#1A1CB0F6'
    }
    return AppTheme.card(dark)
  }

  build() {
    Column({ space: 18 }) {
      Text(this.heading())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(ProgressStore.instance.dark))
        .padding({ left: 24, right: 24, top: 12 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 12 }) {
        if (this.item.speakText.length > 0) {
          SpeakButton({ text: this.item.speakText, large: this.listening })
        }
        if (!this.listening) {
          Text(this.item.prompt)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(ProgressStore.instance.dark))
            .layoutWeight(1)
        }
      }
      .padding({ left: 24, right: 24 })
      .width('100%')

      Column({ space: 12 }) {
        ForEach(this.item.options, (opt: string, i: number) => {
          Text(opt)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(ProgressStore.instance.dark))
            .width('100%')
            .textAlign(TextAlign.Start)
            .padding(16)
            .backgroundColor(this.optionFill(i))
            .borderRadius(16)
            .border({ width: 2, color: this.optionBorder(i) })
            .onClick(() => {
              if (!this.locked()) {
                this.selected = i
              }
            })
        }, (opt: string, i: number) => `${this.item.id}-${i}-${opt}`)
      }
      .padding({ left: 24, right: 24 })
      .width('100%')

      Blank()

      FeedbackFooter({
        canCheck: this.selected >= 0,
        feedback: this.feedback,
        correctAnswer: this.item.options[this.item.correctIndex],
        tip: this.item.tip,
        onCheck: () => {
          if (this.selected < 0) {
            return
          }
          if (this.selected === this.item.correctIndex) {
            this.onResolved('correct', '')
          } else {
            this.onResolved('wrong', this.item.options[this.item.correctIndex])
          }
        },
        onContinue: () => {
          this.onResolved('continue', '')
        }
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct WordBankView {
  @Param @Require item: WordBank
  @Param feedback: string = 'none'
  @Event onResolved: (kind: string, answer: string) => void = (_k: string, _a: string) => {
  }
  @Local bank: Array<BankToken> = []
  @Local built: Array<BankToken> = []
  @Local didSetup: boolean = false

  aboutToAppear(): void {
    if (!this.didSetup) {
      const shuffled = shuffleCopy(this.item.tokens)
      const tokens: Array<BankToken> = []
      for (let i = 0; i < shuffled.length; i++) {
        tokens.push({ id: makeId(), text: shuffled[i] })
      }
      this.bank = tokens
      this.didSetup = true
    }
  }

  private locked(): boolean {
    return this.feedback !== 'none'
  }

  private tapToken(token: BankToken, inBank: boolean): void {
    if (this.locked()) {
      return
    }
    if (inBank) {
      this.bank = this.bank.filter((t: BankToken) => t.id !== token.id)
      this.built = this.built.concat([token])
    } else {
      this.built = this.built.filter((t: BankToken) => t.id !== token.id)
      this.bank = this.bank.concat([token])
    }
  }

  @Builder
  chip(token: BankToken, inBank: boolean) {
    Text(token.text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppTheme.text(ProgressStore.instance.dark))
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(AppTheme.card(ProgressStore.instance.dark))
      .borderRadius(12)
      .border({ width: 2, color: AppTheme.divider(ProgressStore.instance.dark) })
      .shadow({ radius: 0, color: AppTheme.divider(ProgressStore.instance.dark), offsetY: 3 })
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.tapToken(token, inBank)
      })
  }

  build() {
    Column({ space: 18 }) {
      Text('Build this sentence')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(ProgressStore.instance.dark))
        .padding({ left: 24, right: 24, top: 12 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 10 }) {
        if (this.item.speakText.length > 0) {
          SpeakButton({ text: this.item.speakText })
        }
        Text(this.item.prompt)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.text(ProgressStore.instance.dark))
          .layoutWeight(1)
      }
      .padding({ left: 24, right: 24 })
      .width('100%')

      Column({ space: 10 }) {
        if (this.built.length === 0) {
          Text('Tap the words below')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.muted())
        } else {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.built, (token: BankToken) => {
              this.chip(token, false)
            }, (token: BankToken) => `b-${token.id}`)
          }
          .width('100%')
        }
        Divider()
          .color(AppTheme.divider(ProgressStore.instance.dark))
          .strokeWidth(2)
      }
      .constraintSize({ minHeight: 72 })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 24, right: 24 })
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.bank, (token: BankToken) => {
          this.chip(token, true)
        }, (token: BankToken) => `k-${token.id}`)
      }
      .padding({ left: 24, right: 24, top: 8 })
      .width('100%')

      Blank()

      FeedbackFooter({
        canCheck: this.built.length > 0,
        feedback: this.feedback,
        correctAnswer: this.item.correct.join(' '),
        tip: '',
        onCheck: () => {
          const answer: Array<string> = []
          for (let i = 0; i < this.built.length; i++) {
            answer.push(this.built[i].text)
          }
          const expected = this.item.correct.join(' ')
          if (answer.join(' ') === expected) {
            this.onResolved('correct', '')
          } else {
            this.onResolved('wrong', expected)
          }
        },
        onContinue: () => {
          this.onResolved('continue', '')
        }
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct FillBlankView {
  @Param @Require item: FillBlank
  @Param feedback: string = 'none'
  @Event onResolved: (kind: string, answer: string) => void = (_k: string, _a: string) => {
  }
  @Local selected: number = -1

  private locked(): boolean {
    return this.feedback !== 'none'
  }

  private blankText(): string {
    if (this.selected < 0) {
      return '______'
    }
    return this.item.options[this.selected]
  }

  private optionBorder(i: number): string {
    const dark = ProgressStore.instance.dark
    if (this.locked() && i === this.item.correctIndex) {
      return AppTheme.green
    }
    if (this.locked() && this.selected === i) {
      return AppTheme.heart
    }
    if (this.selected === i) {
      return AppTheme.blue
    }
    return AppTheme.divider(dark)
  }

  build() {
    Column({ space: 18 }) {
      Text('Fill in the blank')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(ProgressStore.instance.dark))
        .padding({ left: 24, right: 24, top: 12 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 10 }) {
        if (this.item.speakText.length > 0) {
          SpeakButton({ text: this.item.speakText })
        }
        Text(this.item.translation)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.muted())
          .layoutWeight(1)
      }
      .padding({ left: 24, right: 24 })
      .width('100%')

      Row({ space: 6 }) {
        if (this.item.before.length > 0) {
          Text(this.item.before)
        }
        Text(this.blankText())
          .fontColor(AppTheme.blue)
          .decoration({ type: TextDecorationType.Underline })
        if (this.item.after.length > 0) {
          Text(this.item.after)
        }
      }
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppTheme.text(ProgressStore.instance.dark))
      .padding({ left: 24, right: 24 })
      .width('100%')

      Column({ space: 12 }) {
        ForEach(this.item.options, (opt: string, i: number) => {
          Text(opt)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.text(ProgressStore.instance.dark))
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(16)
            .backgroundColor(this.selected === i ? '#1F1CB0F6' : AppTheme.card(ProgressStore.instance.dark))
            .borderRadius(16)
            .border({ width: 2, color: this.optionBorder(i) })
            .onClick(() => {
              if (!this.locked()) {
                this.selected = i
              }
            })
        }, (opt: string, i: number) => `${this.item.id}-fb-${i}`)
      }
      .padding({ left: 24, right: 24 })
      .width('100%')

      Blank()

      FeedbackFooter({
        canCheck: this.selected >= 0,
        feedback: this.feedback,
        correctAnswer: `${this.item.before} ${this.item.options[this.item.correctIndex]} ${this.item.after}`.replace('  ', ' '),
        tip: '',
        onCheck: () => {
          if (this.selected < 0) {
            return
          }
          if (this.selected === this.item.correctIndex) {
            this.onResolved('correct', '')
          } else {
            this.onResolved('wrong', this.item.options[this.item.correctIndex])
          }
        },
        onContinue: () => {
          this.onResolved('continue', '')
        }
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct MatchPairsView {
  @Param @Require item: MatchPairs
  @Event onResolved: (kind: string, answer: string) => void = (_k: string, _a: string) => {
  }
  @Local left: Array<VocabEntry> = []
  @Local right: Array<VocabEntry> = []
  @Local selectedLeft: string = ''
  @Local selectedRight: string = ''
  @Local matched: Array<string> = []
  @Local didSetup: boolean = false

  aboutToAppear(): void {
    if (!this.didSetup) {
      this.left = shuffleCopy(this.item.pairs)
      this.right = shuffleCopy(this.item.pairs)
      this.didSetup = true
    }
  }

  private isMatched(german: string): boolean {
    return this.matched.indexOf(german) >= 0
  }

  private evaluate(): void {
    if (this.selectedLeft.length === 0 || this.selectedRight.length === 0) {
      return
    }
    let ok = false
    for (let i = 0; i < this.item.pairs.length; i++) {
      if (this.item.pairs[i].german === this.selectedLeft && this.item.pairs[i].english === this.selectedRight) {
        ok = true
        break
      }
    }
    if (ok) {
      this.matched = this.matched.concat([this.selectedLeft])
      this.selectedLeft = ''
      this.selectedRight = ''
      Haptics.light()
      if (this.matched.length === this.item.pairs.length) {
        this.onResolved('correct', '')
        setTimeout(() => {
          this.onResolved('continue', '')
        }, 550)
      }
    } else {
      this.onResolved('miss', '')
      this.selectedLeft = ''
      this.selectedRight = ''
    }
  }

  private pairFill(matched: boolean, selected: boolean): string {
    if (matched) {
      return '#2658CC02'
    }
    if (selected) {
      return '#1F1CB0F6'
    }
    return AppTheme.card(ProgressStore.instance.dark)
  }

  private pairBorder(matched: boolean, selected: boolean): string {
    if (matched) {
      return AppTheme.green
    }
    if (selected) {
      return AppTheme.blue
    }
    return AppTheme.divider(ProgressStore.instance.dark)
  }

  @Builder
  pairButton(title: string, isLeft: boolean, germanKey: string, selected: boolean) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.isMatched(germanKey) ? AppTheme.greenDark : AppTheme.text(ProgressStore.instance.dark))
      .width('100%')
      .textAlign(TextAlign.Center)
      .padding({ top: 14, bottom: 14 })
      .backgroundColor(this.pairFill(this.isMatched(germanKey), selected))
      .borderRadius(14)
      .border({ width: 2, color: this.pairBorder(this.isMatched(germanKey), selected) })
      .opacity(this.isMatched(germanKey) ? 0.7 : 1)
      .onClick(() => {
        if (this.isMatched(germanKey)) {
          return
        }
        if (isLeft) {
          this.selectedLeft = title
        } else {
          this.selectedRight = title
        }
        this.evaluate()
      })
  }

  build() {
    Column({ space: 18 }) {
      Text('Tap the matching pairs')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.text(ProgressStore.instance.dark))
        .padding({ left: 24, right: 24, top: 12 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 12 }) {
        Column({ space: 10 }) {
          ForEach(this.left, (entry: VocabEntry) => {
            this.pairButton(entry.german, true, entry.german, this.selectedLeft === entry.german)
          }, (entry: VocabEntry) => `l-${entry.german}`)
        }
        .layoutWeight(1)

        Column({ space: 10 }) {
          ForEach(this.right, (entry: VocabEntry) => {
            this.pairButton(entry.english, false, entry.german, this.selectedRight === entry.english)
          }, (entry: VocabEntry) => `r-${entry.english}`)
        }
        .layoutWeight(1)
      }
      .padding({ left: 24, right: 24 })
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Blank()

      Text('Match all pairs to continue')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.muted())
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct ExerciseHost {
  @Param @Require exerciseId: string
  @Param @Require kind: string
  @Param mc: MultipleChoice | null = null
  @Param bank: WordBank | null = null
  @Param blank: FillBlank | null = null
  @Param match: MatchPairs | null = null
  @Param feedback: string = 'none'
  @Event onResolved: (kind: string, answer: string) => void = (_k: string, _a: string) => {
  }

  build() {
    Column() {
      if (this.kind === 'multipleChoice' && this.mc !== null) {
        MultipleChoiceView({
          item: this.mc as MultipleChoice,
          listening: false,
          feedback: this.feedback,
          onResolved: (k: string, a: string) => {
            this.onResolved(k, a)
          }
        })
      } else if (this.kind === 'listenChoose' && this.mc !== null) {
        MultipleChoiceView({
          item: this.mc as MultipleChoice,
          listening: true,
          feedback: this.feedback,
          onResolved: (k: string, a: string) => {
            this.onResolved(k, a)
          }
        })
      } else if (this.kind === 'wordBank' && this.bank !== null) {
        WordBankView({
          item: this.bank as WordBank,
          feedback: this.feedback,
          onResolved: (k: string, a: string) => {
            this.onResolved(k, a)
          }
        })
      } else if (this.kind === 'fillBlank' && this.blank !== null) {
        FillBlankView({
          item: this.blank as FillBlank,
          feedback: this.feedback,
          onResolved: (k: string, a: string) => {
            this.onResolved(k, a)
          }
        })
      } else if (this.kind === 'matchPairs' && this.match !== null) {
        MatchPairsView({
          item: this.match as MatchPairs,
          onResolved: (k: string, a: string) => {
            this.onResolved(k, a)
          }
        })
      }
    }
    .id(this.exerciseId)
    .width('100%')
    .layoutWeight(1)
  }
}
