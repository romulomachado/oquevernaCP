require "uri"
require "net/https"
require "json"

@calendar_feeds = [
  "campus-party.com.br_l6ecjd1kqb3u48a2u3mobblljo%40group.calendar.google.com",
  "campus-party.com.br_a42l571rjt75t0e906uma1mqec%40group.calendar.google.com",
  "campus-party.com.br_fss4977vco3a3vr2tp800jfskg%40group.calendar.google.com",
  "campus-party.com.br_2mt0kll3lt3uecboccgml4p5rg%40group.calendar.google.com",
  "campus-party.com.br_ao1mcr7t3mnnqctjuo504m289o%40group.calendar.google.com",
  "campus-party.com.br_v7am8sts84s1qrhk3h4rhsejdk%40group.calendar.google.com",
  "campus-party.com.br_sb1t4qv23ai050un7hpsk4k0t8%40group.calendar.google.com",
  "campus-party.com.br_c0i8atisofqbefkkuhdkrrn5r4%40group.calendar.google.com",
  "campus-party.com.br_9j8hb2nn9ueqgl2799sgrnlres%40group.calendar.google.com"
]


@calendar_feeds.each do |feed|
  puts "Getting feed: " + feed

  gdata_api_url = "https://www.google.com/calendar/feeds/" +
                  feed +
                  "/public/full-noattendees?alt=json&orderby=starttime" +
                  "&start-min=2014-07-23T00:00:00-02:00" +
                  "&start-max=2014-07-27T23:59:59-02:00" +
                  "&futureevents=true&max-results=300"

  uri = URI.parse(gdata_api_url);

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  req = Net::HTTP::Get.new(uri.request_uri)
  req["Host"] = uri.host
  response = http.request(req)

  if response.code == "200"
    agenda = JSON.parse(response.body)

    title = agenda["feed"]["title"]["$t"]
    last_update = agenda["feed"]["updated"]["$t"]
    puts "  Calendário: " + title
    puts "  Entradas: " +  agenda["feed"]["openSearch$totalResults"]["$t"].to_s
    puts "  Atualizado em: " + last_update
    puts "  File size: #{response.body.size.to_s} bytes"
    File.open("./output/"+title.gsub(/[^\x00-\x7F]|[ -]/,"")+".json", 'w') { |file| file.write(response.body) }
  else
    puts "  Erro! #{response.code.to_s} - #{response.body}"
  end
end
