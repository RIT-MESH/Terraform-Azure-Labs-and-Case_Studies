#cloud-config
hostname: ${hostname}
package_update: true
packages:
%{ for p in packages ~}
  - ${p}
%{ endfor ~}
runcmd:
  - systemctl enable --now nginx
  - echo "host: $(hostname) built by templatefile()" > /var/www/html/index.html
