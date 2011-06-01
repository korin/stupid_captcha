# about

Simple stupid captcha, use it with flash.

## how it works
1. Flash ask for captcha, for example at /captcha.json
2. get json with id and img
3. send post with data, captcha_id and captcha_input
4. validate captcha on serwer side
5. save data

# settings

create file config/stupid_captcha.rb and set StupidCaptcha settings
user rake secret to generate some goog salt

    if defined?(StupidCaptcha)
      StupidCaptcha.setup do |config|
        # fonts path, point to directory, default GEM_RROT/assets/fonts
        config.salt = "5b213328a3ed873013c553f15......."

        # fonts path, point to directory, default GEM_RROT/assets/fonts
        config.fonts_path = Rails.root.join('artwork/fonts').to_s

        # set fonts array directly (fonts_path is not used), you can find default fonts in GEM_RROT/assets/fonts
        config.fonts = [
          Rails.root.join('artwork/fonts/1.ttf').to_s
        ]

        # backgrounds path, point to directory, default GEM_RROT/assets/backgrounds
        config.backgrounds_path = Rails.root.join('artwork/backgrounds').to_s

        # set backgrounds array directly (backgrounds_path is not used), you can find default fonts in GEM_RROT/assets/backgrounds
        config.backgrounds = [
          Rails.root.join('artwork/backgrounds/1.png').to_s
        ]

        # colors
        config.colors = %w{black}

      end
    end

# use it
## create captcha controller

    require 'base64'

    class CaptchaController < ApplicationController
      def index
        c = StupidCaptcha::Captcha.new
        c.reset

        respond_to do |wants|
          wants.json  do
            render text: {
              id: c.hash,
              img: Base64.encode64(c.to_blob)
            }.to_json
          end
        end
      end
    end


## create data controller

    class DataController < ApplicationController
      def create
        @data = Data.new(params[:data])

        respond_to do |wants|
          if StupidCaptcha::Captcha.new.check(params[:captcha_id], params[:captcha_input]) && @data.save
            flash[:notice] = 'Data was successfully created.'
            wants.html { redirect_to(@data) }
            wants.xml  { render :xml => @data, :status => :created, :location => @data }
          else
            wants.html { render :action => "new" }
            wants.xml  { render :xml => @data.errors, :status => :unprocessable_entity }
          end
        end
      end
    end

## routing

    get  '/captcha', :controller => "captcha", :action => 'index'
    post '/data'   , :controller => "data"   , :action => 'create'

# Help

Looking for help?
try:
or email to me: lisukorin [at] gmail [dot] com, 
don't forget write 'stupid captcha' in subject or my mail client will treat your message as spam.
