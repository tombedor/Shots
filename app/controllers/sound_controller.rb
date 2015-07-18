class SoundController < ApplicationController
  def backing
    backing = File.read('./app/assets/sounds/backing.mp3')
    send_data backing
  end

  def yakit

  end
end
