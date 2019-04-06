declare type TagState = 'none' | 'select' | 'exclude'

export default class Tag {
  public readonly categories: string[] = []
  public readonly name: string = ''
  public readonly fullName: string = ''
  public state: TagState = 'none'

  public constructor(init: string) {
    this.fullName = init
    const match = /^((?:<\w+>)+)([^<].*)$/.exec(init)
    if (match) {
      this.name = match[2]
      this.categories = match[1].split(/<(\w+)>/)
      this.categories = this.categories.filter(cat => !/^[<>]+$/.test(cat))
    }
  }
  public get target(): string {
    const m = this.name.match(/^\[.\]/)
    if (m) {
      return m[0]
    } else {
      return ''
    }
  }
  public get pureName(): string {
    return this.name.replace(/^\[.\]/, '')
  }

  public getNextState(): TagState {
    switch (this.state) {
      case 'none':
        return 'select'
      case 'select':
        return 'exclude'
      case 'exclude':
        return 'none'
    }
  }
}
