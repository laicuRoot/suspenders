def apply_template!
  if options[:database] == "postgresql" && options[:skip_test] && options[:skip_rubocop]
    after_bundle do
      gem_group :development, :test do
        if ARGV.include?("--suspenders-main")
          gem "suspenders", github: "laicuroot/suspenders", branch: "laicuroot-api-test"
        else
          gem "suspenders"
        end
      end

      run "bundle install"

      generate "suspenders:install:api"
      rails_command "db:prepare"
      rails_command "db:migrate"

      say "\nCongratulations! You just pulled our suspenders."
    end
  else
    message = <<~ERROR


      === Please use the correct options ===

      rails new app_name --api \\
      --suspenders-main \\
      --skip-rubocop \\
      --skip-test \\
      -d=postgresql \\
      -m=https://raw.githubusercontent.com/laicuroot/suspenders/laicuroot-api-test/lib/install/api.rb

    ERROR

    fail Rails::Generators::Error, message
  end
end

apply_template!
