require 'chefspec'

module BswTech
  module ChefSpec
    module LwrpTestHelper
      def generated_cookbook_path
        File.join File.dirname(__FILE__), 'gen_cookbooks'
      end

      def cookbook_path
        File.join generated_cookbook_path, generated_cookbook_name
      end

      def generated_cookbook_name
        'lwrp_gen'
      end

      def environment_name
        'thestagingenv'
      end

      # Unlike other cookbooks we've written, we create the temp cookbook in our spec BEFORE calling this method
      def temp_lwrp_recipe(contents, runner_options={})
        RSpec.configure do |config|
          config.cookbook_path = [*config.cookbook_path] << generated_cookbook_path
        end
        lwrps_full = [*lwrps_under_test].map do |lwrp|
          "#{cookbook_under_test}_#{lwrp}"
        end
        @chef_run = ::ChefSpec::Runner.new(runner_options.merge(step_into: lwrps_full)) do |node|
          env = Chef::Environment.new
          env.name environment_name
          allow(node).to receive(:chef_environment).and_return(env.name)
          allow(node).to receive(:environment).and_return(env.name)
          allow(Chef::Environment).to receive(:load).and_return(env)
          node.automatic['platform_family'] = get_platform_family
        end
        @chef_run.converge("#{generated_cookbook_name}::default")
      end

      def create_temp_cookbook(contents)
        the_path = cookbook_path
        recipes = File.join the_path, 'recipes'
        FileUtils.mkdir_p recipes
        File.open File.join(recipes, 'default.rb'), 'w' do |f|
          f << contents
        end
        File.open File.join(the_path, 'metadata.rb'), 'w' do |f|
          f << "name '#{generated_cookbook_name}'\n"
          f << "version '0.0.1'\n"
          f << "depends '#{cookbook_under_test}'\n"
        end
      end

      def cleanup
        begin
          FileUtils.unstub(:rm_rf)
        rescue RSpec::Mocks::MockExpectationError
          # might not be stubbed, but that's OK
        end
        FileUtils.rm_rf generated_cookbook_path
      end
    end
  end
end