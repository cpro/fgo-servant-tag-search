require 'open-uri'

GET_ALL = ARGV[0] && ARGV[0].trim == '-a'

def fetch_html_into_file(url, path)
    charset = nil
    html = open(url) do |f|
        charset = f.charset
        f.read
    end

    File.open(path, 'w') do |f|
        f.write(html)
    end
end

def url_to_filename(url)
    (/\/([^\/]+\.html)$/i).match(url)[1]
end

LIST_PATH = './servantlist.txt'
FETCH_INTERVAL_SECOND = 5

def main
    File.open(LIST_PATH, 'r') do |f|
        f.each_line do |line|
            name, url = line.chomp.split("\t")
            url = 'https:' + url
            path = './html/' + url_to_filename(url)
            if GET_ALL || !File.exist?(path)
                puts "fetching #{name} (#{url}) ..."
                fetch_html_into_file(url, path)
                sleep FETCH_INTERVAL_SECOND unless f.eof?
            end
        end
    end
end

main
