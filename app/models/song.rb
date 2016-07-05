class Song < ActiveRecord::Base
  attr_accessible :lyric
  require 'open-uri'
  # /tts is the function name, there might be others besides tts
  YAKIT_URL= 'https://www.yakitome.com/api/rest/'
  HERD_ID = 196376

  require 'net/https'
  require 'open-uri'

  def setup
    get_book_id
    get_audio_link
    download_voice_audio
  end

  def voice_path
    "./tmp/audio_files/lyrics/#{yakit_book_id}.mp3"
  end

  def song_path
    "./tmp/audio_files/songs/#{yakit_book_id}.mp3"
  end

  def download_voice_audio
    puts 'downloading voice audio'
    if File.exists? voice_path
      puts 'voice audio exists, returning'
      return true
    end
    get_audio_link if audio_link.nil?
    open(voice_path, 'wb') do |file|
      file << open(audio_link).read
    end
    true
  end

  def get_audio_link
    return audio_link if !audio_link.nil?
    puts "retrieving audio link"
    link = make_request('audio', {book_id: yakit_book_id, format: 'mp3'})['audios'][0]
    if link.nil?
      puts 'file not ready, sleeping 5 seconds...'
      sleep 5
      return get_audio_link
    else
      self.update_attributes!(audio_link: link)
    end
  end

  def get_book_id
    return yakit_book_id if !yakit_book_id.nil?
    puts "retreiving book id"
      data = {
        'voice' => 'Mike',
        'speed' => 5,
        'text' => lyric}
      response = make_request('tts', data)
      self.update_attributes(yakit_book_id: response['book_id'])
  end

  private
  def song_params
    params.require(:song).permit(:lyric)
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

  def api_key
    @api_key ||= HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml", __FILE__))))['yakit_key']
  end

  # potentially useful at some point
  # def myherds
  #   make_request('myherds')
  # end

  # def status
  #   data = {book_id: yakit_book_id}
  #   make_request('status', data)['status']
  # end
end
