class Yakit
  # /tts is the function name, there might be others besides tts
  YAKIT_URL= 'https://www.yakitome.com/api/rest/'
  HERD_ID = 196376

  require 'net/https'
  require 'open-uri'

  def api_key
    @api_key ||= HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml", __FILE__))))['yakit_key']
  end

  def myherds
    make_request('myherds')
  end

  def audio_files
    data = {book_id: HERD_ID, format: 'mp3'}
    make_request('audio', data)
  end

  def make_request(function, data = {})
    url = URI.parse(YAKIT_URL + function)
    data['api_key'] = api_key
    req = Net::HTTP::Post.new(url.path)
    req.form_data = data
    binding.pry
    req.basic_auth url.user, url.password if url.user
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    response = con.start {|http| http.request(req)}
    JSON.parse(response.body)
  end

  def create_recording(text)
    data = {
      'voice' => 'Mike',
      'speed' => 5,
      'text' => text}
    response = make_request('tts', data)
  end
end
