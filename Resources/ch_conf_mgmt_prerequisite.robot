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

*** Variables ***

${PARENT_IP}             192.168.1.110
${CHILD_IP}              192.168.1.200
${HTTP_PORT}             8000
${USERNAME}              pi
${PASSWORD}              crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=
${url_tedge}             qaenvironment.eu-latest.cumulocity.com
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
Create child device name
    Create Timestamp                                    #Timestamp is used for unique names
    Define Child Device name                            #Adding CD in front of the timestamp
Clean devices from the cloud
    Remove all managedObjects from cloud                #Removing all existing devices from the tenant 
Prerequisite Parent
    Parent Connection                                   #Creates ssh connection to the parent device  
    ${rc}=    Execute Command    sudo tedge disconnect c8y    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}  
    
    Delete child related content                        #Delete any previous created child related configuration files/folders on the parent device
    Check for child related content                     #Checks if folders that will trigger child device creation are existing
    Set external MQTT bind address                      #Setting external MQTT bind address which child will use for communication 
    Set external MQTT port                              #Setting external MQTT port which child will use for communication Default:1883
    
    ${rc}=    Execute Command    sudo tedge connect c8y    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0} 
    Restart Configuration plugin                        #Stop and Start c8y-configuration-plugin
    Close Connection                                    #Closes the connection to the parent device
Prerequisite Child
    Child device delete configuration files             #Delete any previous created child related configuration files/folders on the child device
Prerequisite Cloud
    GET Parent ID                                       #Get the Parent ID from the cloud
    GET Parent name                                     #Get the Parent name from the cloud

*** Keywords ***
Create Timestamp
    ${timestamp}=    get current date    result_format=%H%M%S
    Set Suite Variable    ${timestamp}
Define Child Device name
    ${CHILD}=   Set Variable    CD${timestamp}
    Set Suite Variable    ${CHILD}
Parent Connection
    Open Connection     ${PARENT_IP}
    Login               ${USERNAME}    ${PASSWORD}
Child Connection
    Open Connection     ${CHILD_IP}
    Login               ${USERNAME}    ${PASSWORD}
Set external MQTT bind address
    ${rc}=    Execute Command    sudo tedge config set mqtt.external.bind_address ${PARENT_IP}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Set external MQTT port
    ${rc}=    Execute Command    sudo tedge config set mqtt.external.port 1883    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Check for child related content
    @{dir_cont}    List Directories In Directory    /etc/tedge/operations/c8y
    Should Be Empty   ${dir_cont}
    @{dir_cont}    List Directories In Directory    /etc/tedge/c8y
    Should Be Empty   ${dir_cont}
    @{dir_cont}    List Directories In Directory    /var/tedge
    Should Be Empty   ${dir_cont}
Remove all managedObjects from cloud
    Get all existing managedObjects
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    GET On Session    API_Testing    url=/inventory/managedObjects?fragmentType=c8y_IsDevice
    ${json_response}=    Set Variable    ${Get_Response.json()}  
    @{id}=    Get Value From Json    ${json_response}    $..id   
    ${man_Obj_id}    Get From List    ${id}    1
    FOR    ${element}    IN    @{id}
           ${delete}=    Run Keyword And Ignore Error   Delete existing managedObject
           Set Suite Variable    ${element}   
    END
Get all existing managedObjects
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    GET On Session    API_Testing    url=/inventory/managedObjects?fragmentType=c8y_IsDevice
    ${json_response}=    Set Variable    ${Get_Response.json()}  
    @{id}=    Get Value From Json    ${json_response}    $..id   
    ${man_Obj_id}    Get From List    ${id}    1
    Set Suite Variable    ${man_Obj_id}
Delete existing managedObject
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    DELETE On Session    API_Testing     /inventory/managedObjects/${element}
Delete child related content
    Execute Command    sudo rm -rf /etc/tedge/operations/c8y/CD*         #if folder exists, child device will be created
    Execute Command    sudo rm c8y-configuration-plugin.toml
    Execute Command    sudo rm -rf /etc/tedge/c8y/CD*                    #if folder exists, child device will be created
    Execute Command    sudo rm -rf /var/tedge/*
Child device delete configuration files
    Child Connection
    Execute Command    sudo rm config1
    Execute Command    sudo rm c8y-configuration-plugin
    Close Connection
Restart Configuration plugin
    ${rc}=    Execute Command    sudo systemctl stop c8y-configuration-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0} 
    ${rc}=    Execute Command    sudo systemctl start c8y-configuration-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0} 
GET Parent ID
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    GET On Session    API_Testing    identity/externalIds/c8y_Serial/${PARENT_NAME}   #c8y identity list --device ${DeviceID}
    ${json_response}=    Set Variable    ${Get_Response.json()}  
    @{id}=    Get Value From Json    ${json_response}    $..id   
    ${parent_id}    Get From List    ${id}    0
    Set Suite Variable    ${parent_id}
GET Parent name
    ${auth}=    Create List    ${user}    ${pass}
    Create Session    API_Testing    https://${url_tedge}    auth=${auth}
    ${Get_Response}=    GET On Session    API_Testing    /identity/globalIds/${parent_id}/externalIds
    ${json_response}=    Set Variable    ${Get_Response.json()}
    @{pd_name}=    Get Value From Json    ${json_response}    $..externalId
    ${pardev_name}    Get From List    ${pd_name}    0
    Set Suite Variable    ${pardev_name}
