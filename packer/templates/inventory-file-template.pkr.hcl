[default]
{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }}

[default:vars]
ansible_ssh_common_args=-o StrictHostKeyChecking=no -o IdentitiesOnly=yes -J
%{~ if ansible-bastion.host != "" ~}
%{ if ansible-bastion.user != "" ~}
 ${ansible-bastion.user}@
%{~ else ~}
${" "}
%{~ endif ~}
${ansible-bastion.host}
%{~ endif ~}
%{ for file in identity-files ~}
 -i ${file}
%{~ endfor }
