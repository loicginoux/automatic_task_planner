

Let you automatically plan tasks between differnet users, this tasks are created in a google calendar and everyone is reminded when they needs to do a task.


HOW TO:

1 - Add list of participant emails in calendar_task_planner.rb file

2 - Modify type of tasks

3 - create a file client_secret.json from the template file. Open it and replace YOUR_CLIENT_ID and YOUR_CLIENT_SECRET with your credentials. You will find them by creating an app via https://console.developers.google.com/flows/enableapi?apiid=calendar

4 - gem install "google-api-client"

5 - ruby calendar_task_planner.rb

6 - if you need to delete all the events: ruby clean_calendar.rb


More info on google calendar api here: https://developers.google.com/google-apps/calendar/overview
