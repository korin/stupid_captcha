require 'RMagick'

module StupidCaptcha
  GEM_ROOT = File.join(File.dirname(__FILE__), '..')

  mattr_accessor :fonts_path
  @@fonts_path = File.join(GEM_ROOT, 'assets/fonts').to_s
  mattr_accessor :fonts
  @@fonts = nil

  mattr_accessor :backgrounds_path
  @@backgrounds_path = File.join(GEM_ROOT, 'assets/backgrounds').to_s
  mattr_accessor :backgrounds
  @@backgrounds = nil

  mattr_accessor :colors
  @@colors = %w(black red green blue)

  mattr_accessor :salt
  @@salt = nil

  def self.setup
    yield self
  end

  def random_string( len = 12)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(len) { |i| str << chars[rand(chars.size-1)] }
    return str
  end

  def encrypt(text, salt)
    Digest::SHA1.hexdigest(text+salt)
  end

  def fonts
    @@fonts ||= files(fonts_path)
  end

  def backgrounds
    @@backgrounds ||= files(backgrounds_path)
  end

  def salt
    raise "StupidCaptcha.salt is blank" if @@salt.blank?
    @@salt
  end

  def files(path)
    array = []
    Dir.foreach(path) do |x|
      file = path+"/"+x
      if File.file?(file)
        array << file
      end
    end
    return array
  end

  def check(hash, text)
    hash.eql?(encrypt(text, salt))
  end

  class Captcha
    include StupidCaptcha

    attr_accessor :text, :img, :hash

    def render
        icon = Magick::Image.read(backgrounds.sample).first

        drawable = Magick::Draw.new
        drawable.pointsize = 32.0
        drawable.font = fonts.sample
        drawable.fill = colors.sample
        drawable.gravity = Magick::CenterGravity

        # Tweak the font to draw slightly up and left from the center
        #        drawable.annotate(icon, 0, 0, -3, -6, @order.quantity.to_s)
        drawable.annotate(icon, 0, 0, 0,0, text)

        img = icon
    end

    def reset
      @text = random_string(rand(3)+5)
      @hash = encrypt(text, salt)
      @img = render
    end

    def to_blob
      img.to_blob
    end

  end
end


require 'stupid_captcha/rails'
