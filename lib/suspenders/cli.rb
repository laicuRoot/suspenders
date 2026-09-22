# frozen_string_literal: true

module Suspenders
  # Command-line interface for generating Rails applications with Suspenders.
  # This class handles the creation of new Rails apps using a custom template
  # and predefined configuration options.
  class CLI
    # Platforms Suspenders can target. The first entry is the default.
    PAAS_OPTIONS = ["heroku", "railway"].freeze
    DEFAULT_PAAS = PAAS_OPTIONS.first

    # Options passed to the Rails generator for all new applications,
    # regardless of target platform.
    BASE_OPTIONS = [
      "-d=postgresql",
      "--skip-test"
    ].freeze

    # Options passed to the Rails generator per target platform.
    #
    # Heroku skips the Solid ecosystem in favor of Sidekiq and Redis.
    # Railway keeps Solid Queue, Cache, and Cable, and skips the Docker, Kamal,
    # and Thruster setup since Railway builds with Railpack.
    PAAS_RAILS_OPTIONS = {
      "heroku" => ["--skip-solid"],
      "railway" => ["--skip-kamal", "--skip-docker", "--skip-thruster"]
    }.freeze

    # Initializes a new CLI instance.
    #
    # @param app_name [String] the name of the Rails application to create
    # @param paas [String] the target platform, one of PAAS_OPTIONS
    def initialize(app_name, paas: DEFAULT_PAAS)
      @app_name = app_name
      @paas = paas
    end

    # Creates and runs a new CLI instance for the given application name.
    #
    # @param app_name [String] the name of the Rails application to create
    # @param paas [String] the target platform, one of PAAS_OPTIONS
    # @return [Boolean] true if the Rails app was created successfully
    # @raise [Error] if Rails is not installed, the platform is unknown, or
    #   app creation fails
    def self.run(app_name, paas: DEFAULT_PAAS)
      new(app_name, paas: paas).run
    end

    # Executes the CLI workflow to generate a new Rails application.
    # Verifies Rails installation and generates the app with Suspenders template.
    #
    # @return [Boolean] true if the Rails app was created successfully
    # @raise [Error] if Rails is not installed, the platform is unknown, or
    #   app creation fails
    def run
      verify_paas!
      verify_rails_exists!
      generate_new_rails_app
    end

    private

    attr_reader :app_name, :paas

    def verify_paas!
      unless PAAS_OPTIONS.include?(paas)
        raise Error, "Unknown PaaS #{paas.inspect}. Expected one of: #{PAAS_OPTIONS.join(", ")}"
      end
    end

    def verify_rails_exists!
      unless system("which", "rails", out: File::NULL, err: File::NULL)
        raise Error, "Rails not found. Install with: gem install rails"
      end
    end

    def generate_new_rails_app
      template_path = File.expand_path("../templates/web.rb", __dir__)
      options = BASE_OPTIONS + PAAS_RAILS_OPTIONS.fetch(paas) + ["-m=#{template_path}"]

      # The template runs in a child process, so the platform is handed over
      # through the environment.
      if system({"SUSPENDERS_PAAS" => paas}, "rails", "new", app_name, *options)
        true
      else
        raise Error, "Failed to create Rails app"
      end
    end
  end
end
