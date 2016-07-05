# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Shots::Application.initialize!
FileUtils::mkdir_p 'tmp/audio_files/lyrics'
FileUtils::mkdir_p 'tmp/audio_files/songs'
