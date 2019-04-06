require 'nokogiri'
require 'open-uri'

url_atwiki = 'https://www9.atwiki.jp/f_go/pages/713.html'

charset = nil
html = open(url_atwiki) do |f|
    charset = f.charset
    f.read
end

entries = []

doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('//div[@class="zeb svtlistnowrap"]//tr').each do |node|
    node_link = node.at_xpath('.//a')
    next unless node_link

    id = node.at_xpath('./td[1]').content.to_i(10)
    name = node_link.content
    link = node_link.attribute('href').to_s
    note = node.at_xpath('./td[last()]').content.strip
    entries.push [id, name, link, note]
    # puts [id, name, link, note].join("\t")
end

url_wicurio = 'https://grand_order.wicurio.com/index.php?%E3%82%B5%E3%83%BC%E3%83%B4%E3%82%A1%E3%83%B3%E3%83%88%E4%B8%80%E8%A6%A7'

charset = nil
html = open(url_wicurio) do |f|
    charset = f.charset
    f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('//div[@class="ie5"]//tr').each do |node|
    node_link = node.at_xpath('.//a')
    next unless node_link

    node_id = node.at_xpath('./th[1]')
    next unless node_id
    id = node_id.content.to_i(10)
    ent = entries.find {|e| e[0] == id}
    next unless ent

    link = node_link.attribute('href').to_s
    link.sub!(/^https?:/, '')
    ent.push link
end

entries.each {|e| puts e.join("\t")}
