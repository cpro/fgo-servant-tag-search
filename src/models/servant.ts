import NoblePhantasm, { NoblePhantasmJsonEntry } from '@/models/noblephantasm'
import Skill, { SkillJsonEntry } from '@/models/skill'
import ClassSkill, { ClassSkillJsonEntry } from '@/models/classskill'
import Tag from '@/models/tag'

export default class Servant {
  public id = 0
  public name = ''
  public className = ''
  public rarity = 0
  public cost = 0
  public quick = 0
  public arts = 0
  public buster = 0
  public attribution = ''
  public gender = ''
  public alignment = ''
  public traits: string[] = []
  public noblePhantasm = new NoblePhantasm()
  public skills: Skill[] = []
  public classSkills: ClassSkill[] = []
  public availability = ''
  public tags: Tag[] = []
  public urlWiki1 = ''
  public urlWiki2 = ''

  public constructor(entry?: ServantJsonEntry) {
    if (!entry) {
      return
    }

    this.id = entry.id
    this.name = entry.name
    this.className = entry.className
    this.rarity = entry.rarity
    this.cost = entry.cost
    this.quick = entry.quick
    this.arts = entry.arts
    this.buster = entry.buster
    this.attribution = entry.attribution
    this.gender = entry.gender
    this.alignment = entry.alignment
    this.traits = entry.traits
    this.noblePhantasm = new NoblePhantasm(entry.noblePhantasm)
    this.skills = entry.skills.map(s => new Skill(s))
    this.classSkills = entry.classSkills.map(s => new ClassSkill(s))
    this.availability = entry.availability
    this.tags = entry.tags.map(t => new Tag(t))
    this.urlWiki1 = entry.urlWiki1
    this.urlWiki2 = entry.urlWiki2
  }
}

export interface ServantJsonEntry {
  id: number
  name: string
  className: string
  rarity: number
  cost: number
  quick: number
  arts: number
  buster: number
  attribution: string
  gender: string
  alignment: string
  traits: string[]
  noblePhantasm: NoblePhantasmJsonEntry
  skills: SkillJsonEntry[]
  classSkills: ClassSkillJsonEntry[]
  availability: string
  tags: string[]
  urlWiki1: string
  urlWiki2: string
}
