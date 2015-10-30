require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'date'
require 'fileutils'

APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "calendar-ruby-quickstart.json")
SCOPE = 'https://www.googleapis.com/auth/calendar'
CALENDAR_ID = "l9qli6ni2hqjm5dj7akd6kla0g@group.calendar.google.com"


class EventManager
  def initialize()
    @client = Google::APIClient.new(:application_name => APPLICATION_NAME)
    @client.authorization = authorize
    @calendar_api = @client.discovered_api('calendar', 'v3')
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization request via InstalledAppFlow.
  # If authorization is required, the user's default browser will be launched
  # to approve the request.
  #
  # @return [Signet::OAuth2::Client] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
    storage = Google::APIClient::Storage.new(file_store)
    auth = storage.authorize

    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
      flow = Google::APIClient::InstalledAppFlow.new({
        :client_id => app_info.client_id,
        :client_secret => app_info.client_secret,
        :scope => SCOPE})
      auth = flow.authorize(storage)
      puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
    end
    auth
  end

  # Fetch the next 10 events for the user
  def list_events(number = 10)
    results = @client.execute!(
      :api_method => @calendar_api.events.list,
      :parameters => {
        :calendarId => CALENDAR_ID,
        :maxResults => number,
        :singleEvents => true,
        :orderBy => 'startTime',
        :timeMin => Time.now.iso8601 })
  end


  def fetch_next_events(number = 10)
    results = list_events(number)
    puts "Upcoming events:"
    puts "No upcoming events found" if results.data.items.empty?
    results.data.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
    end
  end

  def create_event(task, description="", email, start_date, end_date)
    {
      'summary' => task,
      'location' => 'Co&Art',
      'description' => description,
      'start' => {
        'date' => start_date.to_s,
      },
      'end' => {
        'date' => end_date.to_s,
      },
      # 'recurrence' => [
      #   'RRULE:FREQ=DAILY;COUNT=7'
      # ],
      'attendees' => [
        {'email' => email}
      ],
      'reminders' => {
        'useDefault' => false,
        'overrides' => [
          {'method' => 'email', 'minutes' => 24 * 60},
          # {'method' => 'popup', 'minutes' => 10},
        ],
      }
    }
  end

  def add_event(event)
    results = @client.execute!(
      :api_method => @calendar_api.events.insert,
      :parameters => {
        :calendarId => CALENDAR_ID},
      :body_object => event)
    event = results.data
    puts "Event created: #{event.htmlLink}"
  end

  def delete_all_events()
    while !list_events(10).data.items.empty?
      results = list_events(10)
      puts "No upcoming events found" if results.data.items.empty?
      results.data.items.each do |event|
        puts "Event deleted: #{event.summary}"
        delete_event(event.id)
      end
    end
    # @client.execute!(
    #   :api_method => @calendar_api.calendars.clear,
    #   :parameters => {
    #     :calendarId => CALENDAR_ID},
    # )
    puts "All events cleared"
  end
  def delete_event(event_id)
    @client.execute!(
      :api_method => @calendar_api.events.delete,
      :parameters => {
        :calendarId => CALENDAR_ID,
        eventId: event_id}
    )
  end
end
