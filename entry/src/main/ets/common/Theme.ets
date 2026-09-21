export class AppTheme {
  static readonly green: string = '#58CC02'
  static readonly greenPressed: string = '#46A302'
  static readonly greenDark: string = '#58A700'
  static readonly blue: string = '#1CB0F6'
  static readonly blueDark: string = '#1899D6'
  static readonly gold: string = '#FFC800'
  static readonly goldDark: string = '#E5A100'
  static readonly heart: string = '#FF4B4B'
  static readonly heartDark: string = '#EA2B2B'
  static readonly streak: string = '#FF9600'
  static readonly purple: string = '#CE82FF'
  static readonly purpleDark: string = '#A568CC'
  static readonly locked: string = '#E5E5E5'
  static readonly lockedDark: string = '#AFAFAF'

  static background(dark: boolean): string {
    return dark ? '#131F24' : '#FFFFFF'
  }

  static surface(dark: boolean): string {
    return dark ? '#202F36' : '#F7F7F7'
  }

  static text(dark: boolean): string {
    return dark ? '#F1F7FB' : '#3C3C3C'
  }

  static muted(): string {
    return '#AFAFAF'
  }

  static divider(dark: boolean): string {
    return dark ? '#37464F' : '#E5E5E5'
  }

  static card(dark: boolean): string {
    return dark ? '#202F36' : '#FFFFFF'
  }
}
