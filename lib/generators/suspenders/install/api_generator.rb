module Suspenders
  module Generators
    module Install
      class ApiGenerator < Rails::Generators::Base
        include Suspenders::Generators::DatabaseUnsupported

        source_root File.expand_path("../../../templates/install/api", __FILE__)
        desc <<~MARKDOWN
          Invokes all necessary generators for new Rails API applications generated with Suspenders.

          This generator is intended to be invoked as part of an [application template][].

          ```
          rails new app_name --api \\
          --suspenders-main \\
          --skip-rubocop \\
          --skip-test \\
          -d=postgresql \\
          -m=https://raw.githubusercontent.com/laicuroot/suspenders/laicuroot-api-test/lib/install/api.rb
          ```

          [application template]: https://guides.rubyonrails.org/rails_application_templates.html
        MARKDOWN

        def invoke_generators
          generate "suspenders:advisories"
          generate "suspenders:email"
          generate "suspenders:factories"
          generate "suspenders:api:lint"
          generate "suspenders:rake"
          generate "suspenders:setup"
          generate "suspenders:tasks"
          generate "suspenders:api:testing"
          generate "suspenders:jobs"

          # Needs to run after other generators, since some touch the
          # configuration files.
          generate "suspenders:environments:test"
          generate "suspenders:environments:development"
          generate "suspenders:environments:production"

          # Needs to be run last since it depends on lint, testing, and
          # advisories
          generate "suspenders:ci"
        end

        def cleanup
          rake "suspenders:cleanup:organize_gemfile"
          rake "suspenders:cleanup:generate_readme"
          copy_file "CONTRIBUTING.md", "CONTRIBUTING.md"
        end

        def lint
          run "bundle exec rake standard:fix_unsafely"
        end
      end
    end
  end
end
