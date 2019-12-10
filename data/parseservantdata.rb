# coding: utf-8

require 'nokogiri'
require 'json'

CLASS_TABLE = %w(
    セイバー アーチャー ランサー
    ライダー キャスター アサシン バーサーカー
    ルーラー アヴェンジャー アルターエゴ ムーンキャンサー フォーリナー シールダー)

class Servant
    attr_accessor :id, :name, :class_name, :rarity, :cost, :quick, :arts, :buster, 
        :attribution, :gender, :alignment, :traits, :skills, :noble_phantasm, 
        :class_skills, :availability, :illustrator, :voice_actor,
        :url_wiki1, :url_wiki2
    attr_reader :tags

    def initialize
        @traits = []
        @skills = []
        @class_skills = []
        @noble_phantasm = nil
    end

    def to_json(*a)
        {
            id: @id,
            name: @name,
            className: @class_name,
            rarity: @rarity,
            cost: @cost,
            quick: @quick,
            arts: @arts,
            buster: @buster,
            attribution: @attribution,
            gender: @gender,
            alignment: @alignment,
            traits: @traits,
            noblePhantasm: @noble_phantasm,
            skills: @skills,
            classSkills: @class_skills,
            availability: @availability,
            illustrator: @illustrator,
            voiceActor: @voice_actor,
            tags: @tags,
            urlWiki1: @url_wiki1,
            urlWiki2: @url_wiki2,
        }.to_json(*a)
    end

    def generate_tags
        @tags = []

        @tags.push("<servant><servant_class>#{@class_name}")
        @tags.push("<servant><servant_class>三騎士") if %w(セイバー アーチャー ランサー).include?(@class_name)
        @tags.push("<servant><servant_class>四騎士") if %w(ライダー キャスター アサシン バーサーカー).include?(@class_name)
        @tags.push("<servant><servant_class>エクストラクラス") if %w(ルーラー アヴェンジャー アルターエゴ ムーンキャンサー フォーリナー シールダー).include?(@class_name)
        @tags.push("<servant><servant_rarity>★#{@rarity}")
        @tags.push("<servant><servant_rarity>★4") if @id == 1 # マシュ
        (2 .. 4).each {|i| @tags.push("<servant><servant_rarity>★#{i}以上") if @rarity >= i}
        (2 .. 4).each {|i| @tags.push("<servant><servant_rarity>★#{i}以下") if @rarity <= i}
        if ['男性', '女性'].include?(@gender)
            @tags.push("<servant><servant_trait>#{@gender}")
        else
            @tags.push("<servant><servant_trait>性別不明")
        end
        @tags += @alignment.sub('善＆悪', '善・悪').split('・').map {|a| "<servant><servant_attr>#{a}"}
        @tags.push('<servant><servant_attr>善・中庸・悪以外') unless @alignment.match?(/・(善|中庸|悪)/)
        @tags.push('<servant><servant_card>' + 'Q' * @quick + 'A' * @arts + 'B' * @buster)
        @tags.push("<servant><servant_attr>#{@attribution}属性")
        @tags.push('<servant><servant_attr>天または地') if @attribution == '天' or @attribution == '地'
        @tags += @traits.select {|t| !t.match?(/^(サーヴァント|セイバークラスのサーヴァント|ｴﾇﾏ特攻無効|不明特性〔竜殺し？〕|騎乗スキル)$/)}.map {|t| "<servant><servant_trait>#{t}"}

        case @availability
        when /クリアで追加/
            @tags.push('<servant><servant_availability>ストーリー限定')
        when /期間限定/
            @tags.push('<servant><servant_availability>期間限定')
        when /イベント報酬/
            @tags.push('<servant><servant_availability>イベント報酬')
        else
            @tags.push('<servant><servant_availability>恒常') unless @id == 1 # マシュを除外
        end

        @noble_phantasm.generate_tags
        @skills.each {|s| s.generate_tags}
        @class_skills.each {|s| s.generate_tags}

        @tags += @noble_phantasm.tags
        @tags += @noble_phantasm.upgrade.tags if @noble_phantasm.upgrade

        skill_tags = @skills.map {|skill| skill.tags + (skill.upgrade ? skill.upgrade.tags : [])} .flatten
        @tags += skill_tags
        if skill_tags.index {|tag| tag.match(/(?<!毎ターン)NP(獲得|配布)$/)}
            np_gain = @skills.reduce(0) {|total, skill| total + (skill.upgrade ? skill.upgrade.np_gain_max : skill.np_gain_max)}
            if np_gain <= 20
                @tags.push("<buff><buff_np>NP#{$1 == '配布' ? '10-20' : np_gain}#{$1}")
            elsif np_gain < 30
                @tags.push("<buff><buff_np>NP25-27#{$1}")
            elsif np_gain <= 50
                @tags.push("<buff><buff_np>NP#{np_gain}#{$1}")
            else
                @tags.push("<buff><buff_np>NP51～#{$1}")
            end
        end

        @tags += @class_skills.map {|skill| skill.tags} .flatten

        if !@noble_phantasm.upgrade && @skills.all? {|skill| !skill.upgrade}
            @tags.push("<other><other_misc>未強化")
        end

        @tags.push("<other><illustrator>#{@illustrator.gsub(/[(（][^)）]+[)）]/, '')}")
        @voice_actor.gsub(/[(（][^)）]+[)）]/, '').split(/[・＆&]|\s*→\s*/).each do |va|
            @tags.push("<other><voice_actor>#{va}")
        end

        @tags.uniq!
    end
end

class NoblePhantasm
    attr_accessor :name, :ruby, :description,  :card_type, :unlock, :upgrade
    attr_reader :tags

    def to_json(*a)
        {
            name: @name,
            ruby: @ruby,
            description: @description,
            cardType: @card_type,
            unlock: @unlock,
            upgrade: @upgrade,
            tags: @tags,
        }.to_json(*a)
    end

    def generate_tags
        @tags = []

        @tags.push("<servant><servant_card><servant_noblephantasm>#{@card_type[0]}宝具")
        
        cat = '<servant><servant_noblephantasm>'
        if @description.match(/強力な(防御力?無視)?攻撃/)
            @tags.push("#{cat}攻撃宝具")
            if @description.include?('敵全体')
                @tags.push("#{cat}全体攻撃宝具")
            else
                @tags.push("#{cat}単体攻撃宝具")
            end
            @tags.push("#{cat}防御力無視宝具") if $1
            @tags.push("#{cat}特攻宝具") if @description.include?('特攻')
        else
            @tags.push("#{cat}補助宝具")
        end
        @tags.push("#{cat}宝具強化済") if @upgrade

        @tags += parse_description_to_tag(@description)
        @tags.uniq!

        @upgrade.generate_tags if @upgrade
    end
end

class Skill
    attr_accessor :name, :description, :ct, :unlock, :upgrade, :np_gain_min, :np_gain_max
    attr_reader :tags

    def initialize
        @np_gain_min = 0
        @np_gain_max = 0
    end

    def to_json(*a)
        {
            name: @name,
            description: @description,
            ct: @ct,
            unlock: @unlock,
            upgrade: @upgrade,
            tags: @tags,
        }.to_json(*a)
    end

    def generate_tags
        @tags = []
        @tags += parse_description_to_tag(@description)
        @tags.uniq!

        @upgrade.generate_tags if @upgrade
    end
end

class ClassSkill
    attr_accessor :name, :description
    attr_reader :tags

    def to_json(*a)
        {
            name: @name,
            description: @description,
            tags: @tags,
        }.to_json(*a)
    end

    def generate_tags
        @tags = []

        @tags.push('<servant><servant_trait><servant_classskill>神性') if @name.start_with?("神性", "女神の神核", "愛神の神核")
        @tags.push('<servant><servant_trait><servant_classskill>騎乗') if @name.start_with?('騎乗')
        @tags.concat(parse_description_to_tag(@description)) if @description.include?('特攻状態')

        %w(対魔力 陣地作成 狂化 道具作成 気配遮断 単独行動 自己回復 領域外の生命 単独顕現).each do |t|
            @tags.push("<servant><servant_classskill>#{t}") if @name.start_with?(t)
        end
    end
end

def parse_description_to_tag(desc)
    tags = []

    reg = /^[<【].+のみ使用可能[>】]/
    if reg.match?(desc)
        tags.push('<other><other_misc>使用条件付き')
        desc = desc.sub(reg, '')
    end
    desc.delete_prefix!('皮を愛でて')

    cur = 0

    patterns = [
        '((?:敵|(?:自身を除く)?味方)[全単]体|自身)(?=(?:〔(?:[^〕]+)〕)?(?:に|へ?の|を))',
        '(攻撃力|防御力|クリティカル威力|宝具威力|(?:Quick|Arts|Buster)カード性能|スター発生率|(?:弱体|精神異常|強化解除)耐性|NP獲得量?|(?:弱体|精神異常|即死|強化)(?:付与)?成功率)(?=[がを]?(?:少し|大|\(?\d+[%％]\)?)?アップ)',
        '(攻撃力|防御力|クリティカル(?:発生率|威力)|宝具威力|(?:Quick|Arts|Buster)カード性能|強化成功率)(?=を?(?:小|大)?ダウン)',
        '(被ダメージカット状態を付与)',
        '(スターを(?:大量)?獲得)',
        '(【デメリット】)',
        '(無敵|回避)(?=(?:状態(?:\((?:\d+[T回]・?)+\))?を)?付与)',
        '(HPを?回復状態を付与)',
        '(ターゲット集中状態を付与)',
        '(NPを(?:少し|すごく|ものすごく)?増やす)',
        '(弱体|精神異常|毒)(?=(?:状態を)?解除)',
        '(防御強化|強化|無敵|回避)(?=状態を解除)',
        '(弱体|精神異常|やけど)(?=無効状態(?:\(.+\))?を付与)',
        '〔([^〕]+)〕(?:クラスへの)?特攻',
        '(ガッツ状態(?:\(.+\))?を付与)',
        '((?:カードの)?スター集中度を大?アップ|スター集中状態を付与)',
        '(スター集中度をダウン)',
        '(毎ターンスター(?:\([^\)]+\))?獲得)',
        '(魅了|スタン|行動不能|豚化|恐怖)(?=(?:（[^）]+）)?(?:状態を)?付与(?!）)|状態にする)',
        '(強力な(?:防御力?無視)?攻撃)',
        '(強化無効状態を付与)',
        '(宝具|スキル)(?=封印状態を付与)',
        '(即死無効状態を付与)',
        '(チャージを(?:[低中高]確率で)?(?:\d*)減らす)',
        '(呪い|毒|やけど)(?=状態を付与)',
        '(無敵貫通|必中)(?=(?:状態)?を付与)',
        '(Quick|Arts|Buster)(?=(?:攻撃|カード)耐性をダウン)',
        '(即死効果)',
        '(HPを?[大超全]?回復(?!量|効果量))',
        '(回復量をアップ)',
        '(毎ターンNP獲得状態を付与|NPを毎ターン増やす)',
        '(延焼|蝕毒|呪厄)',
        '(最大HP[がを]?大?(?:アップ|増やす|増える))',
        '(スキルチャージを\d*進める)',
        '(クラス(?:に対する|に対して)?相性)',
        '(精神弱体|弱体|魅了|即死)(?=耐性を?(?:小|大)?ダウン)',
        '(防御無視状態を付与)',
        '(〕(?:の|のある|している)フィールド|フィールドが〔[^〕]+〕の時)',
        '(フィールドを〔[^〕]+〕特性にする状態を付与)',
    ]

    target = '自身'
    target_short = '[自]'
    is_ally = true
    desc.scan(Regexp.new(patterns.join('|'))).each do |s|
        cat = ''
        if s[0]
            target = s[0]
            target.delete_prefix!('自身を除く')
            target_short = case target
            when '敵全体'
                '[全]'
            when '敵単体'
                '[単]'
            when /味方[全単]体/
                '[他]'
            when '自身'
                '[自]'
            end
            is_ally = !target.include?('敵')
        elsif s[1] and is_ally
            cat = '<buff>'
            buff = s[1]
            buff.sub!(/(攻撃|防御)力/) {|b| $1}
            buff.sub!('発生率', '発生')
            buff.sub!('付与成功率', '成功率')
            buff.sub!(/Quick|Arts|Buster/) {|s| s[0]}
            buff.sub!('カード性能', '性能')
            case buff
            when '攻撃', '宝具威力', /[QAB]性能/
                cat += '<buff_attack>'
            when 'クリティカル威力', 'スター発生'
                cat += '<buff_critical>'
            when '防御'
                cat += '<buff_defence>'
            when /耐性$/
                cat += '<buff_regist>'
            when /成功率$/
                cat += '<buff_probability>'
            when /NP獲得量?/
                cat += '<buff_np>'
                buff = 'NP獲得量'
            end
            if target == '味方全体' and buff == '攻撃' and tags.find {|t| t.include?('[他]攻撃アップ')}
                tags.push("#{cat}二重カリスマ")
            elsif buff.match?(/(耐性|成功率)$/)
                tags.push("#{cat}#{buff}アップ")
            else
                tags.push("#{cat}#{target_short}#{buff}アップ")
            end
        elsif s[2] and !is_ally
            cat = '<debuff>'
            debuff = s[2]
            debuff.sub!(/(攻撃|防御)力/) {|b| $1}
            debuff.sub!('発生率', '発生')
            debuff.sub!(/Quick|Arts|Buster/) {|s| s[0]}
            debuff.sub!('カード性能', '性能')
            case debuff
            when '攻撃', /^クリティカル/, '宝具威力', /[QAB]性能/
                cat += '<debuff_attack>'
            when '防御'
                cat += '<debuff_defence>'
            when /耐性$/
                cat += '<debuff_regist>'
            when /成功率$/
                cat += '<debuff_probability>'
            end
            tags.push("#{cat}#{target_short}#{debuff}ダウン")
        elsif s[3]
            tags.push("<buff><buff_defence>被ダメカット")
            tags.push("<buff><buff_defence>#{target_short}被ダメカット")
        elsif s[4]
            tags.push('<buff><buff_critical>スター獲得')
        elsif s[5]
            tags.push('<other><other_misc>デメリット')
        elsif s[6]
            cat = '<buff><buff_defence>'
            tags.push("#{cat}回避/無敵")
            tags.push("#{cat}#{s[6]}")
            tags.push("#{cat}#{target_short}回避/無敵")
        elsif s[7]
            cat = '<buff><buff_heal>'
            tags.push("#{cat}毎ターンHP回復")
            tags.push("#{cat}#{target_short}HP回復")
        elsif s[8]
            cat = '<buff><buff_defence>'
            tags.push("#{cat}タゲ集中")
            tags.push("#{cat}タゲ集中付与") if target == '味方単体'
        elsif s[9]
            cat = '<buff><buff_np>'
            if target == '自身'
                tags.push("#{cat}NP獲得")
            else
                tags.push("#{cat}NP配布")
            end
        elsif s[10] and is_ally
            cat = '<buff><buff_heal>'
            if s[10] == '弱体'
                tags.push("<buff><buff_heal><buff_regist>弱体解除/無効")
            else
                tags.push("#{cat}#{s[10]}解除")
            end
            tags.push("#{cat}#{target_short}#{s[10]}解除")
        elsif s[11] and !is_ally
            cat = '<debuff><debuff_antibuff>'
            case s[11]
            when '回避', '無敵'
                tags.push("#{cat}回避/無敵解除")
            when '防御強化'
                tags.push("#{cat}防御強化解除")
            else
                tags.push("#{cat}#{s[11]}解除")
                tags.push("#{cat}#{target_short}#{s[11]}解除")
            end
        elsif s[12]
            cat = '<buff><buff_regist>'
            if s[12] == '弱体'
                tags.push("<buff><buff_heal><buff_regist>弱体解除/無効")
                tags.push("#{cat}#{target_short}弱体無効")
            else
                tags.push("#{cat}#{s[12]}無効")
            end
        elsif s[13]
            cat = '<buff><buff_extradamage>'
            tags += (s[13].split('と').map do |s|
                s.sub!('クラスのサーヴァント', 'サーヴァント')
                s.sub!(/天または地の力を持つサーヴァント.*/, '天地サーヴァント')
                s.sub!('人の力を持つ敵', '人属性')
                s.sub!(/[(（][^)）]+[)）]/, '')
                "#{cat}#{s}特攻"
            end)
        elsif s[14]
            cat = '<buff><buff_defence>'
            tags.push("#{cat}ガッツ")
            tags.push("#{cat}#{target_short}ガッツ付与")
        elsif s[15]
            cat = '<buff><buff_critical>'
            tags.push("#{cat}スター集中")
            tags.push("#{cat}スター集中付与") if target == '味方単体'
            tags.push("#{cat}特定カードスター集中") if s[15].start_with?('カードの')
        elsif s[16]
            cat = '<buff><buff_critical>'
            tags.push("#{cat}スター集中ダウン")
        elsif s[17]
            cat = '<buff><buff_critical>'
            tags.push("#{cat}毎ターンスター獲得")
        elsif s[18] and !is_ally
            cat = '<debuff><debuff_delay>'
            tags.push("#{cat}行動不能系付与")
            tags.push("#{cat}#{s[18]}付与")
            tags.push("#{cat}#{target_short}行動不能系付与")
        elsif s[19]
            cat = '<debuff><debuff_defence>'
            tags.push("#{cat}宝具前防御ダウン") if tags.index {|t| t.match?(/(\[[全単]\])?防御ダウン$/)}
            tags.push("#{cat}宝具前防御強化解除") if tags.index {|t| t.match?(/(\[[全単]\])?防御強化解除$/)}
            cat = '<buff><buff_attack>'
            tags.push("#{cat}宝具前攻撃アップ") if tags.index {|t| t.match?(/(\[[自他]\])?攻撃アップ$/)}
            tags.push("#{cat}宝具前カード性能アップ") if tags.index {|t| t.match?(/[QAB]性能アップ$/)}
            tags.push('<buff><buff_attack>防御無視') if s[19].match?(/防御力?無視/)
        elsif s[20]
            cat = '<debuff><debuff_antibuff>'
            tags.push("#{cat}強化無効")
            tags.push("#{cat}#{target_short}強化無効")
        elsif s[21] and !is_ally
            cat = '<debuff><debuff_delay>'
            tags.push("#{cat}#{s[21]}封印")
            tags.push("#{cat}#{target_short}#{s[21]}封印")
        elsif s[22]
            cat = '<buff><buff_regist>'
            tags.push("#{cat}即死無効")
        elsif s[23]
            cat = '<debuff><debuff_delay>'
            tags.push("#{cat}チャージ減")
            tags.push("#{cat}#{target_short}チャージ減")
        elsif s[24]
            cat = '<debuff><debuff_slip>'
            tags.push("#{cat}スリップダメージ")
            tags.push("#{cat}#{target_short}スリップダメージ")
            tags.push("#{cat}#{s[24]}付与")
        elsif s[25] and is_ally
            cat = '<buff><buff_attack>'
            tags.push("#{cat}必中/無敵貫通")
            tags.push("#{cat}#{s[25]}")
            tags.push("#{cat}#{target_short}必中/無敵貫通")
        elsif s[26]
            cat = '<debuff><debuff_defence>'
            tags.push("#{cat}カード耐性ダウン")
            tags.push("#{cat}#{s[26][0]}耐性ダウン")
        elsif s[27] and !is_ally
            cat = '<buff><buff_attack>'
            tags.push("#{cat}即死")
            tags.push("#{cat}#{target_short}即死")
        elsif s[28] and is_ally
            cat = '<buff><buff_heal>'
            tags.push("#{cat}HP回復")
            tags.push("#{cat}#{target_short}HP回復")
        elsif s[29]
            cat = '<buff><buff_heal>'
            tags.push("#{cat}HP回復量アップ")
        elsif s[30]
            cat = '<buff><buff_np>'
            tags.push("#{cat}毎ターンNP獲得")
            tags.push("#{cat}#{target_short}毎ターンNP獲得")
        elsif s[31]
            cat = '<debuff><debuff_slip>'
            tags.push("#{cat}スリップダメージ強化")
            tags.push("#{cat}#{s[31]}")
        elsif s[32]
            cat = '<buff><buff_heal>'
            tags.push("#{cat}最大HPアップ")
        elsif s[33]
            cat = '<buff><buff_skillcharge>'
            tags.push("#{cat}スキルチャージ短縮")
        elsif s[34]
            cat = '<buff><buff_extradamage>'
            tags.push("#{cat}クラス相性変更")
        elsif s[35] and !is_ally
            cat = '<debuff><debuff_regist>'
            tags.push("#{cat}#{s[35]}耐性ダウン")
        elsif s[36]
            cat = '<buff><buff_attack>'
            tags.push("#{cat}防御無視")
            tags.push("#{cat}防御無視状態付与")
        elsif s[37]
            cat = '<other><other_misc>'
            tags.push("#{cat}フィールド依存効果")
        elsif s[38]
            cat = '<other><other_misc>'
            tags.push("#{cat}フィールド特性変更")
        end
    end

    tags
end

def open_parsed_html(path)
    charset = 'utf-8'
    html = File.open(path) do |f|
        f.read
    end
    Nokogiri::HTML.parse(html, nil, charset)
end

def parse_servant_data(doc)
    servant = Servant.new
    node_baseinfo = doc.at_xpath('//h3[contains(text(),"基本情報")]/following-sibling::div[1]')

    servant.id = node_baseinfo.at_xpath('.//td[1]').content.strip.sub('No.', '').to_i
    node_servantname = node_baseinfo.at_xpath('.//td[contains(.,"真名")]/following-sibling::td[1]')
    if node_servantname.at_xpath('.//ruby/rb')
        servant.name = node_servantname.xpath('.//ruby/rb').map {|n| n.content.strip} .join()
        servant.name += node_servantname.xpath('./text()').map {|t| t.content.strip } .join()
    else
        servant.name = node_servantname.content.strip
    end
    servant.name.sub!(Regexp.new("〔(#{CLASS_TABLE.join('|')})〕"), '')
    servant.class_name = node_baseinfo.at_xpath('.//td[contains(.,"Class")]/following-sibling::td[1]').content.strip
    servant.rarity = node_baseinfo.at_xpath('.//td[contains(.,"Rare")]/following-sibling::td[1]').content.strip.to_i
    servant.cost = node_baseinfo.at_xpath('.//td[contains(.,"Cost")]/following-sibling::td[1]').content.strip.to_i

    node_cards = node_baseinfo.at_xpath('.//td[contains(.,"Quick")]/../following-sibling::tr[1]')
    servant.quick = node_cards.at_xpath('./td[1]').content.strip.to_i
    servant.arts = node_cards.at_xpath('./td[2]').content.strip.to_i
    servant.buster = node_cards.at_xpath('./td[3]').content.strip.to_i

    node_subinfo = doc.at_xpath('//h4[contains(.,"隠しステータス")]/following-sibling::div[1]')

    servant.attribution = node_subinfo.at_xpath('.//td[contains(.,"相性")]/following-sibling::td[1]').content.strip
    node_attr = node_subinfo.xpath('.//td[contains(.,"成長")]/following-sibling::td[position()>1]')
    servant.alignment = [node_attr[0].content.strip.sub(/\(\*\d+\)/, ''), node_attr[1].content.strip].join('・')
    servant.gender = node_attr[2].content.strip.sub(/(男|女)性?/) { "#{$1}性" }
    servant.traits = node_subinfo.at_xpath('.//td[contains(.,"特性")]/following-sibling::td[1]').content.strip.split(/\s*\/\s*/)

    # noble phantasm
    node_np = doc.at_xpath('//h3[contains(.,"宝具")]/following-sibling::div[1]')
    servant.noble_phantasm = parse_noblephantasm(node_np)

    # skills
    node_skill1 = doc.at_xpath('//h4[contains(.,"Skill1：")][1]')
    servant.skills.push(parse_skill(node_skill1))
    node_skill2 = doc.at_xpath('//h4[contains(.,"Skill2：")][1]')
    servant.skills.push(parse_skill(node_skill2))
    node_skill3 = doc.at_xpath('//h4[contains(.,"Skill3：")][1]')
    servant.skills.push(parse_skill(node_skill3))

    # skill unlock
    nodes_skill_unlock = doc.xpath('//h4[contains(.,"開放条件")]/following-sibling::ol[1]/li')
    nodes_skill_unlock.each_with_index do |n, i|
        servant.skills[i].unlock = n.at_xpath('./text()').content.strip
        n_up = n.at_xpath('./ol/li[1]/text()')
        servant.skills[i].upgrade.unlock = n_up.content.strip.sub(/^\[強化\]\s*/, '') if n_up and servant.skills[i].upgrade
    end

    # class skills
    node_classskill_base = doc.at_xpath('//h3[contains(.,"クラススキル")]')
    node_classskill = node_classskill_base.at_css('+ div')
    while node_classskill
        servant.class_skills.push(parse_classskill(node_classskill))
        node_classskill = node_classskill.at_css('+ div')
    end

    node_metainfo = doc.at_xpath('//h3[contains(.,"イラストレーター・声優")]/following-sibling::div[1]')
    servant.illustrator = node_metainfo.at_xpath('.//td[contains(.,"ILLUST")]/following-sibling::td[1]').content.strip
    servant.voice_actor = node_metainfo.at_xpath('.//td[contains(.,"CV")]/following-sibling::td[1]').content.strip

    servant
end

def parse_noblephantasm(node)
    np = NoblePhantasm.new

    node_truename = node.at_xpath('./table//td[contains(text(), "真名判明後")]')
    if node_truename
        node = node_truename.at_xpath('./following-sibling::td/div[1]')
    end

    nodes_name = node.xpath('.//th[1]/text()')
    np.ruby = nodes_name[0].content.strip
    np.name = nodes_name[1].content.strip
    
    node_datarow = node.xpath('.//tr[3]/td')
    np.card_type = node_datarow[0].content.strip
    desc = parse_desc(node_datarow[3])
    node.xpath('.//tr[position()>3]').each do |n|
        desc += parse_desc(n.at_xpath('./td[1]'))
    end
    desc = desc.sub(/[\s　]*\n[\s　]*(?:Quick|Arts|Buster)\(x\d+(?:\.\d+)?\)[\s　]*/i, '')
    np.description = desc

    # np upgrade
    node_upgrade_base = node.at_xpath('./following::h4[starts-with(normalize-space(),"強化後")][1]')
    if node_upgrade_base
        node_upgrade = node_upgrade_base.at_xpath('./following-sibling::div[1]')
        np.upgrade = parse_noblephantasm(node_upgrade)
        np.upgrade.unlock = node_upgrade_base.content.sub(/^.*強化後/, '').strip
    end

    np
end

def parse_skill(node)
    skill = Skill.new

    skill_number, name = node.content.strip.split('：')
    skill.name = name
    node_ruby = node.at_xpath('./ruby')
    if node_ruby
        skill.name = node_ruby.at_xpath('./rb').content.strip + node_ruby.at_xpath('./following-sibling::text()').content.chomp
    end
    
    node_skillbody = node.at_xpath('./following-sibling::div[1]')
    nodes_datarow = node_skillbody.xpath('.//tr[2]/td')
    skill.ct = nodes_datarow[0].content.strip
    desc = parse_desc(nodes_datarow[1])
    desc += parse_skill_npgain(nodes_datarow[2 .. -1], desc, skill)

    node_skillbody.xpath('.//tr[position()>2]').each do |n|
        next_desc = parse_desc(n.at_xpath('./td[1]'))
        next_desc += parse_skill_npgain(n.xpath('./td[position()>=2]'), next_desc, skill)
        desc += next_desc
    end
    skill.description = desc

    # skill upgrade
    node_upgrade_base = node.at_xpath("./following-sibling::h4[contains(.,\"#{skill_number}\")][1]")
    if node_upgrade_base
        skill.upgrade = parse_skill(node_upgrade_base)
    end

    skill
end

def parse_desc(node)
    desc = ''
    node.children.each do |c|
        desc += c.text.strip if c.text?
        if c.name == 'span' and c['class'] == 'buff'
            _, buff_name, buff_desc = c.text.strip.split(',')
            desc += "#{buff_name}（#{buff_desc}）"
        end
    end
    desc.gsub!(/(（[^）].+状態）)状態/) {|s| "状態#{$1}"}
    desc.gsub!(/\s*・?確率\d+[%％]\s*/, '')
    desc.gsub!(/\(\)|（）/, '')

    desc
end

def parse_skill_npgain(nodes, desc, skill)
    if desc.match?(/NPを(?:少し|すごく|ものすごく)?増やす/)
        skill.np_gain_min = nodes[0].content.strip.to_i
        skill.np_gain_max = nodes[nodes.size - 1].content.strip.to_i
        if skill.np_gain_min == skill.np_gain_max
            return "(#{skill.np_gain_max})"
        else
            return "(#{skill.np_gain_min}-#{skill.np_gain_max})"
        end
    else
        return ''
    end
end

def parse_classskill(node)
    class_skill = ClassSkill.new

    rank = node.at_xpath('.//tr[1]/td[1]').content.strip.split(',')[1]
    name = node.at_xpath('.//tr[1]/td[2]').content.strip
    class_skill.name = [name, rank].join(' ')

    nodes_descrows = node.xpath('.//tr[position()>1]')
    desc = []
    nodes_descrows.each do |n|
        desc.push(n.at_xpath('./td[1]').content.strip)
    end
    class_skill.description = desc.join('＆').gsub(/＆+/, '＆')

    class_skill
end

def url_to_filename(url)
    (/\/([^\/]+\.html)$/i).match(url)[1]
end

LIST_PATH = './servantlist.txt'

def generate_servants
    servants = []
    File.open(LIST_PATH, 'r') do |f|
        f.each_line do |line|
            id, name, url, availability, url2 = line.chomp.split("\t")
            path = './html/' + url_to_filename(url)
            doc = open_parsed_html(path)
            begin
                servant = parse_servant_data(doc)
                servant.availability = availability
                servant.generate_tags
                servant.url_wiki1 = url
                servant.url_wiki2 = url2
                servants.push(servant)
            rescue => e
                puts "Error at #{name} (#{path})"
                raise e
            end
        end
    end
    servants
end

def generate_taglist(servants)
    all_tags = servants.inject([]) {|tags, servant| tags.concat(servant.tags)}
    all_tags.uniq!
    all_tags.sort! do |tag1, tag2|
        reg_pref = /\[.\]/
        diff = (tag1.sub(reg_pref, '') <=> tag2.sub(reg_pref, ''))
        if diff == 0
            diff = tag1[reg_pref].to_s <=> tag2[reg_pref].to_s
        end
        diff
    end
    all_tags
end

def tag_categories(tag)
    reg_pref = /^\[.\]/
    tag_target = tag[reg_pref]
    tag_body = tag.sub(reg_pref, '')


end

def main
    servants = generate_servants
    File.write('../public/servant.json', JSON.pretty_generate(servants).gsub("\u00A0", ''))
    
    taglist = generate_taglist(servants)
    File.write('../public/tag.json', JSON.pretty_generate(taglist))
end

main
