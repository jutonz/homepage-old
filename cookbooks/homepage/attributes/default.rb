normal["apt"]["unattended_upgrades"]["enable"] = true
normal["apt"]["unattended_upgrades"]["allowed_origins"] = ["Ubuntu trusty-security"]
normal["brightbox-ruby"]["version"] = "2.3"
normal["environment_variables"] = nil

default['workflows']['user'] = "deploy"
default['workflows']['group'] = "www-data"
