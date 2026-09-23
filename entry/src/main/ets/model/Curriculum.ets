import {
  CourseUnit,
  Exercise,
  FillBlank,
  Lesson,
  MatchPairs,
  MultipleChoice,
  PromptLanguage,
  VocabEntry,
  vocab,
  WordBank
} from './Models'

function mc(id: string, prompt: string, lang: PromptLanguage, options: Array<string>, correct: number,
  speak: string = '', tip: string = ''): Exercise {
  const speakText = speak.length > 0 ? speak : (lang === PromptLanguage.GERMAN ? prompt : options[correct])
  const item: MultipleChoice = {
    id: id,
    prompt: prompt,
    promptLanguage: lang,
    options: options,
    correctIndex: correct,
    speakText: speakText,
    tip: tip
  }
  return { kind: 'multipleChoice', id: id, mc: item, bank: null, blank: null, match: null }
}

function listen(id: string, german: string, options: Array<string>, correct: number): Exercise {
  const item: MultipleChoice = {
    id: id,
    prompt: 'What do you hear?',
    promptLanguage: PromptLanguage.ENGLISH,
    options: options,
    correctIndex: correct,
    speakText: german,
    tip: ''
  }
  return { kind: 'listenChoose', id: id, mc: item, bank: null, blank: null, match: null }
}

function bank(id: string, prompt: string, tokens: Array<string>, correct: Array<string>, speak: string = ''): Exercise {
  const speakText = speak.length > 0 ? speak : correct.join(' ')
  const item: WordBank = {
    id: id,
    prompt: prompt,
    tokens: tokens,
    correct: correct,
    speakText: speakText
  }
  return { kind: 'wordBank', id: id, mc: null, bank: item, blank: null, match: null }
}

function blank(id: string, before: string, after: string, translation: string, options: Array<string>,
  correct: number, speak: string = ''): Exercise {
  const spoken = speak.length > 0 ? speak : `${before} ${options[correct]} ${after}`.replace('  ', ' ')
  const item: FillBlank = {
    id: id,
    before: before,
    after: after,
    translation: translation,
    options: options,
    correctIndex: correct,
    speakText: spoken
  }
  return { kind: 'fillBlank', id: id, mc: null, bank: null, blank: item, match: null }
}

function match(id: string, pairs: Array<VocabEntry>): Exercise {
  const item: MatchPairs = { id: id, pairs: pairs }
  return { kind: 'matchPairs', id: id, mc: null, bank: null, blank: null, match: item }
}

function pair(german: string, english: string): VocabEntry {
  return vocab(german, english, '')
}

function lesson(id: string, title: string, symbol: string, xpReward: number, exercises: Array<Exercise>): Lesson {
  return { id: id, title: title, symbol: symbol, xpReward: xpReward, exercises: exercises }
}

export class Curriculum {
  private static cached: Array<CourseUnit> | undefined = undefined

  static units(): Array<CourseUnit> {
    if (Curriculum.cached === undefined) {
      Curriculum.cached = buildUnits()
    }
    return Curriculum.cached as Array<CourseUnit>
  }

  static allLessons(): Array<Lesson> {
    const result: Array<Lesson> = []
    const units = Curriculum.units()
    for (let u = 0; u < units.length; u++) {
      const lessons = units[u].lessons
      for (let i = 0; i < lessons.length; i++) {
        result.push(lessons[i])
      }
    }
    return result
  }

  static lesson(id: string): Lesson | null {
    const all = Curriculum.allLessons()
    for (let i = 0; i < all.length; i++) {
      if (all[i].id === id) {
        return all[i]
      }
    }
    return null
  }

  static unitById(id: string): CourseUnit | null {
    const units = Curriculum.units()
    for (let i = 0; i < units.length; i++) {
      if (units[i].id === id) {
        return units[i]
      }
    }
    return null
  }

  static unitContaining(lessonID: string): CourseUnit | null {
    const units = Curriculum.units()
    for (let i = 0; i < units.length; i++) {
      const lessons = units[i].lessons
      for (let j = 0; j < lessons.length; j++) {
        if (lessons[j].id === lessonID) {
          return units[i]
        }
      }
    }
    return null
  }

  static isUnlocked(lessonID: string, completed: Array<string>): boolean {
    const all = Curriculum.allLessons()
    let index = -1
    for (let i = 0; i < all.length; i++) {
      if (all[i].id === lessonID) {
        index = i
        break
      }
    }
    if (index <= 0) {
      return index === 0
    }
    return completed.indexOf(all[index - 1].id) >= 0
  }
}

function buildUnits(): Array<CourseUnit> {
  return [
    greetings(),
    introductions(),
    food(),
    numbers(),
    people(),
    travel(),
    verbs(),
    cafe()
  ]
}

function greetings(): CourseUnit {
  return {
    id: 'greetings',
    number: 1,
    title: 'Greetings',
    germanTitle: 'Begrüßungen',
    subtitle: 'Say hello, goodbye, and thanks',
    symbol: '👋',
    color: '#58CC02',
    lessons: [
      lesson('u1-l1', 'Hallo!', '☀️', 10, [
        mc('u1l1e1', 'Hello', PromptLanguage.ENGLISH, ['Hallo', 'Tschüss', 'Bitte', 'Nein'], 0, 'Hallo'),
        mc('u1l1e2', 'Guten Tag', PromptLanguage.GERMAN, ['Good night', 'Good day', 'Thank you', 'Please'], 1, 'Guten Tag'),
        listen('u1l1e3', 'Guten Morgen', ['Good evening', 'Good morning', 'Goodbye', 'Excuse me'], 1),
        mc('u1l1e4', 'Goodbye (casual)', PromptLanguage.ENGLISH, ['Bitte', 'Danke', 'Tschüss', 'Ja'], 2, 'Tschüss'),
        bank('u1l1e5', 'Good night', ['Nacht', 'Gute', 'Tag', 'Morgen'], ['Gute', 'Nacht']),
        match('u1l1e6', [pair('Hallo', 'Hello'), pair('Tschüss', 'Bye'), pair('Guten Morgen', 'Good morning'),
          pair('Guten Abend', 'Good evening')])
      ]),
      lesson('u1-l2', 'How are you?', '😊', 10, [
        mc('u1l2e1', "Wie geht's?", PromptLanguage.GERMAN, ["What's your name?", 'How are you?', 'Where are you?', 'Who are you?'], 1, "Wie geht's?"),
        mc('u1l2e2', 'Fine, thanks', PromptLanguage.ENGLISH, ['Sehr gut', 'Gut, danke', 'Nicht so gut', 'Bitte schön'], 1, 'Gut, danke'),
        listen('u1l2e3', 'Sehr gut', ['Very good', 'Not good', 'See you', 'Good night'], 0),
        blank('u1l2e4', 'Gut,', '', 'Fine, thanks', ['danke', 'bitte', 'hallo', 'nein'], 0),
        bank('u1l2e5', 'How are you?', ["geht's", 'Wie', 'heißt', 'du'], ['Wie', "geht's"]),
        mc('u1l2e6', 'Not so well', PromptLanguage.ENGLISH, ['Sehr gut', 'Gut, danke', 'Nicht so gut', 'Freut mich'], 2, 'Nicht so gut')
      ]),
      lesson('u1-l3', 'Please & thanks', '❤️', 10, [
        mc('u1l3e1', 'Thank you', PromptLanguage.ENGLISH, ['Bitte', 'Danke', 'Ja', 'Nein'], 1, 'Danke'),
        mc('u1l3e2', 'Bitte', PromptLanguage.GERMAN, ['Sorry', "Please / You're welcome", 'Hello', 'Goodbye'], 1, 'Bitte',
          'Bitte can mean please or you\'re welcome.'),
        mc('u1l3e3', 'Yes', PromptLanguage.ENGLISH, ['Nein', 'Ja', 'Doch', 'Hallo'], 1, 'Ja'),
        listen('u1l3e4', 'Entschuldigung', ['Congratulations', 'Excuse me', 'Good luck', 'See you soon'], 1),
        bank('u1l3e5', 'Thank you very much', ['Vielen', 'Dank', 'Bitte', 'schön'], ['Vielen', 'Dank'], 'Vielen Dank'),
        match('u1l3e6', [pair('Danke', 'Thank you'), pair('Bitte', 'Please'), pair('Ja', 'Yes'), pair('Nein', 'No')])
      ]),
      lesson('u1-l4', 'Unit 1 review', '⭐', 15, [
        listen('u1l4e1', 'Guten Abend', ['Good morning', 'Good evening', 'Good night', 'Good day'], 1),
        mc('u1l4e2', 'Auf Wiedersehen', PromptLanguage.GERMAN, ['See you later', 'Goodbye', 'Welcome', 'Cheers'], 1, 'Auf Wiedersehen'),
        bank('u1l4e3', 'Excuse me', ['Entschuldigung', 'Bitte', 'Danke', 'Hallo'], ['Entschuldigung']),
        blank('u1l4e4', 'Wie', '?', 'How are you?', ["geht's", 'heißt', 'bist', 'kommst'], 0),
        mc('u1l4e5', "You're welcome", PromptLanguage.ENGLISH, ['Danke schön', 'Bitte schön', 'Guten Tag', 'Tschüss'], 1, 'Bitte schön'),
        match('u1l4e6', [pair('Guten Tag', 'Good day'), pair('Gute Nacht', 'Good night'),
          pair('Vielen Dank', 'Thank you very much'), pair('Entschuldigung', 'Excuse me')])
      ])
    ],
    vocab: [
      vocab('Hallo', 'Hello'),
      vocab('Guten Morgen', 'Good morning'),
      vocab('Guten Tag', 'Good day'),
      vocab('Guten Abend', 'Good evening'),
      vocab('Gute Nacht', 'Good night'),
      vocab('Tschüss', 'Bye', 'casual'),
      vocab('Auf Wiedersehen', 'Goodbye', 'more formal'),
      vocab("Wie geht's?", 'How are you?', 'informal'),
      vocab('Danke', 'Thank you'),
      vocab('Bitte', "Please / You're welcome"),
      vocab('Ja', 'Yes'),
      vocab('Nein', 'No'),
      vocab('Entschuldigung', 'Excuse me / Sorry')
    ]
  }
}

function introductions(): CourseUnit {
  return {
    id: 'introductions',
    number: 2,
    title: 'Introductions',
    germanTitle: 'Vorstellen',
    subtitle: 'Names, origins, and meeting people',
    symbol: '🙂',
    color: '#1CB0F6',
    lessons: [
      lesson('u2-l1', 'My name is', 'Aa', 10, [
        mc('u2l1e1', 'Wie heißt du?', PromptLanguage.GERMAN, ['How old are you?', "What's your name?", 'Where do you live?', 'How are you?'], 1, 'Wie heißt du?'),
        mc('u2l1e2', 'My name is Anna', PromptLanguage.ENGLISH, ['Ich bin Anna', 'Ich heiße Anna', 'Ich habe Anna', 'Ich komme Anna'], 1, 'Ich heiße Anna'),
        listen('u2l1e3', 'Freut mich', ["I'm sorry", 'Nice to meet you', 'See you tomorrow', "I don't know"], 1),
        blank('u2l1e4', 'Ich', 'Max.', 'My name is Max.', ['heiße', 'gehe', 'esse', 'habe'], 0),
        bank('u2l1e5', "What's your name?", ['heißt', 'du', 'Wie', 'bist'], ['Wie', 'heißt', 'du']),
        mc('u2l1e6', 'I am a student', PromptLanguage.ENGLISH, ['Ich bin Student', 'Ich habe Student', 'Ich heiße Student', 'Ich esse Student'], 0, 'Ich bin Student')
      ]),
      lesson('u2-l2', 'Where from?', '🌍', 10, [
        mc('u2l2e1', 'Woher kommst du?', PromptLanguage.GERMAN, ['Where are you going?', 'Where are you from?', 'Where do you live?', 'Who are you?'], 1, 'Woher kommst du?'),
        mc('u2l2e2', 'I am from Germany', PromptLanguage.ENGLISH, ['Ich wohne Deutschland', 'Ich komme aus Deutschland', 'Ich bin Deutschland', 'Ich heiße Deutschland'], 1, 'Ich komme aus Deutschland'),
        listen('u2l2e3', 'Ich komme aus Österreich', ['I live in Austria', 'I am from Austria', 'I speak Austrian', 'I go to Austria'], 1),
        blank('u2l2e4', 'Ich komme aus', '.', 'I am from Switzerland.', ['der Schweiz', 'Schweiz', 'die Schweiz', 'dem Schweiz'], 0, 'Ich komme aus der Schweiz'),
        bank('u2l2e5', 'Where are you from?', ['kommst', 'du', 'Woher', 'bist'], ['Woher', 'kommst', 'du']),
        mc('u2l2e6', 'the USA', PromptLanguage.ENGLISH, ['die USA', 'der USA', 'das USA', 'den USA'], 3, 'den USA', 'You say: Ich komme aus den USA.')
      ]),
      lesson('u2-l3', 'I speak…', '💬', 10, [
        mc('u2l3e1', 'I speak German', PromptLanguage.ENGLISH, ['Ich lerne Deutsch', 'Ich spreche Deutsch', 'Ich heiße Deutsch', 'Ich mag Deutsch'], 1, 'Ich spreche Deutsch'),
        mc('u2l3e2', 'Sprechen Sie Englisch?', PromptLanguage.GERMAN, ['Do you speak English?', 'Are you English?', 'Where is England?', 'I speak English'], 0, 'Sprechen Sie Englisch?', 'Sie is the formal you.'),
        listen('u2l3e3', 'Ich spreche ein bisschen Deutsch', ['I speak German fluently', 'I speak a little German', "I don't speak German", 'I am learning English'], 1),
        blank('u2l3e4', 'Ich', 'Englisch.', 'I speak English.', ['spreche', 'heiße', 'komme', 'bin'], 0),
        bank('u2l3e5', 'I speak a little German', ['spreche', 'ein', 'bisschen', 'Deutsch', 'Ich', 'viel'], ['Ich', 'spreche', 'ein', 'bisschen', 'Deutsch']),
        match('u2l3e6', [pair('Deutsch', 'German'), pair('Englisch', 'English'), pair('ein bisschen', 'a little'), pair('sprechen', 'to speak')])
      ]),
      lesson('u2-l4', 'Unit 2 review', '⭐', 15, [
        mc('u2l4e1', 'Freut mich', PromptLanguage.GERMAN, ["I'm tired", 'Nice to meet you', "I'm hungry", "I'm lost"], 1, 'Freut mich'),
        bank('u2l4e2', 'My name is Lena', ['heiße', 'Ich', 'Lena', 'bin'], ['Ich', 'heiße', 'Lena']),
        listen('u2l4e3', 'Ich komme aus Berlin', ['I live in Berlin', 'I am from Berlin', 'I like Berlin', 'I go to Berlin'], 1),
        blank('u2l4e4', 'Wie', 'du?', "What's your name?", ['heißt', "geht's", 'bist', 'kommst'], 0),
        mc('u2l4e5', 'I am from Austria', PromptLanguage.ENGLISH, ['Ich komme aus Österreich', 'Ich wohne Österreich', 'Ich bin aus Schweiz', 'Ich heiße Österreich'], 0, 'Ich komme aus Österreich'),
        match('u2l4e6', [pair('Ich heiße', 'My name is'), pair('Ich bin', 'I am'), pair('Woher kommst du?', 'Where are you from?'), pair('Freut mich', 'Nice to meet you')])
      ])
    ],
    vocab: [
      vocab('Ich heiße…', 'My name is…'),
      vocab('Wie heißt du?', "What's your name?", 'informal'),
      vocab('Ich bin…', 'I am…'),
      vocab('Freut mich', 'Nice to meet you'),
      vocab('Woher kommst du?', 'Where are you from?'),
      vocab('Ich komme aus…', 'I am from…'),
      vocab('Ich spreche…', 'I speak…'),
      vocab('ein bisschen', 'a little')
    ]
  }
}

function food(): CourseUnit {
  return {
    id: 'food',
    number: 3,
    title: 'Food & drink',
    germanTitle: 'Essen & Trinken',
    subtitle: 'Order coffee, bread, and water',
    symbol: '🍴',
    color: '#FF9600',
    lessons: [
      lesson('u3-l1', 'Basics', '☕', 10, [
        mc('u3l1e1', 'das Wasser', PromptLanguage.GERMAN, ['the bread', 'the water', 'the coffee', 'the tea'], 1, 'das Wasser', 'das = neuter the.'),
        mc('u3l1e2', 'the coffee', PromptLanguage.ENGLISH, ['der Tee', 'der Kaffee', 'die Milch', 'das Bier'], 1, 'der Kaffee'),
        listen('u3l1e3', 'das Brot', ['the cheese', 'the bread', 'the apple', 'the wine'], 1),
        match('u3l1e4', [pair('der Kaffee', 'coffee'), pair('der Tee', 'tea'), pair('das Wasser', 'water'), pair('die Milch', 'milk')]),
        mc('u3l1e5', 'der Apfel', PromptLanguage.GERMAN, ['the apple', 'the cheese', 'the beer', 'the wine'], 0, 'der Apfel'),
        blank('u3l1e6', 'Ich trinke', '.', 'I drink water.', ['Wasser', 'Brot', 'Käse', 'Apfel'], 0)
      ]),
      lesson('u3-l2', 'I eat, I drink', '🥤', 10, [
        mc('u3l2e1', 'I eat bread', PromptLanguage.ENGLISH, ['Ich trinke Brot', 'Ich esse Brot', 'Ich habe Brot', 'Ich bin Brot'], 1, 'Ich esse Brot'),
        mc('u3l2e2', 'Ich trinke Kaffee', PromptLanguage.GERMAN, ['I eat coffee', 'I drink coffee', 'I like coffee', 'I want coffee'], 1, 'Ich trinke Kaffee'),
        listen('u3l2e3', 'Ich esse einen Apfel', ['I eat an apple', 'I drink an apple', 'I have the apple', 'I want cheese'], 0),
        bank('u3l2e4', 'I drink tea', ['trinke', 'Tee', 'Ich', 'esse', 'Kaffee'], ['Ich', 'trinke', 'Tee']),
        blank('u3l2e5', 'Ich', 'Käse.', 'I eat cheese.', ['esse', 'trinke', 'bin', 'heiße'], 0),
        match('u3l2e6', [pair('essen', 'to eat'), pair('trinken', 'to drink'), pair('der Käse', 'cheese'), pair('das Bier', 'beer')])
      ]),
      lesson('u3-l3', 'I would like', '🎂', 10, [
        mc('u3l3e1', 'Ich hätte gern…', PromptLanguage.GERMAN, ["I don't want…", 'I would like…', 'I already have…', 'I am eating…'], 1, 'Ich hätte gern', 'Polite way to order.'),
        bank('u3l3e2', 'I would like a coffee', ['hätte', 'gern', 'einen', 'Kaffee', 'Ich', 'das'], ['Ich', 'hätte', 'gern', 'einen', 'Kaffee']),
        listen('u3l3e3', 'Die Rechnung, bitte', ['A table, please', 'The check, please', 'More water, please', "I'm ready"], 1),
        mc('u3l3e4', 'the wine', PromptLanguage.ENGLISH, ['das Bier', 'der Wein', 'die Milch', 'der Tee'], 1, 'der Wein'),
        blank('u3l3e5', 'Ich hätte gern', ', bitte.', 'I would like water, please.', ['Wasser', 'Hallo', 'Danke', 'Ja'], 0),
        mc('u3l3e6', 'Together or separately?', PromptLanguage.ENGLISH, ['Zusammen oder getrennt?', 'Links oder rechts?', 'Ja oder nein?', 'Tee oder Kaffee?'], 0, 'Zusammen oder getrennt?')
      ]),
      lesson('u3-l4', 'Unit 3 review', '⭐', 15, [
        listen('u3l4e1', 'Ich hätte gern einen Kaffee', ['I would like a coffee', 'I drink tea', 'I eat bread', 'The check please'], 0),
        mc('u3l4e2', 'die Milch', PromptLanguage.GERMAN, ['the milk', 'the cheese', 'the apple', 'the beer'], 0, 'die Milch'),
        bank('u3l4e3', 'The check, please', ['Rechnung', 'Die', 'bitte', 'Wasser'], ['Die', 'Rechnung', 'bitte']),
        match('u3l4e4', [pair('das Brot', 'bread'), pair('der Apfel', 'apple'), pair('der Wein', 'wine'), pair('Ich esse', 'I eat')]),
        blank('u3l4e5', 'Ich', 'Bier.', 'I drink beer.', ['trinke', 'esse', 'bin', 'heiße'], 0),
        mc('u3l4e6', 'I would like tea', PromptLanguage.ENGLISH, ['Ich hätte gern Tee', 'Ich esse Tee', 'Ich bin Tee', 'Ich heiße Tee'], 0, 'Ich hätte gern Tee')
      ])
    ],
    vocab: [
      vocab('das Wasser', 'water', 'neuter'),
      vocab('der Kaffee', 'coffee', 'masculine'),
      vocab('der Tee', 'tea', 'masculine'),
      vocab('das Brot', 'bread', 'neuter'),
      vocab('der Apfel', 'apple', 'masculine'),
      vocab('die Milch', 'milk', 'feminine'),
      vocab('der Käse', 'cheese', 'masculine'),
      vocab('Ich esse', 'I eat'),
      vocab('Ich trinke', 'I drink'),
      vocab('Ich hätte gern', 'I would like', 'polite')
    ]
  }
}

function numbers(): CourseUnit {
  return {
    id: 'numbers',
    number: 4,
    title: 'Numbers',
    germanTitle: 'Zahlen',
    subtitle: 'Count to ten and ask prices',
    symbol: '#',
    color: '#CE82FF',
    lessons: [
      lesson('u4-l1', '1 to 5', '1', 10, [
        mc('u4l1e1', 'eins', PromptLanguage.GERMAN, ['one', 'two', 'three', 'zero'], 0, 'eins'),
        mc('u4l1e2', 'two', PromptLanguage.ENGLISH, ['eins', 'zwei', 'drei', 'vier'], 1, 'zwei'),
        listen('u4l1e3', 'drei', ['two', 'three', 'four', 'five'], 1),
        match('u4l1e4', [pair('eins', 'one'), pair('zwei', 'two'), pair('drei', 'three'), pair('vier', 'four')]),
        mc('u4l1e5', 'five', PromptLanguage.ENGLISH, ['vier', 'fünf', 'sechs', 'sieben'], 1, 'fünf'),
        blank('u4l1e6', 'eins, zwei,', '', 'one, two, three', ['drei', 'vier', 'acht', 'zehn'], 0)
      ]),
      lesson('u4-l2', '6 to 10', '10', 10, [
        mc('u4l2e1', 'sechs', PromptLanguage.GERMAN, ['six', 'seven', 'eight', 'sixteen'], 0, 'sechs'),
        listen('u4l2e2', 'sieben', ['six', 'seven', 'nine', 'ten'], 1),
        mc('u4l2e3', 'eight', PromptLanguage.ENGLISH, ['acht', 'neun', 'zehn', 'elf'], 0, 'acht'),
        match('u4l2e4', [pair('sechs', 'six'), pair('sieben', 'seven'), pair('acht', 'eight'), pair('neun', 'nine')]),
        mc('u4l2e5', 'zehn', PromptLanguage.GERMAN, ['nine', 'ten', 'eleven', 'twelve'], 1, 'zehn'),
        bank('u4l2e6', 'nine', ['neun', 'zehn', 'eins', 'zwei'], ['neun'])
      ]),
      lesson('u4-l3', 'How much?', '€', 10, [
        mc('u4l3e1', 'Wie viel kostet das?', PromptLanguage.GERMAN, ['What is that?', 'How much does that cost?', 'How many are there?', 'Where is that?'], 1, 'Wie viel kostet das?'),
        listen('u4l3e2', 'Das kostet fünf Euro', ['That costs four euros', 'That costs five euros', 'That costs ten euros', 'I have five euros'], 1),
        bank('u4l3e3', 'How much does that cost?', ['viel', 'kostet', 'das', 'Wie', 'wo'], ['Wie', 'viel', 'kostet', 'das']),
        blank('u4l3e4', 'Das kostet', 'Euro.', 'That costs ten euros.', ['zehn', 'eins', 'Wasser', 'bitte'], 0),
        mc('u4l3e5', 'I have two apples', PromptLanguage.ENGLISH, ['Ich habe zwei Äpfel', 'Ich esse zwei Äpfel', 'Ich bin zwei Äpfel', 'Ich möchte zwei Apfel'], 0, 'Ich habe zwei Äpfel'),
        match('u4l3e6', [pair('Wie viel?', 'How much?'), pair('Euro', 'euro'), pair('kosten', 'to cost'), pair('zehn', 'ten')])
      ])
    ],
    vocab: [
      vocab('eins', 'one'), vocab('zwei', 'two'), vocab('drei', 'three'), vocab('vier', 'four'), vocab('fünf', 'five'),
      vocab('sechs', 'six'), vocab('sieben', 'seven'), vocab('acht', 'eight'), vocab('neun', 'nine'), vocab('zehn', 'ten'),
      vocab('Wie viel kostet das?', 'How much does that cost?')
    ]
  }
}

function people(): CourseUnit {
  return {
    id: 'people',
    number: 5,
    title: 'People',
    germanTitle: 'Menschen',
    subtitle: 'Family, friends, and articles',
    symbol: '👨‍👩‍👧',
    color: '#FF4B4B',
    lessons: [
      lesson('u5-l1', 'Family', '👨‍👩‍👧', 10, [
        mc('u5l1e1', 'die Mutter', PromptLanguage.GERMAN, ['the father', 'the mother', 'the sister', 'the child'], 1, 'die Mutter'),
        mc('u5l1e2', 'the father', PromptLanguage.ENGLISH, ['die Frau', 'der Vater', 'der Bruder', 'das Kind'], 1, 'der Vater'),
        listen('u5l1e3', 'die Schwester', ['the brother', 'the sister', 'the friend', 'the family'], 1),
        match('u5l1e4', [pair('die Mutter', 'mother'), pair('der Vater', 'father'), pair('die Schwester', 'sister'), pair('der Bruder', 'brother')]),
        mc('u5l1e5', 'das Kind', PromptLanguage.GERMAN, ['the man', 'the woman', 'the child', 'the friend'], 2, 'das Kind'),
        bank('u5l1e6', 'This is my family', ['ist', 'meine', 'Familie', 'Das', 'der'], ['Das', 'ist', 'meine', 'Familie'])
      ]),
      lesson('u5-l2', 'Friends', '👥', 10, [
        mc('u5l2e1', 'der Freund', PromptLanguage.GERMAN, ['the girlfriend', 'the (male) friend', 'the child', 'the man'], 1, 'der Freund', 'der Freund can also mean boyfriend.'),
        mc('u5l2e2', 'the woman', PromptLanguage.ENGLISH, ['der Mann', 'die Frau', 'das Kind', 'die Familie'], 1, 'die Frau'),
        listen('u5l2e3', 'die Freundin', ['the (female) friend', 'the mother', 'the sister', 'the teacher'], 0),
        blank('u5l2e4', 'Das ist', '.', 'This is my friend. (male)', ['mein Freund', 'meine Freund', 'mein Freundin', 'die Freund'], 0),
        bank('u5l2e5', 'He is a man', ['ist', 'ein', 'Mann', 'Er', 'Sie'], ['Er', 'ist', 'ein', 'Mann']),
        match('u5l2e6', [pair('der Mann', 'the man'), pair('die Frau', 'the woman'), pair('der Freund', 'the friend'), pair('die Familie', 'the family')])
      ]),
      lesson('u5-l3', 'Articles', 'abc', 15, [
        mc('u5l3e1', 'Which article is masculine?', PromptLanguage.ENGLISH, ['die', 'das', 'der', 'den'], 2, 'der'),
        mc('u5l3e2', 'die is used with', PromptLanguage.ENGLISH, ['masculine nouns', 'feminine nouns', 'neuter nouns', 'plural only'], 1),
        listen('u5l3e3', 'der, die, das', ['a, an, the', 'the (m, f, n)', 'yes, no, please', 'one, two, three'], 1),
        blank('u5l3e4', '', 'Wasser', 'the water', ['das', 'der', 'die', 'den'], 0),
        mc('u5l3e5', 'the coffee', PromptLanguage.ENGLISH, ['die Kaffee', 'das Kaffee', 'der Kaffee', 'den Kaffee'], 2, 'der Kaffee'),
        match('u5l3e6', [pair('der', 'masculine the'), pair('die', 'feminine the'), pair('das', 'neuter the'), pair('ein', 'a / an')])
      ])
    ],
    vocab: [
      vocab('die Mutter', 'the mother', 'feminine'),
      vocab('der Vater', 'the father', 'masculine'),
      vocab('die Schwester', 'the sister'),
      vocab('der Bruder', 'the brother'),
      vocab('das Kind', 'the child', 'neuter'),
      vocab('die Familie', 'the family'),
      vocab('der Freund', 'the (male) friend'),
      vocab('die Freundin', 'the (female) friend'),
      vocab('der Mann', 'the man'),
      vocab('die Frau', 'the woman')
    ]
  }
}

function travel(): CourseUnit {
  return {
    id: 'travel',
    number: 6,
    title: 'Travel',
    germanTitle: 'Reisen',
    subtitle: 'Find the station, hotel, and restroom',
    symbol: '✈️',
    color: '#1CB0F6',
    lessons: [
      lesson('u6-l1', 'Where is…?', '📍', 10, [
        mc('u6l1e1', 'Wo ist…?', PromptLanguage.GERMAN, ['Who is…?', 'Where is…?', 'What is…?', 'How is…?'], 1, 'Wo ist'),
        mc('u6l1e2', 'the train station', PromptLanguage.ENGLISH, ['das Hotel', 'der Bahnhof', 'der Flughafen', 'die Toilette'], 1, 'der Bahnhof'),
        listen('u6l1e3', 'Wo ist der Bahnhof?', ['Where is the hotel?', 'Where is the station?', 'Where is the airport?', 'Where is the restroom?'], 1),
        bank('u6l1e4', 'Where is the hotel?', ['ist', 'das', 'Hotel', 'Wo', 'der'], ['Wo', 'ist', 'das', 'Hotel']),
        mc('u6l1e5', 'die Toilette', PromptLanguage.GERMAN, ['the ticket', 'the restroom', 'the street', 'the city'], 1, 'die Toilette'),
        match('u6l1e6', [pair('der Bahnhof', 'train station'), pair('das Hotel', 'hotel'), pair('der Flughafen', 'airport'), pair('die Toilette', 'restroom')])
      ]),
      lesson('u6-l2', 'Directions', '➡️', 10, [
        mc('u6l2e1', 'links', PromptLanguage.GERMAN, ['right', 'left', 'straight ahead', 'back'], 1, 'links'),
        mc('u6l2e2', 'right', PromptLanguage.ENGLISH, ['links', 'rechts', 'geradeaus', 'hier'], 1, 'rechts'),
        listen('u6l2e3', 'geradeaus', ['left', 'right', 'straight ahead', 'stop'], 2),
        bank('u6l2e4', 'Go left, please', ['links', 'bitte', 'Gehen', 'Sie', 'rechts'], ['Gehen', 'Sie', 'links', 'bitte']),
        blank('u6l2e5', 'Es ist', '.', 'It is on the right.', ['rechts', 'Wasser', 'danke', 'drei'], 0),
        match('u6l2e6', [pair('links', 'left'), pair('rechts', 'right'), pair('geradeaus', 'straight ahead'), pair('hier', 'here')])
      ]),
      lesson('u6-l3', 'Tickets', '🎫', 15, [
        mc('u6l3e1', 'die Fahrkarte', PromptLanguage.GERMAN, ['the suitcase', 'the ticket', 'the passport', 'the map'], 1, 'die Fahrkarte'),
        listen('u6l3e2', 'Eine Fahrkarte nach Berlin, bitte', ['A ticket to Berlin, please', 'A hotel in Berlin, please', 'A coffee in Berlin, please', 'The station in Berlin'], 0),
        bank('u6l3e3', "I'm looking for the airport", ['suche', 'den', 'Flughafen', 'Ich', 'Bahnhof'], ['Ich', 'suche', 'den', 'Flughafen']),
        mc('u6l3e4', "I don't understand", PromptLanguage.ENGLISH, ['Ich verstehe nicht', 'Ich weiß nicht', 'Ich bin nicht', 'Ich komme nicht'], 0, 'Ich verstehe nicht'),
        blank('u6l3e5', 'Sprechen Sie', '?', 'Do you speak English?', ['Englisch', 'Deutsch', 'Wasser', 'links'], 0),
        match('u6l3e6', [pair('die Fahrkarte', 'ticket'), pair('Ich suche', "I'm looking for"), pair('Ich verstehe nicht', "I don't understand"), pair('bitte', 'please')])
      ])
    ],
    vocab: [
      vocab('Wo ist…?', 'Where is…?'),
      vocab('der Bahnhof', 'train station'),
      vocab('das Hotel', 'hotel'),
      vocab('der Flughafen', 'airport'),
      vocab('die Toilette', 'restroom'),
      vocab('links', 'left'),
      vocab('rechts', 'right'),
      vocab('geradeaus', 'straight ahead'),
      vocab('die Fahrkarte', 'ticket'),
      vocab('Ich verstehe nicht', "I don't understand")
    ]
  }
}

function verbs(): CourseUnit {
  return {
    id: 'verbs',
    number: 7,
    title: 'Everyday verbs',
    germanTitle: 'Verben',
    subtitle: 'Live, learn, go, and have',
    symbol: '⚡',
    color: '#58CC02',
    lessons: [
      lesson('u7-l1', 'I am / I have', '🙂', 10, [
        mc('u7l1e1', 'I am tired', PromptLanguage.ENGLISH, ['Ich habe müde', 'Ich bin müde', 'Ich gehe müde', 'Ich lerne müde'], 1, 'Ich bin müde'),
        mc('u7l1e2', 'Ich habe Zeit', PromptLanguage.GERMAN, ['I am time', 'I have time', 'I need time', 'I like time'], 1, 'Ich habe Zeit'),
        listen('u7l1e3', 'Ich bin hungrig', ['I am thirsty', 'I am hungry', 'I am tired', 'I am happy'], 1),
        bank('u7l1e4', 'I am happy', ['bin', 'glücklich', 'Ich', 'habe', 'müde'], ['Ich', 'bin', 'glücklich']),
        blank('u7l1e5', 'Ich', 'Durst.', 'I am thirsty. (I have thirst)', ['habe', 'bin', 'gehe', 'lerne'], 0, 'Ich habe Durst'),
        match('u7l1e6', [pair('Ich bin', 'I am'), pair('Ich habe', 'I have'), pair('müde', 'tired'), pair('hungrig', 'hungry')])
      ]),
      lesson('u7-l2', 'Learn & live', '📖', 10, [
        mc('u7l2e1', 'Ich lerne Deutsch', PromptLanguage.GERMAN, ['I teach German', 'I learn German', 'I speak German', 'I like German'], 1, 'Ich lerne Deutsch'),
        mc('u7l2e2', 'I live in Berlin', PromptLanguage.ENGLISH, ['Ich gehe in Berlin', 'Ich wohne in Berlin', 'Ich bin Berlin', 'Ich habe Berlin'], 1, 'Ich wohne in Berlin'),
        listen('u7l2e3', 'Ich lerne jeden Tag', ['I learn every day', 'I live every day', 'I go every day', 'I eat every day'], 0),
        bank('u7l2e4', 'I am learning German', ['lerne', 'Deutsch', 'Ich', 'spreche', 'Wohnen'], ['Ich', 'lerne', 'Deutsch']),
        blank('u7l2e5', 'Ich', 'in München.', 'I live in Munich.', ['wohne', 'lerne', 'habe', 'heiße'], 0),
        match('u7l2e6', [pair('lernen', 'to learn'), pair('wohnen', 'to live'), pair('jeden Tag', 'every day'), pair('Deutsch', 'German')])
      ]),
      lesson('u7-l3', 'Going places', '🚶', 15, [
        mc('u7l3e1', 'Ich gehe ins Café', PromptLanguage.GERMAN, ['I am the café', 'I go to the café', 'I drink the café', 'I see the café'], 1, 'Ich gehe ins Café'),
        listen('u7l3e2', 'Ich gehe nach Hause', ['I go home', 'I am at home', 'I leave the house', 'I have a house'], 0),
        bank('u7l3e3', 'I go to the station', ['gehe', 'zum', 'Bahnhof', 'Ich', 'Hotel'], ['Ich', 'gehe', 'zum', 'Bahnhof']),
        mc('u7l3e4', 'today', PromptLanguage.ENGLISH, ['gestern', 'heute', 'morgen', 'jetzt'], 1, 'heute'),
        blank('u7l3e5', 'Ich gehe', 'ins Restaurant.', 'I am going to the restaurant today.', ['heute', 'Wasser', 'müde', 'drei'], 0),
        match('u7l3e6', [pair('gehen', 'to go'), pair('heute', 'today'), pair('morgen', 'tomorrow'), pair('nach Hause', 'home')])
      ])
    ],
    vocab: [
      vocab('Ich bin', 'I am'),
      vocab('Ich habe', 'I have'),
      vocab('müde', 'tired'),
      vocab('hungrig', 'hungry'),
      vocab('lernen', 'to learn'),
      vocab('wohnen', 'to live'),
      vocab('gehen', 'to go'),
      vocab('heute', 'today'),
      vocab('morgen', 'tomorrow')
    ]
  }
}

function cafe(): CourseUnit {
  return {
    id: 'cafe',
    number: 8,
    title: 'At the café',
    germanTitle: 'Im Café',
    subtitle: 'A full beginner conversation',
    symbol: '☕',
    color: '#FFC800',
    lessons: [
      lesson('u8-l1', 'Ordering', '📋', 15, [
        listen('u8l1e1', 'Was möchten Sie?', ['What would you like?', 'How much is it?', 'Where are you from?', 'Do you understand?'], 0),
        mc('u8l1e2', 'For here or to go?', PromptLanguage.ENGLISH, ['Mit oder ohne?', 'Zum Hieressen oder zum Mitnehmen?', 'Zusammen oder getrennt?', 'Tee oder Kaffee?'], 1, 'Zum Hieressen oder zum Mitnehmen?'),
        bank('u8l1e3', 'A coffee with milk, please', ['Kaffee', 'mit', 'Milch', 'Einen', 'bitte', 'ohne'], ['Einen', 'Kaffee', 'mit', 'Milch', 'bitte']),
        mc('u8l1e4', 'without sugar', PromptLanguage.ENGLISH, ['mit Zucker', 'ohne Zucker', 'kein Kaffee', 'viel Milch'], 1, 'ohne Zucker'),
        blank('u8l1e5', 'Das ist alles,', '.', "That's all, thank you.", ['danke', 'bitte', 'hallo', 'nein'], 0),
        match('u8l1e6', [pair('Was möchten Sie?', 'What would you like?'), pair('zum Mitnehmen', 'to go'), pair('mit Milch', 'with milk'), pair('ohne Zucker', 'without sugar')])
      ]),
      lesson('u8-l2', 'Paying', '💳', 15, [
        mc('u8l2e1', 'Kann ich mit Karte zahlen?', PromptLanguage.GERMAN, ['Can I pay by card?', 'Do you have a card?', 'Where is the card?', 'I need a ticket'], 0, 'Kann ich mit Karte zahlen?'),
        listen('u8l2e2', 'Bar oder Karte?', ['Bread or coffee?', 'Cash or card?', 'Here or to go?', 'Tea or milk?'], 1),
        bank('u8l2e3', 'The check, please', ['Die', 'Rechnung', 'bitte', 'Karte'], ['Die', 'Rechnung', 'bitte']),
        mc('u8l2e4', 'Keep the change', PromptLanguage.ENGLISH, ['Stimmt so', 'Kein Problem', 'Gute Nacht', 'Auf Wiedersehen'], 0, 'Stimmt so'),
        blank('u8l2e5', 'Das macht', 'Euro.', 'That comes to eight euros.', ['acht', 'Wasser', 'bitte', 'links'], 0),
        match('u8l2e6', [pair('zahlen', 'to pay'), pair('die Karte', 'card'), pair('bar', 'cash'), pair('die Rechnung', 'the check')])
      ]),
      lesson('u8-l3', 'Final challenge', '🏁', 20, [
        listen('u8l3e1', 'Guten Tag, ich hätte gern einen Kaffee', ['Hello, I would like a coffee', 'Good night, I drink tea', 'Excuse me, where is the café?', 'Thanks, the check please'], 0),
        bank('u8l3e2', "I don't understand. Do you speak English?", ['verstehe', 'nicht', 'Sprechen', 'Sie', 'Englisch', 'Ich'], ['Ich', 'verstehe', 'nicht', 'Sprechen', 'Sie', 'Englisch']),
        mc('u8l3e3', 'Where is the restroom?', PromptLanguage.ENGLISH, ['Wo ist die Toilette?', 'Wo ist der Bahnhof?', 'Wie viel kostet das?', 'Wie heißt du?'], 0, 'Wo ist die Toilette?'),
        blank('u8l3e4', 'Ich komme aus', '.', 'I am from Germany.', ['Deutschland', 'Kaffee', 'danke', 'links'], 0),
        mc('u8l3e5', 'Nice to meet you. My name is Otto.', PromptLanguage.ENGLISH, ['Freut mich. Ich heiße Otto.', "Wie geht's. Ich bin Otto.", 'Danke. Ich esse Otto.', 'Bitte. Ich wohne Otto.'], 0, 'Freut mich. Ich heiße Otto.'),
        match('u8l3e6', [pair('Guten Tag', 'Hello'), pair('Ich hätte gern', 'I would like'), pair('Wo ist…?', 'Where is…?'), pair('Vielen Dank', 'Thank you very much')])
      ])
    ],
    vocab: [
      vocab('Was möchten Sie?', 'What would you like?', 'formal'),
      vocab('zum Mitnehmen', 'to go'),
      vocab('ohne Zucker', 'without sugar'),
      vocab('Die Rechnung, bitte', 'The check, please'),
      vocab('Kann ich mit Karte zahlen?', 'Can I pay by card?'),
      vocab('Stimmt so', 'Keep the change'),
      vocab('Das macht…', 'That comes to…')
    ]
  }
}
