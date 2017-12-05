execute 'systemd-daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end
