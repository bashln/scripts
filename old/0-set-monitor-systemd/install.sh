sudo cp /run/media/lm/dev/gitlab/scripts/0-set-monitor-systemd/set-monitor.sh /usr/local/bin/
sudo cp /run/media/lm/dev/gitlab/scripts/0-set-monitor-systemd/set-monitor.service /etc/systemd/system/
sudo systemctl enable set-monitor.service
