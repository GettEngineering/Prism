module Arguments
    def parse(args)
        parsed = {}
      
        args.each do |arg|
          match = /^-?-(?<key>.*?)(=(?<value>.*)|)$/.match(arg)
          if match
            parsed[match[:key].to_sym] = match[:value]
          else
            parsed[:text] = "#{parsed[:text]} #{arg}".strip
          end
        end
      
        parsed
    end
end