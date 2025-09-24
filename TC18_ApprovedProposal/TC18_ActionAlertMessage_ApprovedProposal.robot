*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC18_ActionAlertMessage.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database
Task Setup    Set Selenium Speed    2.5




*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC18_ApprovedProposal/18_ActionAlertMessage_ApprovedProposal.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    3
${cols}    8



*** Test Cases ***
TC18: 18_ActionAlertMessage_ApprovedProposal
    [Documentation]    Test_18_ActionAlertMessage_ApprovedProposal
    [Tags]    ActionAlertMessage_ApprovedProposal
    Go To Academic_Services    ${datatable}
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${ALLOW}=    Read Excel Cell    ${i}    8
        ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
        Log To Console    Row ${i} - Allow: ${ALLOW}

        Run Keyword If    '${ALLOW}' == 'Y'
        ...    Run Keywords
        ...    Update Status Data In DB
        ...    AND    Run ActionAlertMessage    ${i}

        Run Keyword If    '${ALLOW}' != 'Y'
        ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}   
    END
    
    
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document