class SongsController < ApplicationController
  def backing
    backing = File.read('./app/assets/sounds/backing.mp3')
    send_data backing
  end

  def new
  end

  def create
    @song = Song.find_or_create_by!(params['song'])
    @song.setup
    redirect_to @song
  end

  def show
    @song = Song.find(params['id'])
  end
end
