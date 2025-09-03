*** Settings ***
Library    SeleniumLibrary
Resource    TC09_SelectRequest.robot


*** Keywords ***
Clear Select Data In DB
    [Arguments]    ${i}
    ${student_id}=    Read Excel Cell    ${i}    2
    ${student_id}=    Evaluate    '' if $student_id in ['None', '', None] else $student_id
    ${query}=    Set Variable    UPDATE student SET requestId = NULL WHERE studentId = '${student_id}';
    Execute Sql String    ${query}

Go To Academic_Services
    [Arguments]    ${row}
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.1

Login As Student
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')]
    Input Text    css:#stuname    6504106322        
    Input Text    css:#stupwd    6504106322
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT

Click Select Request Button   
    [Arguments]    ${i}
    Click Element    //tbody/tr[${i}+5]/td[6]/form[1]/button[1]
    Sleep    1s

Check Selected Project Is Correct
    [Arguments]    ${row}
    ${ExpectedResult}=    Read Excel Cell    ${row}    2
    ${ActualMessage}=    Get Text    (//span[contains(text(),'ถูกเลือกแล้ว')])
    Write Excel Cell    ${row}    5    ${ActualMessage}
    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}
    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}

Check Project Selection In Database
    [Arguments]    ${i}    
    ${student_id}=    Set Variable    6504106322
    ${ExpectedRequestID}=    Read Excel Cell    ${i}    6

    ${query}=    Set Variable    SELECT requestId FROM student WHERE studentId = '${student_id}'
    ${result}=    Query    ${query}
    log To Console    Query Result: ${result}
    
    IF    '${result}' == '[]'
    ${dbcheck}=    Set Variable    FALSE

    ELSE
        ${ActualRequestID}=    Set Variable    ${result[0][0]}
        ${dbcheck}=    Run Keyword And Return Status    Should Be Equal As Integers    ${ActualRequestID}    ${ExpectedRequestID}
        Execute Javascript    window.scrollTo(0, 300);
        Capture Page Screenshot    Project_Test_AcademicService/TC09_SelectRequest/Screenshots_DBCheck/${i}_DBCheck.png
    END
    Write Excel Cell    ${i}    7    ${dbcheck}
    Close All Browsers



Compare Result And Write Status
    [Arguments]    ${i}    
    ${ExpectedResult}=    Read Excel Cell    ${i}    3
    ${ActualMessage}=    Read Excel Cell    ${i}    5   

    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip() 

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    8    PASS
    ELSE
        Write Excel Cell    ${i}    8    FAIL
    END





