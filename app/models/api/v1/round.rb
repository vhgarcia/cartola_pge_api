module Api
  module V1
    class Round < ApplicationRecord
      belongs_to :season
      belongs_to :dispute_month


      def self.partials
        last_round = Round.last
        scores = Score.where(round: last_round).order('partial_score desc')
      end

      def self.battle_generator
        fantasma = Player.where("name = 'Fantasma'").first
        round = Round.new
        last_round = Round.last
        round.number = last_round.number + 1
        round.season_id = Season.last.id
        round.date = Time.now
        round.save

        players = Player.where("active is true").to_a
        unless ( players.size % 2 == 0 )
          players.delete(fantasma)
        end

        while ( players.size > 0 ) do
          player = players[rand(players.size)]
          # Comparo o player com todos os outros players
          confrontos = Hash.new
          players.delete(player)
          players.each do |rival|
            home = Battle.where("first_id = ? and second_id = ?", player.id, rival.id)
            visiting = Battle.where("first_id = ? and second_id = ?", rival.id, player.id)
            confrontos[rival.id] = home.size + visiting.size
          end

          #descobre os que tem menos jogos
          menor = 10
          confrontos.each do |k, v|
            menor = v if v < menor
          end
          #agora pega os que tem menos jogos
          adversarios = confrontos.select{|k,v| v == menor }.collect{|k, v| k}
          adversario = Player.find(adversarios[rand(adversarios.size)])
          players.delete(adversario)
          Battle.create(first_id: player.id, second_id: adversario.id, round_id: round.id )
        end
      end
    end
  end
end
