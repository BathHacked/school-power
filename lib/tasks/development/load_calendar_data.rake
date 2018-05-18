namespace :development do
  desc 'Load sample usage data for 3 schools'

  desc 'Load banes-default-calendar'
  task load_banes_default_calendar: [:environment] do
    england = Area.where(title: 'England and Wales').first_or_create
    area = Area.where(title: 'Bristol and North East Somerset (BANES)', parent_area: england).first_or_create
    Loader::Calendars.load!("etc/banes-default-calendar.csv", area)
  end

  desc 'Load sheffield-calendar'
  task load_sheffield_default_calendar: [:environment] do
    england = Area.where(title: 'England and Wales').first_or_create
    area = Area.where(title: 'Sheffield', parent_area: england).first_or_create
    Loader::Calendars.load!("etc/sheffield-default-calendar.csv", area)
  end
end
