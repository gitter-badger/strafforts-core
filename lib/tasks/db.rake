require "yaml"

namespace :db do
  desc "Restore DB dump file to local"
  # Usage: docker-compose run web bundle exec rails db:restore
  task :restore, [:file] => :environment do |_t, args|
    dump_file = args[:file] || "latest.dump"

    # Create DB in case it doesn't exist.
    system "bundle exec rails db:create"

    # Remove the existing dump file.
    FileUtils.rm(dump_file, force: true)

    # Download latest.dump from Heroku server.
    system "heroku pg:backups:download"

    # Read development DB configs.
    database_yml = YAML.load_file("#{Rails.root}/config/database.yml")
    host = database_yml["development"]["host"]
    database = database_yml["development"]["database"]
    username = database_yml["development"]["username"]

    command = "pg_restore --verbose --clean --no-acl --no-owner -h #{host} -U #{username} -W -d #{database} #{dump_file}"
    puts "Executing: #{command}"
    system command

    # Run db:migrate and db:seed.
    system "bundle exec rails db:migrate && bundle exec rails db:seed"
  end

  desc "Convert development DB to Rails test fixtures"
  # Usage: docker-compose run web bundle exec bin/rails db:to_fixtures
  task to_fixtures: :environment do
    TABLES_TO_SKIP = %w[ar_internal_metadata delayed_jobs schema_info schema_migrations].freeze

    begin
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection.tables.each do |table_name|
        next if TABLES_TO_SKIP.include?(table_name)

        conter = "000"
        file_path = "#{Rails.root}/spec/fixtures/#{table_name}.yml"
        File.open(file_path, "w") do |file|
          rows = ActiveRecord::Base.connection.select_all("SELECT * FROM #{table_name}")
          data = rows.each_with_object({}) do |record, hash|
            suffix = record["id"].blank? ? conter.succ! : record["id"]
            hash["#{table_name.singularize}_#{suffix}"] = record
          end
          puts "Writing table '#{table_name}' to '#{file_path}'"
          file.write(data.to_yaml)
        end
      end
    ensure
      ActiveRecord::Base.connection&.close
    end
  end

  desc "Purge all existing FAQs."
  # Usage: docker-compose run web bundle exec rails db:truncate_faqs
  task truncate_faqs: :environment do
    truncate_table("faqs")
  end

  def truncate_table(table_name)
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY")
    ActiveRecord::Base.connection&.close
  end
end
