# Settings specified here will take precedence over those in config/application.rb
RedmineApp::Application.configure do
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes     = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils        = true

  # Show full error reports and disable caching
  #config.action_controller.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_view.cache_template_loading            = false  #k-takai開発専用目的

  # Don't care if the mailer can't send
  # なぜか現状のrepositryはSMTPメール送信が無効になっている｡
#   config.action_mailer.raise_delivery_errors = false 
  # しかしActionMailerをつかったSMTP外部配信では､以下の様に配信許可をする必要がある､
  # と考える｡
  config.action_mailer.perform_deliveries = true 
  config.action_mailer.raise_delivery_errors = true

  config.active_support.deprecation = :log
end
