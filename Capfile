ssh_options[:keys] = %w(~/.ssh/id_rsa ~/.ssh/id_dsa)
ssh_options[:forward_agent] = true
 
set :user, "joho"
set :use_sudo, false
 
role :appserver, "whoisjohnbarton.com"
 
desc "Redeploy the app"
task :deploy do
  run "cd /opt/apps/whoisjohnbarton/cards; git pull; rake restart_app"
end