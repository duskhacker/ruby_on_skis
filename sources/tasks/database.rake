namespace :db do
  desc "Reset database"
  task :reset do
    reset_environment = ENV[Environment.app_env_const] || 'development'
    puts "Resetting #{reset_environment} environment."
    Environment.require_libs(false)
    File.unlink Environment.db_file(reset_environment) rescue {}
    Environment.setup(reset_environment, false)
  end

  desc "Migrate database"
  task :migrate do
    migrate_environment = ENV[Environment.app_env_const] || 'development'
    puts "Migrating #{migrate_environment} environment."
    Environment.require_libs(false)
    Environment.establish_connection
    Environment.migrate
  end
end

