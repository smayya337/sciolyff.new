#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optimist'
require 'yaml'
require 'set'

Optimist.options do
  version 'sciolyff 0.1.0'
  banner <<~STRING
    Checks if a given file is in the Scioly File Format

    Usage:
            ./#{File.basename(__FILE__)} [options] <file>

    where [options] are:
  STRING
end

if ARGV.first.nil? || !File.exist?(ARGV.first)
  puts "Error: file '#{ARGV.first}' not found."
  puts 'Try --help for help.'
  exit
end

begin
  file = File.read(ARGV.first)
  $rep = YAML.load(file)
rescue StandardError => exception
  puts 'Error: could not read file as YAML.'
  warn exception.message
  exit
end

puts 'More than one file given, ignoring all but first.' if ARGV.length > 1

puts <<~STRING
  Validating file with Minitest...

  Overkill? Probably.
  Doesn't give line numbers from original file? Yeah.

STRING

require 'minitest/autorun'

# Tests that also serve as the specification for the sciolyff file format
#
class SciolyFFValidate < Minitest::Test
  def setup
    @rep = $rep
  end

  def test_has_tournament
    refute_nil @rep['Tournament']
  end

  def test_has_events
    refute_nil @rep['Events']
  end

  def test_has_teams
    refute_nil @rep['Teams']
  end

  def test_has_placings_or_scores
    refute_nil @rep['Placings'] || @rep['Scores']
  end

  def test_has_penalties
    refute_nil @rep['Penalties']
  end

  def test_does_not_have_extra_sections
    sections = Set.new %w[Tournament Events Teams Placings Scores Penalties]
    assert Set.new(@rep.keys).subset? sections
  end

  def test_has_tournament_info
    info = @rep['Tournament']
    refute_nil info['name']
    refute_nil info['level']
    refute_nil info['division']
    refute_nil info['year']
    refute_nil info['date']
  end

  def test_does_not_have_extra_tournament_info
    info = Set.new %w[name level division year date]
    assert Set.new(@rep['Tournament'].keys).subset? info
  end

  def test_has_valid_tournament_name
    assert_instance_of String, @rep['Tournament']['name']
  end

  def test_has_valid_tournament_level
    level = @rep['Tournament']['level']
    assert_includes %w[Invitational Regionals States Nationals], level
  end

  def test_has_valid_tournament_division
    assert_includes %w[A B C], @rep['Tournament']['division']
  end

  def test_has_valid_tournament_year
    assert_instance_of Integer, @rep['Tournament']['year']
  end

  def test_has_valid_tournament_date
    assert_instance_of Date, @rep['Tournament']['date']
  end
end
