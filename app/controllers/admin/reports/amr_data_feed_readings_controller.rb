module Admin
  module Reports
    class AmrDataFeedReadingsController < AdminController
      include CsvDownloader

      CSV_HEADER = "School URN,Name,Mpan Mprn,Reading Date,Reading Date Format,Record Last Updated,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00".freeze

      def index
        school_id = params[:school_id]

        respond_to do |format|
          format.csv do
            if school_id
              school = School.find(school_id)
              send_data readings_to_csv(AmrDataFeedReading.download_query_for_school(school_id), CSV_HEADER), filename: "#{school.name.parameterize}-amr-raw-readings.csv"
            else
              send_data readings_to_csv(AmrDataFeedReading.download_all_data, CSV_HEADER), filename: "all-amr-raw-readings.csv"
            end
          end
        end
      end
    end
  end
end
