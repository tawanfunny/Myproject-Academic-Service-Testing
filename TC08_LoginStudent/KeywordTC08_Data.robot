*** Settings ***
Library    SeleniumLibrary
Library    Screenshot
Resource    TC08_Data_LoginStudent.robot

*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC08-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window


Run Data_LoginStudent
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    9
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Go To StudentLogin Page
    ...    AND    Fill Student Login Form    ${row}
    ...    AND    Handle Submission Result   ${row}
    ...    AND    Validate Database For Login    ${row}    ${UNStudent}    ${PWDStudent}
    ...    AND    Compare Result And Write Status    ${row}
 
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Go To StudentLogin Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')]

Fill Student Login Form
    [Arguments]    ${i}

    ${UNStudent}    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
    Input Text    css:#stuname    ${UNStudent}
    Set Test Variable    ${UNStudent}

    ${PWDStudent}    Read Excel Cell    ${i}    3
    ${PWDStudent}=    Evaluate    '' if $PWDStudent in ['None', '', None] else $PWDStudent
    Input Text    css:#stupwd   ${PWDStudent}
    Set Test Variable    ${PWDStudent}

    Click Button    //body/form[1]/input[3]

    ${ExpectedResult}=    Read Excel Cell    ${i}    4

Handle Submission Result
    [Arguments]    ${i}
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}

    IF    '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
        Run Keyword And Ignore Error    Click Element    //a[contains(text(),'ออกจากระบบ')]
    ELSE
        ${ActualMessage}=    Set Variable    Alert not found
        Sleep    2
        Capture Page Screenshot    TC08_LoginStudent/Screenshots_Data_AlertNotFound/${i}_AlertNotFound.png
        Run Keyword And Ignore Error    Click Element    css:a.back-home-link:nth-child(8)
    END

    Run Keyword And Ignore Error    Go To    ${URL}
    Set Test Variable    ${ActualMessage}
    Sleep    2


Validate Database For Login
    [Arguments]    ${i}    ${UNStudent}    ${PWDStudent}
    ${username_result}=    Query    SELECT studentId FROM student WHERE studentId='${UNStudent}'
    ${has_username}=    Run Keyword And Return Status    Should Not Be Empty    ${username_result}
    Run Keyword If    ${has_username}    Should Be Equal As Strings    ${username_result[0][0]}    ${UNStudent}

    ${password_result}=    Query    SELECT studentPassword FROM student WHERE studentPassword='${PWDStudent}'
    ${has_password}=    Run Keyword And Return Status    Should Not Be Empty    ${password_result}
    Run Keyword If    ${has_password}    Should Be Equal As Strings    ${password_result[0][0]}    ${PWDStudent}

    ${found_condition}=    Evaluate    ${has_username} and ${has_password}
    Run Keyword If    '${has_username}' == 'True'
    ...    Log To Console    Username: ${UNStudent} => พบในฐานข้อมูล
    Run Keyword If    '${has_username}' == 'False'
    ...    Log To Console    Username: ${UNStudent} => ไม่พบในฐานข้อมูล
    Run Keyword If    '${has_password}' == 'True'
    ...    Log To Console    Password: ${PWDStudent} => พบในฐานข้อมูล
    Run Keyword If    '${has_password}' == 'False'
    ...    Log To Console    Password: ${PWDStudent} => ไม่พบในฐานข้อมูล

    Run Keyword If    ${found_condition}
    ...    Write Excel Cell    ${i}    7    FOUND
    Run Keyword If    not ${found_condition}
    ...    Write Excel Cell    ${i}    7    NOT FOUND

Compare Result And Write Status
    [Arguments]    ${i}    
    ${ExpectedResult}=    Read Excel Cell    ${i}    4
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${i}    6    ${ActualMessage}

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    8    PASS
        Capture Page Screenshot    TC08_LoginStudent/Screenshots_Data_Pass/${i}_${ActualMessage}.png
    ELSE
        Write Excel Cell    ${i}    8    FAIL
        Capture Page Screenshot    TC08_LoginStudent/Screenshots_Data_Fail/${i}_${ActualMessage}.png
    END

   Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    11    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    11    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}
