Capistrano::Configuration.instance(true).load do  
  after "deploy:update_code", "juggernaut:copy_config" # copy juggernaut.yml on update code
  after "deploy:restart"    , "juggernaut:restart"     # restart juggernaut on app restart
end