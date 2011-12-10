module Smooch
  class Base
     attr_accessor :controller
     attr_accessor :view
     def initialize(controller=nil)
       self.controller = controller
       self.view = view
       init_flash
     end

     FLASH_KEY = :smooch
     def record(property, hash={})
       @records[property.to_s] = hash
       write_flash
     end
     def init_flash
       hash = flash[FLASH_KEY] || {}
       @records = hash[:r] || {}
       @sets = hash[:s] || {}
       @choices = hash[:c] || {}
     end
     def write_flash
       hash = nil
       unless @records.empty?
         hash ||= {}
         hash[:r] = @records
       end
       unless @sets.empty?
          hash ||= {}
          hash[:s] = @sets
        end
        unless @choices.empty?
           hash ||= {}
           hash[:c] = @choices
         end
       flash[FLASH_KEY] = hash
     end
     def clear_flash
       flash[FLASH_KEY] = nil
     end

     def set(property, value)
       @sets[property.to_s] = value
       write_flash
     end

     def ab(name, choices=nil)
       val = nil

       # get from parameter passed in
       val = get_ab_param(name) unless val
       val = nil if val and choices and not choices.include?(val)

       # get from database
       val = get_ab_database(name) unless val
       val = nil if val and choices and not choices.include?(val)

       # get from local storage
       val = get_ab_cached(name) unless val
       val = nil if val and choices and not choices.include?(val)

       # get from cookie
       val = get_ab_cookie(name) unless val
       val = nil if val and choices and not choices.include?(val)

       if choices and Smooch.ab_static?
         val = choices.first unless val
       end
       
       # pick a random one
       val = get_ab_random_choice(choices) unless val

       set_ab_value(name, val)
     end

     def key(name)
       # TODO: by identity?
       md5 = Digest::MD5.hexdigest("#{name}")[-10,10]
       "ab_#{md5}"
     end
     def get_ab_param(name)
       return params["_ab"]
     end
     def get_ab_random_choice(choices)
       return nil unless choices
       choices[rand(choices.size)]
     end
     def get_ab_cached(name)
       @choices[name]
     end
     def get_ab_cache_key
       [@records, @sets, @choices].to_param
     end
     def get_ab_cookie(name)
       get_cookie(key(name))
     end
     def set_ab_value(name, val)
       set_ab_database(name, val)
       set_cookie(key(name), val)
       @choices[name] = val
       write_flash
       val
     end

     # TODO db support
     def get_ab_database(name)
       # get_identity / key(name)
       nil 
     end
     def set_ab_database(name, val)
       # get_identity / key(name)
     end

     # ------ from controller
     def get_smooch_identity
       controller.smooch_identity
     end
     def get_kiss_identity
       controller.kiss_identity
     end
     def set_cookie(key, value)
       unless cookies[key] == value
         cookies[key] = { :value => value, :expires => 2.months.from_now }
       end
     end
     def get_cookie(key)
       cookies[key]
     end

     # ------ for view
     def js(text)
       text = view.send('h', text)
       text = view.send('escape_javascript', text)
       text
     end
     def push_record(hash)
       out = ""
       hash.each do |key, value|
         out += "_kmq.push(['record', '#{js(key)}'"
         unless value.empty?
           out += ", #{value.to_json.gsub(/<\/?script>/i, "")}"
         end
         out += "]);\n"
       end
       out = out.html_safe if out.respond_to?(:html_safe) 
       out
     end
     def push_set(hash)
       out = ""
       hash.each do |key, value|
          out += "_kmq.push(['set', {'#{js(key)}' : '#{js(value)}'}]);\n"
       end
       out = out.html_safe if out.respond_to?(:html_safe) 
       out
     end
     
     def api_key
       Smooch::API_KEY.blank? ? nil : Smooch::API_KEY
     end
     
     def script(send=true)
       clear_flash

       out = <<-JAVASCRIPT
         <script type="text/javascript">
           var _kmq = _kmq || [];
           function _kms(u) {
             setTimeout(function() {
               var s = document.createElement('script');
               var f = document.getElementsByTagName('script')[0];
               s.type = 'text/javascript';
               s.async = true;
               s.src = u;
               f.parentNode.insertBefore(s, f);
             }, 1);
           }
       JAVASCRIPT
       if send and api_key.present?
         out += "_kms('//i.kissmetrics.com/i.js');\n"
         out += "_kms('//doug1izaerwt3.cloudfront.net/#{api_key}.1.js');\n"
       end

       identity = get_kiss_identity
       out += "_kmq.push(['identify', '#{js(identity)}']);\n" if identity   

       out += push_record(@records)
       out += push_set(@sets)
       out += push_set(@choices)

       out += "</script>\n"
       out = out.html_safe if out.respond_to?(:html_safe)  
       out
     end


     # ------ for tests
     def has_record?(property)
       !@records[property.to_s].nil?
     end
     def has_set?(property)
       !@sets[property.to_s].nil?
     end
     
     def cookies
       return {} unless controller
       controller.send(:cookies)
     end
     
     def flash
       return {} unless controller
       controller.send(:flash)
     end
     
     def params
       return {} unless controller
       controller.send(:params)
     end
   end
 end