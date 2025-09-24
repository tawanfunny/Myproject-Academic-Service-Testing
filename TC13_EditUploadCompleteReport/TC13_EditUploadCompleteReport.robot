*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC13_EditUploadCompleteReport.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC13_EditUploadCompleteReport/13_Data_EditUploadCompletereport.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    18
${cols}    13
${upload_path}    ${CURDIR}/EditPDF/

*** Test Cases ***
TC13: 13_Data_EditUploadCompleteReport
    [Documentation]    Test_13_Data_EditUploadCompleteReport
    [Tags]    EditUploadCompleteReport
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${ALLOW}=    Read Excel Cell    ${i}    10
        ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
        Log To Console    Row ${i} - Allow: ${ALLOW}

        Run Keyword If    '${ALLOW}' == 'Y'
        ...    Run Keywords
        ...    Clear Report Data In DB    ${i}
        ...    AND    Run EditUploadCompleteReport   ${i}

        Run Keyword If    '${ALLOW}' != 'Y'
        ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}    
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document