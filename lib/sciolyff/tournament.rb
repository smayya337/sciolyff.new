# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Tournament < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @tournament = SciolyFF.rep[:Tournament]
      skip unless @tournament.instance_of? Hash
    end

    def test_has_info
      refute_nil @tournament[:location]
      refute_nil @tournament[:level]
      refute_nil @tournament[:division]
      refute_nil @tournament[:year]
      refute_nil @tournament[:date]
    end

    def test_does_not_have_extra_info
      info = Set.new %i[name location level division state year date]
      assert Set.new(@tournament.keys).subset? info
    end

    def test_has_valid_name
      skip unless @tournament.key? :name
      assert_instance_of String, @tournament[:name]
    end

    def test_has_valid_location
      skip unless @tournament.key? :location
      assert_instance_of String, @tournament[:location]
    end

    def test_has_valid_level
      skip unless @tournament.key? :level
      level = @tournament[:level]
      assert_includes %w[Invitational Regionals States Nationals], level
    end

    def test_has_valid_division
      skip unless @tournament.key? :division
      assert_includes %w[A B C], @tournament[:division]
    end

    def test_has_valid_state
      skip unless @tournament.key? :level
      level = @tournament[:level]
      skip unless %w[Regionals States].include? level
      assert_instance_of String, @tournament[:state]
    end

    def test_has_valid_year
      skip unless @tournament.key? :year
      assert_instance_of Integer, @tournament[:year]
    end

    def test_has_valid_date
      skip unless @tournament.key? :date
      assert_instance_of Date, @tournament[:date]
    end
  end
end
