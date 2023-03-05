#!/bin/bash

# 1.Updates all packages and installs security updates
sudo apt-get update
sudo apt-get upgrade -y

# 2.Disable password authentication for SSH and configure SSH to only allow public key authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 3.Configure the firewall to only allow traffic on ports 22 and 80
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable

# 4.Ensure that the server is configured to use a non-root user for the application
sudo adduser --disabled-password --gecos "" appuser
sudo usermod -aG sudo appuser

# 5.Disable any unnecessary services (ex: apache2)
sudo systemctl disable apache2

# 6.Remove any unused packages
sudo apt-get autoremove -y

# 7.Ensure that the server is configured to use a secure DNS resolver
sudo apt-get install -y systemd-resolved
sudo systemctl enable systemd-resolved.service
sudo systemctl start systemd-resolved.service
sudo sed -i 's/#DNS=/DNS=1.1.1.1/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved.service

# 8.Configure the web server to use HTTPS with a valid SSL certificate
sudo apt-get install -y certbot
sudo certbot certonly --standalone --agree-tos --no-eff-email --email andreeko28@gmail.com -d test-levart.com
sudo cp /etc/letsencrypt/live/test-levart.com/fullchain.pem /etc/nginx/fullchain.pem
sudo cp /etc/letsencrypt/live/test-levart.com/privkey.pem /etc/nginx/privkey.pem
sudo sed -i 's/listen 80/listen 443 ssl/' /etc/nginx/sites-available/default
sudo sed -i 's/#ssl_certificate/ssl_certificate/' /etc/nginx/sites-available/default
sudo sed -i 's/#ssl_certificate_key/ssl_certificate_key/' /etc/nginx/sites-available/default
sudo systemctl restart nginx

# 9.Configure the server to use a strong password policy and enable password complexity requirements.
# Install the necessary packages
sudo apt update
sudo apt install -y libpam-pwquality

# Configure the password policy
sudo sed -i 's/# minlen = 8/minlen = 12/g' /etc/security/pwquality.conf
sudo sed -i 's/# dcredit = 0/dcredit = -1/g' /etc/security/pwquality.conf
sudo sed -i 's/# ucredit = 0/ucredit = -1/g' /etc/security/pwquality.conf
sudo sed -i 's/# lcredit = 0/lcredit = -1/g' /etc/security/pwquality.conf
sudo sed -i 's/# ocredit = 0/ocredit = -1/g' /etc/security/pwquality.conf
sudo sed -i 's/# minclass = 0/minclass = 4/g' /etc/security/pwquality.conf

# Enable password complexity requirements
sudo sed -i 's/password    requisite           pam_cracklib.so retry=3 minlen=8/password    requisite           pam_pwquality.so retry=3/' /etc/pam.d/common-password
sudo sed -i 's/password    [success=1 default=ignore]      pam_unix.so obscure sha512/password    [success=1 default=ignore]      pam_unix.so obscure sha512 minlen=12 remember=5/' /etc/pam.d/common-password
