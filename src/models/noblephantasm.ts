import Tag from '@/models/tag'

export default class NoblePhantasm {
  public name = ''
  public ruby = ''
  public description = ''
  public cardType = ''
  public unlock: string | null = null
  public upgrade: NoblePhantasm | null = null
  public tags: Tag[] = []

  public constructor(entry?: NoblePhantasmJsonEntry) {
    if (!entry) {
      return
    }

    this.name = entry.name
    this.ruby = entry.ruby
    this.description = entry.description
    this.cardType = entry.cardType
    this.unlock = entry.unlock
    if (entry.upgrade) {
      this.upgrade = new NoblePhantasm(entry.upgrade)
    }
    this.tags = entry.tags.map(t => new Tag(t))
  }
}

export interface NoblePhantasmJsonEntry {
  name: string
  ruby: string
  description: string
  cardType: string
  unlock: string | null
  upgrade: NoblePhantasmJsonEntry | null
  tags: string[]
}
