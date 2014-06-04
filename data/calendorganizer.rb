require "time"
require "json"

@hashes = {
  "CPRecife3 - Palco Principal" => "principal",
  "CPRecife3 - Galileu" => "galileu",
  "CPRecife3 - Michelangelo" => "michelangelo",
  "CPRecife3 - Pitágoras" => "pitagoras",
  "CPRecife3  Hypatia" => "hypatia",
  "CPRecife3 - Stadium" => "stadium",
  "CPRecife3  - Cross Space" => "crossspace",
  "CPRecife3 - Workshop I" => "workshop1",
  "CPRecife3 - Workshop II" => "workshop2"
}

@result = {
  :general => {},
  :tracks  => {},
  :index   => {
    :general => []
  }
}
# {"1223445688" => [{:title:$t, :link:type[text/html]:href, gd$when:first:startTime, }, {}] }

Dir['./output/*.json'].each do |file|
  puts "Crunching #{file}..."
  agenda = JSON.parse(File.read(file))

  title   = agenda["feed"]["title"]["$t"]
  hashtag = @hashes[title]
  puts "Calendar: #{title} - hashtag: #{hashtag}"

  track_entries = {}
  track_index   = []
  general_index = @result[:index][:general]

  entries = agenda["feed"]["entry"]

  unless entries.nil?
    entries.each do |entry|
      data = {}
      data["title"] = entry["title"]["$t"]
      item = entry["link"].index { |i| i["type"] == "text/html" }
      if item
        data["link"] = entry["link"][item]["href"]
      else
        data["link"] = nil
      end
      data["start"] = entry["gd$when"][0]["startTime"]

      timestamp = Time.xmlschema(data["start"]).to_i.to_s
      puts "Entry: #{data["title"]}\n       #{data["link"]}\n       #{data["start"]}\n       #{timestamp.to_s}"

      unless @result[:general][timestamp]
        @result[:general][timestamp] = []
        general_index << timestamp
      end
      @result[:general][timestamp] << data

      unless track_entries[timestamp]
        track_entries[timestamp] = []
        track_index << timestamp
      end
      track_entries[timestamp] << data
    end
  end

  @result[:tracks][hashtag] = track_entries
  @result[:index][hashtag]  = track_index.sort!
  @result[:index][:general] = general_index.sort!
end

result_json = @result.to_json
File.open("./output/the_data_you_need_to_make_magic.json", 'w') { |file| file.write(result_json) }
puts "Done!"
