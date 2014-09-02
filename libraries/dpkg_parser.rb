module BswTech
  class DpkgParser
    def parse(command_output)
      results = []
      # There is an optional architecture (e.g. amd64) appended to the package name but we don't want that
      command_output.scan(/(\S+?)(:\S+)?\s+(\w+)\s+(\S+)/) do |match|
        status = match[2]
        unless ['ii', 'rc'].include? status
          fail "Unknown status '#{status}' in dpkg-query output"
        end
        version = match[3]
        results << {:name => match[0], :version => version} if status == 'ii'
      end
      results
    end
  end
end