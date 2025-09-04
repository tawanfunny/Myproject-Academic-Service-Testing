*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC12_UploadCompleteReport.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC12_UploadCompleteReport/12_UploadToEdit.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome 
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    20   
${cols}    12
${upload_path}    ${CURDIR}/PDF/

*** Test Cases ***
TC12: 12_UploadToEdit
    Go To Academic_Services    ${datatable}
    
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${UNStudent}=    Read Excel Cell    ${i}    2
        ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
        ${UseMock}=    Read Excel Cell    ${i}    11
        ${UseMock}=    Evaluate    '' if $UseMock in ['None', '', None] else $UseMock.strip().upper()
    
        # 1) เคลียร์ report data ก่อนทุกครั้ง
        Clear Report Data In DB    ${UNStudent}

        # 3) รันเทสอัปโหลดจริง → ผล update เฉพาะ report
        Run UploadCompleteReport    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document

*** Keywords ***
*** Settings ***
Library    SeleniumLibrary
Resource    TC12_UploadCompleteReport.robot

*** Keywords ***
Clear Report Data In DB
    [Arguments]    ${student_id}
    ${query}=    Set Variable    UPDATE report SET reportStatus = NULL WHERE studentId = '${student_id}';
    Execute Sql String    ${query}


Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    upfiepdf
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.1

Run UploadCompleteReport
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    10
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Go To Login Page
    ...    AND    Login As Student    ${row}
    ...    AND    Go To Upload Complete Report Page
    ...    AND    Upload Complete Report    ${row}
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate And Write Result    ${row}
 
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')] 

Login As Student
    [Arguments]    ${i}
    ${UNStudent}    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
    Input Text    css:#stuname    ${UNStudent}

    ${PWDStudent}    Read Excel Cell    ${i}    3
    ${PWDStudent}=    Evaluate    '' if $PWDStudent in ['None', '', None] else $PWDStudent
    Input Text    css:#stupwd   ${PWDStudent}

    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT

Go To Upload Complete Report Page
    Wait Until Element Is Visible    //body/div[1]/div[1]/div[4]/a[1]

    Click Element    //body/div[1]/div[1]/div[4]/a[1]
    Click Element    //a[contains(text(),'อัปโหลดไฟล์')]

Upload Complete Report
    [Arguments]    ${i}
    ${FilePDF}    Read Excel Cell    ${i}    4
    ${FilePDF}=    Evaluate    '' if $FilePDF in ['None', '', None] else $FilePDF
    ${FilePDF}    Set Variable    ${upload_path}${FilePDF}
        
    ${is_exist}=    Run Keyword And Return Status    File Should Exist    ${FilePDF}
    Run Keyword Unless    ${is_exist}    Write Excel Cell    ${i}    7    FAIL - File not found
    Run Keyword If    ${is_exist}    Choose File    css:#reportFile    ${FilePDF}
    Log To Console    Uploading file: ${FilePDF}
        
    Click Element    //button[contains(text(),'อัปโหลด')]
    Sleep    2


Handle Submission Result
        [Arguments]    ${i}
        ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
        Log To Console    Alert Status: ${alert_result[0]}
        Log To Console    Alert Text: ${alert_result[1]}

        Set Test Variable    ${alert_result}
        
        IF    '${alert_result[0]}' == 'PASS'
            ${ActualMessage}=    Set Variable    ${alert_result[1]}  
            Click Element   //a[contains(text(),'ออกจากระบบ')]
        ELSE
            ${ActualMessage}=    Set Variable    AlertNotFound
            Go To    ${URL}   
        END

        Set Test Variable    ${ActualMessage}
        Sleep    5

Check File Uploaded In Database
    [Arguments]    ${i}    ${check_mock}=False
    ${UNStudent}=    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent

    ${table_name}=    Run Keyword If    '${check_mock}'=='True'    Set Variable    report_mock
    ...    ELSE    Set Variable    report

    ${query}=    Set Variable    SELECT reportStatus FROM ${table_name} WHERE studentId = '${UNStudent}' AND reportStatus LIKE '%จัดส่งเอกสารแล้ว%'
    Log To Console    Executing query: ${query}
    ${result}=    Query    ${query}
    Log To Console    DB query result: ${result}

    ${dbcheck}=    Run Keyword And Return Status    Should Not Be Empty    ${result}
    Write Excel Cell    ${i}    8    ${dbcheck}
    Log To Console    DB Check for Student ${UNStudent}: ${dbcheck}

Validate And Write Result
        [Arguments]    ${i}
        ${ExpectedResult}    Read Excel Cell    ${i}    5 
        ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
        ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

        Log To Console    Expected Result: ${ExpectedResult}
        Log To Console    Actual Message: ${ActualMessage}

        Write Excel Cell    ${i}    7    ${ActualMessage}
        ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
        IF   ${compare_result}
            Write Excel Cell    ${i}    9    PASS
        ELSE
            Write Excel Cell    ${i}    9    FAIL
        END
    