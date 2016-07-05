class SongsController < ApplicationController
  def backing
    backing = File.read('./app/assets/sounds/backing.mp3')
    send_data backing
  end

  def new
  end

  def create
    text = params['song']['text']
    @song = Song.new(text)
    @song.create
    redirect_to @song
  end
end
