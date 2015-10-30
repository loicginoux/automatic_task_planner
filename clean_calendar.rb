require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'date'
require 'fileutils'
require_relative 'event_manager'

em = EventManager.new()
em.delete_all_events()
em.fetch_next_events(10)
