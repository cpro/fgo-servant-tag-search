import Tag from '@/models/tag'

export default class ClassSkill {
  public name = ''
  public description = ''
  public tags: Tag[] = []

  public constructor(entry: ClassSkillJsonEntry) {
    this.name = entry.name
    this.description = entry.description
    this.tags = entry.tags.map(t => new Tag(t))
  }
}

export interface ClassSkillJsonEntry {
  name: string
  description: string
  tags: string[]
}
