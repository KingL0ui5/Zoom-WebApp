# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_app_session'
#Rails.application.config.session_store :active_record_store, :key => '_my_app_session' #moves session storage to this table
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
Rails.application.config.action_dispatch.cookies_same_site_protection = :none
Rails.application.config.action_dispatch.cookies_limit = 8192 