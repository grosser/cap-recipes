require 'cap_recipes/tasks/with_scope.rb'

Capistrano::Configuration.instance(true).load do
  set :local_ping_path, 'http://localhost'

  namespace :rails do
    # ===============================================================
    # UTILITY TASKS
    # ===============================================================
    desc "Symlinks the shared/config/database yaml to release/config/"
    task :symlink_db_config, :roles => :web do
      puts "Copying database configuration to release path"
      try_sudo "rm #{release_path}/config/database.yml -f"
      try_sudo "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    desc "Repair permissions to allow user to perform all actions"
    task :repair_permissions, :roles => :web do
      puts "Applying correct permissions to allow for proper command execution"
      try_sudo "chmod -R 744 #{current_path}/log #{current_path}/tmp"
      try_sudo "chown -R #{user}:#{user} #{current_path}"
      try_sudo "chown -R #{user}:#{user} #{current_path}/tmp"
    end

    desc "Displays the production log from the server locally"
    task :tail, :roles => :web do
      stream "tail -f #{shared_path}/log/production.log"
    end

    desc "Pings localhost to startup server"
    task :ping, :roles => :web do
      puts "Pinging the web server to start it"
      run "wget -O /dev/null #{local_ping_path} 2>/dev/null"
    end
    
    # ===============================================================
    # MAINTENANCE TASKS
    # ===============================================================
    namespace :sweep do
      desc "Clear file-based fragment and action caching"
      task :log, :roles => :web  do
        puts "Sweeping all the log files"
        run "cd #{current_path} && #{sudo} rake log:clear RAILS_ENV=production"
      end

      desc "Clear file-based fragment and action caching"
      task :cache, :roles => :web do
        puts "Sweeping the fragment and action cache stores"
        run "cd #{release_path} && #{sudo} rake tmp:cache:clear RAILS_ENV=production"
      end
    end
  end
end