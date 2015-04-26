class Control < Plugin

    def init(init)
        @bot = init
    end

    def help(h)
        h += "<hr><span style='color:red;'>Plugin CONTROL</span><br />"
        h += "<b>#{@bot[:controlstring]}ch</b> Bot jump in your channel.<br />"
        h += "<b>#{@bot[:controlstring]}debug</b> Probe command.<br />"
        h += "<b>#{@bot[:controlstring]}gotobed</b> Bot sleeps in less then 1 second :).<br />"
        h += "<b>#{@bot[:controlstring]}wakeup</b> Bot is under adrenalin again.<br />"
        h += "<b>#{@bot[:controlstring]}follow</b> Bot will follow you.<br />"
        h += "<b>#{@bot[:controlstring]}unfollow</b> Bot transforms from a dog into a lazy cat :).<br />"
        h += "<b>#{@bot[:controlstring]}stick</b> Jail Bot into channel.<br />"
        h += "<b>#{@bot[:controlstring]}unstick</b> Free Bot.<br />"
    end

    def handle_chat(msg, message)

        if message == 'ch'
            channeluserisin = msg_sender.channel_id
            if @bot[:cli].me.current_channel.channel_id.to_i == channeluserisin.to_i
                @bot[:cli].text_user(msg.actor, "Hey superbrain, I am already in your channel :)")
            else
                @bot[:cli].text_channel(@bot[:cli].me.current_channel, "Hey, \"#{@bot[:cli].users[msg.actor].name}\" asked me to make some music, going now. Bye :)")
                @bot[:cli].join_channel(channeluserisin)
            end
        end

        if message == 'debug'
            @bot[:cli].text_user(msg.actor, "<span style='color:red;font-size:30px;'>Stay out of here :)</span>")
        end

        if message == 'gotobed'
            @bot[:cli].join_channel(@init[:mumbleserver_targetchannel])
            @bot[:mpd].pause = true
            @bot[:cli].me.deafen true
            begin
                Thread.kill(@following)
                @alreadyfollowing = false
            rescue
            end
        end

        if message == 'wakeup'
            @bot[:mpd].pause = false
            @bot[:cli].me.deafen false
            @bot[:cli].me.mute false
        end

        if message == 'follow'
                if @alreadyfollowing == true
                    @bot[:cli].text_user(msg.actor, "I am already following someone! But from now on I will follow you, master.")
                    @alreadyfollowing = false
                    begin
                        Thread.kill(@following)
                        @alreadyfollowing = false
                    rescue TypeError
                        if @init[:debug]
                            puts "#{$!}"
                        end
                    end
                else
                @bot[:cli].text_user(msg.actor, "I am following your steps, master.")
                end
                @follow = true
                @alreadyfollowing = true
                currentuser = msg.actor
                @following = Thread.new {
                    begin
                        while @follow == true do
                            @bot[:cli].join_channel(@bot[:cli].users[currentuser].channel_id) if (@bot[:cli].me.current_channel != @bot[:cli].users[currentuser].channel_id)
                            sleep 0.5
                        end
                    rescue
                        if @init[:debug]
                            puts "#{$!}"
                        end
                        @alreadyfollowing = false
                        Thread.kill(@following)
                    end
                }
        end

        if message == 'unfollow'
            if @follow == false
                @bot[:cli].text_user(msg.actor, "I am not following anyone.")
            else
                @bot[:cli].text_user(msg.actor, "I will stop following.")
                @follow = false
                @alreadyfollowing = false
                begin
                    Thread.kill(@following)
                    @alreadyfollowing = false
                rescue TypeError
                    if @init[:debug]
                        puts "#{$!}"
                    end
                    @bot[:cli].text_user(msg.actor, "#{@controlstring}follow hasn't been executed yet.")
                end
            end
        end

        if message == 'stick'
            if @alreadysticky == true
                @bot[:cli].text_user(msg.actor, "I'm already sticked! Resetting...")
                @alreadysticky = false
                begin
                    Thread.kill(@sticked)
                    @alreadysticky = false
                rescue TypeError
                    if @init[:debug]
                        puts "#{$!}"
                    end
                end
            else
                @bot[:cli].text_user(msg.actor, "I am now sticked to this channel.")
            end
            @sticky = true
            @alreadysticky = true
            channeluserisin = @bot[:cli].users[msg.actor].channel_id
            @sticked = Thread.new {
                while @sticky == true do
                    if @bot[:cli].me.current_channel == channeluserisin
                        sleep(1)
                    else
                        begin
                            @bot[:cli].join_channel(channeluserisin)
                            sleep(1)
                        rescue
                            @alreadysticky = false
                            @bot[:cli].join_channel(@init[:mumbleserver_targetchannel])
                            Thread.kill(@sticked)
                            if @init[:debug]
                                puts "#{$!}"
                            end
                        end
                    end
                end
            }
        end

        if message == 'unstick'
            if @sticky == false
                @bot[:cli].text_user(msg.actor, "I am currently not sticked to a channel.")
            else
                @bot[:cli].text_user(msg.actor, "I am not sticked anymore")
                @sticky = false
                @alreadysticky = false
                begin
                    Thread.kill(@sticked)
                rescue TypeError
                    if @init[:debug]
                        puts "#{$!}"
                    end
                end
            end
        end
    end
end