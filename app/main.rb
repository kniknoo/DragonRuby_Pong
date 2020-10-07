# frozen_string_literal: true

require 'lib/dragon_object.rb'
require 'lib/pong.rb'

def tick(args)
  args.outputs.background_color = COLORS[0][12]
  state ||= args.state
  if state.tick_count.zero?
    args.static_solids << [0, 680, 1280, 40, COLORS[1][12]]
    setup(state)
  end
  show_buttons(args)
  check_buttons(state)
  always_animate(state)
  return unless state.tick_count > state.wait_until && state.play.value

  update_gameplay(state)
  return unless state.ball.off_screen?

  update_score(state)
  check_for_winner(state)
  reset_field(state)
end

def setup(state)
  state.players = [Player.new(side: 'left', type: 'human',
                              color: COLORS[2][9], sound: 'ping'),
                   Player.new(side: 'right', type: 'computer',
                              color: COLORS[2][5], sound: 'pong')]
  state.scores = [Score.new(x: 300, color: COLORS[3][12]),
                  Score.new(x: 980, color: COLORS[3][12])]
  state.ball = Ball.new
  state.result = Result.new(color: COLORS[3][12])
  state.wait_until = -1
  state.mute = Button.new(x: 0, y: 680, w: 110, h: 40, text: "Mute",
                          bg: COLORS[0][2], fg: COLORS[3][2], toggle: true,
                          dim: COLORS[1][12], font: DSEG, value: true)
  state.play = Button.new(x: 580, y: 400, w: 120, h: 45, text: "Play",
                          bg: COLORS[1][2], fg: COLORS[3][2],
                          dim: COLORS[1][2], font: DSEG)
end

def show_buttons(args)
  args.primitives << args.state.mute.show
  args.primitives << args.state.play.show unless args.state.play.value
end

def check_buttons(state)
  state.mute.switch if state.mute.clicked?
  if state.play.clicked?
    state.play.value = true
    state.result.text = ''
    state.scores.each(&:reset)
  end
end

def always_animate(state)
  state.players.each(&:move)
  state.ball.color_change if (state.tick_count % 5).zero?
end

def update_gameplay(state)
  state.ball.move
  state.players.each do |player|
    state.ball.bounce(player) if state.ball.touching?(player)
  end
end

def update_score(state)
  state.ball.x > 1280 ? state.scores[0].point : state.scores[1].point
end

def check_for_winner(state)
  state.scores.each.with_index do |score, i|
    if score.text == 10
      state.result.text = "Player #{i + 1} wins"
      state.play.value = false
    end
  end
end

def reset_field(state)
  state.wait_until = state.tick_count + 60
  state.ball.reset
end
