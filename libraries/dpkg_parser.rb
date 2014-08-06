module BswTech
  class DpkgParser
    def parse(command_output)
      results = []
      command_output.scan(/(\w+)\s+(\S+).*/) do |match|
        status = match[0]
        unless ['ii', 'rc'].include? status
          fail "Unknown status #{status} in dpkg -l output"
        end
        results << match[1] if status == 'ii'
      end
      results
    end
  end
end