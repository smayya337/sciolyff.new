# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Placing < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @event = interpreter.events.find { |e| e.name   == @rep[:event] }
      @team  = interpreter.teams .find { |t| t.number == @rep[:team]  }
    end

    attr_reader :event, :team

    def participated?
      @rep[:participated] == true || @rep[:participated].nil?
    end

    def disqualified?
      @rep[:disqualitied] == true
    end

    def exempt?
      @rep[:exempt] == true
    end

    def unknown?
      @rep[:unknown] == true
    end

    def tie?
      @rep[:tie] == true
    end

    def place
      @rep[:place]
    end

    def did_not_participate?
      !participated? && !disqualified?
    end

    def participation_only?
      participated? && !place && !unknown?
    end

    def points
      return @cache[:points] if @cache[:points]

      n = event.competing_teams.count

      @cache[:points] =
        if    disqualified?        then n + 2
        elsif did_not_participate? then n + 1
        elsif participation_only?  then n
        elsif unknown?             then n - 1
        else  calculate_points
        end
    end

    def considered_for_team_points?
      !(event.trial? || event.trialed? || exempt?)
    end

    private

    def calculate_points
      return place if event.trial?

      place - event.placings.count do |p|
        (p.exempt? || p.team.exhibition?) &&
          p.place &&
          p.place < place
      end
    end
  end
end