def shotted_all_pins?(pins)
  if pins.is_a?(Integer)
    pins == 10
  else
    pins == 'X'
  end
end

def strike?(frame)
  shotted_all_pins?(frame.first)
end

def spare?(frame)
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
  current_frame_score = 10
  next_frame_score = frames[current_index + 1][0]

  current_frame_score + next_frame_score
end

def separate_by_frame(shots)
  last_index = shots.size - 1
  frame_number = 1
  frames = []
  frame = []
  shots.each_with_index do |shot, idx|
    if shotted_all_pins?(shot) && frame.empty? && frame_number < 10
      frame << shot << 0
    else
      frame << shot
    end

    if (frame_number < 10 && frame.size == 2) ||
      (idx == last_index && frame.size == 2) ||
      (frame_number == 10 && frame.size == 3)

      frames << frame
      frame_number += 1
      frame = []
    end
  end

  frames
end

score = ARGV[0]
scores = score.chars
shots = scores.map { |s| shotted_all_pins?(s) ? 10 : s.to_i }
frames = separate_by_frame(shots)

point = 0
frames.each.with_index(frame_number = 1) do |frame, frame_number|
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
