class Yakit


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
end
