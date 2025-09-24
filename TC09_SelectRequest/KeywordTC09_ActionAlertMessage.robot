*** Settings ***
Library    SeleniumLibrary
Resource    TC09_ActionAlertMessage_SelectRequest.robot

*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2

Update Status Data In DB
    ${query}=    Set Variable    UPDATE db_academic_services.requestservice SET requestStatus = 'อนุมัติ';
    Execute Sql String    ${query}

Clear Select Data In DB
    ${query}=    Set Variable    UPDATE db_academic_services.student SET requestId = NULL;
    Execute Sql String    ${query}

# Clear Select Data In DB
#     [Arguments]    ${i}
#     ${student_id}=    Read Excel Cell    ${i}    2
#     ${student_id}=    Evaluate    '' if $student_id in ['None', '', None] else $student_id
#     ${query}=    Set Variable    UPDATE student SET requestId = NULL WHERE studentId = '${student_id}';
#     Execute Sql String    ${query}

Go To Academic_Services
    [Arguments]    ${row}
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window


Login As Student
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')]
    Input Text    css:#stuname    6501233840        
    Input Text    css:#stupwd    6503106364
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT

Read Expected Result From Excel
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    3  
    Set Suite Variable    ${ExpectedResult}
    Log To Console    Expected Result: ${ExpectedResult}

Click Select Button And Capture Alert
    [Arguments]    ${i}  
    Click Element    //tbody/tr[1]/td[6]/form[1]/button[1]
    Sleep    1s
    ${status}    ${message}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Run Keyword If    '${status}' == 'PASS'    Set Suite Variable    ${ActualMessage}    ${message}
    Run Keyword If    '${status}' != 'PASS'    Set Suite Variable    ${ActualMessage}    Alert Not Found
    Execute Javascript    window.scrollTo(0, 300);
    Capture Page Screenshot    TC09_SelectRequest/Screenshots_ActionAlert/${i}_ActionAlert.png
    
    Write Excel Cell    ${i}    5    ${ActualMessage}

Compare And Write Result To Excel
    [Arguments]    ${i}
    ${is_pass}=    Run Keyword And Return Status    Should Be Equal    ${ActualMessage}    ${ExpectedResult}
    Run Keyword If    ${is_pass}    Write Excel Cell    ${i}    6    Pass
    Run Keyword If    not ${is_pass}    Write Excel Cell    ${i}    6    Fail
    
    
