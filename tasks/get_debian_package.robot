*** Settings ***
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    Process
Library    CryptoLibrary    variable_decryption=True
# Suite Setup            DUT Connection
# Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${DUT}              192.168.1.120
${USERNAME}         pi
${PASSWORD}         crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=
${git_token}        crypt:yT+Kkob1/tnpuvwG6EOXIKza8E+pHbM7UllYMpSExRXQ0V/bV/xKBvlRRxpT12OZ2lAALRxDxGegEPUxFggdm0v224H4EFz19W/vTaV/QyhiksZiVP0H6Q==
${RUN_ID}           3498740838
${DIRECTORY}        /home/pi/
${ARCH}
${FILENAME}
${command}        gh run download -R thin-edge/thin-edge.io 3498740838 --pattern "debian-packages-armv7-unknown-linux-gnueabihf"

*** Test Cases ***
# Define Device ID and debian package
#     DUT Connection                                 #Connecting to the device under test
#     Create Timestamp                               #Timestamp is used to achieve unique ID
#     Define Device id                               #Setting up device id which is created with prefix ST before the timestamp
#     Check Architecture                             #Checking architecture to define the debian package name
#     Set File Name                                  #Definning debian package name 
#     Close Connection                               #Closing the connection to device under test
Download debian package
    # Authorize gh                                   #gh cli is used and for that gh authorisation with token is needed
    Download debian package                        #Downloading the debian package from Github repo
# Copy debian package to DUT
#     DUT Connection                                 #Connecting to the device under test
#     Copy debian package to DUT                     #Copy the debian package to device under test
#     Close Connection                               #Closing the connection to device under test
# Delete directory on master
#     Run    sudo rm -rf ${DIRECTORY}${FILENAME}     #Delete with the download created directory

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
Check Architecture
    ${output}=    Execute Command   uname -m
    ${ARCH}    Set Variable    ${output}
    Set Suite Variable    ${ARCH}
Set File Name    #Setting the file name for download
    Run Keyword If    '${ARCH}'=='aarch64'    aarch64
    ...  ELSE    armv7   
aarch64
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-aarch64-unknown-linux-gnu
    Log    ${FILENAME}
    Set Suite Variable    ${FILENAME}
armv7
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-armv7-unknown-linux-gnueabihf
    Log    ${FILENAME}
    Set Suite Variable    ${FILENAME}
Authorize gh
    Run    export GITHUB_TOKEN=${git_token}

Download debian package
    ${rc}=    Run And Return Rc    gh run download -D /Users/home/pi -R thin-edge/thin-edge.io 3498740838 --pattern "debian-packages-armv7-unknown-linux-gnueabihf"    
    Wait Until Created    /Users/home/pi/debian-packages-armv7-unknown-linux-gnueabihf
    Log To Console    ${rc}
Copy debian package to DUT
    Put Directory    ${FILENAME}
    