module Api
  module V1
    class AwardsController < ApplicationController
      before_action :authenticate_user, except: [ :index, :championship, :monthly ]
      before_action :set_award, only: [:show, :update, :destroy]

      # GET /awards
      def index
        @awards = Award.all

        render json: @awards
      end

      def championship
        @awards = $redis.get("championship_award")

        render json: @awards
      end

      def monthly
        @awards = $redis.get("monthly_awards")

        render json: @awards
      end

      # GET /awards/1
      def show
        render json: @award
      end

      # POST /awards
      def create
        @award = Award.new(award_params)

        if @award.save
          render json: @award, status: :created, location: @award
        else
          render json: @award.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /awards/1
      def update
        if @award.update(award_params)
          render json: @award
        else
          render json: @award.errors, status: :unprocessable_entity
        end
      end

      # DELETE /awards/1
      def destroy
        @award.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_award
          @award = Award.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def award_params
          params.require(:award).permit(:type, :dispute_month_id, :team_id, :position, :season_id)
        end
    end
  end
end
