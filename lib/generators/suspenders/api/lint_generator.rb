module Suspenders
  module Api
    class LintGenerator < Rails::Generators::Base
      include Suspenders::Generators::Helpers

      source_root File.expand_path("templates", __dir__)
      desc <<~MARKDOWN
        - Uses [standard][] for Ruby linting.

        **Available Commands**

        - Run `bin/rails standard` to lint Ruby code.
        - Run `bundle exec standardrb --fix` to fix standard violations.

        [standard]: https://github.com/standardrb/standard
      MARKDOWN

      def install_gems
        gem_group :development, :test do
          gem "standard"
        end
        Bundler.with_unbundled_env { run "bundle install" }
      end

      def configure_erb_lint
        template "rubocop.yml.tt", ".rubocop.yml"
      end
    end
  end
end
