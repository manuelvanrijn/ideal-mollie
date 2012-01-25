module IdealMollie
  #
  # Simpel extend on the Rails::Engine to add support for a new config section within the environment configs
  #
  # @example
  #   # /config/environments/development.rb
  #   config.ideal_mollie.partner_id = 123456
  #   config.ideal_mollie.report_url = "http://example.org/report"
  #   config.ideal_mollie.return_url = "http://example.org/return"
  #   config.ideal_mollie.test_mode = false
  #
  class Engine < Rails::Engine
    config.ideal_mollie = IdealMollie::Config
  end
end
