namespace :after_party do
  desc 'Deployment task: create_oxford_amr_config'
  task create_oxford_amr_config: :environment do
    puts "Running deploy task 'create_oxford_amr_config'"

   reading_fields =  '00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00'
    AmrDataFeedConfig.where(
      description: 'Stark (Oxfordshire etc)',
      s3_folder: 'stark',
      s3_archive_folder: 'archive-stark',
      local_bucket_path: 'tmp/amr_files_bucket/stark',
      access_type: 'Email',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'Meter Number',
      reading_date_field: 'Reading Date',
      reading_fields: reading_fields.split(','),
      header_example: "Meter Number,Stark ID,Reading Date,#{reading_fields}"
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190503121932'
  end
end
