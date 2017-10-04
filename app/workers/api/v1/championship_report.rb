module Api
  module V1
    class ChampionshipReport
      def self.format_award(results)
        return nil if results.empty?
        winners = []
        results.sort_by{|x| x.position}.each do |result|
          winners << {
            :team_name => result.team.name,
            :position => result.position,
            :prize => result.prize,
            :team_symbol => Connection.team_score(result.team.slug)["time"]["url_escudo_svg"]
          }
        end
        return winners
      end

      def self.perform
        champions = Hash.new
        season = Season.last
        champions["first_turn"] = format_award(Award.where("season_id = ? and award_type = 3", season.id))
        champions["second_turn"] = format_award(Award.where("season_id = ? and award_type = 4", season.id))
        champions["championship"] = format_award(Award.where("season_id = ? and award_type = 0", season.id))
        $redis.set("championship_award", champions.to_json)
      end
    end
  end
end
