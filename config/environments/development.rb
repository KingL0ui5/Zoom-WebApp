Rails.application.configure do
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  
  config.web_console.whitelisted_ips = '149.86.60.126'
  config.web_console.whitelisted_ips = '171.33.196.184'

 # config.action_mailer.raise_delivery_errors = false #for sending emails 
  host = 'https://c68dc96b16ad48c6ba78dbbb297e85d4.vfs.cloud9.us-east-1.amazonaws.com/'
  config.action_mailer.default_url_options = { host: host, protocol: 'https' }
  config.action_mailer.perform_deliveries = true
  config.assets.check_precompiled_asset = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.gmail.com',
    :port           => 587,
    :user_name      => "notifications.vanishingfunds@gmail.com",
    :password       => "ayatgrlgkeivrgcn",
    :authentication => 'plain',
    :enable_starttls_auto => true,
    :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  }
  config.action_mailer.default_options = { from: 'notifications.vanishingfunds@gmail.com' }

end
