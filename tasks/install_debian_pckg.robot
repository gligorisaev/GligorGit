*** Settings ***
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    CryptoLibrary    variable_decryption=True
Suite Setup            DUT Connection
Suite Teardown         Close All Connections

*** Variables ***
${DUT}              217.160.212.171    #192.168.1.110
${USERNAME}         pi
${PASSWORD}         crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=
${url_tedge}        qaenvironment.eu-latest.cumulocity.com
${user}             systest_preparation
${pass}             crypt:34mpoxueRYy/gDerrLeBThQ2wp9F+2cw50XaNyjiGUpK488+1fgEfE6drOEcR+qZQ6dcjIWETukbqLU= 

*** Test Cases ***
Prerequisites DUT
    Create Timestamp                               #Timestamp is used to achieve unique ID
    Define Device id                               #Setting up device id which is created with prefix ST before the timestamp
    Disconnect from c8y                            #Disconnects from Cumulocity IoT if connected
    Uninstall tedge with purge                     #Uninstalling eventual previous installations
Installing tedge on DUT
    Install Mosquitto
    Install Libmosquitto1
    Install Collectd-core
    Install thin-edge.io
    Install tedge mapper
    Install tedge agent
    # Install tedge apama plugin
    Install tedge apt plugin
    Install tedge logfile request plugin
    Install c8y configuration plugin
    Install Watchdog
Connecting to c8y
    Create self-signed certificate
    Set c8y URL
    Upload certificate
    Connect to c8y


*** Keywords ***
DUT Connection
    Open Connection     ${DUT}
    Login               ${USERNAME}    ${PASSWORD}
Create Timestamp
    ${timestamp}=    get current date    result_format=%d%m%Y%H%M%S
    Set Suite Variable    ${timestamp}
Define Device id
    ${DeviceID}   Set Variable    CH_DEV_CONF_MGMT    #ST${timestamp}
    Set Suite Variable    ${DeviceID}
Disconnect from c8y        #Disconnects from Cumulocity IoT if connected
    Execute Command    sudo tedge disconnect c8y
Uninstall tedge with purge
    Execute Command    wget https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/uninstall-thin-edge_io.sh
    Execute Command    chmod a+x uninstall-thin-edge_io.sh
    Execute Command    ./uninstall-thin-edge_io.sh purge
Install Mosquitto
    ${rc}=    Execute Command    sudo apt-get --assume-yes install mosquitto    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install Libmosquitto1
    ${rc}=    Execute Command    sudo apt-get --assume-yes install libmosquitto1    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install Collectd-core
    ${rc}=    Execute Command    sudo apt-get --assume-yes install collectd-core    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install thin-edge.io
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install tedge mapper
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge-mapper_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install tedge agent
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge-agent_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install tedge apama plugin
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge-apama-plugin_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install tedge apt plugin
   ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge-apt-plugin_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install tedge logfile request plugin
   ${rc}=    Execute Command    sudo dpkg -i ./debian*/c8y-log-plugin_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install c8y configuration plugin
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/c8y-configuration-plugin_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Install Watchdog
    ${rc}=    Execute Command    sudo dpkg -i ./debian*/tedge-watchdog_0*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Create self-signed certificate
    Execute Command    tedge cert remove
    ${rc}=    Execute Command    sudo tedge cert create --device-id ${DeviceID}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    ${output}=    Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
Set c8y URL
    ${rc}=    Execute Command    sudo tedge config set c8y.url ${url_tedge}    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}
Upload certificate    
    Write   sudo tedge cert upload c8y --user ${user}
    Write    ${pass}
    Sleep    60s
Connect to c8y
    ${output}=    Execute Command    sudo tedge connect c8y    #You can then check the content of that certificate.
    Sleep    3s
    Should Contain    ${output}    tedge-agent service successfully started and enabled!
    Execute Command    rm *.deb | rm *.zip | rm *.sh*
