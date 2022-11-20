*** Settings ***
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    CryptoLibrary    variable_decryption=True
Suite Setup            DUT Connection
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${DUT}              192.168.1.120
${USERNAME}         pi
${PASSWORD}         crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=


*** Test Cases ***
Prerequisites DUT
    Create Timestamp                               #Timestamp is used to achieve unique ID
    Define Device id                               #Setting up device id which is created with prefix ST before the timestamp
    Execute Command    cd debian*



*** Keywords ***
DUT Connection
    Open Connection     ${DUT}
    Login               ${USERNAME}    ${PASSWORD}
Create Timestamp
    ${timestamp}=    get current date    result_format=%d%m%Y%H%M%S
    Set Suite Variable    ${timestamp}
Define Device id
    ${DeviceID}   Set Variable    ST${timestamp}
    Set Suite Variable    ${DeviceID}
