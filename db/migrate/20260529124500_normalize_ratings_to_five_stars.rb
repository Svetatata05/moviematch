class NormalizeRatingsToFiveStars < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE ratings
      SET score = CEIL(score / 2.0)
      WHERE score > 5
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE ratings
      SET score = score * 2
      WHERE score <= 5
    SQL
  end
end
