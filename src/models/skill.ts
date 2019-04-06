import Tag from '@/models/tag'

export default class Skill {
  public name = ''
  public description = ''
  public ct = 0
  public unlock = ''
  public upgrade: Skill | null = null
  public tags: Tag[] = []

  public constructor(entry: SkillJsonEntry) {
    this.name = entry.name
    this.description = entry.description
    this.ct = entry.ct
    this.unlock = entry.unlock
    if (entry.upgrade) {
      this.upgrade = new Skill(entry.upgrade)
    }
    this.tags = entry.tags.map(t => new Tag(t))
  }
}

export interface SkillJsonEntry {
  name: string
  description: string
  ct: number
  unlock: string
  upgrade: SkillJsonEntry | null
  tags: string[]
}
