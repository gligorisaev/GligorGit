#Command to execute:    robot -d \results --timestampoutputs --log health_tedge_mapper.html --report NONE health_tedge_mapper.robot

*** Settings ***
Library    Browser
Library    SSHLibrary
Library    DateTime
Library    CryptoLibrary    variable_decryption=True
Library    Dialogs
Library    String
Library    CSVLibrary
Library    OperatingSystem
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections

*** Variables ***
${DUT}            192.168.1.110
${USERNAME}       pi
${PASSWORD}       crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=          
${Version}        0.*
${download_dir}    /home/pi/
${url_dow}    https://github.com/thin-edge/thin-edge.io/actions
${url_tedge}    qaenvironment.eu-latest.cumulocity.com
${user}    qatests
${pass}    crypt:34mpoxueRYy/gDerrLeBThQ2wp9F+2cw50XaNyjiGUpK488+1fgEfE6drOEcR+qZQ6dcjIWETukbqLU=    


*** Tasks ***
Go to root
    Run    cd
Install thin-edge.io on your device
    Create Timestamp
    Define Device id
    Uninstall tedge with purge
    Clear previous downloaded files if any
    Install_thin-edge
Set the URL of your Cumulocity IoT tenant
    ${rc}=    Execute Command    sudo tedge config set c8y.url ${url_tedge}    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}

Create the certificate
    ${rc}=    Execute Command    sudo tedge cert create --device-id ${DeviceID}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    #You can then check the content of that certificate.
    ${output}=    Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Should Contain    ${output}    Subject: CN=${DeviceID}, O=Thin Edge, OU=Test Device
    Should Contain    ${output}    Issuer: CN=${DeviceID}, O=Thin Edge, OU=Test Device
    Should Contain    ${output}    Valid from:
    Should Contain    ${output}    Valid up to:
    Should Contain    ${output}    Thumbprint:

tedge cert upload c8y command
    Write   sudo tedge cert upload c8y --user ${user}
    Write    ${pass}
    Sleep    3s

Connect the device
    ${output}=    Execute Command    sudo tedge connect c8y    #You can then check the content of that certificate.
    Sleep    3s
    Should Contain    ${output}    Checking if systemd is available.
    Should Contain    ${output}    Checking if configuration for requested bridge already exists.
    Should Contain    ${output}    Validating the bridge certificates.
    Should Contain    ${output}    Creating the device in Cumulocity cloud.
    Should Contain    ${output}    Saving configuration for requested bridge.
    Should Contain    ${output}    Restarting mosquitto service.
    Should Contain    ${output}    Awaiting mosquitto to start. This may take up to 5 seconds.
    Should Contain    ${output}    Enabling mosquitto service on reboots.
    Should Contain    ${output}    Successfully created bridge connection!
    Should Contain    ${output}    Sending packets to check connection. This may take up to 2 seconds.
    Should Contain    ${output}    Connection check is successful.
    Should Contain    ${output}    Checking if tedge-mapper is installed.
    Should Contain    ${output}    Starting tedge-mapper-c8y service.
    Should Contain    ${output}    Persisting tedge-mapper-c8y on reboot.
    Should Contain    ${output}    tedge-mapper-c8y service successfully started and enabled!
    Should Contain    ${output}    Enabling software management.
    Should Contain    ${output}    Checking if tedge-agent is installed.
    Should Contain    ${output}    Starting tedge-agent service.
    Should Contain    ${output}    Persisting tedge-agent on reboot.
    Should Contain    ${output}    tedge-agent service successfully started and enabled!

Sending your first telemetry data
    ${rc}=    Execute Command    tedge mqtt pub c8y/s/us 211,20    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}

Check the arrival of telemetry data
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    GET On Session    API_Testing    identity/externalIds/c8y_Serial/${PARENT_NAME}   #c8y identity list --device ${DeviceID}
    ${json_response}=    Set Variable    ${Get_Response.json()}  
    @{id}=    Get Value From Json    ${json_response}    $..id   
    ${parent_id}    Get From List    ${id}    0
    Set Suite Variable    ${parent_id}





*** Keywords ***
Open Connection And Log In
   Open Connection     ${DUT}
   Login               ${USERNAME}        ${PASSWORD}

Create Timestamp    #Creating timestamp to be used for Device ID
        ${timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${timestamp}
        Set Global Variable    ${timestamp}
Define Device id    #Defining the Device ID, structure is (ST'timestamp') (eg. ST01092022091654)
        ${DeviceID}   Set Variable    ST${timestamp}
        Set Suite Variable    ${DeviceID}
Uninstall tedge with purge
    Execute Command    wget https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/uninstall-thin-edge_io.sh
    Execute Command    chmod a+x uninstall-thin-edge_io.sh
    Execute Command    ./uninstall-thin-edge_io.sh purge
Clear previous downloaded files if any
    Execute Command    rm *.deb | rm *.zip | rm *.sh*
Install_thin-edge
    ${rc}=    Execute Command    curl -fsSL https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/get-thin-edge_io.sh | sudo sh -s    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
