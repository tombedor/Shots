class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.timestamps
      t.text :lyric
      t.text :yakit_book_id
      t.text :audio_link
    end

    add_index :songs, :lyric, unique: true
  end
end
