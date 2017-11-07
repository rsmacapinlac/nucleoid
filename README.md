# Nucleoid

Nucleoid is a web application bundled with some scripts to build a low cost pay
as you go cellphone in the cloud.

# Contributing

Nucleoid is written in Ruby, uses the Sinatra framework, ActiveRecord to store
persistent data / settings and RSpec for testing.

## Setup

1. Install ngrok (somewhere in your PATH)
2. Setup a twilio account and get a phone number. You need: account_sid,
   auth_token and your phone number's sid
3. Create a .env file from the env.example file and fill in the values from step
   2
4. Start the development server ```bundle exec rerun rackup```

Once the development server is started this will update the twilio phone number settings with ngrok's url and the phone number should work.

# How to configure

Since the app doesn't have a front end _yet_. Configuration of the application
is made by sending posts to URI's.

The simplest way to do this is using [Postman](https://www.getpostman.com/)

```
post APP_HOST/config/:name
value=something
```
Upon installing you probably want to configure a forwarding number.

Send a post request to APP_HOST/config/FORWARDING_NUMBER value=+15551234567

## Seeing the current configuration

```APP_HOST/configs.json```

## Do not disturb

Send a post request to ```APP_HOST/config/dnb``` with ```value=[true|false]```

# Todo's

[ ] Continous Integration / Testing
[ ] Rake task for sending mail
[ ] Some sort of a front-end
[ ] Expiry of numbers that are not being used
[ ] 1-click deployment to Heroku

### Assumptions

* You're using rbenv
* You have an ngrok config file at '~/.ngrok2/ngrok.yml'
* You are running rack on port 9292
