class Yakit
  # /tts is the function name, there might be others besides tts
  YAKIT_URL= 'https://www.yakitome.com/api/rest/tts'

  require 'net/https'
  require 'open-uri'

  def api_key
    return @api_key if @api_key
    @api_key = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml", __FILE__))))['yakit_key']
  end

  def get_recording(text)
    data = {
      'api_key' => api_key,
      'voice' => 'Mike',
      'speed' => 5,
      'text' => text}


    url = URI.parse(YAKIT_URL)
    req = Net::HTTP::Post.new(url.path)
    req.form_data = data
    req.basic_auth url.user, url.password if url.user
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    con.start {|http| http.request(req)}
  end









  ##### Copied from python,

  import httplib
  import urllib
  def rest(request_type, api_func, vars):
    """performs RESTful calls to YAKiToMe API functions"""
  headers = {
    "Content-type": "application/x-www-form-urlencoded",
    "Accept": "text/plain"
  }
  conn = httplib.HTTPSConnection('www.yakitome.com')
  conn.request(request_type,
               '/api/rest/%s' % api_func,
               urllib.urlencode(vars),
               headers,
  )
  response = conn.getresponse()
  return response.read()

  # setup variables
  vars = dict(
    api_key=my_api_key,
    voice='Mike',
    speed=5,
    text='Hello world!'
  )
  # POST data to tts function
  tts_response = rest('POST', 'tts', vars)

  def initialize
    @key = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml", __FILE__))))['yakit_key']
  end

  def sample
    rest('POST', 'tts', vars)

  end

end
