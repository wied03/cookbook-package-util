module BswTech
  class DpkgParser
    def parse(command_output)
      results = []
      command_output.scan(/(\S+) (\w+).*/) do |match|
        status = match[1]
        unless ['ii', 'rc'].include? status
          fail "Unknown status '#{status}' in dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev}\\n' output"
        end
        results << match[0] if status == 'ii'
      end
      results
    end
  end
end