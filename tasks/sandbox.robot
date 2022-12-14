#PRECONDITION: 
#Device CH_DEV_CONF_MGMT is existing on tenant, if not
#use -v DeviceID:xxxxxxxxxxx in the command line to use your existing device

*** Settings ***
Library    SSHLibrary
Library    DateTime
Library    MQTTLibrary
Library    CryptoLibrary    variable_decryption=True
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource   
Suite Setup    Prepare testing environment

*** Variables ***

${PARENT_IP}             192.168.1.110
${CHILD_IP}              192.168.1.200
${HTTP_PORT}             8000
${USERNAME}              pi
${PASSWORD}              crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=
${url_tedge}             env997770.eu-latest.cumulocity.com    #qaenvironment.eu-latest.cumulocity.com
${user}                  systest_preparation
${pass}                  crypt:34mpoxueRYy/gDerrLeBThQ2wp9F+2cw50XaNyjiGUpK488+1fgEfE6drOEcR+qZQ6dcjIWETukbqLU= 
${config}                "files = [\n\t { path = '/home/pi/config1', type = 'config1' },\n ]\n"
${PARENT_NAME}           CH_DEV_CONF_MGMT
${CHILD}                
${topic_snap}            /commands/res/config_snapshot"
${topic_upd}             /commands/res/config_update"
${payl_notify}           '{"status": null,  "path": "", "type":"c8y-configuration-plugin", "reason": null}'
${payl_exec}             '{"status": "executing", "path": "/home/pi/config1", "type": "config1", "reason": null}'
${payl_succ}             '{"status": "successful", "path": "/home/pi/config1", "type": "config1", "reason": null}'

*** Test Cases ***

*** Keywords ***
Prepare testing environment
    
