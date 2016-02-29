class Yakit
  require 'open-uri'
  # /tts is the function name, there might be others besides tts
  YAKIT_URL= 'https://www.yakitome.com/api/rest/'
  HERD_ID = 196376

  require 'net/https'
  require 'open-uri'

  def initialize(text)
    @text = text
  end

  def text
    @text
  end

  def api_key
    @api_key ||= HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml", __FILE__))))['yakit_key']
  end

  def status
    data = {book_id: book_id}
    make_request('status', data)['status']
  end

  def myherds
    make_request('myherds')
  end

  def download
    if audio_link.nil?
      puts 'file not ready, sleeping 5 seconds...'
      sleep 5
      download
    else
      open("./tmp/audio_files/#{book_id}.mp3", 'wb') do |file|
        file << open(audio_link).read
      end
    end
  end

  def audio_link
    @audio_link ||= make_request('audio', {book_id: book_id, format: 'mp3'})['audios'][0]
  end

  def make_request(function, data = {})
    url = URI.parse(YAKIT_URL + function)
    data['api_key'] = api_key
    req = Net::HTTP::Post.new(url.path)
    req.form_data = data
    req.basic_auth url.user, url.password if url.user
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    response = con.start {|http| http.request(req)}
    JSON.parse(response.body)
  end

  def book_id
    return @book_id if !@book_id.nil?
    data = {
      'voice' => 'Mike',
      'speed' => 5,
      'text' => text}
    response = make_request('tts', data)
    @book_id = response['book_id']
  end
end
