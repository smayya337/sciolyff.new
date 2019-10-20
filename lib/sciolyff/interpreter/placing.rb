# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  # Models the result of a team participating (or not) in an event
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
      @rep[:disqualified] == true
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
      !participated?
    end

    def participation_only?
      participated? && !place && !disqualified? && !unknown?
    end

    def dropped_as_part_of_worst_placings?
      team.worst_placings_to_be_dropped.include?(self)
    end

    def points
      @points ||= if !considered_for_team_points? then 0
                  else isolated_points
                  end
    end

    def isolated_points
      n = event.maximum_place

      if    disqualified? then n + 2
      elsif did_not_participate? then n + 1
      elsif participation_only? || unknown? then n
      else  [calculate_points, n].min
      end
    end

    def considered_for_team_points?
      initially_considered_for_team_points? &&
        !dropped_as_part_of_worst_placings?
    end

    def initially_considered_for_team_points?
      !(event.trial? || event.trialed? || exempt?)
    end

    def placed_behind_exhibition?
      !exhibition_placings_behind.zero?
    end

    private

    def calculate_points
      return place if event.trial?

      place - exhibition_placings_behind
    end

    def exhibition_placings_behind
      @exhibition_placings_behind ||= event.placings.count do |p|
        (p.exempt? || p.team.exhibition?) &&
          p.place &&
          p.place < place
      end
    end
  end
end
