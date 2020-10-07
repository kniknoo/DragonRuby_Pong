DSEG = 'fonts/DSEG14Modern-Bold.ttf'
PALETTE = [ %w{484848 000858 000878 000870 380050 580010 580000 400000
               100000 001800 001E00 00230A 001820 000000 080808 080808 },
            %w{A0A0A0 0048B8 0830E0 5818D8 A008A8 D00058 D01000 A02000
               604000 085800 006800 006810 006070 080808 080808 080808 },
            %w{F8F8F8 20A0F8 5078F8 9868F8 F868F8 F870B0 F87068 F88018
               C09800 70B000 28C020 00C870 00C0D0 282828 080808 080808 },
            %w{F8F8F8 A0D8F8 B0C0F8 D0B0F8 F8C0F8 F8C0E0 F8C0C0 F8C8A0
               E8D888 C8E090 A8E8A0 90E8C8 90E0E8 A8A8A8 080808 080808 } ]
COLORS = PALETTE.map do |s|
  s.map { |c| c.split('').each_slice(2).map {|e| e.join.to_i(16)} }
end


class Player < Solid
  attr_accessor :side, :sound

  def initialize(side:, color:, type: 'human', sound: '')
    @side = side
    x = 100 if @side == 'left'
    x = 1180 if @side == 'right'
    super(x: x, y: 360, w: 30, h: 175)
    @args = $gtk.args
    @mouse = @args.inputs.mouse
    @type = type
    @r, @g, @b = color
    @sound = "sounds/#{sound}.wav"
    @args.static_solids << self
  end

  def move
    case @type
    when 'human' then @y = @mouse.y - @h / 2
    when 'computer'
      @y -= 8 if @args.state.ball.y < @y + @h - @h / 4
      @y += 8 if @args.state.ball.y > @y + @h / 4
    end
    @y = 670 - @h if @y + @h > 670
    @y = 0 if @y.negative?
  end
end

class Ball < Solid
  attr_accessor :y_spd

  def initialize
    super(x: 640, y: 360, w: 30, h: 30)
    @x_dir = -1
    @x_spd = 10
    @y_dir = -1
    @y_spd = 4
    @args = $gtk.args
    @args.static_solids << self
    reset
  end

  def move
    @x += @x_dir * @x_spd
    @y += @y_dir * @y_spd
    @y_dir = -1 if @y + @h > 670
    @y_dir = 1 if @y.negative?
  end

  def touching?(other)
    (other.x..(other.x + other.w)).include?(@x + @w / 2) &&
      (other.y..(other.y + other.h)).include?(@y + @h / 2)
  end

  def bounce(player)
    difference = @y - player.y - player.h / 2
    @y_spd = (difference / 6.25).abs
    @y_dir = difference.negative? ? -1 : 1
    @x_spd += 0.25
    @x_dir = player.side == 'left' ? 1 : -1
    @args.outputs.sounds << player.sound unless @args.state.mute.value
  end

  def color_change
    @r, @g, @b = COLORS[2][rand(11) + 1]
  end

  def reset
    @x = 640 - @w / 2
    @y = 360 - @h / 2
    @y_spd = rand(8) - 4
    @x_spd = 10
  end

  def off_screen?
    (@x + @w).negative? || @x > 1280
  end
end

class Score < Label
  def initialize(x:, color: )
    super(x: x, y: 720, text: 0, color: color, font: DSEG, font_size: 8)
    @args = $gtk.args
    @args.static_labels << self
  end

  def point
    @text += 1
    @args.outputs.sounds << 'sounds/point.wav' unless @args.state.mute.value
  end

  def reset
    @text = 0
  end
end

class Result < Label
  def initialize(color:)
    super(x: 640, y: 300, text: '', font_align: 1, font: DSEG, color: color)
    $gtk.args.static_labels << self
  end
end
