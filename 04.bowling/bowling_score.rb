#! /usr/bin/env ruby

# frozen_string_literal: true

def shotted_all_pins?(shotted_pins)
  all_pins = shotted_pins.is_a?(Integer) ? 10 : 'X'
  shotted_pins == all_pins
end

def strike?(frame)
  shotted_all_pins?(frame[0])
end

def spare?(frame)
  return false if frame[0] == 10

  frame_score = frame.inject { |sum, shot| sum + shot }
  frame_score == 10
end

def calculate_strike_score(frames, frame_number)
  current_index = frame_number - 1
  next_frame = frames[current_index + 1]
  after_next_frame = frames[current_index + 2]

  current_frame_score = 10
  next_frame_score = next_frame[0]
  after_next_frame_score =
    if strike?(next_frame) && frame_number < 9
      after_next_frame[0]
    else
      next_frame[1]
    end

  current_frame_score + next_frame_score + after_next_frame_score
end

def calculate_spare_score(frames, frame_number)
  current_index = frame_number - 1
  next_frame = frames[current_index + 1]

  current_frame_score = 10
  next_frame_score = next_frame[0]

  current_frame_score + next_frame_score
end

def separate_by_frame(shots)
  last_index = shots.size - 1
  frame_number = 1
  frames = []
  frame = []
  shots.each_with_index do |shot, idx|
    frame << shot
    frame << 0 if strike?(frame) && frame_number < 10

    next if frame.size < 2 || (frame_number == 10 && idx != last_index)

    frames << frame
    frame_number += 1
    frame = []
  end

  frames
end

score = ARGV[0]
scores = score.chars
shots = scores.map { |s| shotted_all_pins?(s) ? 10 : s.to_i }
frames = separate_by_frame(shots)

point = 0
frames.each.with_index(1) do |frame, frame_number|
  point +=
    if strike?(frame) && frame_number < 10
      calculate_strike_score(frames, frame_number)
    elsif spare?(frame) && frame_number < 10
      calculate_spare_score(frames, frame_number)
    else
      frame.inject { |frame_score, shot| frame_score + shot }
    end
end

puts point
