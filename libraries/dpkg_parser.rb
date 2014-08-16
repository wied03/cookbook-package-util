module BswTech
  class DpkgParser
    def parse(command_output)
      results = []
      command_output.scan(/(\S+)\s+(\w+)\s+(\S+)/) do |match|
        status = match[1]
        unless ['ii', 'rc'].include? status
          fail "Unknown status '#{status}' in dpkg-query output"
        end
        version = match[2]
        results << {:name => match[0], :version => version} if status == 'ii'
      end
      results
    end
  end
end