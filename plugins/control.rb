class Control < Plugin

    def init(init)
        @bot = init
        if @bot[:mpd] != nil
            @bot[:control] = self
            @historysize = 20
            @bot[:control_automute] = false if @bot[:control_automute] == nil
            if @bot[:control_historysize] != nil
                @historysize =  @bot[:control_historysize]
            else
                @historysize = 20
            end
            @history = Array.new 
            @muted = false
            @playing  = !@bot[:mpd].paused?
            @bot[:cli].mute false
       
            # Register for permission denied messages
            @bot[:cli].on_permission_denied do |msg|
                nopermission(msg)
            end
        
            # Register for user state changes
            @bot[:cli].on_user_state do |msg|
                userstate(msg)
            end
        end
        
        return @bot
    end
    
    def name
        if @bot[:mpd] == nil
            "false"
        else    
            self.class.name
        end
    end

    def help(h)
        h += "<hr><span style='color:red;'>Plugin #{self.class.name}</span><br />"
        h += "<b>#{@bot[:controlstring]}ch</b> - The bot will enter your channel if he has permission to.<br />"
        h += "<b>#{@bot[:controlstring]}debug</b> - Probe command.<br />"
        h += "<b>#{@bot[:controlstring]}gotobed</b> - Bot sleeps in less then 1 second :)<br />"
        h += "<b>#{@bot[:controlstring]}wakeup</b> - Bot is under adrenalin again.<br />"
        h += "<b>#{@bot[:controlstring]}follow</b> - Bot will start to follow you.<br />"
        h += "<b>#{@bot[:controlstring]}unfollow</b> - Bot transforms from a dog into a lazy cat :).<br />"
        h += "<b>#{@bot[:controlstring]}stick</b> - Jail bot into channel.<br />"
        h += "<b>#{@bot[:controlstring]}unstick</b> - Free the bot.<br />"
        h += "<b>#{@bot[:controlstring]}history</b> - Print last #{@historysize} commanding users with command given.<br />"
        h += "<b>#{@bot[:controlstring]}automute</b> - Toggles auto muting system."
    end

    def nopermission(msg)
        @follow = false
        @alreadyfollowing = false
        begin
            Thread.kill(@following) if @following != nil
            @alreadyfollowing = false
        rescue TypeError
            if @bot[:debug]
                puts "[control] no following thread but try to kill. #{$!}"
            end
        end
    end

    def userstate(msg)
        #msg.session = session_id of the target
        #msg.actor = session_id of user who did something on someone, if self done, both is the same.
  
        me = @bot[:cli].me
        msg_target = @bot[:cli].users[msg.session]
        if ( me.current_channel != nil ) && ( msg.channel_id != nil )         
            # get register status of user
            if msg_target.user_id.nil?
                sender_is_registered = false
            else
                sender_is_registered = true
            end

            # If user is in my channel and is unregistered then pause playing if stop_on_unregistered_users is enabled.
            if ( me.current_channel.channel_id == msg_target.channel_id ) && ( @bot[:stop_on_unregistered_users] == true) && ( sender_is_registered == false )  
                current = @bot[:mpd].current_song
                if current.file.include? "://" #If yes, it is probably some kind of a stream.
                    @bot[:mpd].stop
                else
                    if @bot[:mpd].paused? == false
                        @bot[:mpd].pause = true
                    end
                end

                @bot[:cli].text_channel(@bot[:cli].me.current_channel, "<span style='color:red;'>An unregistered user currently joined or is acting in our channel. I stopped/paused the music.</span>")
            end

            # Count users in my channel ...
            user_count = 0
            me_in = 0
            me_in = me.channel_id
            @bot[:cli].users.values.select do |user|
                user_count += 1 if ( user.channel_id == me_in ) 
            end
            # if i'm alone
            if ( user_count < 2 ) && ( @bot[:control_automute] == true )
                # if I'm playing then pause play and save that I've stopped myself
                if @bot[:mpd].paused? == false 
                    @bot[:mpd].pause = true
                    @playing = false
                end
                # mute myself and save that I've done it myself
                me.mute true 
                @muted = true
            else
                # only unmute me if I've muted myself before
                if @muted == true
                    me.mute false 
                    @muted = false
                end
                # start playing only I've stopped myself
                if @playing == false
                    @bot[:mpd].pause = false
                    @playing = true
                end
            end
        end
    
    end
    
    def handle_chat(msg, message)
    
        # Put message in Messagehistory and pop old's if size exceeds max. historysize.
        msg.username = @bot[:cli].users[msg.actor].name
        @history << msg                 
        @history.shift if @history.length > @historysize

        if message == 'ch'
            channeluserisin = @bot[:cli].users[msg.actor].channel_id
            if @bot[:cli].me.current_channel.channel_id.to_i == channeluserisin.to_i
                @bot[:cli].text_user(msg.actor, "Hey superbrain, I am already in your channel :)")
            else
                @bot[:cli].text_channel(@bot[:cli].me.current_channel, "Hey, \"#{msg.username}\" asked me to make some music, going now. Bye :)")
                @bot[:cli].join_channel(channeluserisin)
            end
        end

        if message == 'debug'
            @bot[:cli].text_user(msg.actor, "<span style='color:red;font-size:30px;'>Stay out of here :)</span>")
        end
       
        if message == 'gotobed'
            @bot[:cli].join_channel(@bot[:mumbleserver_targetchannel])
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
                        if @bot[:debug]
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
                            if (@bot[:cli].me.current_channel != @bot[:cli].users[currentuser].channel_id)
                                @bot[:cli].join_channel(@bot[:cli].users[currentuser].channel_id) 
                            end
                            sleep 0.5
                        end
                    rescue
                        if @bot[:debug]
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
                    if @bot[:debug]
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
                    if @bot[:debug]
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
                            @bot[:cli].join_channel(@bot[:mumbleserver_targetchannel])
                            Thread.kill(@sticked)
                            if @bot[:debug]
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
                    if @bot[:debug]
                        puts "#{$!}"
                    end
                end
            end
        end
        
        if message == 'history'
            history = @history.clone
            out = "<table><tr><th>Command</th><th>by User</th></tr>"
            loop do 
                break if history.empty?
                histmessage = history.shift
                out += "<tr><td>#{histmessage.message}</td><td>#{histmessage.username}</td></tr>"
            end
            out += "</table>"
            @bot[:cli].text_user(msg.actor, out)
        end
        
        if message == 'automute'
            if @bot[:control_automute] == false
                @bot[:cli].text_user(msg.actor, "Automute is now activated")
                @bot[:control_automute] = true    
            else    
                @bot[:cli].text_user(msg.actor, "Automute is now deactivated")
                @bot[:control_automute] = false
            end
        end
    end
end