*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC09_ActionAlertMessage.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC09_SelectRequest/09_ActionAlertMessage_SelectRequest.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    2
${cols}    8



*** Test Cases ***
TC09: 09_SelectRequest
    [Documentation]    Test_09_ActionAlertMessage_SelectRequest
    [Tags]    ActionAlertMessage_SelectRequest
    Open Excel Document    ${datatable}    TC09-EC 
    
    FOR     ${i}    IN RANGE    2    ${rows}+1
        ${ALLOW}=    Read Excel Cell    ${i}    7
        ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
        Log To Console    Row ${i} - Allow: ${ALLOW}

        Run Keyword If    '${ALLOW}' == 'Y'
        ...    Run Keywords
        ...    Setup Speed
        ...    AND    Update Status Data In DB
        ...    AND    Clear Select Data In DB 
        ...    AND    Go To Academic_Services    ${i}
        ...    AND    Login As Student
        ...    AND    Click Select Button And Capture Alert    ${i}
        ...    AND    Compare And Write Result To Excel   ${i}

        Run Keyword If    '${ALLOW}' != 'Y'
        ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}
    END
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document